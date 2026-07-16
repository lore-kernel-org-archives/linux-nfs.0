Received: from mail-oi1-f208.google.com (mail-oi1-f208.google.com [209.85.167.208])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4B0B433BB2
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 17:02:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.208
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784221347; cv=none; b=qi6NVMU9ga0jyfRXHo4RgdiCTsrhClP4peB6DY3cHC2KQCx9levBuQKVP0OALJ3XsjrwEDDg0Ly4qSLNTEOJNJRMzVDkLAm2d33+Ld3hZVtCO9IL8anyM2i9DLYx9C2Sru7xGg0+rrsm5DAyA5vdz+WHG7NP0nXrVsfIuiYwDU4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784221347; c=relaxed/simple;
	bh=fQIh8Cg2i7uTyNia4XwIchjk4Cn+UEBv39jfzUVCH5o=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=vCzDHxlYkR2E1UJnjPKX3Q0TYXbpRBVrkwdK36IKgN3amkHqlB55+TIa/brkOkve2vlzq0bAKJVeVgYVUUP6Spw2PvUReoi1OW1koxev6nsuaH8LEqh/dbZqtaA77ebD88GbMqoqNmOmFmewXqk/JSJTyx3+q/H09Vsh3Et8VEE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.208
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f208.google.com with SMTP id 5614622812f47-4a42c572645so5199060b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 10:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784221345; x=1784826145;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=75VBJs4QxGQx1dGiUDLTe6W9MURo1vx7Yx9Zdni6vYA=;
        b=WtkGGlyNRoaHG4g76yalydPH0oEw/XBj4LuyA73F8oNTP6yJ26Acv+wr43KYN6nyjK
         QH06Y8ec3IdzrrZgu2a8lWEEXiKTEpHAQb2g/PPhW6WIhNv7QtvDtTQQop8q069t7lct
         vEWtmBmsBkduPSZD32rn++1lmhYY47p6TaohaAAkcxZsjqYJtwEcjCMQ0AiXYZDUvpRp
         XuYbzSHg9zUwltivTH2Pgn+NtmWJBiqW49kcO7AaA0/Us3RyP1161s8Nx71/q64NURLV
         TGxffyp7ypY9MlVzuppBdiiBWkbHQtq+7OgMccFr0WWbaoAlQgCsWrkr6u0VT4+tfmmV
         3FcA==
X-Forwarded-Encrypted: i=1; AHgh+RqwNnXIBWvX1OTIOoxyP5hx80O9sm+JaLkexFE6rY45gSVY/yHOeljImS2KPxywSAPrNdqkuoFOIjI=@vger.kernel.org
X-Gm-Message-State: AOJu0YxnLCnOVUBwpd/JVepXiAMPz/YDFgoQPc2Kq+sQt3fOE401t7K8
	au/C6+skG6i+qd6Q++CQ/1Bke8hvKm5Ds878lvCSB3Vb11d6i/af4uhGbuY7kZ9l8IjPDs9jMvR
	D+Sx5YiK0nX2x5Mp3AL81p1RuVYpfj04kkbaHzNvtUTI4eJz06thFbRqFieo=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:6c8b:b0:4a3:ec8e:2052 with SMTP id
 5614622812f47-4a4c85c0c93mr350489b6e.8.1784221344575; Thu, 16 Jul 2026
 10:02:24 -0700 (PDT)
Date: Thu, 16 Jul 2026 10:02:24 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a590ea0.ccd3b023.4fae3.0000.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_cache_flush_doit
From: syzbot <syzbot+c7eae0eb80858a2dba0f@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    44696aa3a489 Merge tag 'input-for-v7.2-rc2' of git://git.k..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=17efd0b9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5c4196ba0e33631d
dashboard link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/14807749cfb0/disk-44696aa3.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/7f966ce4e5e9/vmlinux-44696aa3.xz
kernel image: https://storage.googleapis.com/syzbot-assets/c821bcd9ea8c/bzImage-44696aa3.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+c7eae0eb80858a2dba0f@syzkaller.appspotmail.com

INFO: task syz.3.4381:22405 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.3.4381      state:D stack:27200 pid:22405 tgid:22404 ppid:17244  task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_cache_flush_doit+0xb5/0x1b0 fs/nfsd/nfsctl.c:2236
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 ____sys_sendmsg+0x54e/0x850 net/socket.c:2684
 ___sys_sendmsg+0x2a5/0x360 net/socket.c:2738
 __sys_sendmsg net/socket.c:2770 [inline]
 __do_sys_sendmsg net/socket.c:2775 [inline]
 __se_sys_sendmsg net/socket.c:2773 [inline]
 __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2773
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f5cbdf9de59
RSP: 002b:00007f5cbef3b028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007f5cbe225fa0 RCX: 00007f5cbdf9de59
RDX: 0000000004000080 RSI: 0000200000000100 RDI: 0000000000000003
RBP: 00007f5cbe033e6f R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f5cbe226038 R14: 00007f5cbe225fa0 R15: 00007ffd5ffd5b58
 </TASK>

Showing all locks held in the system:
6 locks held by kworker/1:1/29:
 #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc90000a57c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc90000a57c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff888029d3c1d8 (&dev->mutex){....}-{4:4}, at: device_lock include/linux/device.h:1102 [inline]
 #2: ffff888029d3c1d8 (&dev->mutex){....}-{4:4}, at: hub_event+0x184/0x4d30 drivers/usb/core/hub.c:5899
 #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: usb_lock_port drivers/usb/core/hub.c:3252 [inline]
 #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_connect drivers/usb/core/hub.c:5464 [inline]
 #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_connect_change drivers/usb/core/hub.c:5707 [inline]
 #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: port_event drivers/usb/core/hub.c:5871 [inline]
 #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_event+0x20a1/0x4d30 drivers/usb/core/hub.c:5953
 #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_connect drivers/usb/core/hub.c:5465 [inline]
 #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_connect_change drivers/usb/core/hub.c:5707 [inline]
 #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: port_event drivers/usb/core/hub.c:5871 [inline]
 #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_event+0x20c9/0x4d30 drivers/usb/core/hub.c:5953
 #5: ffffffff8f8daaa8 (ehci_cf_port_reset_rwsem){.+.+}-{4:4}, at: hub_port_reset+0x14d/0x17e0 drivers/usb/core/hub.c:3067
1 lock held by khungtaskd/32:
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
1 lock held by dhcpcd/5281:
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/core/rtnetlink.c:80 [inline]
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock net/core/rtnetlink.c:341 [inline]
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a3/0x1bd0 net/core/rtnetlink.c:4158
2 locks held by getty/5371:
 #0: ffff8880359000a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x45a/0x1360 drivers/tty/n_tty.c:2211
3 locks held by kworker/1:6/5771:
 #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc900041efc40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc900041efc40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff8880b8728ea0 (lock#6){..-.}-{3:3}, at: local_lock_acquire include/linux/local_lock_internal.h:46 [inline]
 #2: ffff8880b8728ea0 (lock#6){..-.}-{3:3}, at: kcov_remote_stop+0x69/0x6c0 kernel/kcov.c:1040
2 locks held by syz.1.3757/20367:
 #0: ffffffff9009cd28 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e5e0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
2 locks held by syz.3.4381/22405:
 #0: ffffffff9009cd28 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e5e0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_cache_flush_doit+0xb5/0x1b0 fs/nfsd/nfsctl.c:2236
1 lock held by syz-executor/24167:
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/core/rtnetlink.c:80 [inline]
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock net/core/rtnetlink.c:341 [inline]
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a3/0x1bd0 net/core/rtnetlink.c:4158
1 lock held by syz.5.4972/24470:
2 locks held by syz.5.4972/24471:
 #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: do_ip_setsockopt+0xe95/0x2e30 net/ipv4/ip_sockglue.c:1077
 #1: ffff88803b271c60 (sk_lock-AF_INET){+.+.}-{0:0}, at: do_ip_setsockopt+0x1556/0x2e30 net/ipv4/ip_sockglue.c:1078

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 32 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/10/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 nmi_cpu_backtrace+0x274/0x2d0 lib/nmi_backtrace.c:122
 nmi_trigger_cpumask_backtrace+0x17a/0x380 lib/nmi_backtrace.c:65
 trigger_all_cpu_backtrace include/linux/nmi.h:162 [inline]
 __sys_info lib/sys_info.c:157 [inline]
 sys_info+0x135/0x170 lib/sys_info.c:165
 check_hung_uninterruptible_tasks kernel/hung_task.c:353 [inline]
 watchdog+0xfd7/0x1030 kernel/hung_task.c:561
 kthread+0x388/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 4986 Comm: udevd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/10/2026
RIP: 0010:get_current arch/x86/include/asm/current.h:25 [inline]
RIP: 0010:write_comp_data kernel/kcov.c:245 [inline]
RIP: 0010:__sanitizer_cov_trace_const_cmp4+0x8/0x90 kernel/kcov.c:314
Code: 89 44 11 20 e9 84 cb 49 ff cc 0f 1f 84 00 00 00 00 00 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 48 8b 04 24 <65> 48 8b 15 58 0a a6 11 65 8b 0d 79 0a a6 11 81 e1 00 01 ff 00 74
RSP: 0018:ffffc9000502fcb0 EFLAGS: 00000246
RAX: ffffffff8273d85d RBX: ffffffff8273d78c RCX: ffff88807f523e00
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
RBP: 0000000000000001 R08: ffffffff8273d78c R09: 0000000000000000
R10: 0000000000000000 R11: ffffffff8eb59c60 R12: dffffc0000000000
R13: ffff888026b8bc70 R14: ffff888026b8bc30 R15: ffff888026b8d000
FS:  00007fe18881d880(0000) GS:ffff888124f58000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000200000e4c000 CR3: 0000000029310000 CR4: 0000000000350ef0
Call Trace:
 <TASK>
 kernfs_root+0xed/0x230 fs/kernfs/kernfs-internal.h:77
 kernfs_active fs/kernfs/dir.c:40 [inline]
 kernfs_dir_next_pos fs/kernfs/dir.c:1964 [inline]
 kernfs_fop_readdir+0x647/0x960 fs/kernfs/dir.c:1989
 iterate_dir+0x2e2/0x4d0 fs/readdir.c:110
 __do_sys_getdents64 fs/readdir.c:399 [inline]
 __se_sys_getdents64+0xf1/0x280 fs/readdir.c:384
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fe1880f0d23
Code: 8b 05 d9 00 10 00 64 c7 00 16 00 00 00 31 c0 eb b0 66 0f 1f 44 00 00 b8 ff ff ff 7f 48 39 c2 48 0f 47 d0 b8 d9 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 05 c3 0f 1f 40 00 48 8b 15 a1 00 10 00 f7 d8
RSP: 002b:00007ffc1ee77458 EFLAGS: 00000293 ORIG_RAX: 00000000000000d9
RAX: ffffffffffffffda RBX: 00005652ff7d3a20 RCX: 00007fe1880f0d23
RDX: 0000000000008000 RSI: 00005652ff7d3a50 RDI: 000000000000000d
RBP: 00005652ff7d3a24 R08: 00007fe1881f1ac0 R09: 0000000000000000
R10: 0000000000000003 R11: 0000000000000293 R12: 00005652ff7d3a50
R13: fffffffffffffe68 R14: 0000000000000002 R15: 00007ffc1ee77700
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
