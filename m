Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40AE04119F2
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 22:31:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788388303; cv=none; b=N+Q9mfXspVMQWIu7wL/eRoNLSZKCfMj8zxr2xcWPgt8ZDWc8ggfNj6Ee/wrqQCHk1J7lfC+UcGEUM64cMaztT05kqn8qAkwC2ODet0UE6x2fx4YfdRkMGsYK8iVLOBfourUasWCxW/RwfabW2uY+I4AZtKm+Uz8oNoV9EX7MDZ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788388303; c=relaxed/simple;
	bh=NLAws/3aTtmyrmhPm11IDzKhJlV7oE0jZENDzlOr84U=;
	h=MIME-Version:Date:In-Reply-To:Message-ID:Subject:From:To:
	 Content-Type; b=JFuLDQzi75JzkQuoqulo4jyr48a32gJMqRQ3XD+YpZbJLWTeMZ9iWXrH7TgObo+WmbjQ5PGpyf3e5TWOe3iQ/pnsmpzSv21uzXDOgVSnAC60I5MmBjzXDuDub6f4X6TK46WglSEksyTH7f/lFdN1+Teyyj/rVK4jM7UeWHEKdXc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f197.google.com with SMTP id 5614622812f47-485ebc5706cso454595b6e.0
        for <linux-nfs@vger.kernel.org>; Wed, 02 Sep 2026 15:31:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788388293; x=1788993093;
        h=content-type:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=W+pl83gb4I7QNRSCAXRvNHTTFXcGygtvzShFK/lpDNA=;
        b=KmhcBd1LES6h3NpXhi8Z+V086q2o6CzGRfaiUyW7E7eH64xl5FndF8KGpxs0oXk+OF
         CF+2mx87QM8H+o3OWTR5PsfGsgcHjSsd9GDRbOdJmffuG52RUyUy3UmUrlkIHkSGuuUm
         7MIya5L22KZ2a835gZvlGFJzAg+yfIs5C3RlZGy2DcKvOfm1GBBAuLC7fkuRz1NgbsOk
         qTrKf+q6y+ZYO3uXXk/f8HFJNFiNTwkhEIgQI63ZQfAg0oqh0683BygDXyeJGoTlukqn
         kCueGpj63fmH9lNvfU4nuKBIDnOmy02Vx65LfOGT/pJKCVqkT2f4g6xYIIfMnAtRVQOF
         5Eaw==
X-Forwarded-Encrypted: i=1; AKwUvBzUb2aWOvzQONlzulWq80WznuQLBD88T+U9Ib7f0HscCk4D9Uf7/bTG9eb1j2QEtPShfJkSOX/1W0g=@vger.kernel.org
X-Gm-Message-State: AFuF++mvO/0/LcPnxxEkPgvvDKURf1vN1bN8uNEnSho1SHCnsnjQwTx0
	Gj8rX5pUrWitewFsBJrISOyeGZj7O4G1nkxTGtKn3h6SaW9ITf3XpFifyuohcE5C2dWVWBTqWyD
	5iOEJZI1+Q1asXzuJI5pni7GDFsp+EAGDLK50r7HShAUhn5i/7OMhED5bM6A=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:61d:b0:6b1:9b72:213c with SMTP id
 006d021491bc7-6b582a61f27mr1555358eaf.3.1788388293215; Wed, 02 Sep 2026
 15:31:33 -0700 (PDT)
Date: Wed, 02 Sep 2026 15:31:33 -0700
In-Reply-To: <6a90c2f3.4d659fcc.734b4.0017.GAE@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a98a3c5.27a413cd.1e878c.0010.GAE@google.com>
Subject: Re: [syzbot] [nfs?] INFO: task hung in nfsd_nrthreads
From: syzbot <syzbot+86a9d43d89b86def6d59@syzkaller.appspotmail.com>
To: cel@kernel.org, dai.ngo@oracle.com, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

syzbot has found a reproducer for the following issue on:

HEAD commit:    89a312991dc6 Merge tag 'cifs-fixes-7.3-rc2' of https://git..
git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
console output: https://syzkaller.appspot.com/x/log.txt?x=14c74125580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8c5c3949d762a91f
dashboard link: https://syzkaller.appspot.com/bug?extid=86a9d43d89b86def6d59
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=143c8b49580000

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+86a9d43d89b86def6d59@syzkaller.appspotmail.com

INFO: task syz-executor195:6046 blocked for more than 10 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor195 state:D stack:27704 pid:6046  tgid:6041  ppid:6040   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5520 [inline]
 __schedule+0x1259/0x6920 kernel/sched/core.c:7270
 __schedule_loop kernel/sched/core.c:7347 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7362
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7419
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccb/0x1bd0 kernel/locking/mutex.c:821
 nfsd_nrthreads+0x57/0xd0 fs/nfsd/nfssvc.c:252
 write_threads+0x34a/0x600 fs/nfsd/nfsctl.c:445
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:114
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f39e2b76239
RSP: 002b:00007f39e2341208 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00007f39e2b76239
RDX: 0000000000000000 RSI: 00007f39e2be928b RDI: 0000000000000005
RBP: 0000000000000021 R08: 0000000000000000 R09: 00007f39e2341cdc
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffd0
R13: 0000000000000000 R14: 00007ffe7fef6410 R15: 00007ffe7fef64f8
 </TASK>

Showing all locks held in the system:
locks held by pr/ttyS0/16: 2, last CPU#2:
 #0: ffffffff8edd8338 (console_srcu){....}-{0:0}, at: rcu_try_lock_acquire include/linux/rcupdate.h:314 [inline]
 #0: ffffffff8edd8338 (console_srcu){....}-{0:0}, at: srcu_read_lock_nmisafe include/linux/srcu.h:439 [inline]
 #0: ffffffff8edd8338 (console_srcu){....}-{0:0}, at: console_srcu_read_lock+0x49/0x60 kernel/printk/printk.c:291
 #1: ffffffff9bc63c78 (&port_lock_key){-.-.}-{3:3}, at: __uart_port_lock_irqsave include/linux/serial_core.h:613 [inline]
 #1: ffffffff9bc63c78 (&port_lock_key){-.-.}-{3:3}, at: univ8250_console_device_lock+0x64/0xc0 drivers/tty/serial/8250/8250_core.c:413
locks held by khungtaskd/44: 1, last CPU#1:
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:309 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:849 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6837
locks held by kworker/u33:5/140: 5, last CPU#0:
 #0: ffff88801c0e4140 ((wq_completion)events_unbound){+.+.}-{0:0}, at: process_one_work+0x1466/0x1b10 kernel/workqueue.c:3371
 #1: ffffc900028f7d08 ((work_completion)(&(&kfence_timer)->work)){+.+.}-{0:0}, at: process_one_work+0xa2c/0x1b10 kernel/workqueue.c:3372
 #2: ffffffff8ec7ca50 (cpu_hotplug_lock){++++}-{0:0}, at: static_key_disable+0x12/0x20 kernel/jump_label.c:247
 #3: ffffffff8ef40280 (jump_label_mutex){+.+.}-{4:4}, at: jump_label_lock kernel/jump_label.c:27 [inline]
 #3: ffffffff8ef40280 (jump_label_mutex){+.+.}-{4:4}, at: static_key_disable_cpuslocked+0x110/0x1c0 kernel/jump_label.c:238
 #4: ffffffff8ec9c340 (text_mutex){+.+.}-{4:4}, at: arch_jump_label_transform_apply+0x17/0x30 arch/x86/kernel/jump_label.c:145
locks held by getty/5533: 2, on CPU#2:
 #0: ffff88802b7970a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc9000337e2e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
locks held by syz-executor195/6044: 4, on CPU#3:
 #0: ffff888026dccef0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
 #1: ffff8880264cc460 (sb_writers#13){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #2: ffffffff8f287680 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:867
 #3: ffffffff90fbb440 (rpcb_create_local_mutex){+.+.}-{4:4}, at: rpcb_create_local+0x100/0x270 net/sunrpc/rpcb_clnt.c:353
locks held by syz-executor195/6046: 3, on CPU#0:
 #0: ffff88803d290d30 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
 #1: ffff8880264cc460 (sb_writers#13){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #2: ffffffff8f287680 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nrthreads+0x57/0xd0 fs/nfsd/nfssvc.c:252

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 44 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
Call Trace:
 <TASK>
 __dump_stack lib/dump_stack.c:94 [inline]
 dump_stack_lvl+0x100/0x190 lib/dump_stack.c:120
 nmi_cpu_backtrace.cold+0x12d/0x151 lib/nmi_backtrace.c:123
 nmi_trigger_cpumask_backtrace+0x21f/0x2a0 lib/nmi_backtrace.c:66
 trigger_all_cpu_backtrace include/linux/nmi.h:164 [inline]
 __sys_info lib/sys_info.c:157 [inline]
 sys_info+0x141/0x190 lib/sys_info.c:165
 check_hung_uninterruptible_tasks kernel/hung_task.c:353 [inline]
 watchdog+0xcb1/0x1030 kernel/hung_task.c:561
 kthread+0x373/0x450 kernel/kthread.c:436
 ret_from_fork+0x730/0xd60 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
Sending NMI from CPU 1 to CPUs 0,2-3:
NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 140 Comm: kworker/u33:5 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
Workqueue: events_unbound toggle_allocation_gate
RIP: 0010:csd_lock_wait kernel/smp.c:363 [inline]
RIP: 0010:smp_call_function_many_cond+0x8f0/0x18c0 kernel/smp.c:1002
Code: 48 b8 00 00 00 00 00 fc ff df 48 8b 4c 24 08 49 89 ce 83 e1 07 49 c1 ee 03 49 89 cd 49 01 c6 41 83 c5 03 e8 b2 bf 0c 00 f3 90 <41> 0f b6 06 41 38 c5 7c 08 84 c0 0f 85 ca 0d 00 00 8b 45 08 31 ff
RSP: 0018:ffffc900028f78a0 EFLAGS: 00000293
RAX: 0000000000000000 RBX: 0000000000000002 RCX: 0000000000000000
RDX: ffff8880257c8000 RSI: ffffffff81ff305e RDI: ffff8880257c8000
RBP: ffff88806a641900 R08: 0000000000000005 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffffed1004af92b3
R13: 0000000000000003 R14: ffffed100d4c8321 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff8880d5b61000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fe4bdf736e8 CR3: 000000000eb96000 CR4: 0000000000352ef0
Call Trace:
 <TASK>
 on_each_cpu include/linux/smp.h:71 [inline]
 smp_text_poke_sync_each_cpu arch/x86/kernel/alternative.c:2602 [inline]
 smp_text_poke_batch_finish+0x337/0xc60 arch/x86/kernel/alternative.c:2812
 arch_jump_label_transform_apply+0x1c/0x30 arch/x86/kernel/jump_label.c:146
 jump_label_update+0x37a/0x550 kernel/jump_label.c:910
 static_key_disable_cpuslocked+0x162/0x1c0 kernel/jump_label.c:240
 static_key_disable+0x1a/0x20 kernel/jump_label.c:248
 toggle_allocation_gate mm/kfence/core.c:909 [inline]
 toggle_allocation_gate+0x149/0x2d0 mm/kfence/core.c:894
 process_one_work+0xac7/0x1b10 kernel/workqueue.c:3396
 process_scheduled_works kernel/workqueue.c:3479 [inline]
 worker_thread+0x5ef/0xe50 kernel/workqueue.c:3560
 kthread+0x373/0x450 kernel/kthread.c:436
 ret_from_fork+0x730/0xd60 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
NMI backtrace for cpu 3
CPU: 3 UID: 0 PID: 0 Comm: swapper/3 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: 28 9c 02 e9 c3 4f 03 00 0f 1f 00 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa eb 07 0f 00 2d c3 56 1c 00 fb f4 <c3> cc cc cc cc 66 2e 0f 1f 84 00 00 00 00 00 66 90 90 90 90 90 90
RSP: 0018:ffffc900001a7e00 EFLAGS: 00000202
RAX: 00000000000486e5 RBX: ffff88801f698000 RCX: ffffffff8bcf6115
RDX: 0000000000000001 RSI: ffffffff8e3eb021 RDI: ffffffff8c620e80
RBP: ffffed1003ed3000 R08: 0000000000000001 R09: ffffed100d4e67bd
R10: ffff88806a733deb R11: 0000000000000001 R12: 0000000000000000
R13: 0000000000000000 R14: 1ffff92000034fc4 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff8880d5e61000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055dbdf281fa0 CR3: 00000000374a8000 CR4: 0000000000352ef0
Call Trace:
 <TASK>
 arch_safe_halt arch/x86/include/asm/paravirt.h:62 [inline]
 default_idle+0x9/0x10 arch/x86/kernel/process.c:768
 default_idle_call+0x6c/0xb0 kernel/sched/idle.c:122
 cpuidle_idle_call kernel/sched/idle.c:199 [inline]
 do_idle+0x3ae/0x5b0 kernel/sched/idle.c:355
 cpu_startup_entry+0x4f/0x60 kernel/sched/idle.c:454
 start_secondary+0x21d/0x2d0 arch/x86/kernel/smpboot.c:312
 common_startup_64+0x13e/0x158
 </TASK>
NMI backtrace for cpu 2
CPU: 2 UID: 0 PID: 16 Comm: pr/ttyS0 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
RIP: 0010:io_serial_out+0x8f/0xb0 drivers/tty/serial/8250/8250_port.c:416
Code: 48 8d 7d 40 44 89 e1 48 b8 00 00 00 00 00 fc ff df 48 89 fa d3 e3 48 c1 ea 03 80 3c 02 00 75 1c 66 03 5d 40 44 89 e8 89 da ee <5b> 5d 41 5c 41 5d e9 16 ae 22 06 e8 01 1b cf fc eb a0 e8 8a 1b cf
RSP: 0018:ffffc900001379e0 EFLAGS: 00000002
RAX: 000000000000000d RBX: 00000000000003f8 RCX: 0000000000000000
RDX: 00000000000003f8 RSI: ffffffff85afe815 RDI: ffffffff9bc63ca0
RBP: ffffffff9bc63c60 R08: 0000000000000001 R09: 000000000000001f
R10: 0000000000000000 R11: 6220363430363a49 R12: 0000000000000000
R13: 000000000000000d R14: 0000000000000008 R15: ffffc90000137da8
FS:  0000000000000000(0000) GS:ffff8880d5d61000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fe4bdf736e8 CR3: 000000002b9dc000 CR4: 0000000000352ef0
Call Trace:
 <TASK>
 serial_port_out include/linux/serial_core.h:817 [inline]
 serial8250_console_putchar drivers/tty/serial/8250/8250_port.c:3287 [inline]
 __serial8250_console_fifo_write+0x20f/0x290 drivers/tty/serial/8250/8250_port.c:3356
 serial8250_console_fifo_write drivers/tty/serial/8250/8250_port.c:3378 [inline]
 __serial8250_console_write drivers/tty/serial/8250/8250_port.c:3429 [inline]
 serial8250_console_write+0xf46/0x1330 drivers/tty/serial/8250/8250_port.c:3493
 nbcon_emit_next_record+0x8f7/0xa70 kernel/printk/nbcon.c:1070
 nbcon_emit_one+0x1a8/0x2b0 kernel/printk/nbcon.c:1157
 nbcon_kthread_func+0x613/0x7d0 kernel/printk/nbcon.c:1271
 kthread+0x373/0x450 kernel/kthread.c:436
 ret_from_fork+0x730/0xd60 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>


---
If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.
