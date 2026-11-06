Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793950542;
	b=IDaEe6b1lsSXIPjJjKa002kaDWowthBSCiN1Y3I4oU+X4upYdQVnwJBb2pZKcoYeVmU7
	 cy1N6yYmH7mvjydg37wIo1gV2+A9GKAdsLbBqa5UuYMn4FGN2qjtRT7B3Hbvrgftv1Q7C
	 ycx/Y9+E7xyaIpwoWyps8gkth2ecMQvD2S3qlhBV7Z46Ihwdms3n8vVArOsMyWZqm313z
	 1O7b34uFRXctoFuclyRmtxCy5FhXAJ5ohm2flfICpShSSBzr9VoUB1quKRXLRyIaWNljf
	 eOEU9nMVjbO2wE7io3RutTHgFF7r7zxW5f2KAt7EKL074tCZAdwdDXEmYEKM0ol30uA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793950542;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:MIME-Version:X-Received:Date:
	 X-Google-Appengine-App-Id:X-Google-Appengine-App-Id-Alias:Message-ID:
	 Subject:From:To:Content-Type;
	bh=i/988GRYLNIQ+m9ZryVFkUgt23XkOKZYFqEEbEyt0zM=;
	b=O+AAH0xoH7K5usjq8OpmB4TLrynhn5tJqrpVPuMok4MrBvtEZVMBwnyEhJZWutPY5xzl
	 72Oae4+mPbURpEVy9ng2WXTFqDHm0MNRf1S61PfwMpSIb7NzynlXp+7o8vF2EORVw4H3Z
	 MZlVhpVk1xoi7pSXK0qT1JBhgWHU2DGUuO7QaEqZvTJL3fKXtJ9AZEFdAsO1LdyM0x4Nq
	 xOqvBYFtwMgETnu2kx/tqk0+SyU2QEHBV9/iJBt9gYdBhAk5tIps1zxporCsnDd9CkIA6
	 wtXH0ic5+FZgvN3AJLHi2HejLZkUJACY2DAHoReFwZDnIoH12yC1UBoJC45Y0OP/8Qg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=syzkaller.appspotmail.com;
	spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
	arc=none smtp.remote-ip=209.85.160.71
Received: from mail-oa1-f71.google.com (mail-oa1-f71.google.com [209.85.160.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CCF0606A32D
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 07:35:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7CCF0606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa1-f71.google.com with SMTP id 586e51a60fabf-46509ab0149so280825fac.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 23:35:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793950540; x=1794555340;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=i/988GRYLNIQ+m9ZryVFkUgt23XkOKZYFqEEbEyt0zM=;
        b=mvxN7VRihu9s+mrdsVreGFr72rgeIuGKUAoPEh/GFWJt39xfwL7H5yDw/Ebgz3Xubb
         2cQhsQlMgHiwuVJOA8eYwIbaf/SKQKM78UcOLOxgjJQSU2Cjc1rYpuh+4gXgIFxE18yu
         f152fzIYUS+3G8XjSw8SmJGHc3SsIrQyjCf3LQUtfSTvjQth9Tq9B54kLWwfkwXvnpiV
         vTE4+hitOat/iQxle89MeD8HLXzyprJc6Xt7rDE9HAj7CCXsckli6oro//UzqKp1QzoU
         AJRE8uLB/B32+NsH/MTEfpwhisQwL6UnkSkE4rgUZp5PPsA9Mr/Y81tG2/SrWRvBF2pi
         u14g==
X-Forwarded-Encrypted: i=1; AKwUvByvnZe+ZaEfAuCq4ow3sMPrP0tKQDWUs4IVgWXDX6UhqXyKV5EssucI/XYVMCbGdIe284vzx0AQuds=@vger.kernel.org
X-Gm-Message-State: APuU4Z9DXa+ovgSwFiV/nMszhXg8vlZaeJ32u360/HCXKThPMpjuvIht
	xYLIdSVzqXAGPWMcYAONarA4O0RC8TGD4DVfyE1mvNHxLUyMaz+VaHGxcp0mySAd9gONKmykP41
	rAE4jEnJ9LT0CoQvS1WR8E846BHPh9cMRLAaKEGqxuBbHKJqpnnOGImn56II=
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Received: by 2002:a05:6808:120a:b0:4ab:230c:5faa with SMTP id
 5614622812f47-567e14c930emr1056164b6e.18.1793950540289; Thu, 05 Nov 2026
 23:35:40 -0800 (PST)
Date: Thu, 05 Nov 2026 23:35:40 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6aed834c.dadc8e63.45095.0004.GAE@google.com>
Subject: [syzbot] [nfs?] possible deadlock in nfsd_file_cache_shutdown
From: syzbot <syzbot+e6bb7c8bc275dfed69c1@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	netdev@vger.kernel.org, okorniev@redhat.com, syzkaller-bugs@googlegroups.com, 
	tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    c4ba1716853d net: atl1c: drop oversized RX frames instead ..
git tree:       net
console output: https://syzkaller.appspot.com/x/log.txt?x=10dad4a1580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d30e1495ee3ac817
dashboard link: https://syzkaller.appspot.com/bug?extid=e6bb7c8bc275dfed69c1
compiler:       Debian clang version 22.1.8 (1~deb13u4), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/1fbe24b1b049/disk-c4ba1716.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/4142b610b0c3/vmlinux-c4ba1716.xz
kernel image: https://storage.googleapis.com/syzbot-assets/2441af2219d1/bzImage-c4ba1716.xz

AI-generated root cause summary:
In drivers/block/nbd.c, nbd_genl_reconnect_sock_cb() incorrectly calls
sk_set_memalloc(sock->sk) while holding the mutex nsock->tx_lock.
sk_set_memalloc() invokes static_branch_inc(), which acquires cpus_read_lock()
(cpu_hotplug_lock). Because nsock->tx_lock is acquired during block I/O request
dispatch in nbd_queue_rq(), it is part of the direct memory reclaim (fs_reclaim)
dependency chain. Acquiring cpu_hotplug_lock under nsock->tx_lock inverts the
core MM locking hierarchy (cpu_hotplug_lock -> slab_mutex -> fs_reclaim),
creating an ABBA circular locking dependency that can lead to system deadlock.

full analysis:  https://syzkaller.appspot.com/x/ai_root_cause?x=e6bb7c8bc275dfed69c1

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+e6bb7c8bc275dfed69c1@syzkaller.appspotmail.com

======================================================
WARNING: possible circular locking dependency detected
syzkaller #0 Not tainted
------------------------------------------------------
syz.4.1718/12980 is trying to acquire lock:
ffffffff90094cc0 (fs_reclaim){+.+.}-{0:0}, at: might_alloc include/linux/sched/mm.h:316 [inline]
ffffffff90094cc0 (fs_reclaim){+.+.}-{0:0}, at: slab_pre_alloc_hook mm/slub.c:4673 [inline]
ffffffff90094cc0 (fs_reclaim){+.+.}-{0:0}, at: slab_alloc_node mm/slub.c:5011 [inline]
ffffffff90094cc0 (fs_reclaim){+.+.}-{0:0}, at: kmem_cache_alloc_noprof+0x5f/0x600 mm/slub.c:5047

but task is already holding lock:
ffffffff900771b8 (slab_mutex){+.+.}-{4:4}, at: __kmem_cache_create_args+0x59/0x470 mm/slab_common.c:350

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #7 (slab_mutex){+.+.}-{4:4}:
       __mutex_lock_common kernel/locking/mutex.c:646 [inline]
       __mutex_lock+0x197/0x15a0 kernel/locking/mutex.c:821
       kmem_cache_destroy+0x73/0x180 mm/slab_common.c:565
       nfsd_file_cache_shutdown+0x126/0x370 fs/nfsd/filecache.c:1063
       nfsd_shutdown_generic fs/nfsd/nfssvc.c:293 [inline]
       nfsd_startup_net fs/nfsd/nfssvc.c:411 [inline]
       nfsd_svc+0x539/0x710 fs/nfsd/nfssvc.c:788
       nfsd_nl_threads_set_doit+0xa6c/0xc30 fs/nfsd/nfsctl.c:1780
       genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
       genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
       genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
       netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2584
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
       netlink_unicast_kernel net/netlink/af_netlink.c:1335 [inline]
       netlink_unicast+0x8ef/0xa80 net/netlink/af_netlink.c:1361
       netlink_sendmsg+0x7f0/0xb20 net/netlink/af_netlink.c:1920
       sock_sendmsg_nosec+0x14e/0x190 net/socket.c:800
       __sock_sendmsg net/socket.c:818 [inline]
       ____sys_sendmsg+0x54e/0x850 net/socket.c:2715
       ___sys_sendmsg+0x2a5/0x360 net/socket.c:2769
       __sys_sendmsg net/socket.c:2801 [inline]
       __do_sys_sendmsg net/socket.c:2806 [inline]
       __se_sys_sendmsg net/socket.c:2804 [inline]
       __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2804
       do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
       do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

-> #6 (cpu_hotplug_lock){++++}-{0:0}:
       percpu_down_read_internal include/linux/percpu-rwsem.h:53 [inline]
       percpu_down_read include/linux/percpu-rwsem.h:77 [inline]
       cpus_read_lock+0x3d/0x160 kernel/cpu.c:490
       static_key_slow_inc+0x12/0x30 kernel/jump_label.c:190
       nbd_genl_reconnect_sock_cb+0x69a/0xbb0 drivers/block/nbd.c:1377
       nbd_genl_foreach_sock+0x265/0x450 drivers/block/nbd.c:2152
       nbd_genl_reconfigure+0xbbb/0x1040 drivers/block/nbd.c:2477
       genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
       genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
       genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
       netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2584
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
       netlink_unicast_kernel net/netlink/af_netlink.c:1335 [inline]
       netlink_unicast+0x8ef/0xa80 net/netlink/af_netlink.c:1361
       netlink_sendmsg+0x7f0/0xb20 net/netlink/af_netlink.c:1920
       sock_sendmsg_nosec+0x14e/0x190 net/socket.c:800
       __sock_sendmsg net/socket.c:818 [inline]
       ____sys_sendmsg+0x54e/0x850 net/socket.c:2715
       ___sys_sendmsg+0x2a5/0x360 net/socket.c:2769
       __sys_sendmsg net/socket.c:2801 [inline]
       __do_sys_sendmsg net/socket.c:2806 [inline]
       __se_sys_sendmsg net/socket.c:2804 [inline]
       __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2804
       do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
       do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

-> #5 (&nsock->tx_lock){+.+.}-{4:4}:
       __mutex_lock_common kernel/locking/mutex.c:646 [inline]
       __mutex_lock+0x197/0x15a0 kernel/locking/mutex.c:821
       nbd_handle_cmd drivers/block/nbd.c:1143 [inline]
       nbd_queue_rq+0x373/0xff0 drivers/block/nbd.c:1207
       blk_mq_dispatch_rq_list+0x499/0x1990 block/blk-mq.c:2131
       __blk_mq_do_dispatch_sched block/blk-mq-sched.c:168 [inline]
       blk_mq_do_dispatch_sched block/blk-mq-sched.c:182 [inline]
       __blk_mq_sched_dispatch_requests+0xd36/0x1580 block/blk-mq-sched.c:307
       blk_mq_sched_dispatch_requests+0xd7/0x190 block/blk-mq-sched.c:329
       blk_mq_run_work_fn+0x167/0x2f0 block/blk-mq.c:2546
       process_one_work kernel/workqueue.c:3495 [inline]
       process_scheduled_works+0xc3d/0x1630 kernel/workqueue.c:3578
       worker_thread+0xa47/0xfb0 kernel/workqueue.c:3659
       kthread+0x38b/0x480 kernel/kthread.c:436
       ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
       ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245

-> #4 (&cmd->lock){+.+.}-{4:4}:
       __mutex_lock_common kernel/locking/mutex.c:646 [inline]
       __mutex_lock+0x197/0x15a0 kernel/locking/mutex.c:821
       nbd_queue_rq+0xc1/0xff0 drivers/block/nbd.c:1199
       blk_mq_dispatch_rq_list+0x499/0x1990 block/blk-mq.c:2131
       __blk_mq_do_dispatch_sched block/blk-mq-sched.c:168 [inline]
       blk_mq_do_dispatch_sched block/blk-mq-sched.c:182 [inline]
       __blk_mq_sched_dispatch_requests+0xd36/0x1580 block/blk-mq-sched.c:307
       blk_mq_sched_dispatch_requests+0xd7/0x190 block/blk-mq-sched.c:329
       blk_mq_run_work_fn+0x167/0x2f0 block/blk-mq.c:2546
       process_one_work kernel/workqueue.c:3495 [inline]
       process_scheduled_works+0xc3d/0x1630 kernel/workqueue.c:3578
       worker_thread+0xa47/0xfb0 kernel/workqueue.c:3659
       kthread+0x38b/0x480 kernel/kthread.c:436
       ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
       ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245

-> #3 (set->srcu){.+.+}-{0:0}:
       srcu_lock_sync include/linux/srcu.h:225 [inline]
       __synchronize_srcu+0xca/0x2f0 kernel/rcu/srcutree.c:1662
       elevator_switch+0x1e8/0x7b0 block/elevator.c:576
       elevator_change+0x2fa/0x480 block/elevator.c:681
       elevator_set_default+0x375/0x440 block/elevator.c:754
       blk_register_queue+0x404/0x4f0 block/blk-sysfs.c:992
       __add_disk+0x6b8/0xdb0 block/genhd.c:531
       add_disk_fwnode+0x100/0x3a0 block/genhd.c:600
       add_disk include/linux/blkdev.h:801 [inline]
       nbd_dev_add+0x733/0xb60 drivers/block/nbd.c:2026
       nbd_init+0x168/0x1f0 drivers/block/nbd.c:2743
       do_one_initcall+0x250/0x870 init/main.c:1419
       do_initcall_level+0x10a/0x1a0 init/main.c:1481
       do_initcalls+0x59/0xa0 init/main.c:1497
       kernel_init_freeable+0x29d/0x3e0 init/main.c:1732
       kernel_init+0x22/0x1d0 init/main.c:1622
       ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
       ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245

-> #2 (&q->elevator_lock){+.+.}-{4:4}:
       __mutex_lock_common kernel/locking/mutex.c:646 [inline]
       __mutex_lock+0x197/0x15a0 kernel/locking/mutex.c:821
       elevator_change+0x1af/0x480 block/elevator.c:679
       elevator_set_none+0xb5/0x140 block/elevator.c:769
       blk_mq_elv_switch_none block/blk-mq.c:5114 [inline]
       __blk_mq_update_nr_hw_queues block/blk-mq.c:5159 [inline]
       blk_mq_update_nr_hw_queues+0x5ef/0x19e0 block/blk-mq.c:5224
       nbd_start_device+0x189/0xb30 drivers/block/nbd.c:1530
       nbd_genl_connect+0x167d/0x1cd0 drivers/block/nbd.c:2310
       genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
       genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
       genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
       netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2584
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
       netlink_unicast_kernel net/netlink/af_netlink.c:1335 [inline]
       netlink_unicast+0x8ef/0xa80 net/netlink/af_netlink.c:1361
       netlink_sendmsg+0x7f0/0xb20 net/netlink/af_netlink.c:1920
       sock_sendmsg_nosec+0x14e/0x190 net/socket.c:800
       __sock_sendmsg net/socket.c:818 [inline]
       ____sys_sendmsg+0x54e/0x850 net/socket.c:2715
       ___sys_sendmsg+0x2a5/0x360 net/socket.c:2769
       __sys_sendmsg net/socket.c:2801 [inline]
       __do_sys_sendmsg net/socket.c:2806 [inline]
       __se_sys_sendmsg net/socket.c:2804 [inline]
       __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2804
       do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
       do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

-> #1 (&q->q_usage_counter(io)#49){++++}-{0:0}:
       blk_alloc_queue+0x544/0x690 block/blk-core.c:505
       blk_mq_alloc_queue block/blk-mq.c:4439 [inline]
       __blk_mq_alloc_disk+0x194/0x390 block/blk-mq.c:4486
       nbd_dev_add+0x494/0xb60 drivers/block/nbd.c:1996
       nbd_init+0x168/0x1f0 drivers/block/nbd.c:2743
       do_one_initcall+0x250/0x870 init/main.c:1419
       do_initcall_level+0x10a/0x1a0 init/main.c:1481
       do_initcalls+0x59/0xa0 init/main.c:1497
       kernel_init_freeable+0x29d/0x3e0 init/main.c:1732
       kernel_init+0x22/0x1d0 init/main.c:1622
       ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
       ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245

-> #0 (fs_reclaim){+.+.}-{0:0}:
       check_prev_add kernel/locking/lockdep.c:3209 [inline]
       check_prevs_add kernel/locking/lockdep.c:3328 [inline]
       validate_chain kernel/locking/lockdep.c:3952 [inline]
       __lock_acquire+0x164c/0x2de0 kernel/locking/lockdep.c:5288
       lock_acquire+0x115/0x350 kernel/locking/lockdep.c:5942
       __fs_reclaim_acquire mm/page_alloc.c:4360 [inline]
       fs_reclaim_acquire+0x71/0x100 mm/page_alloc.c:4374
       might_alloc include/linux/sched/mm.h:316 [inline]
       slab_pre_alloc_hook mm/slub.c:4673 [inline]
       slab_alloc_node mm/slub.c:5011 [inline]
       kmem_cache_alloc_noprof+0x5f/0x600 mm/slub.c:5047
       create_cache mm/slab_common.c:249 [inline]
       __kmem_cache_create_args+0x30c/0x470 mm/slab_common.c:387
       __kmem_cache_create include/linux/slab.h:402 [inline]
       ieee80211s_init net/mac80211/mesh.c:28 [inline]
       ieee80211_mesh_init_sdata+0x371/0x620 net/mac80211/mesh.c:1784
       ieee80211_setup_sdata+0x858/0xc10 net/mac80211/iface.c:1980
       ieee80211_if_change_type+0x141/0x940 net/mac80211/iface.c:2125
       ieee80211_change_iface+0xdc/0x4b0 net/mac80211/cfg.c:275
       rdev_change_virtual_intf net/wireless/rdev-ops.h:74 [inline]
       cfg80211_change_iface+0x40f/0x9c0 net/wireless/util.c:1368
       nl80211_set_interface+0x78e/0xaa0 net/wireless/nl80211.c:5252
       genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
       genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
       genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
       netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2584
       genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
       netlink_unicast_kernel net/netlink/af_netlink.c:1335 [inline]
       netlink_unicast+0x8ef/0xa80 net/netlink/af_netlink.c:1361
       netlink_sendmsg+0x7f0/0xb20 net/netlink/af_netlink.c:1920
       sock_sendmsg_nosec+0x14e/0x190 net/socket.c:800
       __sock_sendmsg net/socket.c:818 [inline]
       ____sys_sendmsg+0x54e/0x850 net/socket.c:2715
       ___sys_sendmsg+0x2a5/0x360 net/socket.c:2769
       __sys_sendmsg net/socket.c:2801 [inline]
       __do_sys_sendmsg net/socket.c:2806 [inline]
       __se_sys_sendmsg net/socket.c:2804 [inline]
       __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2804
       do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
       do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
       entry_SYSCALL_64_after_hwframe+0x77/0x7f

other info that might help us debug this:

Chain exists of:
  fs_reclaim --> cpu_hotplug_lock --> slab_mutex

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(slab_mutex);
                               lock(cpu_hotplug_lock);
                               lock(slab_mutex);
  lock(fs_reclaim);

 *** DEADLOCK ***

locks held by syz.4.1718/12980: 4, last CPU#0:
 #0: ffffffff914f05a8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff9148c2a0 (rtnl_mutex){+.+.}-{4:4}, at: nl80211_pre_doit+0x117/0xfa0 net/wireless/nl80211.c:20140
 #2: ffff888067180800 (&rdev->wiphy.mtx){+.+.}-{4:4}, at: wiphy_lock include/net/cfg80211.h:6974 [inline]
 #2: ffff888067180800 (&rdev->wiphy.mtx){+.+.}-{4:4}, at: nl80211_pre_doit+0x6b2/0xfa0 net/wireless/nl80211.c:20189
 #3: ffffffff900771b8 (slab_mutex){+.+.}-{4:4}, at: __kmem_cache_create_args+0x59/0x470 mm/slab_common.c:350

stack backtrace:
CPU: 0 UID: 0 PID: 12980 Comm: syz.4.1718 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 10/07/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 print_circular_bug+0x2e2/0x300 kernel/locking/lockdep.c:2087
 check_noncircular+0x12f/0x150 kernel/locking/lockdep.c:2219
 check_prev_add kernel/locking/lockdep.c:3209 [inline]
 check_prevs_add kernel/locking/lockdep.c:3328 [inline]
 validate_chain kernel/locking/lockdep.c:3952 [inline]
 __lock_acquire+0x164c/0x2de0 kernel/locking/lockdep.c:5288
 lock_acquire+0x115/0x350 kernel/locking/lockdep.c:5942
 __fs_reclaim_acquire mm/page_alloc.c:4360 [inline]
 fs_reclaim_acquire+0x71/0x100 mm/page_alloc.c:4374
 might_alloc include/linux/sched/mm.h:316 [inline]
 slab_pre_alloc_hook mm/slub.c:4673 [inline]
 slab_alloc_node mm/slub.c:5011 [inline]
 kmem_cache_alloc_noprof+0x5f/0x600 mm/slub.c:5047
 create_cache mm/slab_common.c:249 [inline]
 __kmem_cache_create_args+0x30c/0x470 mm/slab_common.c:387
 __kmem_cache_create include/linux/slab.h:402 [inline]
 ieee80211s_init net/mac80211/mesh.c:28 [inline]
 ieee80211_mesh_init_sdata+0x371/0x620 net/mac80211/mesh.c:1784
 ieee80211_setup_sdata+0x858/0xc10 net/mac80211/iface.c:1980
 ieee80211_if_change_type+0x141/0x940 net/mac80211/iface.c:2125
 ieee80211_change_iface+0xdc/0x4b0 net/mac80211/cfg.c:275
 rdev_change_virtual_intf net/wireless/rdev-ops.h:74 [inline]
 cfg80211_change_iface+0x40f/0x9c0 net/wireless/util.c:1368
 nl80211_set_interface+0x78e/0xaa0 net/wireless/nl80211.c:5252
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2584
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1335 [inline]
 netlink_unicast+0x8ef/0xa80 net/netlink/af_netlink.c:1361
 netlink_sendmsg+0x7f0/0xb20 net/netlink/af_netlink.c:1920
 sock_sendmsg_nosec+0x14e/0x190 net/socket.c:800
 __sock_sendmsg net/socket.c:818 [inline]
 ____sys_sendmsg+0x54e/0x850 net/socket.c:2715
 ___sys_sendmsg+0x2a5/0x360 net/socket.c:2769
 __sys_sendmsg net/socket.c:2801 [inline]
 __do_sys_sendmsg net/socket.c:2806 [inline]
 __se_sys_sendmsg net/socket.c:2804 [inline]
 __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2804
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f0223f9fb19
Code: ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 e8 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007f0224f20028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007f0224226090 RCX: 00007f0223f9fb19
RDX: 0000000000000000 RSI: 0000200000000500 RDI: 0000000000000080
RBP: 00007f0224037b70 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f0224226128 R14: 00007f0224226090 R15: 00007ffe4f069ef8
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
