Received: from mail-oa1-f79.google.com (mail-oa1-f79.google.com [209.85.160.79])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54DA9364940
	for <linux-nfs@vger.kernel.org>; Sat,  1 Aug 2026 00:35:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.79
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785544544; cv=none; b=j2WwbCLj2wkWpNdheKFVa97AwrzRuiU9d25hGOKqe5o8lE0Wv0tXMJbub6Y3XnIVD5OQUL+RFyc7WPKFwlg3aC14sGMKTLYM94VFr/1P/thS1Bh9ryk1Fr4K2KoNK9uL5IO+mCaFjLGmngfX6YNdEypWVKUgxdd/rBvAim7exFs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785544544; c=relaxed/simple;
	bh=Ni3hPvZKt0yLyM4wIy0RCmD7A9TD5a0xi9tUG6RuP8A=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=ZEV51JC8cbWps5TSpbT6ozAG7WtHz9amJAyjGub25K08pK5IH7t/zGJqj/CTIKVzcDbYTpy2ApaOHgmoKJrRQozptdzYiik+eSflfPBdZNpLk461VTwsbH1DWbbwBz2MciOwZaxJms1N7QaCbAOgKpRp04ZifIEBEIy9ohdP6rM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.160.79
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa1-f79.google.com with SMTP id 586e51a60fabf-451fd211101so844087fac.1
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 17:35:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785544535; x=1786149335;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=KPXMT55sbhmcUpxg1X7xsd7ZaTEXntIRKt3AOn16qFo=;
        b=fo08SUMCw96nhLw8tIIwt0fx7lIzZnTXCnqK2EL2iArNzpwX+OWPx0NAA9zzPtn1R7
         AEJW6JoRDdeuJ7MAMQJ3WxYc+Z7pcK8/fGUpLSCXID42V4I0CWHy3e7MgCGeKT6II1db
         Vy4cRMURH4+VRGxVEFnglqb0tzaDT+ZQ2XxnXlIrHcRXJcpzxc0HugxFYKxnbxc3mm1Y
         Hdc8BJNIBgjPYeDiaII0qK7ZcvW4htz03VCGNHjbEBe1AxBzfZjJo1UkICGYyLh+fexR
         M44fTb1A284SUInfIDLfkjhOS0VZMDjM1A/4uxtk64s1OYnryARynOZiu2ZCFZdKbyOp
         LKpA==
X-Forwarded-Encrypted: i=1; AHgh+RrRc8JXttHD+FSWOBfmZ+M2X3KrAWEMTpSb3V1rahH+QV8E0E5QtxylJYtYIhTxHDuNQINpp6bJbJU=@vger.kernel.org
X-Gm-Message-State: AOJu0YwnQjrmuI/EEsQrv513lx3Rk8LD8LK/R8UNjW9ogJ/34I8y0S+o
	JkN8uYcfO7Wyt/gpNfiHk6AzlaSsz5WxLovvjM6DGefRV9J8okYT9IwzGPSE2IP4crNMmq/dojL
	CHVKKaM+IuK5nIA6j9h736XanFatb3fwcWaiVf9e/dfCaedP9G472m1gIZu4=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:1208:b0:496:2b3:ae71 with SMTP id
 5614622812f47-4af5e3536b2mr3549602b6e.18.1785544535339; Fri, 31 Jul 2026
 17:35:35 -0700 (PDT)
Date: Fri, 31 Jul 2026 17:35:35 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a6d3f57.6ce73036.24301b.0010.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in write_threads
From: syzbot <syzbot+78013a8f4497a445a448@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    3708dd948844 Merge tag 'pm-7.2-rc6' of git://git.kernel.or..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=117571b9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4e38b15c29e6a1d9
dashboard link: https://syzkaller.appspot.com/bug?extid=78013a8f4497a445a448
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/52be26782cb7/disk-3708dd94.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/75068ef5ea5b/vmlinux-3708dd94.xz
kernel image: https://storage.googleapis.com/syzbot-assets/cacb93088fbd/bzImage-3708dd94.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+78013a8f4497a445a448@syzkaller.appspotmail.com

INFO: task syz.8.803:9466 blocked for more than 143 seconds.
      Tainted: G S           L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.8.803       state:D stack:28424 pid:9466  tgid:9455  ppid:6451   task_flags:0x400040 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_threads+0x39d/0x5a0 fs/nfsd/nfsctl.c:432
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f8e6f19e019
RSP: 002b:00007f8e700e2028 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f8e6f426090 RCX: 00007f8e6f19e019
RDX: 0000000000000002 RSI: 00002000000001c0 RDI: 0000000000000003
RBP: 00007f8e6f23500c R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f8e6f426128 R14: 00007f8e6f426090 R15: 00007ffd23643708
 </TASK>

Showing all locks held in the system:
2 locks held by ksoftirqd/0/15:
1 lock held by khungtaskd/31:
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
1 lock held by udevd/4988:
2 locks held by getty/5377:
 #0: ffff888035e060a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x45a/0x1360 drivers/tty/n_tty.c:2211
1 lock held by udevd/6239:
3 locks held by kworker/u8:20/8926:
 #0: ffff88803251e940 ((wq_completion)ipv6_addrconf){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88803251e940 ((wq_completion)ipv6_addrconf){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc90005677c40 ((work_completion)(&(&ifa->dad_work)->work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc90005677c40 ((work_completion)(&(&ifa->dad_work)->work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #2: ffffffff9002dac0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_net_lock include/linux/rtnetlink.h:130 [inline]
 #2: ffffffff9002dac0 (rtnl_mutex){+.+.}-{4:4}, at: addrconf_dad_work+0x116/0x15c0 net/ipv6/addrconf.c:4229
3 locks held by syz.8.803/9460:
 #0: ffff88802bbb17b0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x246/0x320 fs/file.c:1259
 #1: ffff8880783f8450 (sb_writers#37){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #1: ffff8880783f8450 (sb_writers#37){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #2: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
3 locks held by syz.8.803/9466:
 #0: ffff88802ba83270 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x246/0x320 fs/file.c:1259
 #1: ffff8880783f8450 (sb_writers#37){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #1: ffff8880783f8450 (sb_writers#37){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #2: ffffffff8ee8e620 (nfsd_mutex){+.+.}-{4:4}, at: write_threads+0x39d/0x5a0 fs/nfsd/nfsctl.c:432
2 locks held by syz.5.1691/12709:
 #0: ffffffff9002dac0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/core/rtnetlink.c:80 [inline]
 #0: ffffffff9002dac0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_net_lock include/linux/rtnetlink.h:130 [inline]
 #0: ffffffff9002dac0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_dellink+0x41b/0x810 net/core/rtnetlink.c:3635
 #1: ffffffff8eb5ff68 (rcu_state.exp_mutex){+.+.}-{4:4}, at: exp_funnel_lock kernel/rcu/tree_exp.h:311 [inline]
 #1: ffffffff8eb5ff68 (rcu_state.exp_mutex){+.+.}-{4:4}, at: synchronize_rcu_expedited+0x2d0/0x770 kernel/rcu/tree_exp.h:961

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 31 Comm: khungtaskd Tainted: G S           L      syzkaller #0 PREEMPT(full) 
Tainted: [S]=CPU_OUT_OF_SPEC, [L]=SOFTLOCKUP
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
CPU: 0 UID: 0 PID: 0 Comm: swapper/0 Tainted: G S           L      syzkaller #0 PREEMPT(full) 
Tainted: [S]=CPU_OUT_OF_SPEC, [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: 2c 7e 02 e9 fe 9f 3e f5 cc cc cc 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 0f 00 2d d3 ce 17 00 fb f4 <e9> d7 9f 3e f5 cc cc cc cc cc cc cc cc cc cc cc cc 90 90 90 90 90
RSP: 0018:ffffffff8e807de0 EFLAGS: 00000246
RAX: 000000000016a9f9 RBX: ffffffff819b5450 RCX: 0000000080000001
RDX: 0000000000000001 RSI: ffffffff8e22e33d RDI: ffffffff8c4bdd80
RBP: ffffffff8e807eb8 R08: ffff8880b86338db R09: 1ffff110170c671b
R10: dffffc0000000000 R11: ffffed10170c671c R12: 0000000000000000
R13: 1ffffffff1d11de8 R14: 1ffffffff1d00fc4 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888124f4d000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f5e6f9ef2f8 CR3: 0000000074204000 CR4: 0000000000350ef0
Call Trace:
 <TASK>
 arch_safe_halt arch/x86/kernel/process.c:767 [inline]
 default_idle+0x9/0x20 arch/x86/kernel/process.c:768
 default_idle_call+0x72/0xb0 kernel/sched/idle.c:122
 cpuidle_idle_call kernel/sched/idle.c:199 [inline]
 do_idle+0x2e0/0x540 kernel/sched/idle.c:355
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

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
