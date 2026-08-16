Received: from mail-ot1-f77.google.com (mail-ot1-f77.google.com [209.85.210.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C7C22F8EBB
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 10:14:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.77
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786875290; cv=none; b=dsIwgH96Mhw9TQIexR+NdysZb6KOiANSNNP3pd1D4SFuK9EEFEkZb190XUYeCpR0M+aOWUdwPVZEgpbp4JMt/DFAWHI40c2DKmMrHn76I+q/GGp2s8vSH3YuaAp8bANu03gy/aAw0JrLbczkeDsLMefqejz4T7cT9y6dfO6heMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786875290; c=relaxed/simple;
	bh=CnUziLPxDwi1d8oEi6FGbhwhdTNT2X1qbbd+TDUnxmQ=;
	h=MIME-Version:Date:In-Reply-To:Message-ID:Subject:From:To:
	 Content-Type; b=W4Yl2BxNEFf6/YeEHzeowWy1eMm2zd7JEBquVefn9RxUPfx6F9eS2zfeGfYDjcahwNXC5WpPPJXN4G+hTt5S4HJ7QOqz+2E1TCtiKDxyFn1LJcsKM9b72ZUPfdjmak58ykPvsNNjX2Ya7i3E5Fp1Gknmeyx/GEvVj1kypSVOk8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.210.77
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-ot1-f77.google.com with SMTP id 46e09a7af769-7eb650e79adso2309316a34.3
        for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 03:14:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786875287; x=1787480087;
        h=content-type:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=s8mMt6t+qmsxh+EXL48+rnT3tSBb6+h53O/fAmBIDoc=;
        b=ahghUoYWxsLlcJXtM3cVin6yBWpglbxZHVUi99wc0ZKRF67t691xyFyLc7qdPaVyNN
         jxNTjiG/Akwks75ct7/JQUkee2BB/S2v3nI/QmASwjITpByyb1wv1Y4PWc2otwOSYc4l
         XHyVj3rTNbfiX7DNWTJOomDwdhUGpm0gXhnok8DLhrx6MVeQmvYiWNSrNSClGSyMS5IL
         odSC329twgcG6cxyPwBsxd+UtfnKcmiML7mdnyKvGZJ0PVb6viFjgVw05mKE/s66HP4Y
         07Cm/AEHCqaiSvVbpnbn6lNUkd9fpQ+D/iPavDSo7rDdp5njw7YXkALH02f0zHIXzC7J
         ZxEA==
X-Forwarded-Encrypted: i=1; AHgh+Roqkcv1xD3QuHd6TodTN1TlAyYy/06G4BcH9pj5nMNAF5CNuEmUHU0lrlfnMmaia6LiJI5wXWuZBG0=@vger.kernel.org
X-Gm-Message-State: AOJu0Yz86NOrwyjrAMDKtsuQHnUw2IVRS4QMIOJCy2pPGQyIxiASKlIZ
	v7+xQW72FdiHXLiODJab71YuYrzpg0VwRTrLn+9iE+rq8EhbHiDI0LwxPmQvkZtEu7GbWxIl4/y
	unKIA226bjxodRHq8fEHU4CW/bRJ0xweT3xAH7IfMyPeho0XR74IB03bH9As=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:3083:b0:6a3:8023:f344 with SMTP id
 006d021491bc7-6b0d5fa5231mr16225259eaf.2.1786875287329; Sun, 16 Aug 2026
 03:14:47 -0700 (PDT)
Date: Sun, 16 Aug 2026 03:14:47 -0700
In-Reply-To: <000000000000f8ed54061ca0d9a5@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a818d97.9ebadd4d.20b15e.0015.GAE@google.com>
Subject: Re: [syzbot] [nfs?] INFO: task hung in nfsd_umount
From: syzbot <syzbot+b568ba42c85a332a88ee@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, chuck.lever@oracle.com, 
	dai.ngo@oracle.com, harri@afaics.de, jlayton@kernel.org, kolga@netapp.com, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	neilb@suse.de, okorniev@redhat.com, syzkaller-bugs@googlegroups.com, 
	tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

syzbot has found a reproducer for the following issue on:

HEAD commit:    3eb40771c00a Merge tag 'soc-fixes-7.2-3' of git://git.kern..
git tree:       upstream
console+strace: https://syzkaller.appspot.com/x/log.txt?x=1309ba79580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=1d67342c314f228d
dashboard link: https://syzkaller.appspot.com/bug?extid=b568ba42c85a332a88ee
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=156daa25580000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=13ad9a79580000

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/21569197c3cb/disk-3eb40771.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/09af5299a851/vmlinux-3eb40771.xz
kernel image: https://storage.googleapis.com/syzbot-assets/c657b46695b7/bzImage-3eb40771.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+b568ba42c85a332a88ee@syzkaller.appspotmail.com

INFO: task syz-executor347:5620 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor347 state:D stack:22184 pid:5620  tgid:5620  ppid:5617   task_flags:0x400140 flags:0x00080001
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 nfsd_shutdown_threads+0x5b/0xf0 fs/nfsd/nfssvc.c:576
 nfsd_umount+0x3b/0x60 fs/nfsd/nfsctl.c:1365
 deactivate_locked_super+0xc1/0x1b0 fs/super.c:477
 deactivate_super fs/super.c:510 [inline]
 deactivate_super+0xe7/0x110 fs/super.c:506
 cleanup_mnt+0x21f/0x450 fs/namespace.c:1317
 task_work_run+0x150/0x240 kernel/task_work.c:233
 ptrace_notify+0xf3/0x120 kernel/signal.c:2531
 ptrace_report_syscall include/linux/ptrace.h:416 [inline]
 ptrace_report_syscall_exit include/linux/ptrace.h:478 [inline]
 arch_ptrace_report_syscall_exit include/linux/entry-common.h:213 [inline]
 syscall_exit_work include/linux/entry-common.h:248 [inline]
 syscall_exit_to_user_mode_work include/linux/entry-common.h:279 [inline]
 syscall_exit_to_user_mode include/linux/entry-common.h:316 [inline]
 do_syscall_64+0x6c0/0x870 arch/x86/entry/syscall_64.c:100
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f056f6eec17
RSP: 002b:00007ffff209c618 EFLAGS: 00000206 ORIG_RAX: 00000000000000a6
RAX: 0000000000000000 RBX: 000000000001399c RCX: 00007f056f6eec17
RDX: 0000000000000000 RSI: 0000000000000009 RDI: 00007ffff209c6d0
RBP: 00007ffff209c6d0 R08: 00007ffff209d6d0 R09: 00000000ffffffff
R10: 0000000000000000 R11: 0000000000000206 R12: 00007ffff209d740
R13: 0000555587301780 R14: 00007ffff209d740 R15: 0000000000000001
 </TASK>
INFO: task syz-executor347:5775 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor347 state:D stack:27448 pid:5775  tgid:5775  ppid:5618   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:112
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f056f6eea19
RSP: 002b:00007ffff209d708 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 645f6473666e2f2e RCX: 00007f056f6eea19
RDX: 0000000000000005 RSI: 0000200000000700 RDI: 0000000000000003
RBP: 0000000000000000 R08: 00007f056f75a222 R09: 00007f056f75a222
R10: 00007f056f75a222 R11: 0000000000000246 R12: 00007f056f75a47b
R13: 0000000000000001 R14: 00007ffff209d740 R15: 0000000000000000
 </TASK>
INFO: task syz-executor347:5776 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor347 state:D stack:27088 pid:5776  tgid:5776  ppid:5615   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:112
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f056f6eea19
RSP: 002b:00007ffff209d708 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 645f6473666e2f2e RCX: 00007f056f6eea19
RDX: 0000000000000005 RSI: 0000200000000700 RDI: 0000000000000003
RBP: 0000000000000000 R08: 00007f056f75a222 R09: 00007f056f75a222
R10: 00007f056f75a222 R11: 0000000000000246 R12: 00007f056f75a47b
R13: 0000000000000001 R14: 00007ffff209d740 R15: 0000000000000000
 </TASK>
INFO: task syz-executor347:5777 blocked for more than 144 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor347 state:D stack:27848 pid:5777  tgid:5777  ppid:5614   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:112
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f056f6eea19
RSP: 002b:00007ffff209d708 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 645f6473666e2f2e RCX: 00007f056f6eea19
RDX: 0000000000000005 RSI: 0000200000000700 RDI: 0000000000000003
RBP: 0000000000000000 R08: 00007f056f75a222 R09: 00007f056f75a222
R10: 00007f056f75a222 R11: 0000000000000246 R12: 00007f056f75a47b
R13: 0000000000000001 R14: 00007ffff209d740 R15: 0000000000000000
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/31:
 #0: ffffffff8ede8200 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8ede8200 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8ede8200 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6775
5 locks held by kworker/u8:6/152:
2 locks held by getty/5348:
 #0: ffff888037c7d0a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
2 locks held by syz-executor347/5619:
 #0: ffff88806d1b80d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: __super_lock fs/super.c:58 [inline]
 #0: ffff88806d1b80d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: __super_lock_excl fs/super.c:73 [inline]
 #0: ffff88806d1b80d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: deactivate_super fs/super.c:509 [inline]
 #0: ffff88806d1b80d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: deactivate_super+0xdf/0x110 fs/super.c:506
 #1: ffffffff8f272480 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_shutdown_threads+0x5b/0xf0 fs/nfsd/nfssvc.c:576
2 locks held by syz-executor347/5620:
 #0: ffff88806d2220d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: __super_lock fs/super.c:58 [inline]
 #0: ffff88806d2220d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: __super_lock_excl fs/super.c:73 [inline]
 #0: ffff88806d2220d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: deactivate_super fs/super.c:509 [inline]
 #0: ffff88806d2220d8 (&type->s_umount_key#67){+.+.}-{4:4}, at: deactivate_super+0xdf/0x110 fs/super.c:506
 #1: ffffffff8f272480 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_shutdown_threads+0x5b/0xf0 fs/nfsd/nfssvc.c:576
2 locks held by syz-executor347/5775:
 #0: ffff888079e4c450 (sb_writers#9){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #1: ffffffff8f272480 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:860
2 locks held by syz-executor347/5776:
 #0: ffff88807af5e450 (sb_writers#9){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #1: ffffffff8f272480 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:860
2 locks held by syz-executor347/5777:
 #0: ffff8880246f6450 (sb_writers#9){.+.+}-{0:0}, at: ksys_write+0x12a/0x250 fs/read_write.c:739
 #1: ffffffff8f272480 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xa5/0xcc0 fs/nfsd/nfsctl.c:860

=============================================

NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 31 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT(full) 
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
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 13 Comm: kworker/u8:1 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
Workqueue: bat_events batadv_mcast_mla_update
RIP: 0010:_static_cpu_has arch/x86/include/asm/cpufeature.h:101 [inline]
RIP: 0010:addr_has_metadata mm/kasan/kasan.h:334 [inline]
RIP: 0010:check_region_inline mm/kasan/generic.c:188 [inline]
RIP: 0010:kasan_check_range+0x31/0x1e0 mm/kasan/generic.c:200
Code: 0f 84 7a 01 00 00 48 89 f8 41 54 41 89 d0 48 01 f0 55 53 0f 82 e6 00 00 00 eb 0f cc cc cc 48 b8 00 00 00 00 00 00 00 ff eb 0a <48> b8 00 00 00 00 00 80 ff ff 48 39 c7 0f 82 c2 00 00 00 4c 8d 54
RSP: 0018:ffffc90000127a60 EFLAGS: 00000282
RAX: ffffc90000127b34 RBX: ffffc90000127b30 RCX: ffffffff8b8815dd
RDX: 0000000000000001 RSI: 0000000000000004 RDI: ffffc90000127b30
RBP: 0000000000000004 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: ffff88807832d8a8 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff888123cde000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00005620a0b86660 CR3: 000000000eb94000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 __asan_memset+0x23/0x50 mm/kasan/shadow.c:84
 batadv_mcast_mla_flags_get net/batman-adv/multicast.c:283 [inline]
 __batadv_mcast_mla_update net/batman-adv/multicast.c:907 [inline]
 batadv_mcast_mla_update+0x10d/0x3200 net/batman-adv/multicast.c:946
 process_one_work+0xa23/0x1940 kernel/workqueue.c:3322
 process_scheduled_works kernel/workqueue.c:3405 [inline]
 worker_thread+0x5ef/0xe50 kernel/workqueue.c:3486
 kthread+0x370/0x450 kernel/kthread.c:436
 ret_from_fork+0x72b/0xd50 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>


---
If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.
