Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 622434418DB;
	Tue, 21 Jul 2026 22:18:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784672296; cv=none; b=H6FzRX6WVdf66uyqSpTgux7ey1Ub3F17ygUaR8eFoKoQN2UNM96WIA85vmg85SHKqvNUrMgtJTj4+lnrPgh8ToIeTLU/er8u9FFPzaK1/BJLjCaEeb94Mn9Pga0TZyRWUTnoKEF3wnENHNsYwBqzgUwIw/XPfqSaEHoHkPwaK4E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784672296; c=relaxed/simple;
	bh=041790wQILlKo2n2jPql+pnDfbn5jgjrvUtfcdAxfu4=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=pTomKSgamPFSh1NvecvZY0HQDRHPi13sbJxqe8HiRgXEbxG0TTRcjuiyKWHbgBxoeopDLQj5R9wuFgOK1xpP7FitNAxmcyKR8UlF/Jgh++RQGIkgRNMPGEQmL/euHRWrlnW+NFuTfav4yFb8XP3SYpuGIvLQZ8uVQqgjqDiNy3Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nJZAyaEX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nJZAyaEX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0ED271F00ADE;
	Tue, 21 Jul 2026 22:18:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784672293;
	bh=BjV1o3oz7uLO9gLUHfvpceFtPfUIS9PNufBYvwFN7Uw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=nJZAyaEXKXOETc/0yskN79N0FI0hZrF/imoIL6BgCiVIE7kAScATR16kzN0DLr9rw
	 rXXYfvVzrquOUxCmxN+AmC4TuwTWcc/w53rTPnuKfI7qSlIiTFUiKBQzYvwxIKtM6Y
	 xPzhuyCTisYmDg8uryLSb8PRKo4maNI8AO4TfOWExiGRw8l++Lo228bfLwenuY6L+3
	 A3so9dlOdhEimoLQLIRcfKbMqo2dp1f6AOZ5469GgJTUPL2W/QQfIizKQs+oPa3hUs
	 nFDZ9Zkssqq1eRAFmMabnjTUr5WJExQoymtCS/FBC3Yrpe1YqZpoCAXzyMovTIbLpo
	 lP1Hw+oRFbeFA==
Message-ID: <0e9288a881c9fa6308cd607435192abb408a1dfb.camel@kernel.org>
Subject: Re: [syzbot] [nfs?] INFO: task hung in nfsd_nl_cache_flush_doit
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: syzbot <syzbot+c7eae0eb80858a2dba0f@syzkaller.appspotmail.com>, 
	Dai.Ngo@oracle.com, cel@kernel.org, linux-kernel@vger.kernel.org, 
	linux-nfs@vger.kernel.org, okorniev@redhat.com,
 syzkaller-bugs@googlegroups.com, 	tom@talpey.com
Date: Tue, 21 Jul 2026 18:18:11 -0400
In-Reply-To: <178467050196.3371781.3758158560019971518@noble.neil.brown.name>
References: <6a590ea0.ccd3b023.4fae3.0000.GAE@google.com>
	  <a16279675545df12a15c2c6ccc8deee1164d6d57.camel@kernel.org>
	 <178467050196.3371781.3758158560019971518@noble.neil.brown.name>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-07-22 at 07:48 +1000, NeilBrown wrote:
> On Tue, 21 Jul 2026, Jeff Layton wrote:
> > On Thu, 2026-07-16 at 10:02 -0700, syzbot wrote:
> > > Hello,
> > >=20
> > > syzbot found the following issue on:
> > >=20
> > > HEAD commit:    44696aa3a489 Merge tag 'input-for-v7.2-rc2' of git://=
git.k..
> > > git tree:       upstream
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=3D17efd0b95=
80000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=3D5c4196ba0=
e33631d
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=3Dc7eae0eb808=
58a2dba0f
> > > compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda=
6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8
> > >=20
> > > Unfortunately, I don't have any reproducer for this issue yet.
> > >=20
> > > Downloadable assets:
> > > disk image: https://storage.googleapis.com/syzbot-assets/14807749cfb0=
/disk-44696aa3.raw.xz
> > > vmlinux: https://storage.googleapis.com/syzbot-assets/7f966ce4e5e9/vm=
linux-44696aa3.xz
> > > kernel image: https://storage.googleapis.com/syzbot-assets/c821bcd9ea=
8c/bzImage-44696aa3.xz
> > >=20
> > > IMPORTANT: if you fix the issue, please add the following tag to the =
commit:
> > > Reported-by: syzbot+c7eae0eb80858a2dba0f@syzkaller.appspotmail.com
> > >=20
> > > INFO: task syz.3.4381:22405 blocked for more than 143 seconds.
> > >       Tainted: G             L      syzkaller #0
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this mess=
age.
> > > task:syz.3.4381      state:D stack:27200 pid:22405 tgid:22404 ppid:17=
244  task_flags:0x400140 flags:0x00080002
> > > Call Trace:
> > >  <TASK>
> > >  context_switch kernel/sched/core.c:5510 [inline]
> > >  __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
> > >  __schedule_loop kernel/sched/core.c:7311 [inline]
> > >  schedule+0x164/0x2b0 kernel/sched/core.c:7326
> > >  schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
> > >  __mutex_lock_common kernel/locking/mutex.c:726 [inline]
> > >  __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
> > >  nfsd_nl_cache_flush_doit+0xb5/0x1b0 fs/nfsd/nfsctl.c:2236
> > >  genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
> > >  genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
> > >  genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
> > >  netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
> > >  genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
> > >  netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
> > >  netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
> > >  netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
> > >  sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
> > >  __sock_sendmsg net/socket.c:790 [inline]
> > >  ____sys_sendmsg+0x54e/0x850 net/socket.c:2684
> > >  ___sys_sendmsg+0x2a5/0x360 net/socket.c:2738
> > >  __sys_sendmsg net/socket.c:2770 [inline]
> > >  __do_sys_sendmsg net/socket.c:2775 [inline]
> > >  __se_sys_sendmsg net/socket.c:2773 [inline]
> > >  __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2773
> > >  do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
> > >  do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
> > >  entry_SYSCALL_64_after_hwframe+0x77/0x7f
> > > RIP: 0033:0x7f5cbdf9de59
> > > RSP: 002b:00007f5cbef3b028 EFLAGS: 00000246 ORIG_RAX: 000000000000002=
e
> > > RAX: ffffffffffffffda RBX: 00007f5cbe225fa0 RCX: 00007f5cbdf9de59
> > > RDX: 0000000004000080 RSI: 0000200000000100 RDI: 0000000000000003
> > > RBP: 00007f5cbe033e6f R08: 0000000000000000 R09: 0000000000000000
> > > R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> > > R13: 00007f5cbe226038 R14: 00007f5cbe225fa0 R15: 00007ffd5ffd5b58
> > >  </TASK>
> > >=20
> > > Showing all locks held in the system:
> > > 6 locks held by kworker/1:1/29:
> > >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: pr=
ocess_one_work kernel/workqueue.c:3297 [inline]
> > >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: pr=
ocess_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> > >  #1: ffffc90000a57c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, =
at: process_one_work kernel/workqueue.c:3297 [inline]
> > >  #1: ffffc90000a57c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, =
at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> > >  #2: ffff888029d3c1d8 (&dev->mutex){....}-{4:4}, at: device_lock incl=
ude/linux/device.h:1102 [inline]
> > >  #2: ffff888029d3c1d8 (&dev->mutex){....}-{4:4}, at: hub_event+0x184/=
0x4d30 drivers/usb/core/hub.c:5899
> > >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: usb_l=
ock_port drivers/usb/core/hub.c:3252 [inline]
> > >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_p=
ort_connect drivers/usb/core/hub.c:5464 [inline]
> > >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_p=
ort_connect_change drivers/usb/core/hub.c:5707 [inline]
> > >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: port_=
event drivers/usb/core/hub.c:5871 [inline]
> > >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_e=
vent+0x20a1/0x4d30 drivers/usb/core/hub.c:5953
> > >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port=
_connect drivers/usb/core/hub.c:5465 [inline]
> > >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port=
_connect_change drivers/usb/core/hub.c:5707 [inline]
> > >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: port_eve=
nt drivers/usb/core/hub.c:5871 [inline]
> > >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_even=
t+0x20c9/0x4d30 drivers/usb/core/hub.c:5953
> > >  #5: ffffffff8f8daaa8 (ehci_cf_port_reset_rwsem){.+.+}-{4:4}, at: hub=
_port_reset+0x14d/0x17e0 drivers/usb/core/hub.c:3067
> > > 1 lock held by khungtaskd/32:
> > >  #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acqui=
re include/linux/rcupdate.h:300 [inline]
> > >  #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock =
include/linux/rcupdate.h:840 [inline]
> > >  #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all=
_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
> > > 1 lock held by dhcpcd/5281:
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/cor=
e/rtnetlink.c:80 [inline]
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock ne=
t/core/rtnetlink.c:341 [inline]
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a=
3/0x1bd0 net/core/rtnetlink.c:4158
> > > 2 locks held by getty/5371:
> > >  #0: ffff8880359000a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_re=
f_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
> > >  #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_t=
ty_read+0x45a/0x1360 drivers/tty/n_tty.c:2211
> > > 3 locks held by kworker/1:6/5771:
> > >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: pr=
ocess_one_work kernel/workqueue.c:3297 [inline]
> > >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: pr=
ocess_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> > >  #1: ffffc900041efc40 ((work_completion)(&hub->events)){+.+.}-{0:0}, =
at: process_one_work kernel/workqueue.c:3297 [inline]
> > >  #1: ffffc900041efc40 ((work_completion)(&hub->events)){+.+.}-{0:0}, =
at: process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> > >  #2: ffff8880b8728ea0 (lock#6){..-.}-{3:3}, at: local_lock_acquire in=
clude/linux/local_lock_internal.h:46 [inline]
> > >  #2: ffff8880b8728ea0 (lock#6){..-.}-{3:3}, at: kcov_remote_stop+0x69=
/0x6c0 kernel/kcov.c:1040
> > > 2 locks held by syz.1.3757/20367:
> > >  #0: ffffffff9009cd28 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 n=
et/netlink/genetlink.c:1217
> > >  #1: ffffffff8ee8e5e0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_=
set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
> > > 2 locks held by syz.3.4381/22405:
> > >  #0: ffffffff9009cd28 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 n=
et/netlink/genetlink.c:1217
> > >  #1: ffffffff8ee8e5e0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_cache_flu=
sh_doit+0xb5/0x1b0 fs/nfsd/nfsctl.c:2236
> > > 1 lock held by syz-executor/24167:
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/cor=
e/rtnetlink.c:80 [inline]
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock ne=
t/core/rtnetlink.c:341 [inline]
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a=
3/0x1bd0 net/core/rtnetlink.c:4158
> > > 1 lock held by syz.5.4972/24470:
> > > 2 locks held by syz.5.4972/24471:
> > >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: do_ip_setsockopt+=
0xe95/0x2e30 net/ipv4/ip_sockglue.c:1077
> > >  #1: ffff88803b271c60 (sk_lock-AF_INET){+.+.}-{0:0}, at: do_ip_setsoc=
kopt+0x1556/0x2e30 net/ipv4/ip_sockglue.c:1078
> > >=20
> > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > >=20
> > > NMI backtrace for cpu 1
> > > CPU: 1 UID: 0 PID: 32 Comm: khungtaskd Tainted: G             L      =
syzkaller #0 PREEMPT(full)=20
> > > Tainted: [L]=3DSOFTLOCKUP
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BI=
OS Google 06/10/2026
> > > Call Trace:
> > >  <TASK>
> > >  dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
> > >  nmi_cpu_backtrace+0x274/0x2d0 lib/nmi_backtrace.c:122
> > >  nmi_trigger_cpumask_backtrace+0x17a/0x380 lib/nmi_backtrace.c:65
> > >  trigger_all_cpu_backtrace include/linux/nmi.h:162 [inline]
> > >  __sys_info lib/sys_info.c:157 [inline]
> > >  sys_info+0x135/0x170 lib/sys_info.c:165
> > >  check_hung_uninterruptible_tasks kernel/hung_task.c:353 [inline]
> > >  watchdog+0xfd7/0x1030 kernel/hung_task.c:561
> > >  kthread+0x388/0x470 kernel/kthread.c:436
> > >  ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
> > >  ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
> > >  </TASK>
> > > Sending NMI from CPU 1 to CPUs 0:
> > > NMI backtrace for cpu 0
> > > CPU: 0 UID: 0 PID: 4986 Comm: udevd Tainted: G             L      syz=
kaller #0 PREEMPT(full)=20
> > > Tainted: [L]=3DSOFTLOCKUP
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BI=
OS Google 06/10/2026
> > > RIP: 0010:get_current arch/x86/include/asm/current.h:25 [inline]
> > > RIP: 0010:write_comp_data kernel/kcov.c:245 [inline]
> > > RIP: 0010:__sanitizer_cov_trace_const_cmp4+0x8/0x90 kernel/kcov.c:314
> > > Code: 89 44 11 20 e9 84 cb 49 ff cc 0f 1f 84 00 00 00 00 00 90 90 90 =
90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 48 8b 04 24 <65> 48 8b 1=
5 58 0a a6 11 65 8b 0d 79 0a a6 11 81 e1 00 01 ff 00 74
> > > RSP: 0018:ffffc9000502fcb0 EFLAGS: 00000246
> > > RAX: ffffffff8273d85d RBX: ffffffff8273d78c RCX: ffff88807f523e00
> > > RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
> > > RBP: 0000000000000001 R08: ffffffff8273d78c R09: 0000000000000000
> > > R10: 0000000000000000 R11: ffffffff8eb59c60 R12: dffffc0000000000
> > > R13: ffff888026b8bc70 R14: ffff888026b8bc30 R15: ffff888026b8d000
> > > FS:  00007fe18881d880(0000) GS:ffff888124f58000(0000) knlGS:000000000=
0000000
> > > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > CR2: 0000200000e4c000 CR3: 0000000029310000 CR4: 0000000000350ef0
> > > Call Trace:
> > >  <TASK>
> > >  kernfs_root+0xed/0x230 fs/kernfs/kernfs-internal.h:77
> > >  kernfs_active fs/kernfs/dir.c:40 [inline]
> > >  kernfs_dir_next_pos fs/kernfs/dir.c:1964 [inline]
> > >  kernfs_fop_readdir+0x647/0x960 fs/kernfs/dir.c:1989
> > >  iterate_dir+0x2e2/0x4d0 fs/readdir.c:110
> > >  __do_sys_getdents64 fs/readdir.c:399 [inline]
> > >  __se_sys_getdents64+0xf1/0x280 fs/readdir.c:384
> > >  do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
> > >  do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
> > >  entry_SYSCALL_64_after_hwframe+0x77/0x7f
> > > RIP: 0033:0x7fe1880f0d23
> > > Code: 8b 05 d9 00 10 00 64 c7 00 16 00 00 00 31 c0 eb b0 66 0f 1f 44 =
00 00 b8 ff ff ff 7f 48 39 c2 48 0f 47 d0 b8 d9 00 00 00 0f 05 <48> 3d 00 f=
0 ff ff 77 05 c3 0f 1f 40 00 48 8b 15 a1 00 10 00 f7 d8
> > > RSP: 002b:00007ffc1ee77458 EFLAGS: 00000293 ORIG_RAX: 00000000000000d=
9
> > > RAX: ffffffffffffffda RBX: 00005652ff7d3a20 RCX: 00007fe1880f0d23
> > > RDX: 0000000000008000 RSI: 00005652ff7d3a50 RDI: 000000000000000d
> > > RBP: 00005652ff7d3a24 R08: 00007fe1881f1ac0 R09: 0000000000000000
> > > R10: 0000000000000003 R11: 0000000000000293 R12: 00005652ff7d3a50
> > > R13: fffffffffffffe68 R14: 0000000000000002 R15: 00007ffc1ee77700
> > >  </TASK>
> > >=20
> > >=20
> > > ---
> > > This report is generated by a bot. It may contain errors.
> > > See https://goo.gl/tpsmEJ for more information about syzbot.
> > > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > >=20
> > > syzbot will keep track of this issue. See:
> > > https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
> > >=20
> > > If the report is already addressed, let syzbot know by replying with:
> > > #syz fix: exact-commit-title
> > >=20
> > > If you want to overwrite report's subsystems, reply with:
> > > #syz set subsystems: new-subsystem
> > > (See the list of subsystem names on the web dashboard)
> > >=20
> > > If the report is a duplicate of another one, reply with:
> > > #syz dup: exact-subject-of-another-report
> > >=20
> > > If you want to undo deduplication, reply with:
> > > #syz undup
> >=20
> >=20
> > I've been doing some investigation on this problem, and I think I
> > pretty much understand it now. There are actually a few different DoS
> > vectors here. Most of them are fairly simple to patch (and I have a few
> > patches for those problems).
> >=20
> > The hard problem here is that rpcbind registration is done
> > synchronously under the nfsd_mutex. To talk to rpcbind, the kernel has
> > to create a RPC client, which does a RPC ping first. If rpcbind is down
> > then it can take up to a minute for the RPC ping to time out.=C2=A0rpcb=
ind
> > registration failure is not considered fatal, so if it fails the kernel
> > keeps going on. If we couple those delays with a long list of
> > listeners, then it's easy to see how to reproduce the hang.
> >=20
> > I think the only real fix here is to do the listener registration
> > outside of the nfsd_mutex. We can either try to drop and reacquire the
> > nfsd_mutex to do the registration or we could move to doing the
> > registration asynchronously outside of the mutex.
> >=20
> > I personally like the latter idea better, but I haven't thought enough
> > about how we'd deal with racing listener netlink calls in that case.
> >=20
> > Thoughts?
>=20
> Why are we waiting a whole minute for a local service to respond?  If it
> hasn't responded in 1 second, is it ever really likely to?
> If rcpbind is down, we should be getting a network-level error,
> shouldn't we?  Hmmm.  There is ENETUNREACH and EHOSTUNREACH but not
> EPORTUNREACH - I'm sure you get something if a UDP port isn't open, but
> ICMP for remote hosts but rpcbind isn't remote.
>=20

I've been wondering that too. Is it a throwback to starting
rpcbind/portmapper from inetd or something?

In any case, a smaller timeout would make sense, but even at 1s, you
could easily cause a lockup warning with just a few hundred listeners.

I think we need a more structural solution as well.

> So I would rather we find a way to make rpc_ping fail more quickly.
> But failing that I think that doing the ping async makes sense.  nfsd
> doesn't need the registration, only clients do.  So delaying it only
> means we don't get an error on startup which we currently do.  This is
> not something that would be expected in practice.  Maybe a kernel
> warning if registration fails, and hope the sysadmin notices?
>=20

We already throw a printk() when registration fails for v2/3. IIRC,
it's not considered fatal, so we just keep going anyway if that
happens.

My main concern with doing it async would be getting reg/unreg requests
out of order and leaving rpcbind with a broken table, but I think we
could probably do something like keep a queue of requests and process
them in order from a dedicated thread or by driving async RPC
submissions serially from callbacks.

--=20
Jeff Layton <jlayton@kernel.org>
