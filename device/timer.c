#include "timer.h"
#include "io.h"
#include "print.h"
#include "interrupt.h"
#include "thread.h"
#include "debug.h"
#include "thread.h"

#define IRQ0_FREQUENCY		100
#define INPUT_FREQUENCY 	1193180
#define COUNTER0_VALUE		INPUT_FREQUENCY / IRQ0_FREQUENCY
#define COUNTER0_PORT		0x40
#define COUNTER0_NO		0
#define COUNTER_MODE		2
#define READ_WRITE_LATCH	3
#define PIT_CONTROL_PORT	0x43


uint32_t ticks;


static void frequency_set(uint8_t counter_port, uint8_t counter_no, uint8_t rwl, uint8_t counter_mode, uint16_t counter_value) {
	outb(PIT_CONTROL_PORT, (uint8_t)(counter_no << 6 | rwl << 4 | counter_mode << 1));
	outb(counter_port, (uint8_t)counter_value);
	outb(counter_port, (uint8_t)counter_value >> 8);
}

void schedule() {
	ASSERT(intr_get_status() == INTR_OFF);
	struct task_struct * cur = running_thread();
	if (cur->status == TASK_RUNNING) {
		ASSERT(!elem_find(&thread_ready_list, &cur->general_tag));
		list_append(&thread_ready_list, &cur->general_tag);
		cur->ticks = cur->priority;
		cur->status = TASK_READY;	
	} else {
		//
	}
	ASSERT(!list_empty(&thread_ready_list));
	thread_tag = NULL;
	thread_tag = list_pop(&thread_ready_list);
	struct task_struct * next = elem2entry(struct task_struct, general_tag, thread_tag);
	next->status = TASK_RUNNING;
	switch_to(cur, next);
}

static void intr_timer_handler(void) {
	struct task_struct * cur_thread = running_thread();
	ASSERT(cur_thread->stack_magic == 0x19870916);
	cur_thread->elapsed_ticks ++;
	ticks ++;
	if (cur_thread->ticks == 0) {
		schedule();
	} else {
		cur_thread->ticks --;
	}
}

void register_handler(uint8_t vector_no, intr_handler function) {
	idt_table[vector_no] = function;
}

void timer_init(void) {
	put_str("timer_init start\n");
	frequency_set(COUNTER0_PORT, COUNTER0_NO, READ_WRITE_LATCH, COUNTER_MODE, COUNTER0_VALUE);
	register_handler(0x20, intr_timer_handler);
	put_str("timer_init done\n");
}

