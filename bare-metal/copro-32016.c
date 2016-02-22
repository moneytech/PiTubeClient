/*
 * Arm2 Co Pro Emulation
 *
 * (c) 2015 David Banks
 * 
 * based on code by from MAME
 */

#define JTAG_DEBUG

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "startup.h"
#include "tube-lib.h"
#include "tube-isr.h"
#include "rpi-gpio.h"
#include "rpi-aux.h"
#include "rpi-interrupts.h"
#include "../NS32016/32016.h"
#include "../NS32016/PandoraV2_00.h"

uint8_t Exit;

void copro_32016_init_hardware()
{
#ifdef JTAG_DEBUG
  enable_JTAG();
#endif

  enable_SoftTube();
}

static void copro_32016_reset()
{
  uint32_t Address;

  for (Address = 0; Address < MEG16; Address += sizeof(PandoraV2_00))
  {
    memcpy(&ns32016ram[Address], PandoraV2_00, sizeof(PandoraV2_00));   // The ROM is everywhere at RESET!
  }

  n32016_reset();                                                       // Reset the device
}

void copro_32016_main(unsigned int r0, unsigned int r1, unsigned int atags)
{
  register unsigned int gpio;
  register unsigned int last_gpio = IRQ_PIN_MASK | NMI_PIN_MASK | RST_PIN_MASK;

  RPI_EnableUart("Pi 32016 CoPro\r\n");                                 // Display Debug Boot Message

  copro_32016_init_hardware();

  enable_MMU_and_IDCaches();
  _enable_unaligned_access();

  copro_32016_reset();

  Exit = 0;
  in_isr = 1;                                                           // This ensures interrupts are not re-enabled in tube-lib.c

  while (1)
  {
    n32016_exec(1);

    gpio = RPI_GpioBase->GPLEV0;

    if (gpio == last_gpio)
    {
      continue;
    }

    if ((gpio & RST_PIN_MASK) == 0)
    {
      printf("RST!!\r\n");
      copro_32016_reset();

      do
      {
        if (Exit)
        {
          return;                                                       // Set Exit true while in Reset to switch to another co-pro
        }

        gpio = RPI_GpioBase->GPLEV0;
      }
      while ((gpio & RST_PIN_MASK) == 0);                               // Wait for Reset to go high
    }

    tube_irq = 0;
    if ((gpio & IRQ_PIN_MASK) == 0)
    {
      tube_irq |= 1;                                                    // IRQ is Active
    }

    if ((gpio & NMI_PIN_MASK) == 0)
    {
      tube_irq |= 2;                                                    // NMI is Active
    }

    last_gpio = gpio;
  }
}