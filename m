Received: from mail-oa2-f0.google.com (mail-oa2-f0.google.com [74.125.231.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD3383AB47E
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 23:06:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.64
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787871990; cv=none; b=oOVtnuF8RXxRNYJnoEOPsdQY1/xr3bIvisnpcq8TCTeWGOt5dG0c4KNa59Du7EJ1CLhAj3vG7MfLEQLcuVIGT+adKtiKuzeVczPyVzh/da0462wLLj6TbRP5LxXjT98Jf2TaKXwPaF9JcbdNd0DNfQDCXoGKkhnMYRvmldAhOYw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787871990; c=relaxed/simple;
	bh=K3LyyJpRAekmCCOfNQss+bePvxqy+QslfZ/U7ZRt3ls=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=G2zWWb71zoFKD4ECRD2ULTNHGQpevn6vujj01iDmpWZ346pF7kNh3PliW0XvZala/sd+0HU/Qbag+3KQHBdM9S9XMQA0E15l3T2q0oP4atW/dyGa6zpYaO21cLhXNoXFjJRV278TfzubalN77lHBE6J9KjGhVOGcwBtOZOgkVzE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=74.125.231.64
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa2-f0.google.com with SMTP id 586e51a60fabf-451e8472960so385505fac.1
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 16:06:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787871988; x=1788476788;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Qmf06zEQDbnZobpEwdaBR83TxTTiT72v/4d2EBQCVw4=;
        b=Dl35y83unLFbt2cx8ayefmiFXqCsxh65ankW5xJ7FuZTP/uguw3Z+Cwn3grZy+m7O/
         qI8MaPrI+DkZ8wfUdseMtI8x6hy6r2eeS+derICzjBoj0mb07IuhhVjX6snLvm4rP2h7
         CiRvx6HhIZoqhWfWpgcZIHXyZVXKGgey3hy+TWT0I3G8RQfZ5j/LuSBbeXCKBno/ykRo
         CeU2LEAnd8bmTKSXu4TidTx1BCeNMoLXtahI+FJ4/hb1fczQ50qxL0gKoW3RFF0aA7dx
         B3EZ1lytGAITwnZNsBawokKnLN14NNCp1aS1yj3r84JlWDV2+PTY3MYHExUwlxYLooJV
         U8JQ==
X-Forwarded-Encrypted: i=1; AHgh+RpxdX1uvaCe1z01ShMO/TIdT4AaO2uKnN7SXWhos9M8Q4NL78uGW+9Sk/IL9VMX9j5pbl7/bIOkOqk=@vger.kernel.org
X-Gm-Message-State: AFuF++kQBDNfyQdQMx/XBBBB4R5mEdumKJSfaSWYu/Dv2b/6f9a2SMz0
	tUmqpEIC0hzPJqE4JLyAZR7f+X4IHlUS3xNg27a42sIxZM8Taixd8yqqAlJ5IrUoX3sUFfEKQnn
	FknQnO1nAyCModp5oPeAZYPo2hB/Zgy5NX5/xiPSkXZKTwbUDxkDFGroN3FE=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:1c0e:b0:486:8a11:6e8b with SMTP id
 5614622812f47-4b397f9f538mr3445107b6e.2.1787871987840; Thu, 27 Aug 2026
 16:06:27 -0700 (PDT)
Date: Thu, 27 Aug 2026 16:06:27 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a90c2f3.4d659fcc.734b4.0017.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nrthreads
From: syzbot <syzbot+86a9d43d89b86def6d59@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    502d45774af0 Merge tag 'clk-for-linus' of git://git.kernel..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=11d58d49580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c2d3e2a7997c1d5c
dashboard link: https://syzkaller.appspot.com/bug?extid=86a9d43d89b86def6d59
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/13c40240edf7/disk-502d4577.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/ccf7e87c89cc/vmlinux-502d4577.xz
kernel image: https://storage.googleapis.com/syzbot-assets/9feb3a41684b/bzImage-502d4577.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+86a9d43d89b86def6d59@syzkaller.appspotmail.com

INFO: task syz.5.1942:10848 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.5.1942      state:D stack:27656 pid:10848 tgid:10847 ppid:8546   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5520 [inline]
 __schedule+0x1259/0x6920 kernel/sched/core.c:7270
 __schedule_loop kernel/sched/core.c:7347 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7362
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7419
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xcbf/0x1bc0 kernel/locking/mutex.c:821
 nfsd_nrthreads+0x57/0xd0 fs/nfsd/nfssvc.c:252
 write_threads+0x34a/0x600 fs/nfsd/nfsctl.c:445
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:114
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f27b1d9e0d9
RSP: 002b:00007f27b2bd1028 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f27b2025fa0 RCX: 00007f27b1d9e0d9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000003
RBP: 00007f27b1e35024 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f27b2026038 R14: 00007f27b2025fa0 R15: 00007fffbfec4448
 </TASK>
INFO: task syz.5.1942:10849 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.5.1942      state:D stack:28728 pid:10849 tgid:10847 ppid:8546   task_flags:0x400040 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5520 [inline]
 __schedule+0x1259/0x6920 kernel/sched/core.c:7270
 __schedule_loop kernel/sched/core.c:7347 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7362
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7419
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xcbf/0x1bc0 kernel/locking/mutex.c:821
 fdget_pos+0x2aa/0x380 fs/file.c:1259
 class_fd_pos_constructor include/linux/file.h:85 [inline]
 ksys_read+0x71/0x250 fs/read_write.c:707
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f27b1d9e0d9
RSP: 002b:00007f27b2bb0028 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: ffffffffffffffda RBX: 00007f27b2026090 RCX: 00007f27b1d9e0d9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000003
RBP: 00007f27b1e35024 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f27b2026128 R14: 00007f27b2026090 R15: 00007fffbfec4448
 </TASK>

Showing all locks held in the system:
locks held by khungtaskd/31: 1, last CPU#0:
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:309 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:849 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6793
locks held by getty/5352: 2, on CPU#0:
 #0: ffff8880338b20a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc9000321e2e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
locks held by syz.4.1396/9282: 3, on CPU#1:
 #0: ffff888020b775f0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
 #1: ffff88807db82460 (sb_writers#22){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #2: ffffffff8f284440 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:867
locks held by syz.5.1942/10848: 3, on CPU#1:
 #0: ffff88807562deb0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
 #1: ffff888040656460 (sb_writers#22){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #2: ffffffff8f284440 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nrthreads+0x57/0xd0 fs/nfsd/nfssvc.c:252
locks held by syz.5.1942/10849: 1, on CPU#0:
 #0: ffff88807562deb0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
locks held by kworker/u8:14/13269: 4, last CPU#0:
 #0: ffff88801f3d2940 ((wq_completion)iou_exit){+.+.}-{0:0}, at: process_one_work+0x1466/0x1b10 kernel/workqueue.c:3362
 #1: ffffc9000611fd08 ((work_completion)(&ctx->exit_work)){+.+.}-{0:0}, at: process_one_work+0xa2c/0x1b10 kernel/workqueue.c:3363
 #2: ffff88807f4d40a0 (&ctx->uring_lock){+.+.}-{4:4}, at: class_mutex_constructor include/linux/mutex.h:253 [inline]
 #2: ffff88807f4d40a0 (&ctx->uring_lock){+.+.}-{4:4}, at: io_req_caches_free io_uring/io_uring.c:2150 [inline]
 #2: ffff88807f4d40a0 (&ctx->uring_lock){+.+.}-{4:4}, at: io_ring_exit_work+0x422/0xd59 io_uring/io_uring.c:2354
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:309 [inline]
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:849 [inline]
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: class_rcu_constructor include/linux/rcupdate.h:1216 [inline]
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: unwind_next_frame+0xbd/0x2090 arch/x86/kernel/unwind_orc.c:495
locks held by kworker/u8:22/14261: 2, on CPU#1:
 #0: ffff88801c094140 ((wq_completion)events_unbound){+.+.}-{0:0}, at: process_one_work+0x1466/0x1b10 kernel/workqueue.c:3362
 #1: ffffc90006c9fd08 ((reaper_work).work){+.+.}-{0:0}, at: process_one_work+0xa2c/0x1b10 kernel/workqueue.c:3363
locks held by syz.0.3240/15025: 3, on CPU#1:
 #0: ffff8880756840f0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
 #1: ffff888037bb8460 (sb_writers#10){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #2: ffff888056933080 (&of->mutex){+.+.}-{4:4}, at: kernfs_fop_write_iter+0x2c2/0x5f0 fs/kernfs/file.c:336
locks held by syz.0.3240/15030: 1, on CPU#1:
 #0: ffff8880756840f0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x2aa/0x380 fs/file.c:1259
locks held by syz-executor/15160: 4, last CPU#0:
 #0: ffffffff8ef3cab0 (dup_mmap_sem){++++}-{0:0}, at: dup_mm kernel/fork.c:1542 [inline]
 #0: ffffffff8ef3cab0 (dup_mmap_sem){++++}-{0:0}, at: copy_mm kernel/fork.c:1595 [inline]
 #0: ffffffff8ef3cab0 (dup_mmap_sem){++++}-{0:0}, at: copy_process+0x4815/0x8370 kernel/fork.c:2307
 #1: ffff8880504e1d38 (&mm->mmap_lock){++++}-{4:4}, at: mmap_write_lock_killable include/linux/mmap_lock.h:562 [inline]
 #1: ffff8880504e1d38 (&mm->mmap_lock){++++}-{4:4}, at: dup_mmap+0x127/0x2370 mm/mmap.c:1716
 #2: ffff8880339829f8 (&mm->mmap_lock/1){+.+.}-{4:4}, at: mmap_write_lock_nested include/linux/mmap_lock.h:552 [inline]
 #2: ffff8880339829f8 (&mm->mmap_lock/1){+.+.}-{4:4}, at: dup_mmap+0x1c9/0x2370 mm/mmap.c:1723
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:309 [inline]
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:849 [inline]
 #3: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: __pte_offset_map+0x2f/0x310 mm/pgtable-generic.c:290
locks held by syz.4.3499/15896: 1, last CPU#1:
 #0: ffff88803306aac8 (&pcm->open_mutex){+.+.}-{4:4}, at: snd_pcm_oss_release+0xfb/0x300 sound/core/oss/pcm_oss.c:2589

=============================================

NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 31 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
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
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 15832 Comm: syz.1.3471 Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 08/05/2026
RIP: 0010:__sanitizer_cov_trace_pc+0x6b/0x70 kernel/kcov.c:231
Code: 82 08 17 00 00 83 f8 02 75 20 48 8b 8a 10 17 00 00 8b 92 0c 17 00 00 48 8b 01 48 83 c0 01 48 39 d0 73 07 48 89 01 48 89 34 c1 <e9> 40 e1 c4 09 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3
RSP: 0018:ffffc90004e378f0 EFLAGS: 00000046
RAX: 0000000000080000 RBX: ffff88802d38a2bc RCX: ffffc9001b780000
RDX: 0000000000080000 RSI: ffffffff820ec036 RDI: ffff88805a58cb00
RBP: 0000000000000001 R08: 0000000000000007 R09: 0000000000000000
R10: 00000000000002ac R11: 0000000000000001 R12: 0000000000000000
R13: ffffc90004e379a8 R14: 0000000000000000 R15: ffff88801d2bc000
FS:  00007fb805db56c0(0000) GS:ffff888123c6d000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000001b34422ff8 CR3: 00000000297f8000 CR4: 00000000003526f0
DR0: 0000000000000000 DR1: 000000000000000a DR2: 0000000000000000
DR3: 00000000c0f00480 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 <TASK>
 rb_reserve_next_event kernel/trace/ring_buffer.c:4988 [inline]
 ring_buffer_lock_reserve+0x4b6/0x1220 kernel/trace/ring_buffer.c:5039
 __trace_buffer_lock_reserve kernel/trace/trace.h:1676 [inline]
 trace_event_buffer_lock_reserve+0x123/0x6f0 kernel/trace/trace.c:1924
 trace_event_buffer_reserve+0x1f9/0x350 kernel/trace/trace_events.c:715
 do_trace_event_raw_event_msr_trace_class arch/x86/include/asm/msr-trace.h:21 [inline]
 trace_event_raw_event_msr_trace_class+0xe8/0x270 arch/x86/include/asm/msr-trace.h:21
 __do_trace_write_msr arch/x86/include/asm/msr-trace.h:45 [inline]
 trace_write_msr+0x160/0x1f0 arch/x86/include/asm/msr-trace.h:45
 apic_write arch/x86/include/asm/apic.h:405 [inline]
 lapic_next_event+0x10/0x20 arch/x86/kernel/apic/apic.c:418
 clockevents_program_event+0x375/0x820 kernel/time/clockevents.c:372
 tick_program_event+0xa9/0x140 kernel/time/tick-oneshot.c:48
 hrtimer_rearm_event kernel/time/hrtimer.c:710 [inline]
 hrtimer_rearm kernel/time/hrtimer.c:2169 [inline]
 __hrtimer_rearm_deferred+0x234/0x7b0 kernel/time/hrtimer.c:2189
 hrtimer_rearm_deferred_tif include/linux/hrtimer_rearm.h:58 [inline]
 hrtimer_rearm_deferred include/linux/hrtimer_rearm.h:67 [inline]
 irqentry_exit_to_kernel_mode_after_preempt include/linux/irq-entry-common.h:505 [inline]
 irqentry_exit_to_kernel_mode include/linux/irq-entry-common.h:542 [inline]
 irqentry_exit+0x5f3/0xa10 kernel/entry/common.c:167
 asm_sysvec_apic_timer_interrupt+0x1a/0x20 arch/x86/include/asm/idtentry.h:674
RIP: 0010:__raw_spin_unlock_irq include/linux/spinlock_api_smp.h:220 [inline]
RIP: 0010:_raw_spin_unlock_irq+0x29/0x50 kernel/locking/spinlock.c:229
Code: 90 f3 0f 1e fa 53 48 8b 74 24 08 48 89 fb 48 83 c7 18 e8 ca a7 16 f6 48 89 df e8 e2 fd 16 f6 e8 cd b7 43 f6 fb bf 01 00 00 00 <e8> e2 07 06 f6 65 48 83 3d 71 c6 ba 08 00 74 06 5b c3 cc cc cc cc
RSP: 0018:ffffc90004e37e40 EFLAGS: 00000206
RAX: 0000000000050741 RBX: ffff88802da61bc0 RCX: 0000000000000000
RDX: 0000000000000001 RSI: ffffffff8e3eb0b9 RDI: 0000000000000001
RBP: ffff88805a58d498 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff88805a58cb00
R13: 0000000100000000 R14: 0000000000000007 R15: 0000000000000000
 spin_unlock_irq include/linux/spinlock.h:413 [inline]
 __set_current_blocked kernel/signal.c:3227 [inline]
 set_current_blocked+0xdd/0x120 kernel/signal.c:3211
 __do_sys_rt_sigreturn+0x1a2/0x2c0 arch/x86/kernel/signal_64.c:263
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fb804f3f459
Code: 11 06 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 90 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 c7 c0 0f 00 00 00 0f 05 <0f> 1f 80 00 00 00 00 48 81 ec 48 01 00 00 49 89 d0 64 48 8b 0c 25
RSP: 002b:00007fb805db4340 EFLAGS: 00000206 ORIG_RAX: 000000000000000f
RAX: ffffffffffffffda RBX: 00007fb805225fa0 RCX: 00007fb804f3f459
RDX: 00007fb805db4340 RSI: 00007fb805db4470 RDI: 0000000000000021
RBP: 00007fb805035024 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000000
R13: 00007fb805226038 R14: 00007fb805225fa0 R15: 00007ffee7eee2b8
 </TASK>


---
This report is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this issue. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

If the report is already addressed, let syzbot know by replying with:
#syz fix: exact-commit-title

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
