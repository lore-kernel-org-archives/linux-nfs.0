Received: from mail-oo1-f72.google.com (mail-oo1-f72.google.com [209.85.161.72])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A91E13C1A
	for <linux-nfs@vger.kernel.org>; Fri,  7 Aug 2026 00:00:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.72
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786060838; cv=none; b=HhIJvpJ+nW+iD9FHUyLdbBSrNffbRorlGTNHRiwnix5/VtY2W909SLJAFvgJQcjnuyU3TGLvdVjDVKQo9D67M7pU58BPQKII+LIUMRUSNp+mMtpyMzbdx9zqMQT6NL3zSkFaVcFM3+IHV9EZDvUIuWzI3NpBKVjo73+EkbGz9bs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786060838; c=relaxed/simple;
	bh=RWcunV0LMVXicwnvnw7+9o6tgBHwsUqauE+s+07UtMw=;
	h=MIME-Version:Date:In-Reply-To:Message-ID:Subject:From:To:
	 Content-Type; b=Qfa22qjhz3kb9qqPEqOy2OT7TvjAjhPncrqK+J5hS4b7kxeS1MMFAiJi1KT5kZcnJpGNZkOLkHZDTFU2ByNVfGgI4/AA5Q3w1ymZnr3OmdXYRClLz+IMYWNTdCAYSekhrxjpWc4Z5Nws8sGu7titg56HUFn6sWsMolnYMRA0xDA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.72
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f72.google.com with SMTP id 006d021491bc7-6ab0ed783aeso1707440eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 06 Aug 2026 17:00:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786060835; x=1786665635;
        h=content-type:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=/n9KGsHRCQsz8PbCYvcSu3nHH4IJAyft64FVOKi4SDU=;
        b=EygPY6D2XgGc5mGuo01l8X9S3EGwWQO1MF+yv2DKzplk9rx8UqijUPO0he7fMaB/y0
         wd5ILoxFXDBSIWTQ5uhrWXVqnmjuxCkOkWrd4rDv2ipNtxcf/6YzX4phv2NwQr7/Evv/
         vm+Y3eSvlNksAKj3AjbHD1F2GFhISK7pyFFIKu9sq96Dc+CNT17Tu4QJ8vpvX/XMyGOD
         GTbxBxaeq1iU6HuKBXl8jibd9Iaq2q0C8gLpHrD6+MRuyjJIS0XCDFgvdsPSvvULd55p
         6BJe5XbhklG5E9x3tobn3ECbqIPj5MWybOELx+n840CSgDeHhPQ/eWTq56YKR8jlGzNH
         Uf1Q==
X-Forwarded-Encrypted: i=1; AHgh+RogFf6Ph9X4n7e6foZn9lPtFNPqZ6Tw4iF+5Sx5TsD9flLS0iWgV0aVohBBS8BPYuT7LPACJupuKM8=@vger.kernel.org
X-Gm-Message-State: AOJu0YwCC9fvU2fDwUz3/aZhHH6gDX+zJQ6zAhg6Dsi1PNv2rbFyK5z1
	y6DZQqX7LjUoFgqY9N0rTBWxL/pLvCDG2bWuqLaik8JKtd2C0CT0Ebw4sD/VYdjw1XjpL0jRn8X
	dyL/DDq7eW0KGqxeARwpRNMUvWVa3Sw2yFY3GAp89PSEavmywZ8JbpTyfzP4=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:4dfb:b0:69d:7fdb:3416 with SMTP id
 006d021491bc7-6aebcc4bfd4mr5864216eaf.21.1786060835634; Thu, 06 Aug 2026
 17:00:35 -0700 (PDT)
Date: Thu, 06 Aug 2026 17:00:35 -0700
In-Reply-To: <00000000000063fd99061ba29d87@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a752023.b50370da.49fe0.0015.GAE@google.com>
Subject: Re: [syzbot] [nfs?] INFO: task hung in nfsd_nl_version_get_doit
From: syzbot <syzbot+41bc60511c2884783c27@syzkaller.appspotmail.com>
To: chuck.lever@oracle.com, dai.ngo@oracle.com, jlayton@kernel.org, 
	kolga@netapp.com, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	neilb@suse.de, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

syzbot has found a reproducer for the following issue on:

HEAD commit:    fcaeecb8b0cd Merge tag 'probes-fixes-v7.2-rc6' of git://gi..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=10403e49580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d69870d5e052935f
dashboard link: https://syzkaller.appspot.com/bug?extid=41bc60511c2884783c27
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=135e57b9580000

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+41bc60511c2884783c27@syzkaller.appspotmail.com

INFO: task syz-executor371:5953 blocked for more than 10 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor371 state:D stack:28568 pid:5953  tgid:5952  ppid:5951   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 nfsd_nl_version_get_doit+0x18c/0x810 fs/nfsd/nfsctl.c:1889
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
 __sys_sendto+0x48b/0x4e0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xe0/0x1c0 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fae5b4580de
RSP: 002b:00007fae5b402168 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007fae5b4026c0 RCX: 00007fae5b4580de
RDX: 0000000000000014 RSI: 00007fae5b4021e0 RDI: 0000000000000004
RBP: 0000000000000027 R08: 00007fae5b4021d4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffd0
R13: 0000000000000000 R14: 00007fff8af2b580 R15: 00007fff8af2b668
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/31:
 #0: ffffffff8ebe6200 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8ebe6200 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8ebe6200 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6775
2 locks held by kworker/u8:6/501:
 #0: ffff88801bc44140 ((wq_completion)events_unbound){+.+.}-{0:0}, at: process_one_work+0x12b1/0x1940 kernel/workqueue.c:3297
 #1: ffffc900037cfd08 ((work_completion)(&sub_info->work)){+.+.}-{0:0}, at: process_one_work+0x988/0x1940 kernel/workqueue.c:3298
2 locks held by getty/5370:
 #0: ffff8880338d00a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
2 locks held by syz-executor371/5952:
 #0: ffffffff90b4d5a8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f070880 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0xd5/0x1a80 fs/nfsd/nfsctl.c:1964
2 locks held by syz-executor371/5953:
 #0: ffffffff90b4d5a8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f070880 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_version_get_doit+0x18c/0x810 fs/nfsd/nfsctl.c:1889
1 lock held by modprobe/7138:

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 31 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
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
CPU: 0 UID: 0 PID: 7141 Comm: modprobe Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
RIP: 0010:__sanitizer_cov_trace_pc+0xb/0x70 kernel/kcov.c:213
Code: 64 00 be 03 00 00 00 5b e9 42 5e 13 03 66 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 65 8b 05 45 5b 5a 12 <48> 8b 34 24 65 48 8b 15 21 5b 5a 12 a9 00 01 ff 00 74 1b f6 c4 01
RSP: 0018:ffffc90005907130 EFLAGS: 00000202
RAX: 0000000080000000 RBX: ffff88807253d408 RCX: ffffffff8bb34482
RDX: 0000000000000002 RSI: 0000000000000000 RDI: ffff88802034ca80
RBP: ffff88807253d450 R08: 0000000000000005 R09: 0000000000000000
R10: 0000000000000002 R11: 0000000000000000 R12: 0000000000000002
R13: 0000000000000009 R14: dffffc0000000000 R15: ffff88807253d458
FS:  0000000000000000(0000) GS:ffff888123ddd000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fed66708440 CR3: 000000002b11f000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 mas_validate_child_slot lib/maple_tree.c:6784 [inline]
 mt_validate+0x11b0/0x31e0 lib/maple_tree.c:6951
 validate_mm+0xa8/0x4e0 mm/vma.c:652
 vms_complete_munmap_vmas+0x83b/0xdd0 mm/vma.c:1364
 __mmap_complete mm/vma.c:2617 [inline]
 __mmap_region+0xb42/0x2db0 mm/vma.c:2783
 mmap_region+0x35d/0x620 mm/vma.c:2860
 do_mmap+0xc63/0x12f0 mm/mmap.c:560
 vm_mmap_pgoff+0x29e/0x470 mm/util.c:581
 ksys_mmap_pgoff+0x3cb/0x610 mm/mmap.c:606
 __do_sys_mmap arch/x86/kernel/sys_x86_64.c:89 [inline]
 __se_sys_mmap arch/x86/kernel/sys_x86_64.c:82 [inline]
 __x64_sys_mmap+0x125/0x190 arch/x86/kernel/sys_x86_64.c:82
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fed669ea242
Code: 08 00 04 00 00 eb e2 90 41 f7 c1 ff 0f 00 00 75 27 55 89 cd 53 48 89 fb 48 85 ff 74 33 41 89 ea 48 89 df b8 09 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 5e 5b 5d c3 0f 1f 00 c7 05 46 40 01 00 16 00
RSP: 002b:00007ffee569ce78 EFLAGS: 00000206 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 00007fed666f6000 RCX: 00007fed669ea242
RDX: 0000000000000005 RSI: 0000000000008000 RDI: 00007fed666f6000
RBP: 0000000000000812 R08: 0000000000000000 R09: 0000000000003000
R10: 0000000000000812 R11: 0000000000000206 R12: 00007ffee569cec8
R13: 00007fed669bf580 R14: 00007ffee569d2f0 R15: 00000fffdcad39d2
 </TASK>


---
If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.
