Received: from mail-oi1-f208.google.com (mail-oi1-f208.google.com [209.85.167.208])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE7ED3E16B9
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 19:54:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.208
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784750077; cv=none; b=BFACKtf4ChF4zTSvKT67UiZRlMQ1vat7x/m8o5tElBwIvVS9CIEUhh2O4bGt7UBlmqZh6ofy6JVxka6m/pPgpRanX1hEUCo5uc+kz1nZ9x+MYJHS2u64A+VWa+1bQXdBnksCSDwbIhH/lLXlJaIzEtBW2Or2Ud2HdDCEO4JiKhE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784750077; c=relaxed/simple;
	bh=BkUyxnp3iidI95UhXqUsNYAmokvCVK44gC1BRMY/Gok=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=dC/8OIQCnGFkgGY5MTEgZwMW+2URwe7ImoZjbfvs1NOM0YiDIbIlsWZbH88wF37G5SmeWpxtXRI9ACY1dTUe1j2I+tid/n+BZ95wQ24avqDjvQSWFOokt4C9Cl3SgTpiEIJfIqwpMSoMB7T3b6cfWeFsCAd2c2LlOP808oBY+AE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.208
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f208.google.com with SMTP id 5614622812f47-4a43d32fa9fso15942454b6e.2
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 12:54:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784750074; x=1785354874;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2tOoRvFYKhp9JYC+IoUfEQ/hjc2fh9FCRBhYf3orQ/A=;
        b=aIl1k4XYZkZPp21so2V2tN7USq8UOjuhr/YsuFTnSnBgxK1NecFZXIJSBJBwm+kgoO
         Eii/fbwvFKvE51V4tL7oiMrQQZTyFSY4VF1IcZGqfazHcmhL9SZ3wtVPzpVqCHqg9MJl
         I08w0v7ViJIS1ne3niNqO/mlfaOdFQLh6ZqjdQfxohI+sAOe8yAiqZPULFgqRZI6PJ8F
         CmTx8/BV1iLXcwx+X7NzR/QDJ96zJiLUBNOKcJzBMk5ogUcfT6BsJGPp+YidJpi8rL6S
         9q4cFjJF6cUpNF/KaEritl25a80Rp0uvI40DCM1K6KzuouW6cdzRUe1nBaPeiv8uUouw
         WXRw==
X-Forwarded-Encrypted: i=1; AHgh+Rr4Ia/B43YnmvphL+hePwdBNXQpwD/gHLB3ssTuAm3B58JXaZVHRhy/3fZpk+byIa9/hybBTPu/3eo=@vger.kernel.org
X-Gm-Message-State: AOJu0YyazABSpl/4Lh8s1N7m+mZbiuk0w+TSxw0k45mXo/JzSHWXZQpF
	esh9UER/Ond6M2qzZ2GNqhikkCykX5nAqhsUsZVLNOuEgFcpbO6+5P4OmW42VhBXMAjxZe35F/8
	mTbzcn87pLfEXeJ1EJccx7A5oQoQyL4tWg8HI5mMHSEGXEh8BqlSifwACwac=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:ec8:b0:491:6271:b24e with SMTP id
 5614622812f47-4ab3571717amr75249b6e.32.1784750074664; Wed, 22 Jul 2026
 12:54:34 -0700 (PDT)
Date: Wed, 22 Jul 2026 12:54:34 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a611ffa.16bfb6d0.3c48cb.0004.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_expkey_get_reqs_dumpit
From: syzbot <syzbot+16f257c80900b615cb35@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    af5e34a41cd6 Merge tag 'mtd/fixes-for-7.2-rc4' of git://gi..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=10589789580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=98da55a882774dfe
dashboard link: https://syzkaller.appspot.com/bug?extid=16f257c80900b615cb35
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/52cd5ad24930/disk-af5e34a4.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/34e33eca116e/vmlinux-af5e34a4.xz
kernel image: https://storage.googleapis.com/syzbot-assets/e43b3758650e/bzImage-af5e34a4.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+16f257c80900b615cb35@syzkaller.appspotmail.com

INFO: task syz.6.1915:120[  841.369651][   T38] INFO: task syz.6.1915:12092 blocked for more than 147 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.6.1915      state:D stack:26256 pid:12092 tgid:12091 ppid:11283  task_flags:0x400140 flags:0x00080002
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
 nfsd_nl_expkey_get_reqs_dumpit+0xfd/0xd40 fs/nfsd/export.c:347
 genl_dumpit+0x10b/0x1b0 net/netlink/genetlink.c:1026
 netlink_dump+0x711/0xee0 net/netlink/af_netlink.c:2331
 __netlink_dump_start+0x589/0x7b0 net/netlink/af_netlink.c:2446
 genl_family_rcv_msg_dumpit+0x213/0x310 net/netlink/genetlink.c:1075
 genl_family_rcv_msg net/netlink/genetlink.c:1191 [inline]
 genl_rcv_msg+0x5e1/0x7a0 net/netlink/genetlink.c:1209
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
RIP: 0033:0x7fab361cde99
RSP: 002b:00007fab34426028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007fab36455fa0 RCX: 00007fab361cde99
RDX: 0000000004044890 RSI: 0000200000000180 RDI: 0000000000000004
RBP: 00007fab36263eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007fab36456038 R14: 00007fab36455fa0 R15: 00007ffde6ceffe8
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/38:
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
3 locks held by kworker/u8:5/124:
 #0: ffff88813ff5c138 ((wq_completion)events_unbound){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88813ff5c138 ((wq_completion)events_unbound){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc9000152fc40 ((linkwatch_work).work){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc9000152fc40 ((linkwatch_work).work){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffffffff8f5b13b8 (rtnl_mutex){+.+.}-{4:4}, at: linkwatch_event+0xe/0x60 net/core/link_watch.c:313
2 locks held by kworker/u8:16/3555:
 #0: ffff88801f388138 ((wq_completion)iou_exit){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88801f388138 ((wq_completion)iou_exit){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc9000ea2fc40 ((work_completion)(&ctx->exit_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc9000ea2fc40 ((work_completion)(&ctx->exit_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
7 locks held by kworker/u8:17/3702:
 #0: ffff88801aea0938 ((wq_completion)netns){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88801aea0938 ((wq_completion)netns){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc9000ec1fc40 (net_cleanup_work){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc9000ec1fc40 (net_cleanup_work){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffffffff8f5a2800 (pernet_ops_rwsem){++++}-{4:4}, at: cleanup_net+0xf5/0x810 net/core/net_namespace.c:673
 #3: ffff888061539160 (&dev->mutex){....}-{4:4}, at: device_lock include/linux/device.h:1102 [inline]
 #3: ffff888061539160 (&dev->mutex){....}-{4:4}, at: devl_dev_lock net/devlink/devl_internal.h:124 [inline]
 #3: ffff888061539160 (&dev->mutex){....}-{4:4}, at: devlink_pernet_pre_exit+0x129/0x420 net/devlink/core.c:557
 #4: ffff888077a20310 (&devlink->lock_key#10){+.+.}-{4:4}, at: devl_lock net/devlink/core.c:292 [inline]
 #4: ffff888077a20310 (&devlink->lock_key#10){+.+.}-{4:4}, at: devl_dev_lock net/devlink/devl_internal.h:125 [inline]
 #4: ffff888077a20310 (&devlink->lock_key#10){+.+.}-{4:4}, at: devlink_pernet_pre_exit+0x142/0x420 net/devlink/core.c:557
 #5: ffffffff8f5b13b8 (rtnl_mutex){+.+.}-{4:4}, at: nsim_destroy+0x173/0x800 drivers/net/netdevsim/netdev.c:1191
 #6: ffff888036009060 (&dev_instance_lock_key#23){+.+.}-{4:4}, at: netdev_lock include/linux/netdevice.h:2847 [inline]
 #6: ffff888036009060 (&dev_instance_lock_key#23){+.+.}-{4:4}, at: netdev_lock_ops include/net/netdev_lock.h:42 [inline]
 #6: ffff888036009060 (&dev_instance_lock_key#23){+.+.}-{4:4}, at: unregister_netdevice_many_notify+0x11d0/0x2110 net/core/dev.c:12427
2 locks held by getty/5353:
 #0: ffff8880369430a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc90003cbe2e0 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x460/0x1360 drivers/tty/n_tty.c:2211
4 locks held by syz-executor/5598:
2 locks held by syz.2.1652/11145:
 #0: ffffffff8f6224e0 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8e4e94b8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0x136/0x16e0 fs/nfsd/nfsctl.c:1964
3 locks held by syz.6.1915/12092:
 #0: ffffffff8f6224e0 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffff88803a7e2928 (nlk_cb_mutex-GENERIC){+.+.}-{4:4}, at: __netlink_dump_start+0xf4/0x7b0 net/netlink/af_netlink.c:2410
 #2: ffffffff8e4e94b8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_expkey_get_reqs_dumpit+0xfd/0xd40 fs/nfsd/export.c:347
2 locks held by syz-executor/13665:
 #0: ffffffff8fafb570 (&ops->srcu#2){.+.+}-{0:0}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8fafb570 (&ops->srcu#2){.+.+}-{0:0}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8fafb570 (&ops->srcu#2){.+.+}-{0:0}, at: rtnl_link_ops_get+0x23/0x250 net/core/rtnetlink.c:570
 #1: ffffffff8f5b13b8 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/core/rtnetlink.c:80 [inline]
 #1: ffffffff8f5b13b8 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock net/core/rtnetlink.c:341 [inline]
 #1: ffffffff8f5b13b8 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a3/0x1bd0 net/core/rtnetlink.c:4158
1 lock held by syz.8.2319/13776:
1 lock held by syz.7.2325/13789:
 #0: ffff888011bc2cb0 (&mm->mmap_lock){++++}-{4:4}, at: mmap_write_lock_killable include/linux/mmap_lock.h:554 [inline]
 #0: ffff888011bc2cb0 (&mm->mmap_lock){++++}-{4:4}, at: vm_mmap_pgoff+0x1e0/0x4e0 mm/util.c:579
2 locks held by syz.7.2325/13791:
4 locks held by sed/13799:

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 38 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT_{RT,(full)} 
Tainted: [L]=SOFTLOCKUP
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
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 4966 Comm: udevd Tainted: G             L      syzkaller #0 PREEMPT_{RT,(full)} 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 05/09/2026
RIP: 0010:do_raw_spin_lock+0x5a/0x2f0 kernel/locking/spinlock_debug.c:114
Code: 00 00 00 fc ff df 48 c7 44 24 20 b3 8a b5 41 48 c7 44 24 28 cd 26 a2 8d 48 c7 44 24 30 c0 7f a1 81 4c 8d 64 24 20 49 c1 ec 03 <48> b8 f1 f1 f1 f1 f8 f3 f3 f3 49 89 04 14 4c 8d 77 04 4c 89 f0 48
RSP: 0018:ffffc900049c76c0 EFLAGS: 00000802
RAX: ae39b0643529a300 RBX: ffff8880b86403d8 RCX: 0000000080000001
RDX: dffffc0000000000 RSI: ffffffff8daf21b7 RDI: ffff8880b86403d8
RBP: ffffc900049c7778 R08: ffffffff8b44a0a6 R09: 0000000000080000
R10: 0000000000000000 R11: ffff8880b86403f0 R12: 1ffff92000938edc
R13: ffff8880373b8000 R14: ffff8880b86403d8 R15: 1ffff110170c8085
FS:  00007f8601d10880(0000) GS:ffff888125c49000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00005555818d8a38 CR3: 0000000037106000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:133 [inline]
 _raw_spin_lock_irqsave+0x4c/0x60 kernel/locking/spinlock.c:166
 rt_mutex_slowtrylock kernel/locking/rtmutex.c:1404 [inline]
 __rt_spin_trylock kernel/locking/spinlock_rt.c:123 [inline]
 rt_spin_trylock+0x56/0x2b0 kernel/locking/spinlock_rt.c:135
 alloc_from_pcs mm/slub.c:4795 [inline]
 slab_alloc_node mm/slub.c:4933 [inline]
 __do_kmalloc_node mm/slub.c:5361 [inline]
 __kmalloc_noprof+0x1e0/0x780 mm/slub.c:5387
 _kmalloc_noprof include/linux/slab.h:973 [inline]
 _kzalloc_noprof include/linux/slab.h:1290 [inline]
 tomoyo_encode2 security/tomoyo/realpath.c:45 [inline]
 tomoyo_encode+0x2ad/0x570 security/tomoyo/realpath.c:80
 tomoyo_realpath_from_path+0x5fa/0x640 security/tomoyo/realpath.c:283
 tomoyo_get_realpath security/tomoyo/file.c:151 [inline]
 tomoyo_path_perm+0x283/0x560 security/tomoyo/file.c:827
 security_inode_getattr+0x12b/0x310 security/security.c:1895
 vfs_getattr+0x23/0x70 fs/stat.c:259
 vfs_statx_path+0x2b/0x230 fs/stat.c:299
 vfs_statx+0x12e/0x200 fs/stat.c:356
 vfs_fstatat+0x11b/0x170 fs/stat.c:373
 __do_sys_newfstatat fs/stat.c:538 [inline]
 __se_sys_newfstatat fs/stat.c:532 [inline]
 __x64_sys_newfstatat+0x151/0x200 fs/stat.c:532
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f8601e68b0a
Code: 48 8b 15 f1 f2 0d 00 f7 d8 64 89 02 b8 ff ff ff ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 41 89 ca b8 06 01 00 00 0f 05 <3d> 00 f0 ff ff 77 07 31 c0 c3 0f 1f 40 00 48 8b 15 b9 f2 0d 00 f7
RSP: 002b:00007ffefa0915c8 EFLAGS: 00000246 ORIG_RAX: 0000000000000106
RAX: ffffffffffffffda RBX: 000055b64ce52418 RCX: 00007f8601e68b0a
RDX: 00007ffefa0915d0 RSI: 000055b64ce40ef3 RDI: 00000000ffffff9c
RBP: 000055b676721148 R08: 000656e19289435a R09: 3fffffffffffffff
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000001
R13: 00007ffefa0915d0 R14: 0000000000000000 R15: 000656e19289435a
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
