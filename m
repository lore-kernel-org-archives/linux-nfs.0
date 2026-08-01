Received: from mail-oi1-f207.google.com (mail-oi1-f207.google.com [209.85.167.207])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0F44215075
	for <linux-nfs@vger.kernel.org>; Sat,  1 Aug 2026 00:01:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.207
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785542499; cv=none; b=btcO+Id3UoSCv5UQ92rMsASLAvcvRFck+loItRc/kSeKM1+GhKcQ0EuYFpvj8VDV5TZ9rZn11UN4noVe50wlDMXsB6y8FyFYLx3KAmzEjeGUB6LPYGiKNzIIhsu4ye0eMHmxzDd2jzoHsH5UMSGhdL5VZ7KjsWgSyo6VU/LjFxU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785542499; c=relaxed/simple;
	bh=9rTwtUK6N5py99t5gNz6a6dHqff69BW7CqU/JEA7HNQ=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=Pn7CtFOeN/XqHf1X8U7oprE0qqzQzvsHGth3PMn6/vVWfU7OJj83lvwhqxJulW21ahTgIKgWIQiOBNPo6KGeqDtHGCxinco1tE7JsuhQq4U1Ydq7h/39CAUvTMAXKxh6Vb9wNl1RDlHPd/4kcZR0PCMa/wnV3W4VszFUoBGbrgY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.207
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f207.google.com with SMTP id 5614622812f47-495b0cf250dso1028573b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 17:01:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785542494; x=1786147294;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ZygoyrJx+CJoTNK3/+0Puk0CyfKJLOZSA4fCHuBLMbU=;
        b=rDCDGop1wkS4mRim9g07f9a64wBdZnHA9Glw+2c4A3xtJ0QLM1DQHpqzfsAYaTN8zg
         AfQcSicRmp8MUYwrNL3vnQqhIDBfpUrEBYvdiZZ6phDXyPM7t0+szR09lohu9ecweRer
         Z03XzR2GEf01xK5qgZMlcOwyu6fkUSKdkgujHYxFkeKCOMNBGCKio3WQuipIoALir3Vg
         Z26kInZTnSHvqhhD6UiBe5z3Un7fr2xgL5itMC25bH1K+MdkHNFAbSDUCHfY0dsdpLI7
         KRY3R2Vw7AbxH+eQI/KE5/53wEYAD0IuzAxKXjuqxJNFURNF1qN8MCU6dtp8UIST8X9Y
         SjRQ==
X-Forwarded-Encrypted: i=1; AHgh+RrSKc5R+3OsGQNxLaKYFzobLJ+zJ490ROE0IL0+38HupMo6Zlo7fgMgzcrNhVCSo9rACv04leDxur8=@vger.kernel.org
X-Gm-Message-State: AOJu0YybOCDBatyRpk9T0FPC9Y/kqvK05+ZkSPWLM4kR2OAnRUFmxHZp
	QdErg6CjK/BDt7qEyoMEJnZ2DTE7d/itSz9L8OfKG9Bqd1ZYZ/de8gqldoArA/PlV6MJCktCFXG
	csXEUO9sYcU6kBv2aY9V9MqZwRl9jBxxuLq2gJE14zu64woxPukfIDj/KtrA=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:f08:b0:496:b7c:274b with SMTP id
 5614622812f47-4af5e2f5ca4mr4020897b6e.19.1785542494586; Fri, 31 Jul 2026
 17:01:34 -0700 (PDT)
Date: Fri, 31 Jul 2026 17:01:34 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a6d375e.2d659fcc.1d46f5.01a3.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in write_ports
From: syzbot <syzbot+0f7085f07e9cfba423cd@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    f5098b6bae76 Linux 7.2-rc5
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=136ad8c6580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4e38b15c29e6a1d9
dashboard link: https://syzkaller.appspot.com/bug?extid=0f7085f07e9cfba423cd
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=124b7fde580000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=137391b9580000

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/7d76d25427fa/disk-f5098b6b.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/b2a3f9e7cb3e/vmlinux-f5098b6b.xz
kernel image: https://storage.googleapis.com/syzbot-assets/e4d49cdcd799/bzImage-f5098b6b.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+0f7085f07e9cfba423cd@syzkaller.appspotmail.com

INFO: task syz.0.17:6054 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.0.17        state:D stack:27304 pid:6054  tgid:6054  ppid:5761   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f0fa5b9de99
RSP: 002b:00007ffc681b68d8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f0fa5e25fa0 RCX: 00007f0fa5b9de99
RDX: 0000000000000009 RSI: 00002000000001c0 RDI: 0000000000000003
RBP: 00007f0fa5c33eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f0fa5e25fac R14: 00007f0fa5e25fa0 R15: 00007f0fa5e25fa0
 </TASK>
INFO: task syz.2.19:6059 blocked for more than 143 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.2.19        state:D stack:27192 pid:6059  tgid:6059  ppid:5769   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f8ff879de99
RSP: 002b:00007ffe5a9bf368 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f8ff8a25fa0 RCX: 00007f8ff879de99
RDX: 0000000000000009 RSI: 00002000000001c0 RDI: 0000000000000003
RBP: 00007f8ff8833eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f8ff8a25fac R14: 00007f8ff8a25fa0 R15: 00007f8ff8a25fa0
 </TASK>
INFO: task syz.3.20:6060 blocked for more than 144 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.3.20        state:D stack:27304 pid:6060  tgid:6060  ppid:5781   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f566399de99
RSP: 002b:00007ffe568d8408 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f5663c25fa0 RCX: 00007f566399de99
RDX: 0000000000000009 RSI: 00002000000001c0 RDI: 0000000000000003
RBP: 00007f5663a33eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f5663c25fac R14: 00007f5663c25fa0 R15: 00007f5663c25fa0
 </TASK>
INFO: task syz.4.21:6061 blocked for more than 144 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.4.21        state:D stack:27304 pid:6061  tgid:6061  ppid:5772   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f766159de99
RSP: 002b:00007ffef3842888 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f7661825fa0 RCX: 00007f766159de99
RDX: 0000000000000009 RSI: 00002000000001c0 RDI: 0000000000000003
RBP: 00007f7661633eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f7661825fac R14: 00007f7661825fa0 R15: 00007f7661825fa0
 </TASK>
INFO: task syz.5.22:6062 blocked for more than 144 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.5.22        state:D stack:26128 pid:6062  tgid:6062  ppid:5776   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7ffba1b9de99
RSP: 002b:00007ffe462e6b48 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007ffba1e25fa0 RCX: 00007ffba1b9de99
RDX: 0000000000000009 RSI: 00002000000001c0 RDI: 0000000000000003
RBP: 00007ffba1c33eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007ffba1e25fac R14: 00007ffba1e25fa0 R15: 00007ffba1e25fa0
 </TASK>

Showing all locks held in the system:
2 locks held by ksoftirqd/1/23:
1 lock held by khungtaskd/32:
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
2 locks held by kworker/u8:2/37:
 #0: ffff8880b863b160 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested+0x2d/0x160 kernel/sched/core.c:667
 #1: ffff8880b8624440 (psi_seq){-.-.}-{0:0}, at: psi_task_switch+0x57/0x7d0 kernel/sched/psi.c:933
3 locks held by kworker/u9:0/51:
 #0: ffff888053d1d940 ((wq_completion)hci16){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff888053d1d940 ((wq_completion)hci16){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc90000bb7c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc90000bb7c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff888056114ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_cmd_sync_work+0x1cb/0x3f0 net/bluetooth/hci_sync.c:331
3 locks held by kworker/u9:1/4937:
 #0: ffff888036cb5140 ((wq_completion)hci14){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff888036cb5140 ((wq_completion)hci14){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc9000fb77c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc9000fb77c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff8880560d0ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_cmd_sync_work+0x1cb/0x3f0 net/bluetooth/hci_sync.c:331
1 lock held by klogd/4976:
 #0: ffff8880b873b160 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested+0x2d/0x160 kernel/sched/core.c:667
2 locks held by getty/5378:
 #0: ffff8880368890a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc9000322b2e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x45a/0x1360 drivers/tty/n_tty.c:2211
3 locks held by kworker/u9:2/5658:
 #0: ffff88807b416140 ((wq_completion)hci13){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88807b416140 ((wq_completion)hci13){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc900031e7c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc900031e7c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff8880560c0ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_cmd_sync_work+0x1cb/0x3f0 net/bluetooth/hci_sync.c:331
2 locks held by syz-executor/5763:
 #0: ffff88803587c0d8 (&type->s_umount_key#54){+.+.}-{4:4}, at: __super_lock fs/super.c:58 [inline]
 #0: ffff88803587c0d8 (&type->s_umount_key#54){+.+.}-{4:4}, at: __super_lock_excl fs/super.c:73 [inline]
 #0: ffff88803587c0d8 (&type->s_umount_key#54){+.+.}-{4:4}, at: deactivate_super+0xa9/0xe0 fs/super.c:509
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_shutdown_threads+0x4e/0xd0 fs/nfsd/nfssvc.c:576
3 locks held by kworker/u9:3/5764:
 #0: ffff888036cb2140 ((wq_completion)hci15){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff888036cb2140 ((wq_completion)hci15){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc90003267c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc90003267c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff888056134ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_cmd_sync_work+0x1cb/0x3f0 net/bluetooth/hci_sync.c:331
3 locks held by kworker/u9:4/5767:
 #0: ffff88807fb25140 ((wq_completion)hci12){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88807fb25140 ((wq_completion)hci12){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc90003227c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc90003227c40 ((work_completion)(&hdev->cmd_sync_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffff88805026cea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_cmd_sync_work+0x1cb/0x3f0 net/bluetooth/hci_sync.c:331
2 locks held by syz.0.17/6054:
 #0: ffff888055c4a450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888055c4a450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.2.19/6059:
 #0: ffff88802d648450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88802d648450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.3.20/6060:
 #0: ffff8880317dc450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880317dc450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.4.21/6061:
 #0: ffff88807afa0450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88807afa0450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.5.22/6062:
 #0: ffff8880291b2450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880291b2450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.6.24/6224:
 #0: ffff8880212bc450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880212bc450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.9.27/6306:
 #0: ffff888035878450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888035878450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.7.25/6307:
 #0: ffff888026a9e450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888026a9e450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.8.26/6308:
 #0: ffff888035008450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888035008450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.1.28/6309:
 #0: ffff88802959c450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88802959c450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.0.29/6310:
 #0: ffff88802a752450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88802a752450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.2.30/6347:
 #0: ffff888078dee450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888078dee450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.6.34/6540:
 #0: ffff88805dee0450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88805dee0450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.4.32/6547:
 #0: ffff88807949c450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88807949c450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.3.31/6548:
 #0: ffff8880570d0450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880570d0450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.5.33/6549:
 #0: ffff88807d9d6450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88807d9d6450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.7.35/6550:
 #0: ffff8880520c6450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880520c6450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.8.36/6592:
 #0: ffff888077862450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888077862450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.9.37/6772:
 #0: ffff88804c034450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88804c034450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.1.38/6788:
 #0: ffff8880519a4450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880519a4450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.2.40/6789:
 #0: ffff8880335a2450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880335a2450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.0.39/6814:
 #0: ffff88805784e450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88805784e450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.6.41/6821:
 #0: ffff88804e726450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88804e726450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.3.42/6822:
 #0: ffff88804d306450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88804d306450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.4.43/6955:
 #0: ffff8880457c4450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880457c4450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.5.44/7035:
 #0: ffff888047402450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888047402450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.7.45/7050:
 #0: ffff888046504450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888046504450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.8.46/7058:
 #0: ffff888021b2c450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888021b2c450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.1.48/7064:
 #0: ffff888044452450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888044452450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.9.47/7065:
 #0: ffff888031862450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888031862450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.2.49/7104:
 #0: ffff8880343da450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff8880343da450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.0.50/7251:
 #0: ffff888050c6a450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888050c6a450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.6.52/7272:
 #0: ffff88807b882450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88807b882450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.3.51/7293:
 #0: ffff888046016450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888046016450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.4.53/7297:
 #0: ffff88804ca3c450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88804ca3c450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.5.54/7306:
 #0: ffff88802b398450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88802b398450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.8.55/7338:
 #0: ffff88805fd62450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88805fd62450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.7.56/7456:
 #0: ffff888040928450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888040928450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.1.57/7551:
 #0: ffff888044578450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888044578450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.9.58/7565:
 #0: ffff888057422450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888057422450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.2.59/7571:
 #0: ffff888038b0e450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff888038b0e450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.0.60/7574:
 #0: ffff88803525c450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88803525c450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
2 locks held by syz.6.61/7575:
 #0: ffff88803d480450 (sb_writers#12){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #0: ffff88803d480450 (sb_writers#12){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #1: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 32 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
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
CPU: 0 UID: 0 PID: 0 Comm: swapper/0 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: dc 7e 02 e9 fe 5f 3f f5 cc cc cc 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 0f 00 2d 53 8e 18 00 fb f4 <e9> d7 5f 3f f5 cc cc cc cc cc cc cc cc cc cc cc cc 90 90 90 90 90
RSP: 0018:ffffffff8e807de0 EFLAGS: 00000242
RAX: 000000000020275d RBX: ffffffff819b433c RCX: 0000000080000001
RDX: 0000000000000001 RSI: ffffffff8e22d06b RDI: ffffffff8c4bdc80
RBP: ffffffff8e807eb8 R08: ffff8880b86338db R09: 1ffff110170c671b
R10: dffffc0000000000 R11: ffffed10170c671c R12: 0000000000000000
R13: 1ffffffff1d11de8 R14: 1ffffffff1d00fc4 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888124f4e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055af1b803ed0 CR3: 000000007f555000 CR4: 0000000000350ef0
Call Trace:
 <TASK>
 arch_safe_halt arch/x86/kernel/process.c:767 [inline]
 default_idle+0x9/0x20 arch/x86/kernel/process.c:768
 default_idle_call+0x72/0xb0 kernel/sched/idle.c:122
 cpuidle_idle_call kernel/sched/idle.c:199 [inline]
 do_idle+0x1cc/0x540 kernel/sched/idle.c:355
 cpu_startup_entry+0x43/0x60 kernel/sched/idle.c:454
 rest_init+0x2de/0x300 init/main.c:717
 start_kernel+0x392/0x3e0 init/main.c:1175
 x86_64_start_reservations+0x24/0x30 arch/x86/kernel/head64.c:310
 x86_64_start_kernel+0x137/0x1b0 arch/x86/kernel/head64.c:291
 common_startup_64+0x13e/0x157
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
