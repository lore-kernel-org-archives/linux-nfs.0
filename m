Received: from mail-oa2-f0.google.com (mail-oa2-f0.google.com [74.125.231.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 803803E3D86
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 08:33:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.64
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787819628; cv=none; b=LmPrep/o7jM2y4arByk7/tnE/2KGr7+STifuFs44g21XQlKcH1YuzaeRM0qQoFMe20yMK9NCTEOAtexKBqzUIz+hIfka05xZmANiIXPSUxa6AOQ6BgX/vkv3PzvVSWY6x6V1YbSVHkoeop2bbA0uihD+CMhT2kU+m2RfIRdutcc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787819628; c=relaxed/simple;
	bh=NgqDcl/yH06Y2+qPvSSVSoKHhTGUH6rGtqU9TFKu15E=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=HP5HoaZdrIGFYGF5IF12l19PP8lf7htj7Kd6thIwclbVBhc6x10VQQCUVkHPDnAqjiz+2B3DFWLyfDQv50aBukh9fG7SS6qCdvywwHkg/k2S1+ZQHTfQ2ilOrm7Xk6hsxULHAszVIudtyJJWEI9qI7zcFU8GONrB4MsXZsXl6A0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=74.125.231.64
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa2-f0.google.com with SMTP id 586e51a60fabf-451bde4ab1cso718245fac.1
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 01:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787819623; x=1788424423;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=NIotZKdxSe5KTblEX96zuwJ9Zuvss2SCX17qrgz4rGw=;
        b=nXREMYIE+JOVoh3OoBv0YTLEp8s3Aq+LiGhPXRhdwVXUxVXkADo+zJ3sDoqZ8bAEFN
         JOxXMY8pIXhZrdC1EN4HUOo3/TrVQofnb0C582rVD3FUHYEZPr77smvp5ArKi59Ah8lb
         BoAvwg8lHDoD3BzwCTAYYTx+UBJysRFok9+aqpyZ4RmFwM3dxcDX/ZpO+/IHk+JEsDbD
         p/Gz13AO7OQDvPc8NcSJXFm+IKaaZBrtuICq0qKOJGc3JZCB03hrCt3gVlcTNnvaGtkH
         N8ctMgu1/FCPLGO0XqOCwmDRdCDWYD8poFnafN+j1tAqkJw77QpiDnE1pXcNDfT8E+CM
         CUwA==
X-Forwarded-Encrypted: i=1; AHgh+RrC1U+HbIwKf1rQPRvAiGm6mIRr+0/BKLBG6ArxtwiNDPXAcvjF+wOr2yT65bi3gbVue3udcg/Sdj0=@vger.kernel.org
X-Gm-Message-State: AFuF++lbz4KWQ02sPZRfznIr7wxQyOqIp8MLmNFshFg5YOSr1WU1cbVe
	YsBnrfImR4eMf1NIWsZ/gpRr7oprtE/KtTocr21FCZ4JhvYiisAzp/XJv1Dbthh4PjNX3dPCRpC
	8WXx/KUkdsiMoqP+0AShrB7kDHFcfJLEvzJyhxb3ri9NgGl9sbOFTEwWXYc0=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:81f:b0:6b1:b157:bb50 with SMTP id
 006d021491bc7-6b1b157c05amr4621621eaf.27.1787819622727; Thu, 27 Aug 2026
 01:33:42 -0700 (PDT)
Date: Thu, 27 Aug 2026 01:33:42 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a8ff666.27659fcc.2ceef7.0010.GAE@google.com>
Subject: [syzbot] [nfs?] INFO: task hung in nfsd_nl_svc_export_get_reqs_dumpit
From: syzbot <syzbot+e7cea59fd1cb261746b5@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    f9a2394a2348 Merge tag 'mm-hotfixes-stable-2026-08-06-18-4..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1349cfb9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e2828a6233373d18
dashboard link: https://syzkaller.appspot.com/bug?extid=e7cea59fd1cb261746b5
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/8a66bf16c228/disk-f9a2394a.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/89268e08fed4/vmlinux-f9a2394a.xz
kernel image: https://storage.googleapis.com/syzbot-assets/414a08d48dff/bzImage-f9a2394a.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+e7cea59fd1cb261746b5@syzkaller.appspotmail.com

INFO: task syz.1.4033:18710 blocked for more than 143 seconds.
      Tainted: G             L      syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz.1.4033      state:D stack:25520 pid:18710 tgid:18709 ppid:5586   task_flags:0x400140 flags:0x00080002
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
 nfsd_nl_svc_export_get_reqs_dumpit+0xf7/0xc40 fs/nfsd/export.c:674
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
RIP: 0033:0x7ff1c3a2e0d9
RSP: 002b:00007ff1c1c86028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 00007ff1c3cb5fa0 RCX: 00007ff1c3a2e0d9
RDX: 00000000040088c0 RSI: 0000200000000000 RDI: 0000000000000003
RBP: 00007ff1c3ac5024 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007ff1c3cb6038 R14: 00007ff1c3cb5fa0 R15: 00007ffc5284e4a8
 </TASK>

Showing all locks held in the system:
4 locks held by rcuc/1/28:
1 lock held by khungtaskd/38:
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8e1c3000 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
2 locks held by udevd/4947:
2 locks held by getty/5330:
 #0: ffff8880369bb0a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc90003cb62e0 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x460/0x1360 drivers/tty/n_tty.c:2211
2 locks held by kworker/u8:30/14883:
 #0: ffff88801fb40938 ((wq_completion)iou_exit){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #0: ffff88801fb40938 ((wq_completion)iou_exit){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
 #1: ffffc90004897c40 ((work_completion)(&ctx->exit_work)){+.+.}-{0:0}, at: process_one_work kernel/workqueue.c:3297 [inline]
 #1: ffffc90004897c40 ((work_completion)(&ctx->exit_work)){+.+.}-{0:0}, at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
3 locks held by syz-executor/18021:
2 locks held by syz.7.3941/18296:
 #0: ffffffff8f61d520 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8e4e8ad8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0x136/0x16e0 fs/nfsd/nfsctl.c:1964
3 locks held by syz.1.4033/18710:
 #0: ffffffff8f61d520 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffff88802b1fc928 (nlk_cb_mutex-GENERIC){+.+.}-{4:4}, at: __netlink_dump_start+0xf4/0x7b0 net/netlink/af_netlink.c:2410
 #2: ffffffff8e4e8ad8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_svc_export_get_reqs_dumpit+0xf7/0xc40 fs/nfsd/export.c:674
2 locks held by syz-executor/18969:
 #0: ffff888063bb40d0 (&type->s_umount_key#98){+.+.}-{4:4}, at: __super_lock fs/super.c:58 [inline]
 #0: ffff888063bb40d0 (&type->s_umount_key#98){+.+.}-{4:4}, at: __super_lock_excl fs/super.c:73 [inline]
 #0: ffff888063bb40d0 (&type->s_umount_key#98){+.+.}-{4:4}, at: deactivate_super+0xa9/0xe0 fs/super.c:509
 #1: ffffffff8e4e8ad8 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_shutdown_threads+0x4e/0xd0 fs/nfsd/nfssvc.c:576

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 38 Comm: khungtaskd Tainted: G             L      syzkaller #0 PREEMPT_{RT,(full)} 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/24/2026
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
CPU: 0 UID: 0 PID: 0 Comm: swapper/0 Tainted: G             L      syzkaller #0 PREEMPT_{RT,(full)} 
Tainted: [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/24/2026
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: 0b 70 02 e9 13 cf 03 00 cc cc cc 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 0f 00 2d b3 08 26 00 fb f4 <c3> cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc cc 90 90 90 90 90
RSP: 0018:ffffffff8de07de0 EFLAGS: 00000246
RAX: 00000000009c5c99 RBX: ffffffff819a1590 RCX: 0000000080000001
RDX: 0000000000000001 RSI: ffffffff8d880ab5 RDI: ffffffff8bca5980
RBP: ffffffff8de07eb8 R08: ffff8880b8633d5b R09: 1ffff110170c67ab
R10: dffffc0000000000 R11: ffffed10170c67ac R12: 0000000000000000
R13: 1ffffffff1bdede8 R14: 1ffffffff1bc0fc4 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888125c46000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f9ff4955ff8 CR3: 000000003ca8e000 CR4: 00000000003526f0
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
