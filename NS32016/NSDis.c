#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "32016.h"
#include "mem32016.h"
#include "Profile.h"
#include "Trap.h"
#include "defs.h"

#define HEX24 "x'%06" PRIX32
#define HEX32 "x'%" PRIX32

uint32_t OpCount = 0;
uint8_t FunctionLookup[256];
OperandSizeType FredSize;

const char LPRLookUp[16][20] = 
{
   "UPSR",
   "DCR",
   "BPC",
   "DSR",
   "CAR",
   "{0101}",
   "{0110}",
   "{0111}",
   "FP",
   "SP",
   "SB",
   "USP",
   "CFG",
   "PSR",
   "INTBASE",
   "MOD"
};

#ifdef INSTRUCTION_PROFILING
uint32_t IP[MEG16];
#endif

const uint8_t FormatSizes[FormatCount + 1] =
{ 1, 1, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1 };

void PostfixLookup(uint8_t Postfix)
{
   char PostFixLk[] = "BWTD";

   if (Postfix)
   {
      Postfix--;
      PiTRACE("%c", PostFixLk[Postfix & 3]);
   }
}

void AddStringFlags(uint32_t opcode)
{
   if (opcode & (BIT(Backwards) | BIT(UntilMatch) | BIT(WhileMatch)))
   {
      PiTRACE("[");
      if (opcode & BIT(Backwards))
      {
         PiTRACE("B");
      }

      uint32_t Options = (opcode >> 17) & 3;
      if (Options == 1) // While match
      {
         PiTRACE("W");
      }
      else if (Options == 3)
      {
         PiTRACE("U");
      }

      PiTRACE("]");
   }
}


void AddCfgFLags(uint32_t opcode)
{
   PiTRACE("[");
   if (opcode & BIT(15))   PiTRACE("I");
   if (opcode & BIT(16))   PiTRACE("F");
   if (opcode & BIT(17))   PiTRACE("M");
   if (opcode & BIT(18))   PiTRACE("C");
   PiTRACE("]");
}

const char InstuctionText[InstructionCount][8] =
{
   // FORMAT 0
   "BEQ", "BNE", "BCS", "BCC", "BH", "BLS", "BGT", "BLE", "BFS", "BFC", "BLO", "BHS", "BLT", "BGE", "BR", "BN",

   // FORMAT 1	
   "BSR", "RET", "CXP", "RXP", "RETT", "RETI", "SAVE", "RESTORE", "ENTER", "EXIT", "NOP", "WAIT", "DIA", "FLAG", "SVC", "BPT",

   // FORMAT 2
   "ADDQ", "CMPQ", "SPR", "Scond", "ACB", "MOVQ", "LPR", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 3
   "CXPD", "TRAP", "BICPSR", "TRAP", "JUMP", "TRAP", "BISPSR", "TRAP", "TRAP", "TRAP", "ADJSP", "TRAP", "JSR", "TRAP", "CASE", "TRAP",

   // FORMAT 4
   "ADD", "CMP", "BIC", "TRAP", "ADDC", "MOV", "OR", "TRAP", "SUB", "ADDR", "AND", "TRAP", "SUBC", "TBIT", "XOR", "TRAP",

   // FORMAT 5
   "MOVS", "CMPS", "SETCFG", "SKPS", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 6
   "ROT", "ASH", "CBIT", "CBITI", "TRAP", "LSH", "SBIT", "SBITI", "NEG", "NOT", "TRAP", "SUBP", "ABS", "COM", "IBIT", "ADDP",

   // FORMAT 7
   "MOVM", "CMPM", "INSS", "EXTS", "MOVX", "MOVZ", "MOVZ", "MOVX", "MUL", "MEI", "Trap", "DEI", "QUO", "REM", "MOD", "DIV", "TRAP"

   // FORMAT 8
   "EXT", "CVTP", "INS", "CHECK", "INDEX", "FFS", "MOVUS", "MOVSU", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 9
   "MOVif", "LFSR", "MOVLF", "MOVFL", "ROUND", "TRUNC", "SFSR", "FLOOR", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 10
   "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 11
   "ADDf", "MOVf", "CMPf", "TRAP", "SUBf", "NEGf", "TRAP", "TRAP", "DIVf", "TRAP", "TRAP", "TRAP", "MULf", "ABSf", "TRAP", "TRAP",

   // FORMAT 12
   "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 13
   "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // FORMAT 14
   "RDVAL", "WRVAL", "LMR", "SMR", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "CINV", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP", "TRAP",

   // Illegal
   "TRAP" };

int32_t GetDisplacement(uint32_t* pPC)
{
   // Displacements are in Little Endian and need to be sign extended
   int32_t Value;

   MultiReg Disp;
   Disp.u32 = SWAP32(read_x32(*pPC));

   switch (Disp.u32 >> 29)
      // Look at the top 3 bits
   {
      case 0: // 7 Bit Posative
      case 1:
      {
         Value = Disp.u8;
         (*pPC) += sizeof(int8_t);
      }
      break;

      case 2: // 7 Bit Negative
      case 3:
      {
         Value = (Disp.u8 | 0xFFFFFF80);
         (*pPC) += sizeof(int8_t);
      }
      break;

      case 4: // 14 Bit Posative
      {
         Value = (Disp.u16 & 0x3FFF);
         (*pPC) += sizeof(int16_t);
      }
      break;

      case 5: // 14 Bit Negative
      {
         Value = (Disp.u16 | 0xFFFFC000);
         (*pPC) += sizeof(int16_t);
      }
      break;

      case 6: // 30 Bit Posative
      {
         Value = (Disp.u32 & 0x3FFFFFFF);
         (*pPC) += sizeof(int32_t);
      }
      break;

      case 7: // 30 Bit Negative
      default: // Stop it moaning about Value not being set ;)
      {
         Value = Disp.u32;
         (*pPC) += sizeof(int32_t);
      }
      break;
   }

   return Value;
}

void GetOperandText(uint32_t Start, uint32_t* pPC, uint16_t Pattern, uint32_t c)
{
   if (Pattern < 8)
   {
      PiTRACE("R%0" PRId32, Pattern);
   }
   else if (Pattern < 16)
   {
      int32_t d = GetDisplacement(pPC);
      PiTRACE("%0" PRId32 "(R%u)", d, (Pattern & 7));
   }
   else
   {
      switch (Pattern & 0x1F)
      {
         case FrameRelative:
         {
            int32_t d1 = GetDisplacement(pPC);
            int32_t d2 = GetDisplacement(pPC);
            PiTRACE("%" PRId32 "(%" PRId32 "(FP))", d2, d1);
         }
         break;

         case StackRelative:
         {
            int32_t d1 = GetDisplacement(pPC);
            int32_t d2 = GetDisplacement(pPC);
            PiTRACE("%" PRId32 "(%" PRId32 "(SP))", d2, d1);
         }
         break;

         case StaticRelative:
         {
            int32_t d1 = GetDisplacement(pPC);
            int32_t d2 = GetDisplacement(pPC);
            PiTRACE("%" PRId32 "(%" PRId32 "(SB))", d2 , d1);
         }
         break;

         case IllegalOperand:
         {
            PiTRACE("(reserved)");
         }
         break;

         case Immediate:
         {
            int32_t Value;
            MultiReg temp3;

            temp3.u32 = SWAP32(read_x32(*pPC));
            if (FredSize.Op[c] == sz8)
               Value = temp3.u8;
            else if (FredSize.Op[c] == sz16)
               Value = temp3.u16;
            else
               Value = temp3.u32;

            (*pPC) += FredSize.Op[c];
            PiTRACE(HEX32, Value);
         }
         break;

         case Absolute:
         {
            int32_t d = GetDisplacement(pPC);
            PiTRACE("@" HEX32, d);
         }
         break;

         case External:
         {
            int32_t d1 = GetDisplacement(pPC);
            int32_t d2 = GetDisplacement(pPC);
            PiTRACE("EXT(" HEX32 ")+" HEX32, d1, d2);
         }
         break;

         case TopOfStack:
         {
            PiTRACE("TOS");
         }
         break;

         case FpRelative:
         {
            int32_t d = GetDisplacement(pPC);
            PiTRACE("%" PRId32 "(FP)", d);
         }
         break;

         case SpRelative:
         {
            int32_t d = GetDisplacement(pPC);
            PiTRACE("%" PRId32 "(SP)", d);
         }
         break;

         case SbRelative:
         {
            int32_t d = GetDisplacement(pPC);
            PiTRACE("%" PRId32 "(SB)", d);
         }
         break;

         case PcRelative:
         {
            int32_t d = GetDisplacement(pPC);
#if 1
            PiTRACE("* + %" PRId32, d);
            
#else            
            PiTRACE("&06%" PRIX32 "[PC]", Start + d);
#endif
         }
         break;

         case EaPlusRn:
         case EaPlus2Rn:
         case EaPlus4Rn:
         case EaPlus8Rn:
         {
            const char SizeLookup[] = "BWDQ";
            GetOperandText(Start, pPC, Pattern >> 11, c);   // Recurse
            PiTRACE("[R%" PRId16 ":%c]", ((Pattern >> 8) & 3), SizeLookup[Pattern & 3]);
         }
         break;
      }
   }
}

void RegLookUp(uint32_t Start, uint32_t* pPC)
{
   // printf("RegLookUp(%06" PRIX32 ", %06" PRIX32 ")\n", pc, (*pPC));
   uint32_t Index;

   for (Index = 0; Index < 2; Index++)
   {
      if (Regs[Index] < 0xFFFF)
      {
         if (Index == 1)
         {
            PiTRACE(",");
         }

         GetOperandText(Start, pPC, Regs[Index], Index);
      }
   }
}

void BreakPoint(uint32_t pc, uint32_t opcode)
{
#if 1
#ifndef TEST_SUITE
   // Exec address of Bas32
   if (pc == 0x000200)
   {
      printf("Entering Bas32\n");
      ProfileInit();
   }
   // Exec address of Panos
   if (pc == 0x000400)
   {
      printf("Entering Panos\n");
      ProfileInit();
   }
   // Address of SVC &11 (OS_EXIT)
   if (pc == 0xF007BB)
   {
      n32016_dumpregs("Retuning to Pandora");
      ProfileInit();
   }
#endif

   // Useful way to be able to get a breakpoint on a particular instruction
   //if (pc == 0)
#if 0     
   if (pc == 0xF001E9)
   {
      printf("Here!\n");
      //n32016_dumpregs("Oops how did I get here!");
   }

   if ((opcode == 0) && (pc < 20))
   {
      n32016_dumpregs("Oops how did I get here!");
      //Trace = 1;
   }
#endif
#endif
}

void ShowRegs(uint8_t Pattern, uint8_t Reverse)
{
   uint32_t Count;
   uint32_t First = 1;

   PiTRACE("[");

   for (Count = 0; Count < 8; Count++)
   {
      if (Pattern & BIT(Count))
      {
         if (First == 0)
         {
            PiTRACE(",");
         }

         if (Reverse)
         {
            PiTRACE("R%" PRIu32, Count ^ 7);
         }
         else
         {
            PiTRACE("R%" PRIu32, Count);
         }
         First = 0;
      }
   }

   PiTRACE("]");
}

const char PostFixLk[] = "BWTD";
const char EightSpaces[] = "        ";

void AddInstructionText(uint32_t Function, uint32_t opcode, uint32_t OperandSize)
{
   if (Function < InstructionCount)
   {
      char Str[80];

      if (Function == Scond)
      {
         uint32_t Condition = ((opcode >> 7) & 0x0F);
         sprintf(Str, "S%s", &InstuctionText[Condition][1]);             // Offset by 1 to lose the 'B'
      }
      else
      {
         sprintf(Str, "%s", InstuctionText[Function]);
      }

      if ((opcode & 0x80FF) == 0x800E)
      {
         OperandSize = Translating;
      }

      if (OperandSize)
      {
         OperandSize--;
         sprintf(Str + strlen(Str), "%c", PostFixLk[OperandSize & 3]);                 // Offset by 1 to loose the 'B'
      }

      switch (Function)
      {
         case MOVXiW:
         case MOVZiW:
         {
            sprintf(Str + strlen(Str), "W");
         }
         break;

         case MOVZiD:
         case MOVXiD:
         {
            sprintf(Str + strlen(Str), "D");
         }
         break;
      }

      size_t Len = strlen(Str);
      if (Len < (sizeof(EightSpaces) - 1))
      {
         PiTRACE("%s%s", Str, &EightSpaces[Len]);
      }
   }
}

#ifdef SHOW_INSTRUCTIONS
void ShowInstruction(uint32_t StartPc, uint32_t* pPC, uint32_t opcode, uint32_t Function, uint32_t OperandSize)
{
   static uint32_t old_pc = 0xFFFFFFFF;

   if (StartPc < (IO_BASE - 64))                     // The code will not work near the IO Space as it will have side effects
   {
      if (StartPc != old_pc)
      {
         old_pc = StartPc;
         
#if 1
         if (OpCount > 25000)
         {
            exit(1);
         }
         PiTRACE("#%08"PRIu32" ", ++OpCount);
#endif
        
         PiTRACE("&%06" PRIX32 " ", StartPc);
         PiTRACE("[%08" PRIX32 "] ", opcode);
         PiTRACE("F%01" PRIu32 " ", Function >> 4);

         if (Function < InstructionCount)
         {
            AddInstructionText(Function, opcode, OperandSize);

            switch (Function)
            {
               case ADDQ:
               case CMPQ:
               case ACB:
               case MOVQ:
               {
                  int32_t Value = (opcode >> 7) & 0xF;
                  NIBBLE_EXTEND(Value);
                  PiTRACE("%" PRId32 ",", Value);
               }
               break;

               case LPR:
               case SPR:
               {
                  int32_t Value = (opcode >> 7) & 0xF;
                  PiTRACE("%s", LPRLookUp[Value]);
                  if (Function == LPR)
                  {
                     PiTRACE(",");
                  }
               }
               break;
            }

            RegLookUp(StartPc, pPC);

            if ((Function <= BN) || (Function == BSR))
            {
               int32_t d = GetDisplacement(pPC);
               PiTRACE("&%06"PRIX32" ", StartPc + d);
            }

            switch (Function)
            {
               case SAVE:
               {
                  ShowRegs(read_x8((*pPC)++), 0);    //Access directly we do not want tube reads!
               }
               break;

               case RESTORE:
               {
                  ShowRegs(read_x8((*pPC)++), 1);    //Access directly we do not want tube reads!
               }
               break;

               case EXIT:
               {
                  ShowRegs(read_x8((*pPC)++), 1);    //Access directly we do not want tube reads!
               }
               break;
  
               case ENTER:
               {
                  ShowRegs(read_x8((*pPC)++), 0);    //Access directly we do not want tube reads!
                  int32_t d = GetDisplacement(pPC);
                  PiTRACE(" " HEX32 "", d);
               }
               break;

               case RET:               
               case CXP:
               case RXP:
               {
                  int32_t d = GetDisplacement(pPC);
                  PiTRACE(" " HEX32 "", d);
               }
               break;

               case ACB:
               {
                  int32_t d = GetDisplacement(pPC); 
                  PiTRACE("PC x+'%" PRId32 "", d);
               }
               break;

               case MOVM:
               case CMPM:
               {
                  int32_t d = GetDisplacement(pPC);
                  PiTRACE(",%" PRId32, (d / OperandSize) + 1);
               }
               break;

               case EXT:
               case INS:
               {
                  int32_t d = GetDisplacement(pPC);
                  PiTRACE(",%" PRId32, d);
               }
               break;

               case MOVS:
               case CMPS:
               case SKPS:
               {
                 AddStringFlags(opcode);
               }
               break;

               case SETCFG:
               {
                  AddCfgFLags(opcode);
               }
               break;

               case INSS:
               case EXTS:
               {
                  uint8_t Value = read_x8((*pPC)++);
                  PiTRACE(",%" PRIu32 ",%" PRIu32,  Value >> 5, ((Value & 0x1F) + 1));
               }
               break;
            }


            PiTRACE("\n");

#ifdef TEST_SUITE
            if ((*pPC == 0x1CA9) || (*pPC == 0x1CB2))
            {

#ifdef INSTRUCTION_PROFILING
               DisassembleUsingITrace(0, 0x10000);
#endif

               n32016_dumpregs("Test Suite Complete!\n");
               exit(1);
            }
#endif

#ifndef TEST_SUITE
            if (OpCount >= 10000)
            {
               n32016_dumpregs("Lots of trace data here!");
            }
#endif
         }
      }

      return;
   }

   //PiTRACE("PC is :%08"PRIX32" ?????\n", *pPC);
}
#endif

void ShowRegisterWrite(uint32_t Index, uint32_t Value)
{
   if (Regs[Index] < 32)
   {
#ifdef SHOW_REG_WRITES
      if (Regs[Index] < 8)
      {
         PiTRACE(" R%u = %08"PRIX32"\n", Regs[Index], Value);
      }
#endif

#ifdef TEST_SUITE
      if (Regs[Index] == 7)
      {
         PiTRACE("*** TEST = %u\n", Value);

         if (Value == 137)
         {
            PiTRACE("*** BREAKPOINT\n");
         }
      }
#endif
   }
}

#define FUNC(FORMAT, OFFSET) (((FORMAT) << 4) + (OFFSET)) 

uint8_t GetFunction(uint8_t FirstByte)
{
   switch (FirstByte & 0x0F)
   {
      case 0x0A:
         return FUNC(Format0, FirstByte >> 4);
      case 0x02:
         return FUNC(Format1, FirstByte >> 4);

      case 0x0C:
      case 0x0D:
      case 0x0F:
      {
         if ((FirstByte & 0x70) != 0x70)
         {
            return FUNC(Format2, (FirstByte >> 4) & 0x07);
         }

         return FUNC(Format3, 0);
      }
      // No break due to return
   }

   if ((FirstByte & 0x03) != 0x02)
   {
      return FUNC(Format4, (FirstByte >> 2) & 0x0F);
   }

   switch (FirstByte)
   {
      case 0x0E:
         return FUNC(Format5, 0); // String instruction
      case 0x4E:
         return FUNC(Format6, 0);
      case 0xCE:
         return FUNC(Format7, 0);
         CASE4(0x2E)
            : return FUNC(Format8, 0);
      case 0x3E:
         return FUNC(Format9, 0);
      case 0x7E:
         return FUNC(Format10, 0);
      case 0xBE:
         return FUNC(Format11, 0);
      case 0xFE:
         return FUNC(Format12, 0);
      case 0x9E:
         return FUNC(Format13, 0);
      case 0x1E:
         return FUNC(Format14, 0);
   }

   return FormatBad;
}

void n32016_build_matrix()
{
   uint32_t Index;

   memset(FunctionLookup, FormatBad, sizeof(FunctionLookup));

   for (Index = 0; Index < 256; Index++)
   {
      FunctionLookup[Index] = GetFunction(Index);
   }
}

static void getgen(int gen, int c, uint32_t* pPC)
{
   gen &= 0x1F;
   Regs[c] = gen;

   if (gen >= EaPlusRn)
   {
      Regs[c] |= read_x8((*pPC)++) << 8;
      (*pPC)++;

      if ((Regs[c] & 0xF800) == (Immediate << 11))
      {
         SET_TRAP(IllegalImmediate);
      }

      if ((Regs[c] & 0xF800) >= (EaPlusRn << 11))
      {
         SET_TRAP(IllegalDoubleIndexing);
      }
   }
}

#define SET_FRED_SIZE(in) FredSize.Whole = OpSizeLookup[(in) & 0x03]

void Decode(uint32_t* pPC)
{
   uint32_t StartPc = *pPC;
   uint32_t opcode = read_x32(*pPC);
   uint32_t Function = FunctionLookup[opcode & 0xFF];
   uint32_t Format = Function >> 4;

   Regs[0] =
   Regs[1] = 0xFFFF;

   if (Format < (FormatCount + 1))
   {
      *pPC += FormatSizes[Format];                                        // Add the basic number of bytes for a particular instruction
   }

   FredSize.Whole = 0;
   switch (Format)
   {
      case Format0:
      case Format1:
      {
         // Nothing here
      }
      break;

      case Format2:
      {
         SET_FRED_SIZE(opcode);
         getgen(opcode >> 11, 0, pPC);
      }
      break;

      case Format3:
      {
         Function += ((opcode >> 7) & 0x0F);
         SET_FRED_SIZE(opcode);
         getgen(opcode >> 11, 0, pPC);
      }
      break;

      case Format4:
      {
         SET_FRED_SIZE(opcode);
         getgen(opcode >> 11, 0, pPC);
         getgen(opcode >> 6, 1, pPC);
      }
      break;

      case Format5:
      {
         Function += ((opcode >> 10) & 0x0F);
         SET_FRED_SIZE(opcode >> 8);
         if (opcode & BIT(Translation))
         {
            SET_FRED_SIZE(0);         // 8 Bit
         }
      }
      break;

      case Format6:
      {
         Function += ((opcode >> 10) & 0x0F);
         SET_FRED_SIZE(opcode >> 8);

         // Ordering important here, as getgen uses Operand Size
         switch (Function)
         {
            case ROT:
            case ASH:
            case LSH:
            {
               FredSize.Op[0] = sz8;
            }
            break;
         }

         getgen(opcode >> 19, 0, pPC);
         getgen(opcode >> 14, 1, pPC);
      }
      break;

      case Format7:
      {
         Function += ((opcode >> 10) & 0x0F);
         SET_FRED_SIZE(opcode >> 8);
         getgen(opcode >> 19, 0, pPC);
         getgen(opcode >> 14, 1, pPC);
      }
      break;

      case Format8:
      {
         if (opcode & 0x400)
         {
            if (opcode & 0x80)
            {
               switch (opcode & 0x3CC0)
               {
                  case 0x0C80:
                  {
                     Function = MOVUS;
                  }
                  break;

                  case 0x1C80:
                  {
                     Function = MOVSU;
                  }
                  break;

                  default:
                  {
                     Function = TRAP;
                  }
                  break;
               }
            }
            else
            {
               Function = (opcode & 0x40) ? FFS : INDEX;
            }
         }
         else
         {
            Function += ((opcode >> 6) & 3);
         }

         SET_FRED_SIZE(opcode >> 8);

         if (Function == CVTP)
         {
            SET_FRED_SIZE(3);               // 32 Bit
         }

         getgen(opcode >> 19, 0, pPC);
         getgen(opcode >> 14, 1, pPC);
      }
      break;

      case Format9:
      {
         Function += ((opcode >> 11) & 0x07);
      }
      break;

      case Format11:
      {
         Function += ((opcode >> 10) & 0x0F);
      }
      break;

      case Format14:
      {
         Function += ((opcode >> 10) & 0x0F);
      }
      break;

      default:
      {
         SET_TRAP(UnknownFormat);
      }
      break;
   }

   ShowInstruction(StartPc, pPC, opcode, Function, FredSize.Op[0]);
}

#ifdef INSTRUCTION_PROFILING
#define BYTE_COUNT 10

void DisassembleUsingITrace(uint32_t Location, uint32_t End)
{
   uint32_t Index;
   uint32_t Address = Location;

   PiTRACE("DisassembleUsingITrace(%06" PRIX32 ", %06" PRIX32 ")\n", Location, End);
   for (Index = Location; Index < End; Index++)
   {
      if (IP[Index])
      {
         if (Address < Index)
         {
            uint32_t Temp;
            uint32_t Break = 0;

            for (Temp = Address; Temp < Index; Temp++, Break++)
            {
               if ((Break % BYTE_COUNT) == 0)
               {
                  PiTRACE("\n.byte %u", read_x8(Temp));
                  continue;
               }

               PiTRACE(",%u", read_x8(Temp));
            }

            PiTRACE("\n");
         }

         PiTRACE("#%06" PRId32 ": ", IP[Index]);
         Address = Index;
         Decode(&Address);
         ShowTraps();
         CLEAR_TRAP();
      }
   }
}
#endif

void Disassemble(uint32_t Location, uint32_t End)
{
   do
   {
      Decode(&Location);
      ShowTraps();
      CLEAR_TRAP();
   }
   while (Location < End);

#ifdef WIN32
   system("pause");
#endif
}