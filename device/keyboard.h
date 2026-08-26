#ifndef __KEYBOARD_H
#define __KEYBOARD_H

static void intr_keyboard_handler(void);
void keyboard_init(void);
extern struct ioqueue kbd_buf;

#endif