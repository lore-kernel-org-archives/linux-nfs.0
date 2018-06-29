Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f198.google.com ([209.85.223.198]:45912 "EHLO
        mail-io0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbeF2I6E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2018 04:58:04 -0400
Received: by mail-io0-f198.google.com with SMTP id i18-v6so6327672iog.12
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2018 01:58:03 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 29 Jun 2018 01:58:03 -0700
In-Reply-To: <001a1143e62eb6a9510565640e76@google.com>
Message-ID: <000000000000a6cfcb056fc40bae@google.com>
Subject: Re: WARNING: ODEBUG bug in __do_softirq
From: syzbot <syzbot+51c9bdfa559769d2f897@syzkaller.appspotmail.com>
To: anna.schumaker@netapp.com, bfields@fieldses.org,
        davem@davemloft.net, jlayton@kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com,
        trond.myklebust@hammerspace.com, trond.myklebust@primarydata.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

syzbot has found a reproducer for the following crash on:

HEAD commit:    509fda105ba8 samples/bpf: xdp_rxq_info action XDP_TX must ..
git tree:       bpf-next
console output: https://syzkaller.appspot.com/x/log.txt?x=107f20b8400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=a63be0c83e84d370
dashboard link: https://syzkaller.appspot.com/bug?extid=51c9bdfa559769d2f897
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=17990d88400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+51c9bdfa559769d2f897@syzkaller.appspotmail.com

random: crng init done
------------[ cut here ]------------
ODEBUG: free active (active state 0) object type: timer_list hint:  
xprt_init_autodisconnect+0x0/0x240 net/sunrpc/xprt.c:193
WARNING: CPU: 0 PID: 0 at lib/debugobjects.c:329  
debug_print_object+0x16a/0x210 lib/debugobjects.c:326
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.18.0-rc2+ #43
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  panic+0x238/0x4e7 kernel/panic.c:184
  __warn.cold.8+0x163/0x1ba kernel/panic.c:536
  report_bug+0x252/0x2d0 lib/bug.c:186
  fixup_bug arch/x86/kernel/traps.c:178 [inline]
  do_error_trap+0x1fc/0x4d0 arch/x86/kernel/traps.c:296
  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:316
  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:992
RIP: 0010:debug_print_object+0x16a/0x210 lib/debugobjects.c:326
Code: 1a 88 48 89 fa 48 c1 ea 03 80 3c 02 00 0f 85 92 00 00 00 48 8b 14 dd  
80 99 1a 88 4c 89 f6 48 c7 c7 00 8f 1a 88 e8 46 aa e6 fd <0f> 0b 83 05 79  
57 3e 06 01 48 83 c4 18 5b 41 5c 41 5d 41 5e 41 5f
RSP: 0018:ffff8801dae07808 EFLAGS: 00010086
RAX: 0000000000000000 RBX: 0000000000000003 RCX: 0000000000000000
RDX: 0000000000000100 RSI: ffffffff816318f1 RDI: 0000000000000001
RBP: ffff8801dae07848 R08: ffffffff88e75dc0 R09: ffffed003b5c3ec2
R10: ffffed003b5c3ec2 R11: ffff8801dae1f617 R12: 0000000000000001
R13: ffffffff88f9ca20 R14: ffffffff881a93a0 R15: ffffffff81690d10
  __debug_check_no_obj_freed lib/debugobjects.c:783 [inline]
  debug_check_no_obj_freed+0x3b2/0x595 lib/debugobjects.c:815
  kfree+0xc7/0x260 mm/slab.c:3812
  __rcu_reclaim kernel/rcu/rcu.h:173 [inline]
  rcu_do_batch kernel/rcu/tree.c:2558 [inline]
  invoke_rcu_callbacks kernel/rcu/tree.c:2818 [inline]
  __rcu_process_callbacks kernel/rcu/tree.c:2785 [inline]
  rcu_process_callbacks+0x1004/0x1850 kernel/rcu/tree.c:2802
  __do_softirq+0x2e8/0xb17 kernel/softirq.c:288
  invoke_softirq kernel/softirq.c:368 [inline]
  irq_exit+0x1d1/0x200 kernel/softirq.c:408
  exiting_irq arch/x86/include/asm/apic.h:527 [inline]
  smp_apic_timer_interrupt+0x186/0x730 arch/x86/kernel/apic/apic.c:1052
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:863
  </IRQ>
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:54
Code: c7 48 89 45 d8 e8 da 87 27 fa 48 8b 45 d8 e9 d2 fe ff ff 48 89 df e8  
c9 87 27 fa eb 8a 90 90 90 90 90 90 90 55 48 89 e5 fb f4 <5d> c3 0f 1f 84  
00 00 00 00 00 55 48 89 e5 f4 5d c3 90 90 90 90 90
RSP: 0018:ffffffff88e07bc0 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff13
RAX: dffffc0000000000 RBX: 1ffffffff11c0f7b RCX: 0000000000000000
RDX: 1ffffffff11e3618 RSI: 0000000000000001 RDI: ffffffff88f1b0c0
RBP: ffffffff88e07bc0 R08: ffffed003b5c46d7 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff88e07c78 R14: ffffffff899eaae0 R15: 0000000000000000
  arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
  default_idle+0xc7/0x450 arch/x86/kernel/process.c:500
  arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:491
  default_idle_call+0x6d/0x90 kernel/sched/idle.c:93
  cpuidle_idle_call kernel/sched/idle.c:153 [inline]
  do_idle+0x3aa/0x570 kernel/sched/idle.c:262
  cpu_startup_entry+0x10c/0x120 kernel/sched/idle.c:368
  rest_init+0xe1/0xe4 init/main.c:442
  start_kernel+0x90e/0x949 init/main.c:738
  x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:452
  x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:433
  secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:242

======================================================
WARNING: possible circular locking dependency detected
4.18.0-rc2+ #43 Not tainted
------------------------------------------------------
swapper/0/0 is trying to acquire lock:
000000006528fc84 ((console_sem).lock){-.-.}, at: down_trylock+0x13/0x70  
kernel/locking/semaphore.c:136

but task is already holding lock:
000000004bd165f9 (&obj_hash[i].lock){-.-.}, at: __debug_check_no_obj_freed  
lib/debugobjects.c:774 [inline]
000000004bd165f9 (&obj_hash[i].lock){-.-.}, at:  
debug_check_no_obj_freed+0x16c/0x595 lib/debugobjects.c:815

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3 (&obj_hash[i].lock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x96/0xc0 kernel/locking/spinlock.c:152
        __debug_object_init+0x127/0x12e0 lib/debugobjects.c:381
        debug_object_init+0x16/0x20 lib/debugobjects.c:429
        debug_hrtimer_init kernel/time/hrtimer.c:410 [inline]
        debug_init kernel/time/hrtimer.c:458 [inline]
        hrtimer_init+0x97/0x480 kernel/time/hrtimer.c:1308
        init_dl_task_timer+0x1b/0x50 kernel/sched/deadline.c:1056
        __sched_fork+0x2ae/0x590 kernel/sched/core.c:2186
        init_idle+0x75/0x7a0 kernel/sched/core.c:5408
        sched_init+0xbf3/0xd2c kernel/sched/core.c:6106
        start_kernel+0x47d/0x949 init/main.c:602
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:452
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:433
        secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:242

-> #2 (&rq->lock){-.-.}:
        __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
        _raw_spin_lock+0x2a/0x40 kernel/locking/spinlock.c:144
        rq_lock kernel/sched/sched.h:1805 [inline]
        task_fork_fair+0x93/0x680 kernel/sched/fair.c:9953
        sched_fork+0x446/0xb40 kernel/sched/core.c:2382
        copy_process.part.39+0x1c09/0x7220 kernel/fork.c:1773
        copy_process kernel/fork.c:1616 [inline]
        _do_fork+0x291/0x12a0 kernel/fork.c:2099
        kernel_thread+0x34/0x40 kernel/fork.c:2158
        rest_init+0x22/0xe4 init/main.c:408
        start_kernel+0x90e/0x949 init/main.c:738
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:452
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:433
        secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:242

-> #1 (&p->pi_lock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x96/0xc0 kernel/locking/spinlock.c:152
        try_to_wake_up+0xd2/0x12b0 kernel/sched/core.c:1986
        wake_up_process+0x10/0x20 kernel/sched/core.c:2149
        __up.isra.1+0x1c0/0x2a0 kernel/locking/semaphore.c:262
        up+0x13c/0x1c0 kernel/locking/semaphore.c:187
        __up_console_sem+0xbe/0x1b0 kernel/printk/printk.c:242
        console_unlock+0x7a2/0x10b0 kernel/printk/printk.c:2411
        do_con_write+0x12cc/0x22a0 drivers/tty/vt/vt.c:2435
        con_write+0x25/0xc0 drivers/tty/vt/vt.c:2784
        process_output_block drivers/tty/n_tty.c:579 [inline]
        n_tty_write+0x6c1/0x11a0 drivers/tty/n_tty.c:2308
        do_tty_write drivers/tty/tty_io.c:963 [inline]
        tty_write+0x45f/0xae0 drivers/tty/tty_io.c:1051
        __vfs_write+0x117/0x9f0 fs/read_write.c:485
        vfs_write+0x1f8/0x560 fs/read_write.c:549
        ksys_write+0x101/0x260 fs/read_write.c:598
        __do_sys_write fs/read_write.c:610 [inline]
        __se_sys_write fs/read_write.c:607 [inline]
        __x64_sys_write+0x73/0xb0 fs/read_write.c:607
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #0 ((console_sem).lock){-.-.}:
        lock_acquire+0x1e4/0x540 kernel/locking/lockdep.c:3924
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x96/0xc0 kernel/locking/spinlock.c:152
        down_trylock+0x13/0x70 kernel/locking/semaphore.c:136
        __down_trylock_console_sem+0xae/0x200 kernel/printk/printk.c:225
        console_trylock+0x15/0xa0 kernel/printk/printk.c:2230
        console_trylock_spinning kernel/printk/printk.c:1643 [inline]
        vprintk_emit+0x6ad/0xdf0 kernel/printk/printk.c:1906
        vprintk_default+0x28/0x30 kernel/printk/printk.c:1948
        vprintk_func+0x7a/0xe7 kernel/printk/printk_safe.c:382
        printk+0xa7/0xcf kernel/printk/printk.c:1981
        __warn_printk+0x8c/0xe0 kernel/panic.c:590
        debug_print_object+0x16a/0x210 lib/debugobjects.c:326
        __debug_check_no_obj_freed lib/debugobjects.c:783 [inline]
        debug_check_no_obj_freed+0x3b2/0x595 lib/debugobjects.c:815
        kfree+0xc7/0x260 mm/slab.c:3812
        __rcu_reclaim kernel/rcu/rcu.h:173 [inline]
        rcu_do_batch kernel/rcu/tree.c:2558 [inline]
        invoke_rcu_callbacks kernel/rcu/tree.c:2818 [inline]
        __rcu_process_callbacks kernel/rcu/tree.c:2785 [inline]
        rcu_process_callbacks+0x1004/0x1850 kernel/rcu/tree.c:2802
        __do_softirq+0x2e8/0xb17 kernel/softirq.c:288
        invoke_softirq kernel/softirq.c:368 [inline]
        irq_exit+0x1d1/0x200 kernel/softirq.c:408
        exiting_irq arch/x86/include/asm/apic.h:527 [inline]
        smp_apic_timer_interrupt+0x186/0x730 arch/x86/kernel/apic/apic.c:1052
        apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:863
        native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:54
        arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
        default_idle+0xc7/0x450 arch/x86/kernel/process.c:500
        arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:491
        default_idle_call+0x6d/0x90 kernel/sched/idle.c:93
        cpuidle_idle_call kernel/sched/idle.c:153 [inline]
        do_idle+0x3aa/0x570 kernel/sched/idle.c:262
        cpu_startup_entry+0x10c/0x120 kernel/sched/idle.c:368
        rest_init+0xe1/0xe4 init/main.c:442
        start_kernel+0x90e/0x949 init/main.c:738
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:452
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:433
        secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:242

other info that might help us debug this:

Chain exists of:
   (console_sem).lock --> &rq->lock --> &obj_hash[i].lock

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&obj_hash[i].lock);
                                lock(&rq->lock);
                                lock(&obj_hash[i].lock);
   lock((console_sem).lock);

  *** DEADLOCK ***

2 locks held by swapper/0/0:
  #0: 00000000eb5a51da (rcu_callback){....}, at: __rcu_reclaim  
kernel/rcu/rcu.h:168 [inline]
  #0: 00000000eb5a51da (rcu_callback){....}, at: rcu_do_batch  
kernel/rcu/tree.c:2558 [inline]
  #0: 00000000eb5a51da (rcu_callback){....}, at: invoke_rcu_callbacks  
kernel/rcu/tree.c:2818 [inline]
  #0: 00000000eb5a51da (rcu_callback){....}, at: __rcu_process_callbacks  
kernel/rcu/tree.c:2785 [inline]
  #0: 00000000eb5a51da (rcu_callback){....}, at:  
rcu_process_callbacks+0xfc6/0x1850 kernel/rcu/tree.c:2802
  #1: 000000004bd165f9 (&obj_hash[i].lock){-.-.}, at:  
__debug_check_no_obj_freed lib/debugobjects.c:774 [inline]
  #1: 000000004bd165f9 (&obj_hash[i].lock){-.-.}, at:  
debug_check_no_obj_freed+0x16c/0x595 lib/debugobjects.c:815

stack backtrace:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.18.0-rc2+ #43
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_circular_bug.isra.36.cold.57+0x1bd/0x27d  
kernel/locking/lockdep.c:1227
  check_prev_add kernel/locking/lockdep.c:1867 [inline]
  check_prevs_add kernel/locking/lockdep.c:1980 [inline]
  validate_chain kernel/locking/lockdep.c:2421 [inline]
  __lock_acquire+0x3449/0x5020 kernel/locking/lockdep.c:3435
  lock_acquire+0x1e4/0x540 kernel/locking/lockdep.c:3924
  __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
  _raw_spin_lock_irqsave+0x96/0xc0 kernel/locking/spinlock.c:152
  down_trylock+0x13/0x70 kernel/locking/semaphore.c:136
  __down_trylock_console_sem+0xae/0x200 kernel/printk/printk.c:225
  console_trylock+0x15/0xa0 kernel/printk/printk.c:2230
  console_trylock_spinning kernel/printk/printk.c:1643 [inline]
  vprintk_emit+0x6ad/0xdf0 kernel/printk/printk.c:1906
  vprintk_default+0x28/0x30 kernel/printk/printk.c:1948
  vprintk_func+0x7a/0xe7 kernel/printk/printk_safe.c:382
  printk+0xa7/0xcf kernel/printk/printk.c:1981
  __warn_printk+0x8c/0xe0 kernel/panic.c:590
  debug_print_object+0x16a/0x210 lib/debugobjects.c:326
  __debug_check_no_obj_freed lib/debugobjects.c:783 [inline]
  debug_check_no_obj_freed+0x3b2/0x595 lib/debugobjects.c:815
  kfree+0xc7/0x260 mm/slab.c:3812
  __rcu_reclaim kernel/rcu/rcu.h:173 [inline]
  rcu_do_batch kernel/rcu/tree.c:2558 [inline]
  invoke_rcu_callbacks kernel/rcu/tree.c:2818 [inline]
  __rcu_process_callbacks kernel/rcu/tree.c:2785 [inline]
  rcu_process_callbacks+0x1004/0x1850 kernel/rcu/tree.c:2802
  __do_softirq+0x2e8/0xb17 kernel/softirq.c:288
  invoke_softirq kernel/softirq.c:368 [inline]
  irq_exit+0x1d1/0x200 kernel/softirq.c:408
  exiting_irq arch/x86/include/asm/apic.h:527 [inline]
  smp_apic_timer_interrupt+0x186/0x730 arch/x86/kernel/apic/apic.c:1052
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:863
  </IRQ>
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:54
Code: c7 48 89 45 d8 e8 da 87 27 fa 48 8b 45 d8 e9 d2 fe ff ff 48 89 df e8  
c9 87 27 fa eb 8a 90 90 90 90 90 90 90 55 48 89 e5 fb f4 <5d> c3 0f 1f 84  
00 00 00 00 00 55 48 89 e5 f4 5d c3 90 90 90 90 90
RSP: 0018:ffffffff88e07bc0 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff13
RAX: dffffc0000000000 RBX: 1ffffffff11c0f7b RCX: 0000000000000000
RDX: 1ffffffff11e3618 RSI: 0000000000000001 RDI: ffffffff88f1b0c0
RBP: ffffffff88e07bc0 R08: ffffed003b5c46d7 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff88e07c78 R14: ffffffff899eaae0 R15: 0000000000000000
  arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
  default_idle+0xc7/0x450 arch/x86/kernel/process.c:500
  arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:491
  default_idle_call+0x6d/0x90 kernel/sched/idle.c:93
  cpuidle_idle_call kernel/sched/idle.c:153 [inline]
  do_idle+0x3aa/0x570 kernel/sched/idle.c:262
  cpu_startup_entry+0x10c/0x120 kernel/sched/idle.c:368
  rest_init+0xe1/0xe4 init/main.c:442
  start_kernel+0x90e/0x949 init/main.c:738
  x86_64_start_reservations+0x29/0x2 arch/x86/kernel/head64.c:452
Lost 2 message(s)!
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..

