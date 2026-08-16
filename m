Received: from mail-oo1-f77.google.com (mail-oo1-f77.google.com [209.85.161.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 514DA3D16F0
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 09:28:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.77
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786872521; cv=none; b=IaxhgradHMgYjiCA37uI9sQX+KPasJp3v8RaCjgYOwu0DJs/L6S8iD+FpXBbIwz1xP7yUeMm6+M4lK/uAvFQMfqOgXexLMNIs+HGztq9EK6Z2ql9k6hj0EQjZsFeThCAw3DBQ9oE0MV7HctDE+KccRM5fX17ed5C+RNQ2e0NXco=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786872521; c=relaxed/simple;
	bh=hrkGdGg5j1HBhaAqyoa1Jp67npKhJg2oWeGrroCdiW8=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=uYaRhDA5q3ClebCEa8rOCtJZ8RKI69XVcu1XAyNoUHD502JGNecuFFHf1Dfsoe/5sG47eWDY8xCf7WDc9lpAgFpKYvVbF6MzQUpXMf0mTArIgSMOsnv7u9T9+WWH8brTaOaNbjM/CV+SnRunNR+JOqBohEh3bOxeRTW98zc3cwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.77
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f77.google.com with SMTP id 006d021491bc7-6a313ec13ceso3215739eaf.2
        for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 02:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786872518; x=1787477318;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=A3CdUYnl4hlKbPxhMirbQwn42q6d6JEaje6+kissc3I=;
        b=XuxMwHTW7wH6T5emKfJtM9olwiDCi7j9FmBVqsTbbLUX/uxlPDNvNCbtXt8bAMRfm7
         Bd2I+pzzw/JJk95elpKcsoMeCisPoprjj18IJoKeO25dGa2wunUFLTZBgo8P8Bcb1d4+
         utspSHEnuCbpcKTbcQ8jPagUgNaOIMKMFq1RHJi1JMdQuJbruqrkBdEM3yIA+2Elwb1Q
         VdRDat4x+nDyx5qwcGwgImxDEMufC4kgLStXAXrPZn+pIR4L1ShxVyaLxjw51dv3wrMp
         DbIoT6gf3OS/BmPcWMGaN0xWXRSpvA9pFT36Jy0UAcuE4MV0Mpduq2VGcsEtA1anVi/U
         GRvw==
X-Forwarded-Encrypted: i=1; AHgh+RpvRO+RTBnjdBiWlGhJJrqcDRlIzWqsjAlaquZmqK/RsFZjNQt79+QdIWZERyZpc7wnxS0wuSNI20I=@vger.kernel.org
X-Gm-Message-State: AOJu0Yw6Jp8I7D7qRHd7w8GxcMT4xg1DgVKcR/RLXX2LvkGAaa53h7pr
	JIWXicNHaI0GOJUskpwP6EOhOlrx9swp4aSg++zMGeZI63q/bnnlHDAKJIEJc7LtiLW7rFFGNSr
	t4+HXuMcRuQPbFpXOTWsmuhDsMOGz/CXWiEeGn/ErwVvp+ynHxphyncWYmsg=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:1992:b0:6b0:529f:8757 with SMTP id
 006d021491bc7-6b0d68e184dmr15413780eaf.25.1786872518283; Sun, 16 Aug 2026
 02:28:38 -0700 (PDT)
Date: Sun, 16 Aug 2026 02:28:38 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a8182c6.9ebadd4d.20b15e.0014.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in write_versions
From: syzbot <syzbot+1c807916bc4bb0c1c340@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    3d6d817622b0 Merge tag 'scsi-fixes' of git://git.kernel.or..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=113f4c79580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=aaf0da806f995318
dashboard link: https://syzkaller.appspot.com/bug?extid=1c807916bc4bb0c1c340
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/73702470016c/disk-3d6d8176.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/1287b74eb82e/vmlinux-3d6d8176.xz
kernel image: https://storage.googleapis.com/syzbot-assets/d3ecc656bd20/bzImage-3d6d8176.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+1c807916bc4bb0c1c340@syzkaller.appspotmail.com

INFO: task syz.2.2321:12662 blocked for more than 144 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.2.2321      state:D stack:28424 pid:12662 tgid:12654 ppid:5623   task_flags:0x400040 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 write_versions+0x95/0xe30 fs/nfsd/nfsctl.c:701
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:112
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7fc2ce99e0d9
RSP: 002b:00007fc2cf87c028 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007fc2cec26090 RCX: 00007fc2ce99e0d9
RDX: 0000000000000002 RSI: 00002000000001c0 RDI: 0000000000000005
RBP: 00007fc2cea35024 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007fc2cec26128 R14: 00007fc2cec26090 R15: 00007ffcac70e688
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/31:
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
2 locks held by getty/5362:
 #0: ffff8880357360a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc9000322b2e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x45a/0x1360 drivers/tty/n_tty.c:2211
3 locks held by syz.2.2321/12657:
 #0: ffff88807834e9b0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x246/0x320 fs/file.c:1259
 #1: ffff88807fb94450 (sb_writers#27){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #1: ffff88807fb94450 (sb_writers#27){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #2: ffffffff8ee8dd80 (nfsd_mutex){+.+.}-{4:4}, at: write_ports+0xb5/0xd10 fs/nfsd/nfsctl.c:860
3 locks held by syz.2.2321/12662:
 #0: ffff888022f8d5f0 (&f->f_pos_lock){+.+.}-{4:4}, at: fdget_pos+0x246/0x320 fs/file.c:1259
 #1: ffff88807fb94450 (sb_writers#27){.+.+}-{0:0}, at: file_start_write include/linux/fs.h:2733 [inline]
 #1: ffff88807fb94450 (sb_writers#27){.+.+}-{0:0}, at: vfs_write+0x22b/0xba0 fs/read_write.c:683
 #2: ffffffff8ee8dd80 (nfsd_mutex){+.+.}-{4:4}, at: write_versions+0x95/0xe30 fs/nfsd/nfsctl.c:701
2 locks held by syz.3.2488/13375:
 #0: ffffffff900988e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8dd80 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_unlock_filesystem_doit+0x2af/0x400 fs/nfsd/nfsctl.c:2345
1 lock held by syz.6.2904/14762:

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 31 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
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
CPU: 0 UID: 0 PID: 0 Comm: swapper/0 Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/16/2026
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: cb 7e 02 e9 9e 8f 3f f5 cc cc cc 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 0f 00 2d b3 be 18 00 fb f4 <e9> 77 8f 3f f5 cc cc cc cc cc cc cc cc cc cc cc cc 90 90 90 90 90
RSP: 0018:ffffffff8e807de0 EFLAGS: 00000246
RAX: 00000000006a9d0f RBX: ffffffff819b4450 RCX: 0000000080000001
RDX: 0000000000000001 RSI: ffffffff8e228edb RDI: ffffffff8c4bbf80
RBP: ffffffff8e807eb8 R08: ffff8880b86338db R09: 1ffff110170c671b
R10: dffffc0000000000 R11: ffffed10170c671c R12: 0000000000000000
R13: 1ffffffff1d11de8 R14: 1ffffffff1d00fc4 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888124f55000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00002000002a8030 CR3: 0000000075734000 CR4: 0000000000350ef0
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
