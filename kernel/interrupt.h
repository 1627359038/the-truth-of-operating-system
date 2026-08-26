#ifndef __INTERRUPT_H
#define __INTERRUPT_H
#include "stdint.h"
#include "print.h"
typedef void*  intr_handler;
void idt_init(void);
#define IDT_DESC_CNT 0x30 
extern void *idt_table[IDT_DESC_CNT];

enum intr_status {
	INTR_OFF,
	INTR_ON
};

enum intr_status intr_get_status(void);
enum intr_status intr_set_status(enum intr_status);
enum intr_status intr_enable(void);
enum intr_status intr_disable(void);
void register_handler(uint8_t vector_no, intr_handler function);
#endif
