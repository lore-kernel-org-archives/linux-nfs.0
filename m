Received: from mail-oo2-f7.google.com (mail-oo2-f7.google.com [74.125.231.135])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B4EF2BCF4C
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 22:38:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.135
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788475122; cv=none; b=s2WxUh3FjzNx5WMC5l17xmCH/7yx7oy95HORKyz+X1D0qgFzDuqwkZIq1h2MY/wX9X7MVCnZlGiYVtG3wN6tridJBrxmuUrycInOZ0n+ZVOLALHSz4lMp4hBqcXaTg2dt0f/yeU7CAGzFqbb3NZEqTHBZxNYVcaxC7t9W4gm0Ew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788475122; c=relaxed/simple;
	bh=srKtBN7YiWfEJnHZlCVPhTL+BXHoTKstoVhYCmwaebM=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=spYWgPmN6ol1BOcbRZ9pYR/OeL0N5FthoW6wxHCznlCtDvrFCETHXqGxQ38k+dH701mNKv9/El7qP4QWfwC8UhU62OpXeL8eKiCKtgfq/34Lwb/qxTodtOi449rbwq1rMZ2aHyRRSTirE+d88gGMF51VTyul5S1czgxMgHZWmz4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=74.125.231.135
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo2-f7.google.com with SMTP id 006d021491bc7-6b137c364c5so74180eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 15:38:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788475120; x=1789079920;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=XSguvTv0VEWmcSNYt7WY8UZQpYNnQc+lL3sqxL8n/LE=;
        b=GUk5p1fnd1UBE+u7Xv6Yi3Ju2zZXxqF0yPrMwD7w/EQYvpqo4S2M8lWCmH3o9Zb9Fz
         syCMQB2A5YJsfGBLsGW8YLrYI33T+h9UCt60rVB71/QWEUiHRuKYmcyMyMBE4jPOHz0o
         JzH+t5IUCEJx6BS+8nRNCAzAi5LSRlgFdFPn1lz9vrzLmmjDRwwHx2zcynNL79+wBSjB
         NpwvlUdCqpF+iu/9woaCF8hAEQLY6tWnognaVV8R1mQtI+cTNsPx4U9mG+IUkCbSvEkh
         0xxCnjUnQ3Mg1jiqYrNrv9F73vxTjktHEfS7vDT3iHmBZjuaMZs89YTQo6aqXZkVRezb
         s3ag==
X-Forwarded-Encrypted: i=1; AKwUvBzepyuEuWJaiyaYCKxvrHPC3krbwPamuxhaTQ8xYNCy6jTWRRST9nHWJglsOeZ2g2Xpt4RNy5RXRVI=@vger.kernel.org
X-Gm-Message-State: AFuF++l34W4Jit/r0LEZScw6KTZysm41FatuEhEh1FffU7AADtkkvjl2
	GhPtZryfWsNQyzVSOfUosNcMK+MN5dOXP1paVkCzDrGERo+YX8qlycrsxIML8+JaOuxsK4+FXFw
	U7EA/r0nGaCJIfnq/sruc2YMntuOhSk8oq//gcGG3ymz2G9weKk7kJCLhRnM=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a4a:ec4a:0:b0:6b7:46fc:1dd with SMTP id
 006d021491bc7-6b746fc025cmr152867eaf.60.1788475120144; Thu, 03 Sep 2026
 15:38:40 -0700 (PDT)
Date: Thu, 03 Sep 2026 15:38:40 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a99f6f0.2e567484.299ffc.000c.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd4_cld_tracking_init
From: syzbot <syzbot+edbebd898142ee5e24ce@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    940de590b839 Merge tag 'hardening-v7.3-rc2' of git://git.k..
git tree:       upstream
console+strace: https://syzkaller.appspot.com/x/log.txt?x=12c6b39e580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8c5c3949d762a91f
dashboard link: https://syzkaller.appspot.com/bug?extid=edbebd898142ee5e24ce
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14872125580000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12b8cb49580000

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/75055d1d5648/disk-940de590.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/419590aed71c/vmlinux-940de590.xz
kernel image: https://storage.googleapis.com/syzbot-assets/c51c5e853b44/bzImage-940de590.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+edbebd898142ee5e24ce@syzkaller.appspotmail.com

INFO: task syz-executor22
INFO: task syz-executor224:5626 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor224 state:D stack:24312 pid:5626  tgid:5625  ppid:5624   task_flags:0x400140 flags:0x00080802
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5520 [inline]
 __schedule+0x1259/0x6920 kernel/sched/core.c:7270
 __schedule_loop kernel/sched/core.c:7347 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7362
 schedule_timeout+0x1b2/0x280 kernel/time/sleep_timeout.c:75
 do_wait_for_common kernel/sched/completion.c:100 [inline]
 __wait_for_common+0x2e7/0x4c0 kernel/sched/completion.c:121
 __cld_pipe_upcall fs/nfsd/nfs4recover.c:673 [inline]
 cld_pipe_upcall fs/nfsd/nfs4recover.c:691 [inline]
 nfsd4_cld_get_version fs/nfsd/nfs4recover.c:1425 [inline]
 nfsd4_cld_tracking_init+0x4be/0x10f0 fs/nfsd/nfs4recover.c:1490
 nfsd4_client_tracking_init+0xe5/0x1c0 fs/nfsd/nfs4recover.c:1941
 nfs4_state_start_net.cold+0xb7/0x480 fs/nfsd/nfs4state.c:9838
 nfsd_startup_net fs/nfsd/nfssvc.c:391 [inline]
 nfsd_svc+0x54a/0x7d0 fs/nfsd/nfssvc.c:775
 write_threads+0x316/0x600 fs/nfsd/nfsctl.c:438
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:114
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fbfd3713269
RSP: 002b:00007fbfd36eb1d8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007fbfd37c3b68 RCX: 00007fbfd3713269
RDX: 0000000000000002 RSI: 0000200000000100 RDI: 0000000000000005
RBP: 00007fbfd37c3b60 R08: 35203a6b63617473 R09: 35203a6b63617473
R10: 35203a6b63617473 R11: 0000000000000246 R12: 00007fbfd3795378
R13: 0000200000000200 R14: 0000200000000500 R15: 00002000000000c0
 </TASK>

Showing all locks held in the system:
locks held by kworker/u8:1/13: 2, on CPU#0:
 #0: ffff88801c094140 ((wq_completion)events_unbound){+.+.}-{0:0}, at: process_one_work+0x1466/0x1b10 kernel/workqueue.c:3371
 #1: ffffc90000127d08 ((work_completion)(&(&kfence_timer)->work)){+.+.}-{0:0}, at: process_one_work+0xa2c/0x1b10 kernel/workqueue.c:3372
locks held by pr/ttyS0/16: 2, last CPU#0:
 #0: ffffffff8edd8338 (console_srcu){....}-{0:0}, at: rcu_try_lock_acquire include/linux/rcupdate.h:314 [inline]
 #0: ffffffff8edd8338 (console_srcu){....}-{0:0}, at: srcu_read_lock_nmisafe include/linux/srcu.h:439 [inline]
 #0: ffffffff8edd8338 (console_srcu){....}-{0:0}, at: console_srcu_read_lock+0x49/0x60 kernel/printk/printk.c:291
 #1: ffffffff9bc63c78 (&port_lock_key){-.-.}-{3:3}, at: __uart_port_lock_irqsave include/linux/serial_core.h:613 [inline]
 #1: ffffffff9bc63c78 (&port_lock_key){-.-.}-{3:3}, at: univ8250_console_device_lock+0x64/0xc0 drivers/tty/serial/8250/8250_core.c:413
locks held by khungtaskd/32: 1, last CPU#1:
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:309 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:849 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6837
locks held by getty/5360: 2, on CPU#1:
 #0: ffff888029f520a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032262e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
locks held by syz-executor224/5626: 3, on CPU#1:
 #0: ffff88802b935970 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
 #1: ffff888035040460 (sb_writers#9){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #2: ffffffff8f287680 (nfsd_mutex){+.+.}-{4:4}, at: write_threads+0x288/0x600 fs/nfsd/nfsctl.c:436

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 32 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 08/05/2026
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
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 16 Comm: pr/ttyS0 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 08/05/2026
RIP: 0010:io_serial_in+0x87/0xb0 drivers/tty/serial/8250/8250_port.c:410
Code: 07 5c fc 48 8d 7d 40 44 89 e1 48 b8 00 00 00 00 00 fc ff df 48 89 fa d3 e3 48 c1 ea 03 80 3c 02 00 75 1a 66 03 5d 40 89 da ec <5b> 0f b6 c0 5d 41 5c c3 cc cc cc cc e8 48 1a cf fc eb a2 e8 d1 1a
RSP: 0018:ffffc90000157958 EFLAGS: 00000002
RAX: dffffc0000000000 RBX: 00000000000003fd RCX: 0000000000000000
RDX: 00000000000003fd RSI: ffffffff85afe8d0 RDI: ffffffff9bc63ca0
RBP: ffffffff9bc63c60 R08: 0000000000000001 R09: 000000000000001f
R10: 0000000000000000 R11: 205d323354202020 R12: 0000000000000000
R13: 0000000000000020 R14: fffffbfff378c7e9 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888123b61000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000561b47b0e660 CR3: 000000000eb96000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 serial_in drivers/tty/serial/8250/8250.h:128 [inline]
 serial_lsr_in drivers/tty/serial/8250/8250.h:150 [inline]
 wait_for_lsr+0x13a/0x210 drivers/tty/serial/8250/8250_port.c:2013
 serial8250_fifo_wait_for_lsr_thre+0x5f/0xd0 drivers/tty/serial/8250/8250_port.c:3270
 __serial8250_console_fifo_write+0xa5/0x290 drivers/tty/serial/8250/8250_port.c:3345
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
This report is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this issue. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

If the report is already addressed, let syzbot know by replying with:
#syz fix: exact-commit-title

If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
