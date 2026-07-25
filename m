Received: from mail-oa1-f79.google.com (mail-oa1-f79.google.com [209.85.160.79])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FF57381EB5
	for <linux-nfs@vger.kernel.org>; Sat, 25 Jul 2026 08:22:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.79
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784967754; cv=none; b=RhImgekxISRlO69hz4Rtc6x5Ttw/11dMxf0T9X5g2zseeF1PvO53p8Ju9jUVIG40GTlaz/BLcioCHJ/B4Ovnf5YggKOIzB2hoVXNTmIiKfB6hw+VZPsjNdnFibOGyYvCRDqMG758zltELqVQLyguRmMtItkLFdkEXRpm3VahmrA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784967754; c=relaxed/simple;
	bh=tpSTykWthf452X3xm1GKV68sHFJni97wjl5xrsfLLBA=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=JM7hZrKv08CtqC8DXxNaba/eLoHXv5BAJSwCscug4KDdQrc6TWHp7yw4q1m/syuIJVyZtkkE6mJ88nLkYlniJ8jQCPqbkkizAmgNLSj33lP0g8OqOtWt2EgA5ns/D7oVdmWRGxPC742l3+tIc/0wRmS9sRGKA1J6OqqGNGTHEIE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.160.79
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa1-f79.google.com with SMTP id 586e51a60fabf-4519ef1babeso561840fac.2
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jul 2026 01:22:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784967750; x=1785572550;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gjuAZzus3YXKMja47sP+dUzF1nzfPIPHzonsq/Gh93w=;
        b=RQsmQcmoB8i+Hq2NJhyE/Sw4lHj+Cy1Q7g3AS+sv2+vERf77ix/qVa1MssJjeWXjWb
         Ooge6rIErRwEDb90EDi4plE5jYdgXvGBez07g1Xg2ZiUItLfsmhPW1mMIPTC0YCE9lIA
         A1gqNW18cXa5+d0To00deW+b2tGK2rKO4SDWbHFJL5t6LHWeLZDx5rW/jHsO/a6nf0BR
         Vwqb10YItTut2hS6790hVHDpQBxGU3q+7jiB/WHC8qi4U3a6P8mT7jLDSJvP28YX/U3q
         XKUXTX/I6tMds/hds1wFCbnSP8JrRM/ZKsFX/JFyq7HA4aw5O8Un/3wGgQLdCV8SfqgC
         1smQ==
X-Forwarded-Encrypted: i=1; AHgh+RojUIHJ8Ch+2MtbQJZpl6jo/QiShhS6S0N3iC6GGYUBQTsSB0G+XmANi78s87npB25djcBMyN668nY=@vger.kernel.org
X-Gm-Message-State: AOJu0Yzb/pCdjA+MGXlulZQhygTYo9B2MJTag06lTkoCr/6rFr5YLzix
	aYiLvNb4M2BKVEUiswFKLRC8+6CJKWJyQkbUHoQKp84iti5OJd95qLoNoq+kIoYabZJO/UdpBqj
	T6/gYgOLkay/7VlpfSToOu8UoPjAjOb8rbk++cqLtglmru64rmqRNtC4pmts=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:2512:b0:4a4:25b4:a0be with SMTP id
 5614622812f47-4ab69f56e99mr1821298b6e.2.1784967750046; Sat, 25 Jul 2026
 01:22:30 -0700 (PDT)
Date: Sat, 25 Jul 2026 01:22:30 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a647246.a2ea2cc8.fbad6.0014.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_unlock_export_doit
From: syzbot <syzbot+406e5b77ff9375770297@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    c6859eed755d Merge tag 's390-7.2-5' of git://git.kernel.or..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=12173c32580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=d69870d5e052935f
dashboard link: https://syzkaller.appspot.com/bug?extid=406e5b77ff9375770297
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/6e4d5c4fc311/disk-c6859eed.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/9ef4aa36606f/vmlinux-c6859eed.xz
kernel image: https://storage.googleapis.com/syzbot-assets/326a92f07322/bzImage-c6859eed.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+406e5b77ff9375770297@syzkaller.appspotmail.com

INFO: task syz.4.992:9483 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.4.992       state:D stack:27512 pid:9483  tgid:9482  ppid:5613   task_flags:0x400140 flags:0x00080002
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x125c/0x6730 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0xdd/0x2c0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0xccc/0x1bd0 kernel/locking/mutex.c:821
 nfsd_nl_unlock_export_doit+0x376/0x570 fs/nfsd/nfsctl.c:2392
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
 ____sys_sendmsg+0xa4d/0xbe0 net/socket.c:2684
 ___sys_sendmsg+0x190/0x1e0 net/socket.c:2738
 __sys_sendmsg+0x160/0x210 net/socket.c:2770
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x115/0x870 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f9f3159de99
RSP: 002b:00007f9f323c5028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007f9f31825fa0 RCX: 00007f9f3159de99
RDX: 0000000004000080 RSI: 0000200000000100 RDI: 0000000000000004
RBP: 00007f9f31633eaf R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f9f31826038 R14: 00007f9f31825fa0 R15: 00007ffd3c83e1c8
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/30:
 #0: ffffffff8ebe6180 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8ebe6180 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8ebe6180 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x3d/0x184 kernel/locking/lockdep.c:6775
2 locks held by getty/5365:
 #0: ffff888037cb60a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x24/0x80 drivers/tty/tty_ldisc.c:243
 #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x419/0x14e0 drivers/tty/n_tty.c:2211
2 locks held by kworker/u8:13/7264:
 #0: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested kernel/sched/core.c:675 [inline]
 #0: ffff8880b843b520 (&rq->__lock){-.-.}-{2:2}, at: raw_spin_rq_lock_nested+0x88/0x140 kernel/sched/core.c:659
 #1: ffff8880b8524568 (psi_seq){-.-.}-{0:0}, at: psi_sched_switch kernel/sched/stats.h:218 [inline]
 #1: ffff8880b8524568 (psi_seq){-.-.}-{0:0}, at: __schedule+0x2e8e/0x6730 kernel/sched/core.c:7228
2 locks held by syz.2.979/9431:
 #0: ffffffff90b4b3c8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f070460 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0xd5/0x1a80 fs/nfsd/nfsctl.c:1964
2 locks held by syz.4.992/9483:
 #0: ffffffff90b4b3c8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8f070460 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_unlock_export_doit+0x376/0x570 fs/nfsd/nfsctl.c:2392
2 locks held by syz.0.1263/10571:
 #0: ffff888026a960d8 (&type->s_umount_key#90){+.+.}-{4:4}, at: __super_lock fs/super.c:58 [inline]
 #0: ffff888026a960d8 (&type->s_umount_key#90){+.+.}-{4:4}, at: __super_lock_excl fs/super.c:73 [inline]
 #0: ffff888026a960d8 (&type->s_umount_key#90){+.+.}-{4:4}, at: deactivate_super fs/super.c:509 [inline]
 #0: ffff888026a960d8 (&type->s_umount_key#90){+.+.}-{4:4}, at: deactivate_super+0xdf/0x110 fs/super.c:506
 #1: ffffffff8f070460 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_shutdown_threads+0x5b/0xf0 fs/nfsd/nfssvc.c:576
3 locks held by syz.6.1570/11779:
 #0: ffffffff90b4b3c8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffff888029c536e8 (nlk_cb_mutex-GENERIC){+.+.}-{4:4}, at: __netlink_dump_start+0x150/0x990 net/netlink/af_netlink.c:2410
 #2: ffffffff8f070460 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_rpc_status_get_dumpit+0xb7/0x1200 fs/nfsd/nfsctl.c:1510
2 locks held by syz.7.1620/11944:
1 lock held by syz.1.1624/11964:
 #0: ffff88802bde0ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_dev_do_close+0x26/0xb0 net/bluetooth/hci_core.c:497
2 locks held by syz-executor/11975:
 #0: ffff88807d470ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_dev_do_close+0x26/0xb0 net/bluetooth/hci_core.c:497
 #1: ffffffff8ebf1c28 (rcu_state.exp_mutex){+.+.}-{4:4}, at: exp_funnel_lock+0x27f/0x3c0 kernel/rcu/tree_exp.h:311
2 locks held by syz.5.1629/11989:
 #0: ffff888056f30ea0 (&hdev->req_lock){+.+.}-{4:4}, at: hci_dev_do_close+0x26/0xb0 net/bluetooth/hci_core.c:497
 #1: ffffffff8ebf1c28 (rcu_state.exp_mutex){+.+.}-{4:4}, at: exp_funnel_lock+0x19e/0x3c0 kernel/rcu/tree_exp.h:343

=============================================

NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 30 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/10/2026
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
CPU: 1 UID: 0 PID: 7266 Comm: kworker/u8:14 Tainted: G             L      syzkaller #0 PREEMPT(full) 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 06/10/2026
Workqueue: events_unbound toggle_allocation_gate
RIP: 0010:__sanitizer_cov_trace_pc+0xb/0x70 kernel/kcov.c:213
Code: 64 00 be 03 00 00 00 5b e9 12 90 13 03 66 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 65 8b 05 85 b3 59 12 <48> 8b 34 24 65 48 8b 15 61 b3 59 12 a9 00 01 ff 00 74 1b f6 c4 01
RSP: 0018:ffffc900031afb08 EFLAGS: 00000093
RAX: 0000000080000000 RBX: 0000000000000000 RCX: fffff52000635f45
RDX: ffff888050774a80 RSI: ffffffff81f53213 RDI: 0000000000000001
RBP: 0000000000000008 R08: 0000000000000000 R09: ffffed10170a4c50
R10: ffff8880b8526283 R11: 0000000000000000 R12: 0000000100004758
R13: ffff88801bc44000 R14: ffffffff9b75e988 R15: ffffffff9b75e948
FS:  0000000000000000(0000) GS:ffff888123ee7000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ffcf3808e68 CR3: 000000000e992000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 __queue_delayed_work+0x336/0x450 kernel/workqueue.c:2585
 queue_delayed_work_on+0x180/0x1e0 kernel/workqueue.c:2620
 queue_delayed_work include/linux/workqueue.h:714 [inline]
 toggle_allocation_gate mm/kfence/core.c:920 [inline]
 toggle_allocation_gate+0x18e/0x2d0 mm/kfence/core.c:903
 process_one_work+0xa23/0x1940 kernel/workqueue.c:3322
 process_scheduled_works kernel/workqueue.c:3405 [inline]
 worker_thread+0x5ef/0xe50 kernel/workqueue.c:3486
 kthread+0x370/0x450 kernel/kthread.c:436
 ret_from_fork+0x72b/0xd50 arch/x86/kernel/process.c:158
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
