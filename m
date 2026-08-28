Received: from mail-oa2-f11.google.com (mail-oa2-f11.google.com [74.125.231.75])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D68C377EB8
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 07:35:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.75
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787902537; cv=none; b=KW2HzczO8Q0Kp7gCIJMYu1QxLFdHeUOAjQwvKCgR2BfJnoSewJYEKcnyZYjpXESNY4c+dmdEbxBw99cKsiy+GyNHEyLB3GTrrjfCxdx1xI29wl834tO1D14RLzYHpSZEaHSD8qYimNFg5EMy98d2DPqPRnl9/vkgI+8n85jtZMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787902537; c=relaxed/simple;
	bh=MeYXlJ4iAb29w/4b9sV/1OGhhI9fC3/y3eyFPMIZqlI=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=uMgxVtjeGmmkUf8mWJFXUdkligPhJy1chyaSJgJvMqmyVR+SfbPwOcI/fN9EJpnEG4vZ9ngXrOTJGMXeom193aypkNvVlb3vkSdu1k16tECtf3TOd5W5tGtzmNhePs4Rgla6Wz4HVvJCA3xphcjwZ6afABdPrnaTUkjUODt/xrg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=74.125.231.75
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa2-f11.google.com with SMTP id 586e51a60fabf-45e2c1e33e1so332847fac.1
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 00:35:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787902535; x=1788507335;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Sk3tuujaXEUvd3IIg4mG/osQZBwsOzl7/c/kikiHyYI=;
        b=R77JVUzHQ7XqHHV5+I6dewoidqx132Bud09T8xBmNy3ioZlcTaDW42UAqOW2/pnp3h
         uHQkQNY6D2AItmRxYa9OwW8QjB6bHCGf0RyI7SltSmlK2QMIpWpPsuf6VxkH9oMBEFnF
         q22gYmZcICUUwr+JgU5W4QdpgK+DJc4jSRe1b+BGfkhhcHyxWuphOkvt5JDsuPFGEhgj
         A1XRq8Qw30FMLGD9EOnlgbpgKUqYL6pmgNQ9GJ4OSUuYwj47eIVC06rcCFeZji7ABkUM
         cFaCruDYWyOpEO1vcDGhBBJu9MHlNfcvVIyE8OWxiI7dE9V8Ew2USXZmvjl7/0wQvRzU
         LPGQ==
X-Forwarded-Encrypted: i=1; AHgh+RrLFvTiwQWemPIndJyKYvslMDVWUARVXsf2rezxzfFgW1rj4w0mhacVo++UhLYnguBGkHF927tE3P8=@vger.kernel.org
X-Gm-Message-State: AFuF++nG7/KFpHlkCrCpTJ3uGPrZJaaxyiCgc+rLyeW4H9ei3GOa6EH0
	gPinCfdcDA/NeEYJlG35gTYXHWDzu5CoPajmNiuBv8ZaAWTzGeGrFuGH8aYYpISZSBi8FCB/9kw
	158fmBJvl0fJcoVcXwlUE0ZuDnGTXCGQ5y8m9ebBX5maZZBFLSSIwOy0hk2s=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:2017:b0:6b1:5d5e:679d with SMTP id
 006d021491bc7-6b1c679e571mr4354363eaf.28.1787902534866; Fri, 28 Aug 2026
 00:35:34 -0700 (PDT)
Date: Fri, 28 Aug 2026 00:35:34 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a913a46.4d659fcc.734b4.001a.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_unlock_filesystem_doit
From: syzbot <syzbot+0093d3ab8d8eb2fdde82@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    45c13f3f9e3b Merge tag 'hwlock-v7.3' of git://git.kernel.o..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=16068d49580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c4f4455f41cf6a92
dashboard link: https://syzkaller.appspot.com/bug?extid=0093d3ab8d8eb2fdde82
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/82d12e132e96/disk-45c13f3f.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/46f8d07d4673/vmlinux-45c13f3f.xz
kernel image: https://storage.googleapis.com/syzbot-assets/02439192d277/bzImage-45c13f3f.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+0093d3ab8d8eb2fdde82@syzkaller.appspotmail.com

INFO: task syz.2.1768:11730 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.2.1768      state:D stack:28144 pid:11730 tgid:11729 ppid:5602   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5520 [inline]
 __schedule+0x1259/0x6920 kernel/sched/core.c:7270
 __schedule_loop kernel/sched/core.c:7347 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7362
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7419
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xcbf/0x1bc0 kernel/locking/mutex.c:821
 nfsd_nl_unlock_filesystem_doit+0x203/0x410 fs/nfsd/nfsctl.c:2677
 genl_family_rcv_msg_doit+0x214/0x300 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x560/0x800 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x159/0x420 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x585/0x850 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x8b0/0xda0 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec net/socket.c:800 [inline]
 __sock_sendmsg net/socket.c:815 [inline]
 ____sys_sendmsg+0xa4d/0xbe0 net/socket.c:2713
 ___sys_sendmsg+0x190/0x1e0 net/socket.c:2767
 __sys_sendmsg+0x160/0x210 net/socket.c:2799
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f88cbb9e0d9
RSP: 002b:00007f88cca9f028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007f88cbe25fa0 RCX: 00007f88cbb9e0d9
RDX: 0000000004000080 RSI: 0000200000000100 RDI: 0000000000000003
RBP: 00007f88cbc35024 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f88cbe26038 R14: 00007f88cbe25fa0 R15: 00007ffd44e926f8
 </TASK>

Showing all locks held in the system:
locks held by khungtaskd/32: 1, last CPU#0:
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:309 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:849 [inline]
 #0: ffffffff8edec060 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6793
locks held by udevd/4965: 1, on CPU#0:
 #0: ffff88801d2bf180 (&root->kernfs_rwsem){++++}-{4:4}, at: kernfs_dop_revalidate+0xa5/0x7e0 fs/kernfs/dir.c:1217
locks held by getty/5352: 2, on CPU#1:
 #0: ffff8880380ee0a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc9000322b2e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
locks held by kworker/0:6/5706: 3, on CPU#0:
 #0: ffff88801c057140 ((wq_completion)events){+.+.}-{0:0}, at: process_one_work+0x1466/0x1b10 kernel/workqueue.c:3362
 #1: ffffc90004c37d08 (deferred_process_work){+.+.}-{0:0}, at: process_one_work+0xa2c/0x1b10 kernel/workqueue.c:3363
 #2: ffffffff90cc9840 (rtnl_mutex){+.+.}-{4:4}, at: switchdev_deferred_process_work+0xe/0x20 net/switchdev/switchdev.c:104
locks held by syz.0.1424/10896: 2, on CPU#0:
 #0: ffffffff90d78be8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f284440 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0x1a3/0x1dc0 fs/nfsd/nfsctl.c:2057
locks held by syz.2.1768/11730: 2, on CPU#1:
 #0: ffffffff90d78be8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f284440 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_unlock_filesystem_doit+0x203/0x410 fs/nfsd/nfsctl.c:2677
locks held by syz.1.2261/12930: 2, on CPU#1:
 #0: ffff888055b400e8 (&type->s_umount_key#75){+.+.}-{4:4}, at: __super_lock fs/super.c:60 [inline]
 #0: ffff888055b400e8 (&type->s_umount_key#75){+.+.}-{4:4}, at: __super_lock_excl fs/super.c:75 [inline]
 #0: ffff888055b400e8 (&type->s_umount_key#75){+.+.}-{4:4}, at: deactivate_super fs/super.c:631 [inline]
 #0: ffff888055b400e8 (&type->s_umount_key#75){+.+.}-{4:4}, at: deactivate_super+0xe2/0x110 fs/super.c:628
 #1: ffffffff8f284440 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_shutdown_threads+0x5b/0xf0 fs/nfsd/nfssvc.c:582
locks held by syz-executor/13344: 1, last CPU#0:
 #0: ffffffff8ef90080 (pcpu_alloc_mutex){+.+.}-{4:4}, at: pcpu_alloc_noprof+0xfa8/0x1e50 mm/percpu.c:1796
locks held by syz.5.3369/16148: 4, last CPU#0:
 #0: ffff88804d75d1b0 (&tty->legacy_mutex){+.+.}-{4:4}, at: tty_init_dev.part.0+0x39/0x470 drivers/tty/tty_io.c:1379
 #1: ffff888031c242a8 (&port->mutex){+.+.}-{4:4}, at: class_mutex_constructor include/linux/mutex.h:253 [inline]
 #1: ffff888031c242a8 (&port->mutex){+.+.}-{4:4}, at: tty_port_open+0x8e/0x1f0 drivers/tty/tty_port.c:764
 #2: ffff888027933d18 (&serial->disc_mutex){+.+.}-{4:4}, at: serial_port_activate+0x52/0x290 drivers/usb/serial/usb-serial.c:258
 #3: ffff8880887f8460 (&tdev->td_open_close_lock){+.+.}-{4:4}, at: ti_open+0xb4/0xce0 drivers/usb/serial/ti_usb_3410_5052.c:653
locks held by syz.3.3374/16166: 4, last CPU#0:
 #0: ffffffff90c998a0 (br_ioctl_mutex){+.+.}-{4:4}, at: br_ioctl_call+0x34/0xa0 net/socket.c:1296
 #1: ffffffff90cc9840 (rtnl_mutex){+.+.}-{4:4}, at: br_ioctl_stub+0x2af/0x4d0 net/bridge/br_ioctl.c:418
 #2: ffff88801d2bf180 (&root->kernfs_rwsem){++++}-{4:4}, at: kernfs_add_one+0x38/0xaa0 fs/kernfs/dir.c:825
 #3: ffff88801d2bf210 (&root->kernfs_iattr_rwsem){++++}-{4:4}, at: kernfs_link_sibling+0x555/0x850 fs/kernfs/dir.c:411
locks held by syz.6.3376/16171: 1, last CPU#0:
 #0: ffff88802cf9f470 (&u->iolock){+.+.}-{4:4}, at: __unix_dgram_recvmsg+0x255/0xc30 net/unix/af_unix.c:2587

=============================================

NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 32 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
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
