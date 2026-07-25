Received: from mail-oi1-f206.google.com (mail-oi1-f206.google.com [209.85.167.206])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF3FA84039
	for <linux-nfs@vger.kernel.org>; Sat, 25 Jul 2026 06:32:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.206
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784961155; cv=none; b=eMbzYQ+m23CO5mLn+g2hQ4mMA1fZ2dUcZH/6cYAJArYtaOnvJPcsJw2BqDY2jQjBytgoHg2dimiS+KFN1tj55XTg3e5Ri9cLflqSRqJL9x1pKpKLFJwbkXhYrSKiBGPXRiQLwLrmBusqmyKe+wbujijgSPVdG6Jv+5O7WtxGcak=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784961155; c=relaxed/simple;
	bh=z0h56ayJRQlpthqPemjDgt2JDVWE/kMorP4JWTKdo3M=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=fvYvqlxmB2vXKvrXTke747qpRofkUvjUZasDr89w0PQXRpb+rPvyC5gvfHwwrd73icqrRLkgWyy716o6HFyMySGXwMFWcIi7vEZyO3+9WucSjCEiOFzX5bNJUxXoG5XPWZm78JDBfQ7+VLn3ngfsaY9n+Feo/auLZF8ys6Ke6Qg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.206
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f206.google.com with SMTP id 5614622812f47-49f3a97f1caso668309b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jul 2026 23:32:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784961152; x=1785565952;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BmtLcb1Jb0zXchr33eFn/PfmOERM2pClDijLX+t46BA=;
        b=Be6aJDVT5MQX5U+NxbNq/hNaH+8nx390e3EUawSvawdW4lH6knmhRIr7pcElSlqqob
         WDxJl21yMN9WH59a+PAxMiSSNaoC4lWARE6qXsFaMsOfXOs1DI8UY/P9OuUsKU1llcnw
         /Q3p/i9PMTJUDRaTwH6zmNzo1VPgAdZpqPktYjvNRZGzwDsDNCuj+8Ls9jI7343cyeWI
         gPIeWqFLQPpzlZmJ1x1tXL0zKi26BQabIhvpcb9UrI+m/i5dMHB3A0v2JjDnaSwOuoOd
         a2qhkSfk+3DQB7L6LBrgAl9/maKV8tTi5ynqNTF0nD1ON23+uwDpoPPy7OzIcAAWEND1
         8klA==
X-Forwarded-Encrypted: i=1; AHgh+Rqqy70WgLQxyUzOLXE5KFnu7JWL7yGTho+vYm19iXI2gfey3jsfxpRRcqa5F56Yfvse8e/+clDdJrE=@vger.kernel.org
X-Gm-Message-State: AOJu0YzoxsWWnQnXF0k9SAYcTK/Fiq9zSdx+dvwHuwKULhM8vWinGICk
	JM8V1RG/zcLB5Jgl4pPz0U2UO08HeKdw7cAoAH23Zc1LIAETTLxszZFQJVL9mV9by2ufnWpKyY4
	owdugkzpPTt8JEMA4P8UL4YQuUurmV1ZiqjQOr5K2zPQLC+t/yLHLfGLFiXo=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:144a:b0:4a4:933:dc0f with SMTP id
 5614622812f47-4ab6a34ee6amr1284130b6e.43.1784961152519; Fri, 24 Jul 2026
 23:32:32 -0700 (PDT)
Date: Fri, 24 Jul 2026 23:32:32 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a645880.70955b6c.323240.0015.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_svc_export_set_reqs_doit
From: syzbot <syzbot+4fb3e2ffc13bcbb4e273@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    248951ddc14d Merge tag 'hwmon-for-v7.2-rc5' of git://git.k..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=15d86ab9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d69870d5e052935f
dashboard link: https://syzkaller.appspot.com/bug?extid=4fb3e2ffc13bcbb4e273
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/0383edf8921d/disk-248951dd.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/1040468b7c32/vmlinux-248951dd.xz
kernel image: https://storage.googleapis.com/syzbot-assets/5b4bed77f79b/bzImage-248951dd.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+4fb3e2ffc13bcbb4e273@syzkaller.appspotmail.com

INFO: task syz.1.1268:11597 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.1.1268      state:D
 stack:26776 pid:11597 tgid:11596 ppid:5611   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 nfsd_nl_svc_export_set_reqs_doit+0x8a/0x2f0 fs/nfsd/export.c:1057
 genl_family_rcv_msg_doit+0x214/0x300 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x560/0x800 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x159/0x420 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x585/0x850 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x8b0/0xda0 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec net/socket.c:775 [inline]
 __sock_sendmsg net/socket.c:790 [inline]
 ____sys_sendmsg+0xa4d/0xbe0 net/socket.c:2684
 ___sys_sendmsg+0x190/0x1e0 net/socket.c:2738
 __sys_sendmsg+0x160/0x210 net/socket.c:2770
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f319e19de99
RSP: 002b:00007f319f150028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007f319e425fa0 RCX: 00007f319e19de99
RDX: 0000000024000004 RSI: 0000200000000640 RDI: 0000000000000009
RBP: 00007f319e233eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f319e426038 R14: 00007f319e425fa0 R15: 00007ffe6c6c8f38
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/30:
 #0: ffffffff8ebe6180 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8ebe6180 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8ebe6180 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6775
2 locks held by getty/5368:
 #0: ffff8880380af0a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
1 lock held by udevd/5628:
 #0: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested kernel/sched/core.c:675 [inline]
 #0: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested+0x88/0x140 kernel/sched/core.c:659
6 locks held by kworker/1:6/5736:
 #0: ffff8880236b4d40 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_one_work+0x12b1/0x1940 kernel/workqueue.c:3297
 #1: ffffc9000201fd08 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_one_work+0x988/0x1940 kernel/workqueue.c:3298
 #2: ffff88802b9611d8 (&dev->mutex){....}-{4:4}, at: device_lock include/linux/device.h:1102 [inline]
 #2: ffff88802b9611d8 (&dev->mutex){....}-{4:4}, at: hub_event+0x1c0/0x4a60 drivers/usb/core/hub.c:5899
 #3: ffff88802b966568 (&port_dev->status_lock){+.+.}-{4:4}, at: usb_lock_port drivers/usb/core/hub.c:3252 [inline]
 #3: ffff88802b966568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_connect drivers/usb/core/hub.c:5464 [inline]
 #3: ffff88802b966568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_connect_change drivers/usb/core/hub.c:5707 [inline]
 #3: ffff88802b966568 (&port_dev->status_lock){+.+.}-{4:4}, at: port_event drivers/usb/core/hub.c:5871 [inline]
 #3: ffff88802b966568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_event+0x2b25/0x4a60 drivers/usb/core/hub.c:5953
 #4: ffff88802b8fe360 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_connect drivers/usb/core/hub.c:5465 [inline]
 #4: ffff88802b8fe360 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_connect_change drivers/usb/core/hub.c:5707 [inline]
 #4: ffff88802b8fe360 (hcd->address0_mutex){+.+.}-{4:4}, at: port_event drivers/usb/core/hub.c:5871 [inline]
 #4: ffff88802b8fe360 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_event+0x2b4e/0x4a60 drivers/usb/core/hub.c:5953
 #5: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested kernel/sched/core.c:675 [inline]
 #5: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested+0x88/0x140 kernel/sched/core.c:659
3 locks held by kworker/1:7/5802:
 #0: ffff8880236b4d40 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_one_work+0x12b1/0x1940 kernel/workqueue.c:3297
 #1: ffffc90004b7fd08 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_one_work+0x988/0x1940 kernel/workqueue.c:3298
 #2: ffff8880b8526298 (&base->lock){-.-.}-{2:2}, at: lock_timer_base+0x124/0x1d0 kernel/time/timer.c:1004
2 locks held by syz.4.1009/10591:
 #0: ffffffff90b4b548 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f0703a0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0xd5/0x1a80 fs/nfsd/nfsctl.c:1964
3 locks held by kworker/1:5/11238:
 #0: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested kernel/sched/core.c:675 [inline]
 #0: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested+0x88/0x140 kernel/sched/core.c:659
 #1: ffff8880b8524568 (psi_seq){-.-.}-{0:0}, at: psi_sched_switch kernel/sched/stats.h:218 [inline]
 #1: ffff8880b8524568 (psi_seq){-.-.}-{0:0}, at: __schedule+0x2e8e/0x6730 kernel/sched/core.c:7228
 #2: ffffffff8eeaf7b8 (kernfs_notify_lock){....}-{3:3}, at: spin_lock_irq include/linux/spinlock.h:372 [inline]
 #2: ffffffff8eeaf7b8 (kernfs_notify_lock){....}-{3:3}, at: kernfs_notify_workfn+0x7f/0x5f0 fs/kernfs/file.c:912
2 locks held by syz.1.1268/11597:
 #0: ffffffff90b4b548 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f0703a0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_svc_export_set_reqs_doit+0x8a/0x2f0 fs/nfsd/export.c:1057
4 locks held by syz.6.1784/13444:

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 30 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/10/2026
Call Trace:
 <TASK>
 __dump_stack lib/dump_stack.c:94 [inline]
 dump_stack_lvl+0x100/0x190 lib/dump_stack.c:120
 nmi_cpu_backtrace.cold+0x12d/0x151 lib/nmi_backtrace.c:122
 nmi_trigger_cpumask_backtrace+0x21c/0x2a0 lib/nmi_backtrace.c:65
 trigger_all_cpu_backtrace include/linux/nmi.h:162 [inline]
 __sys_info lib/sys_info.c:157 [inline]
 sys_info+0x141/0x190 lib/sys_info.c:165
 check_hung_uninterruptible_tasks kernel/hung_task.c:353 [inline]
 watchdog+0xcb1/0x1030 kernel/hung_task.c:561
 kthread+0x370/0x450 kernel/kthread.c:436
 ret_from_fork+0x72b/0xd50 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 0 Comm: swapper/0 Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/10/2026
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: e6 8c 02 c3 cc cc cc cc 0f 1f 00 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 0f 00 2d c3 99 11 00 fb f4 <e9> bc 48 03 00 66 2e 0f 1f 84 00 00 00 00 00 66 90 90 90 90 90 90
RSP: 0018:ffffffff8e807e10 EFLAGS: 00000242
RAX: 0000000002d8afe3 RBX: ffffffff8e891480 RCX: ffffffff8bba02d5
RDX: 0000000000000000 RSI: ffffffff8e1a4b71 RDI: ffffffff8c401480
RBP: fffffbfff1d12290 R08: 0000000000000001 R09: ffffed101708678d
R10: ffff8880b8433c6b R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 1ffffffff1d00fc6 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888123de6000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000001b33309ff8 CR3: 0000000074c0d000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 arch_safe_halt arch/x86/include/asm/paravirt.h:62 [inline]
 default_idle+0x9/0x10 arch/x86/kernel/process.c:768
 default_idle_call+0x6c/0xb0 kernel/sched/idle.c:122
 cpuidle_idle_call kernel/sched/idle.c:199 [inline]
 do_idle+0x3a7/0x5b0 kernel/sched/idle.c:355
 cpu_startup_entry+0x4f/0x60 kernel/sched/idle.c:454
 rest_init+0x251/0x260 init/main.c:717
 start_kernel+0x48e/0x490 init/main.c:1175
 x86_64_start_reservations+0x24/0x30 arch/x86/kernel/head64.c:310
 x86_64_start_kernel+0x12b/0x130 arch/x86/kernel/head64.c:291
 common_startup_64+0x13e/0x158
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
