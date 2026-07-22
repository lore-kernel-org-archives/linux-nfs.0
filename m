Received: from mail-ot1-f78.google.com (mail-ot1-f78.google.com [209.85.210.78])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8D3235C19B
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 19:43:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.78
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784749415; cv=none; b=OW3viBBysxaX2KYSBYG2yqI3tc5TBOvQIfWt2cE9wekw1I6KnoGaor2I8LU0YAMr51O/LFMeX6LgUTGld/2cwAn1DPTmtg9Ydfvsfp9mGznUP8qviDSFwzoDcE+OKyW4FkJ+bfiD42uwhFKG4LA7bWV2yEf0fW8j/ffQyJHweYw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784749415; c=relaxed/simple;
	bh=ZL2OvMdC4vDDHLWTnvfkj7h4nsQiZfEUVmQ8nW7fNks=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=pRUN3Rv/5sjRmDHmn+8IRTsFPzTOCB8FPZscz6UEmQ2yfxxBDoyyiLROqtIwnA4ZMindqLor6BYD81Y5gTPA8gkjMHlAHyPJcOalcxclhGSRB/EylyJdEKNOzeee0WHyiBcDbiy+cqiYSkQKM6CrP3LLGeq5CFEKFzPO5zpOdOU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.210.78
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-ot1-f78.google.com with SMTP id 46e09a7af769-7e9f686e18cso10680995a34.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 12:43:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784749412; x=1785354212;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MRHhVKKvnDAZz7/1t70Vk1vW7x1POVCKdB+nLA2r0p4=;
        b=WWGQ4YBwQkhUDFsadirLR9fM2U06o84+5IvKXdzT4RNU94D8nyfLyEbrOL8dtMfE/I
         3mQPuNsI4FU7ZVy+mOTDptWoDUQ5U5nB4ppe9nlNiZkmGc1XlarLbzhHd99BDooaEUrP
         fuU61upeqyOGdtVkMEXAkIaxzCQ7vWyeARu2Bbmz1O6wR4tHYbsP19z3iFsbH4q4nBOi
         XK6D67lKhgf9YtqXlx+VXjaPKy2plCmYSSnOvYa8SBUxLoniVaOMkpQJ/S4Dn+d/7bjj
         Yirrj8hpY96Odlus51Yxi2jWqhaSAJ6tyG2Z899dvNN13rk6urUWSPWumhKL8GMBjwKY
         DKxg==
X-Forwarded-Encrypted: i=1; AHgh+RpY9eiEk1WUDEaQBRhP22/UuxpXF3JuJAz06lqh+0hQVV7evisutAEoN9sGiHvIwDb/ItVrLCGCfXM=@vger.kernel.org
X-Gm-Message-State: AOJu0YzVo5O3ophD6QTSXtCs9o3EX1U3Z7pa21BxgwcRqYDyGnHd8KkD
	D94MIiiDr8O32e8QtJPW2JZeujHbWn0YZZTzoZYU4DtQ/ufVpsz9C4w4DyJlCMZbZJDVd6ONKTl
	dWtq2PytrHScO4EM9kyMJ4z78J9qWoDVn25zt5UV71SQOci/DxnKlo/eKBOE=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:14d4:b0:4a0:d9a1:1a95 with SMTP id
 5614622812f47-4ab352e5f58mr67320b6e.14.1784749412679; Wed, 22 Jul 2026
 12:43:32 -0700 (PDT)
Date: Wed, 22 Jul 2026 12:43:32 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a611d64.42649fcc.22d900.0016.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_expkey_set_reqs_doit
From: syzbot <syzbot+de7e55e90abcbb58ae63@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    0f26556c5eee Merge tag 'nfsd-7.2-1' of git://git.kernel.or..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=162628b9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=98da55a882774dfe
dashboard link: https://syzkaller.appspot.com/bug?extid=de7e55e90abcbb58ae63
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/5042d8e3bd4b/disk-0f26556c.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/b0e5d35a7328/vmlinux-0f26556c.xz
kernel image: https://storage.googleapis.com/syzbot-assets/3314a2de615a/bzImage-0f26556c.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+de7e55e90abcbb58ae63@syzkaller.appspotmail.com

INFO: task syz.5.2252:10556 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.5.2252      state:D stack:27064 pid:10556 tgid:10555 ppid:9650   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x16dc/0x5500 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 rt_mutex_schedule+0x76/0xf0 kernel/sched/core.c:7607
 rt_mutex_slowlock_block+0x55c/0x680 kernel/locking/rtmutex.c:1670
 __rt_mutex_slowlock kernel/locking/rtmutex.c:1747 [inline]
 __rt_mutex_slowlock_locked kernel/locking/rtmutex.c:1787 [inline]
 rt_mutex_slowlock+0x2d4/0x780 kernel/locking/rtmutex.c:1827
 __rt_mutex_lock kernel/locking/rtmutex.c:1842 [inline]
 __mutex_lock_common kernel/locking/rtmutex_api.c:560 [inline]
 mutex_lock_nested+0x168/0x1d0 kernel/locking/rtmutex_api.c:578
 nfsd_nl_expkey_set_reqs_doit+0xfe/0xaf0 fs/nfsd/export.c:561
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7f5/0x990 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 ____sys_sendmsg+0x565/0x870 net/socket.c:2684
 ___sys_sendmsg+0x2a5/0x360 net/socket.c:2738
 __sys_sendmsg net/socket.c:2770 [inline]
 __do_sys_sendmsg net/socket.c:2775 [inline]
 __se_sys_sendmsg net/socket.c:2773 [inline]
 __x64_sys_sendmsg+0x1b7/0x290 net/socket.c:2773
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f3cc3d2de59
RSP: 002b:00007f3cc1f86028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007f3cc3fb5fa0 RCX: 00007f3cc3d2de59
RDX: 0000000004008090 RSI: 0000200000000140 RDI: 0000000000000003
RBP: 0000[  425.894553][   T38] RBP: 00007f3cc3dc3e6f R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f3cc3fb6038 R14: 00007f3cc3fb5fa0 R15: 00007fffa1f3ef88
 </TASK>

Showing all locks held in the system:
3 locks held by kworker/0:0/9:
 #0: ffff88801a765938 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88801a765938 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc900000e7c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc900000e7c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff88802a6ce210 (&dev->mutex){....}-{4:4}, at: device_lock include/linux/device.h:1102 [inline]
 #2: ffff88802a6ce210 (&dev->mutex){....}-{4:4}, at: hub_event+0x187/0x4cf0 drivers/usb/core/hub.c:5899
1 lock held by khungtaskd/38:
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
2 locks held by getty/5348:
 #0: ffff88803646e0a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc90003cc62e0 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x460/0x1360 drivers/tty/n_tty.c:2211
9 locks held by syz-executor/5599:
6 locks held by kworker/1:15/6249:
 #0: ffff88801a765938 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88801a765938 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc900061f7c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc900061f7c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff88802a566210 (&dev->mutex){....}-{4:4}, at: device_lock include/linux/device.h:1102 [inline]
 #2: ffff88802a566210 (&dev->mutex){....}-{4:4}, at: hub_event+0x187/0x4cf0 drivers/usb/core/hub.c:5899
 #3: ffff88802a5d7658 (&port_dev->status_lock){+.+.}-{4:4}, at: usb_lock_port drivers/usb/core/hub.c:3252 [inline]
 #3: ffff88802a5d7658 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_connect drivers/usb/core/hub.c:5464 [inline]
 #3: ffff88802a5d7658 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_connect_change drivers/usb/core/hub.c:5707 [inline]
 #3: ffff88802a5d7658 (&port_dev->status_lock){+.+.}-{4:4}, at: port_event drivers/usb/core/hub.c:5871 [inline]
 #3: ffff88802a5d7658 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_event+0x20ad/0x4cf0 drivers/usb/core/hub.c:5953
 #4: ffff888029c02e58 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_connect drivers/usb/core/hub.c:5465 [inline]
 #4: ffff888029c02e58 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_connect_change drivers/usb/core/hub.c:5707 [inline]
 #4: ffff888029c02e58 (hcd->address0_mutex){+.+.}-{4:4}, at: port_event drivers/usb/core/hub.c:5871 [inline]
 #4: ffff888029c02e58 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_event+0x20e1/0x4cf0 drivers/usb/core/hub.c:5953
 #5: ffffffff8ee58400 (ehci_cf_port_reset_rwsem){.+.+}-{4:4}, at: hub_port_reset+0x14d/0x1800 drivers/usb/core/hub.c:3067
2 locks held by syz.0.1592/9153:
 #0: ffffffff8f6220e0 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8e4e94b8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_threads_set_doit+0x2b9/0xc30 fs/nfsd/nfsctl.c:1660
2 locks held by syz.5.2252/10556:
 #0: ffffffff8f6220e0 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8e4e94b8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_expkey_set_reqs_doit+0xfe/0xaf0 fs/nfsd/export.c:561
2 locks held by syz.2.3144/12437:
 #0: ffffffff8f6220e0 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8e4e94b8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_svc_export_set_reqs_doit+0x132/0x1450 fs/nfsd/export.c:1057
3 locks held by syz.1.3270/12705:
 #0: ffffffff8f6220e0 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffff888039984928 (nlk_cb_mutex-GENERIC){+.+.}-{4:4}, at: __netlink_dump_start+0xf4/0x7b0 net/netlink/af_netlink.c:2410
 #2: ffffffff8e4e94b8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_rpc_status_get_dumpit+0xdb/0x13f0 fs/nfsd/nfsctl.c:1510
6 locks held by syz.6.4350/15026:

=============================================

NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 38 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT_{RT,(full)} 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 05/09/2026
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
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 15026 Comm: syz.6.4350 Not tainted syzkaller #0 PREEMPT_{RT,(full)} 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 05/09/2026
RIP: 0010:__bfs kernel/locking/lockdep.c:1753 [inline]
RIP: 0010:__bfs_backwards kernel/locking/lockdep.c:1860 [inline]
RIP: 0010:check_irq_usage kernel/locking/lockdep.c:2796 [inline]
RIP: 0010:check_prev_add kernel/locking/lockdep.c:3169 [inline]
RIP: 0010:check_prevs_add kernel/locking/lockdep.c:3284 [inline]
RIP: 0010:validate_chain kernel/locking/lockdep.c:3908 [inline]
RIP: 0010:__lock_acquire+0x17a5/0x2ce0 kernel/locking/lockdep.c:5237
Code: 00 00 0f 83 84 01 00 00 4e 8b 3c e5 a0 a9 a5 95 ff c0 25 ff 0f 00 00 89 05 48 47 05 14 4d 85 ff 0f 84 ac 01 00 00 49 8b 47 10 <48> 85 c0 0f 84 38 0d 00 00 8b 0d 34 47 05 14 39 48 5c 0f 84 6a ff
RSP: 0000:ffffc9001d4c71c8 EFLAGS: 00000082
RAX: ffffffff934ac5f8 RBX: 00000000000003cd RCX: ffffffff9633d768
RDX: ffffffff964d6948 RSI: ffff8880312a4af8 RDI: 00000000000003cd
RBP: a845dd3fd526ac6c R08: ffffc9001d4c7190 R09: 0000000000000020
R10: 0000000000000000 R11: ffffffff81a13580 R12: 000000000000059e
R13: ffff8880312a4af8 R14: ffff8880312a3e00 R15: ffffffff9633d768
FS:  00007fe8892c66c0(0000) GS:ffff888125d49000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00002000000d3000 CR3: 000000003973a000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 lock_acquire+0x106/0x350 kernel/locking/lockdep.c:5868
 seqcount_lockdep_reader_access+0x55/0x100 include/linux/seqlock.h:73
 ktime_get_update_offsets_now+0x5d/0x3e0 kernel/time/timekeeping.c:2807
 hrtimer_update_base kernel/time/hrtimer.c:683 [inline]
 __hrtimer_rearm_deferred+0xde/0x430 kernel/time/hrtimer.c:2155
 hrtick_schedule_exit kernel/sched/core.c:1013 [inline]
 finish_lock_switch kernel/sched/core.c:5240 [inline]
 finish_task_switch+0x3e3/0xc60 kernel/sched/core.c:5359
 context_switch kernel/sched/core.c:5513 [inline]
 __schedule+0x16e4/0x5500 kernel/sched/core.c:7234
 preempt_schedule_irq+0x4d/0xa0 kernel/sched/core.c:7556
 irqentry_exit_to_kernel_mode include/linux/irq-entry-common.h:539 [inline]
 irqentry_exit+0x14f/0x8f0 kernel/entry/common.c:167
 asm_sysvec_apic_timer_interrupt+0x1a/0x20 arch/x86/include/asm/idtentry.h:674
RIP: 0010:lock_acquire+0x221/0x350 kernel/locking/lockdep.c:5872
Code: ff ff ff e8 61 3c a1 09 f7 44 24 08 00 02 00 00 0f 84 3a ff ff ff 65 48 8b 05 2b a7 fc 10 48 3b 44 24 58 75 33 fb 48 83 c4 60 <5b> 41 5c 41 5d 41 5e 41 5f 5d e9 d0 05 a5 09 cc 48 8d 3d b8 17 12
RSP: 0000:ffffc9001d4c7800 EFLAGS: 00000286
RAX: 92bc5978f8459800 RBX: 0000000000000000 RCX: 0000000000000046
RDX: 00000000d97d4069 RSI: ffffffff8daf19a2 RDI: ffffffff8bca6280
RBP: ffffffff8214a496 R08: ffffffff8214a496 R09: 0000000000000000
R10: 0000000000008000 R11: ffff888063b2acb0 R12: 0000000000000001
R13: ffff888063b2acb0 R14: 0000000000000001 R15: 0000000000000246
 down_read_trylock+0x102/0x170 kernel/locking/rwsem.c:1619
 mmap_read_trylock include/linux/mmap_lock.h:611 [inline]
 get_mmap_lock_carefully mm/mmap_lock.c:441 [inline]
 lock_mm_and_find_vma+0x36/0x340 mm/mmap_lock.c:501
 do_user_addr_fault+0x341/0x1340 arch/x86/mm/fault.c:1366
 handle_page_fault arch/x86/mm/fault.c:1483 [inline]
 exc_page_fault+0x6a/0xc0 arch/x86/mm/fault.c:1536
 asm_exc_page_fault+0x26/0x30 arch/x86/include/asm/idtentry.h:595
RIP: 0010:fault_in_readable+0x8e/0x130 mm/gup.c:2161
Code: a9 00 00 00 0f 01 cb 0f ae e8 4d 85 f6 40 0f 95 c5 4c 89 ff 4c 89 f6 e8 10 95 b1 ff 4d 39 f7 0f 97 c0 40 84 c5 74 43 4d 89 f5 <41> 8a 45 00 88 44 24 07 49 81 e5 00 f0 ff ff 4d 8d a5 00 10 00 00
RSP: 0000:ffffc9001d4c7aa8 EFLAGS: 00050202
RAX: ffffffff8213a601 RBX: 0000000000000240 RCX: ffff8880312a3e00
RDX: 0000000000000002 RSI: 00002000000d3000 RDI: 00002000000d3240
RBP: ffffc9001d4c7c01 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000100 R11: 0000000000000001 R12: 00007ffffffff000
R13: 00002000000d3000 R14: 00002000000d3000 R15: 00002000000d3240
 fault_in_iov_iter_readable+0x1c8/0x310 lib/iov_iter.c:106
 generic_perform_write+0x75b/0x8b0 mm/filemap.c:4407
 shmem_file_write_iter+0xfb/0x120 mm/shmem.c:3414
 new_sync_write fs/read_write.c:595 [inline]
 vfs_write+0x61e/0xbb0 fs/read_write.c:687
 ksys_write+0x156/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fe88b06de59
Code: ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 e8 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007fe8892c6028 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007fe88b2f5fa0 RCX: 00007fe88b06de59
RDX: 000000003af4701e RSI: 0000200000000240 RDI: 0000000000000003
RBP: 00007fe88b103e6f R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007fe88b2f6038 R14: 00007fe88b2f5fa0 R15: 00007ffe40a8d428
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
