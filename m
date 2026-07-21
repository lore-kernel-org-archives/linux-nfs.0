Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8466435C6B3;
	Tue, 21 Jul 2026 21:48:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784670513; cv=none; b=LFSiQLEEkOyYWJhUKhGovrdvYjR68TNArDgPgXtwmAECNs3c48ZFUTh4a/N8ukE0qRhtSVEgyd987aiHgRPTsaz1N1+psDc1DKRm8jfzc9/TAsPKNLfzNNVNjTthkn9cj9wPg8mc4ksNDGZdbWcdtqYhw9e3s7wZtcj7PiZgUTE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784670513; c=relaxed/simple;
	bh=zWNpij/NFRAUVwPyYVj/fEDh/iK/JVnfU9dC/DI+f1I=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=dy9kUahEb4gnhy1EEQ7NH5nOmdz0TLulYNYf3CSs3lE7MbtJJWCspi9qIYDWvVXVkq6TsYEmGqvd2mIiGMeyKRpyiZBuwqG3VFiClw/EJ5xt9IOG3XEbdzdj24pYKbVTXPTtFaixf5VBhcjVo1KrxYzP//lj1cUGiGLP5GGfvQI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=aUrPu6PU; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=hG8c4CZ4; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="aUrPu6PU";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hG8c4CZ4"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 7D6487A00FD;
	Tue, 21 Jul 2026 17:48:29 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 21 Jul 2026 17:48:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1784670509; x=1784756909; bh=DzCIjcuWEq+WXtXFB0EofCTio0CAw4YxRqy
	9tDUDi9o=; b=aUrPu6PUEYpxuF0sl3Qc6gDLa6yfTaChigjhapyq7zqBhjhobna
	t9WlAD1n4SwNejjY/uAdA9dCK7gsEjqT1KP4m2siCoqt7amprLURLdgtOzFmx5Qz
	A4RpjzZwGyGdOYXCWvMkRQaNj2mjHcqJYeDo6vm0adSCRaW5jiqIGhGH0JlFVBl5
	LUnY86R7XuIokiYCgFq0IKNiYp9fBXfb+/BPfUJuYp/JW1foc74kuaoOWDT78m/h
	/doUjX4haGbTXNLpE0Nj33v0jasfNBOcg1r12ZwimxG3I1kuC3Pd4UJq1xv+Focs
	p+1rYp2H0Kegw7LbrS/IHsEdYHVrQ/9V1SQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1784670509; x=
	1784756909; bh=DzCIjcuWEq+WXtXFB0EofCTio0CAw4YxRqy9tDUDi9o=; b=h
	G8c4CZ4msCfnWLuqRTuQKHmBBAkq0u+auVec3bW33YqBTaRprBfkI/7TEfLxYIC9
	FMyGrLeHCnTc3Klp6fHNXVXL3Yq3ZV3g6Bl3xpzsUDF7pjjXQiGFOxcMXOUrpL19
	7/On9dT4Zu3UCkocJmGMEQ+Xw3SoTRANLq/COv+upUBJJ0E3xIFOZryZnPJFGjFw
	VrjYqswIoO1OibM/vqNljdMO3grtfLf/46gQ8UnfdmyY4MH3tqj1lf+qBIStu3Hq
	G4U88eLdwHyNENXjvkrshBPmk9bOfl1tNfPMGYr6xka4kyUsmiPP2Eg4SZu/wetP
	Z2ttwNR1b+34AFezwP1Dw==
X-ME-Sender: <xms:Lelfaj2zy4NwLkXY2MT4f-hzvpW2Xj3MDEEEAnceW8-iG_oujYg9mg>
    <xme:LelfaijVoVSKGcOkTtQYqHwFz9zsNsr092bFVS4kO_TJVpEAT0d8mfm_YzT-4_DZv
    3SKI8dh4dVPDseEJwXPmBsDxrUKrCojpYGfgXGCWALbk1Tb>
X-ME-Received: <xmr:LelfakmuUGhz06rCXIxNxYI7CEJ9W8F8_HxVFZZPxV28aaxz_NoJ-AzvMtEQ0iKsV1JqQFYyo9-FJEtogg-obr17CvEkpxw>
X-ME-Proxy-Cause: dmFkZTF4cYTRSxiC1HduhQruylS2hNj0BBiL6GL1z6Hrsl3dVg5EaiLAcfmCkhtI4axTDo
    pO9T+iq9JyM85fYCI7kkBtqNkiO3zE+uRPfWhTmt1H+pTSY/6njhvimSsW7DHVSdxNzPIU
    qBeCqacaHbIajY6q5g0Fk3uyFzodLzQNFBl4AqB6jWwQOueleZ8UnSCJHZ9YksMZpcEek8
    vXGJoJxwtzM3AYjSNia7n/IVjrgunwOBCq7jsQZ59+NFPP/cB3QUgEmwzY2aA/wTg7oOEW
    fLC+II/IsGhcVx494feMlfUQTVIMMLDZjZanzC3qg75RW6dBNYJSlcwX7U10azmUuzE5p4
    7QFqx31Jj9zxCy6mgMF2ZSkP/Pxyk6NgZ6SVmyHFCNFKzDkS2sMA4vL+M1as42DPv+XMF8
    2RvnoTl/pt5XtjPbF4mp8nhkb6HA3ERCyOStRTkVNDoktsf0G+70WMqZ2vk0w2LBFgAWRv
    SUu9OmgKSS5oE24QmQ+5LPFiJKQ/JUd/+vFHBGUdK57Mhn7D8gZI9zfi80dkOxLCEgw6GH
    4CypC3kKOV3pIDEE4/n9pVWP3XKCQBaIlgxsUTQxnneAIOWFW0LUj2ogdjLMm93q3GDQ00
    BWzqaG/N3SN2blSs2ky3371Pczpv4PlooH2CsiQAQTOuTmnf/k4f7NVH198A
X-ME-Proxy: <xmx:LelfagayB1iJqlqXnsBsZtZc057p10X_sijqDjpG8t8-RGGSdsOqyA>
    <xmx:LelfanFpZioqzp5UGm3fIEg1O8aBXSVsIKFsxzDWmkE5qv0us9waOA>
    <xmx:LelfanZs93Kc6HyL4mcw1vnQqptnIPQAPQogRy5_PBuPbcd4WSOaOA>
    <xmx:LelfajwKseuvNUMY8vi_b0b5yI6RDM4BfKL3ZIq8Q8lEN3ZRmWnC1w>
    <xmx:LelfaoOcU91U4W6g67Vxzh0OZI2beHazhKy23mMdsBJPsCaL8C5PAxKS>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 21 Jul 2026 17:48:26 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "syzbot" <syzbot+c7eae0eb80858a2dba0f@syzkaller.appspotmail.com>,
 Dai.Ngo@oracle.com, cel@kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, okorniev@redhat.com,
 syzkaller-bugs@googlegroups.com, tom@talpey.com
Subject: Re: [syzbot] [nfs?] INFO: task hung in nfsd_nl_cache_flush_doit
In-reply-to: <a16279675545df12a15c2c6ccc8deee1164d6d57.camel@kernel.org>
References: <6a590ea0.ccd3b023.4fae3.0000.GAE@google.com>
  <a16279675545df12a15c2c6ccc8deee1164d6d57.camel@kernel.org>
Date: Wed, 22 Jul 2026 07:48:21 +1000
Message-id: <178467050196.3371781.3758158560019971518@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 21 Jul 2026, Jeff Layton wrote:
> On Thu, 2026-07-16 at 10:02 -0700, syzbot wrote:
> > Hello,
> >=20
> > syzbot found the following issue on:
> >=20
> > HEAD commit:    44696aa3a489 Merge tag 'input-for-v7.2-rc2' of git://git.=
k..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=3D17efd0b9580000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=3D5c4196ba0e336=
31d
> > dashboard link: https://syzkaller.appspot.com/bug?extid=3Dc7eae0eb80858a2=
dba0f
> > compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e25=
5-1~exp1~20260613092250.77), Debian LLD 22.1.8
> >=20
> > Unfortunately, I don't have any reproducer for this issue yet.
> >=20
> > Downloadable assets:
> > disk image: https://storage.googleapis.com/syzbot-assets/14807749cfb0/dis=
k-44696aa3.raw.xz
> > vmlinux: https://storage.googleapis.com/syzbot-assets/7f966ce4e5e9/vmlinu=
x-44696aa3.xz
> > kernel image: https://storage.googleapis.com/syzbot-assets/c821bcd9ea8c/b=
zImage-44696aa3.xz
> >=20
> > IMPORTANT: if you fix the issue, please add the following tag to the comm=
it:
> > Reported-by: syzbot+c7eae0eb80858a2dba0f@syzkaller.appspotmail.com
> >=20
> > INFO: task syz.3.4381:22405 blocked for more than 143 seconds.
> >       Tainted: G             L      syzkaller #0
> > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > task:syz.3.4381      state:D stack:27200 pid:22405 tgid:22404 ppid:17244 =
 task_flags:0x400140 flags:0x00080002
> > Call Trace:
> >  <TASK>
> >  context_switch kernel/sched/core.c:5510 [inline]
> >  __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
> >  __schedule_loop kernel/sched/core.c:7311 [inline]
> >  schedule+0x164/0x2b0 kernel/sched/core.c:7326
> >  schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
> >  __mutex_lock_common kernel/locking/mutex.c:726 [inline]
> >  __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
> >  nfsd_nl_cache_flush_doit+0xb5/0x1b0 fs/nfsd/nfsctl.c:2236
> >  genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
> >  genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
> >  genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
> >  netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
> >  genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
> >  netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
> >  netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
> >  netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
> >  sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
> >  __sock_sendmsg net/socket.c:790 [inline]
> >  ____sys_sendmsg+0x54e/0x850 net/socket.c:2684
> >  ___sys_sendmsg+0x2a5/0x360 net/socket.c:2738
> >  __sys_sendmsg net/socket.c:2770 [inline]
> >  __do_sys_sendmsg net/socket.c:2775 [inline]
> >  __se_sys_sendmsg net/socket.c:2773 [inline]
> >  __x64_sys_sendmsg+0x1b1/0x290 net/socket.c:2773
> >  do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
> >  do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
> >  entry_SYSCALL_64_after_hwframe+0x77/0x7f
> > RIP: 0033:0x7f5cbdf9de59
> > RSP: 002b:00007f5cbef3b028 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
> > RAX: ffffffffffffffda RBX: 00007f5cbe225fa0 RCX: 00007f5cbdf9de59
> > RDX: 0000000004000080 RSI: 0000200000000100 RDI: 0000000000000003
> > RBP: 00007f5cbe033e6f R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> > R13: 00007f5cbe226038 R14: 00007f5cbe225fa0 R15: 00007ffd5ffd5b58
> >  </TASK>
> >=20
> > Showing all locks held in the system:
> > 6 locks held by kworker/1:1/29:
> >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: proces=
s_one_work kernel/workqueue.c:3297 [inline]
> >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: proces=
s_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> >  #1: ffffc90000a57c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: =
process_one_work kernel/workqueue.c:3297 [inline]
> >  #1: ffffc90000a57c40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: =
process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> >  #2: ffff888029d3c1d8 (&dev->mutex){....}-{4:4}, at: device_lock include/=
linux/device.h:1102 [inline]
> >  #2: ffff888029d3c1d8 (&dev->mutex){....}-{4:4}, at: hub_event+0x184/0x4d=
30 drivers/usb/core/hub.c:5899
> >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: usb_lock_=
port drivers/usb/core/hub.c:3252 [inline]
> >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_=
connect drivers/usb/core/hub.c:5464 [inline]
> >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_port_=
connect_change drivers/usb/core/hub.c:5707 [inline]
> >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: port_even=
t drivers/usb/core/hub.c:5871 [inline]
> >  #3: ffff8880297a9568 (&port_dev->status_lock){+.+.}-{4:4}, at: hub_event=
+0x20a1/0x4d30 drivers/usb/core/hub.c:5953
> >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_con=
nect drivers/usb/core/hub.c:5465 [inline]
> >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_port_con=
nect_change drivers/usb/core/hub.c:5707 [inline]
> >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: port_event d=
rivers/usb/core/hub.c:5871 [inline]
> >  #4: ffff888029beba60 (hcd->address0_mutex){+.+.}-{4:4}, at: hub_event+0x=
20c9/0x4d30 drivers/usb/core/hub.c:5953
> >  #5: ffffffff8f8daaa8 (ehci_cf_port_reset_rwsem){.+.+}-{4:4}, at: hub_por=
t_reset+0x14d/0x17e0 drivers/usb/core/hub.c:3067
> > 1 lock held by khungtaskd/32:
> >  #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire i=
nclude/linux/rcupdate.h:300 [inline]
> >  #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock incl=
ude/linux/rcupdate.h:840 [inline]
> >  #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all_loc=
ks+0x2e/0x180 kernel/locking/lockdep.c:6775
> > 1 lock held by dhcpcd/5281:
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/core/rt=
netlink.c:80 [inline]
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock net/co=
re/rtnetlink.c:341 [inline]
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a3/0x=
1bd0 net/core/rtnetlink.c:4158
> > 2 locks held by getty/5371:
> >  #0: ffff8880359000a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wa=
it+0x25/0x70 drivers/tty/tty_ldisc.c:243
> >  #1: ffffc900032332e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_r=
ead+0x45a/0x1360 drivers/tty/n_tty.c:2211
> > 3 locks held by kworker/1:6/5771:
> >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: proces=
s_one_work kernel/workqueue.c:3297 [inline]
> >  #0: ffff888021e85140 ((wq_completion)usb_hub_wq){+.+.}-{0:0}, at: proces=
s_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> >  #1: ffffc900041efc40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: =
process_one_work kernel/workqueue.c:3297 [inline]
> >  #1: ffffc900041efc40 ((work_completion)(&hub->events)){+.+.}-{0:0}, at: =
process_scheduled_works+0xa20/0x14e0 kernel/workqueue.c:3405
> >  #2: ffff8880b8728ea0 (lock#6){..-.}-{3:3}, at: local_lock_acquire includ=
e/linux/local_lock_internal.h:46 [inline]
> >  #2: ffff8880b8728ea0 (lock#6){..-.}-{3:3}, at: kcov_remote_stop+0x69/0x6=
c0 kernel/kcov.c:1040
> > 2 locks held by syz.1.3757/20367:
> >  #0: ffffffff9009cd28 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/n=
etlink/genetlink.c:1217
> >  #1: ffffffff8ee8e5e0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_=
doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
> > 2 locks held by syz.3.4381/22405:
> >  #0: ffffffff9009cd28 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/n=
etlink/genetlink.c:1217
> >  #1: ffffffff8ee8e5e0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_cache_flush_d=
oit+0xb5/0x1b0 fs/nfsd/nfsctl.c:2236
> > 1 lock held by syz-executor/24167:
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_lock net/core/rt=
netlink.c:80 [inline]
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_nets_lock net/co=
re/rtnetlink.c:341 [inline]
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: rtnl_newlink+0x8a3/0x=
1bd0 net/core/rtnetlink.c:4158
> > 1 lock held by syz.5.4972/24470:
> > 2 locks held by syz.5.4972/24471:
> >  #0: ffffffff9002c4c0 (rtnl_mutex){+.+.}-{4:4}, at: do_ip_setsockopt+0xe9=
5/0x2e30 net/ipv4/ip_sockglue.c:1077
> >  #1: ffff88803b271c60 (sk_lock-AF_INET){+.+.}-{0:0}, at: do_ip_setsockopt=
+0x1556/0x2e30 net/ipv4/ip_sockglue.c:1078
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > NMI backtrace for cpu 1
> > CPU: 1 UID: 0 PID: 32 Comm: khungtaskd Tainted: G             L      syzk=
aller #0 PREEMPT(full)=20
> > Tainted: [L]=3DSOFTLOCKUP
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS G=
oogle 06/10/2026
> > Call Trace:
> >  <TASK>
> >  dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
> >  nmi_cpu_backtrace+0x274/0x2d0 lib/nmi_backtrace.c:122
> >  nmi_trigger_cpumask_backtrace+0x17a/0x380 lib/nmi_backtrace.c:65
> >  trigger_all_cpu_backtrace include/linux/nmi.h:162 [inline]
> >  __sys_info lib/sys_info.c:157 [inline]
> >  sys_info+0x135/0x170 lib/sys_info.c:165
> >  check_hung_uninterruptible_tasks kernel/hung_task.c:353 [inline]
> >  watchdog+0xfd7/0x1030 kernel/hung_task.c:561
> >  kthread+0x388/0x470 kernel/kthread.c:436
> >  ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
> >  ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
> >  </TASK>
> > Sending NMI from CPU 1 to CPUs 0:
> > NMI backtrace for cpu 0
> > CPU: 0 UID: 0 PID: 4986 Comm: udevd Tainted: G             L      syzkall=
er #0 PREEMPT(full)=20
> > Tainted: [L]=3DSOFTLOCKUP
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS G=
oogle 06/10/2026
> > RIP: 0010:get_current arch/x86/include/asm/current.h:25 [inline]
> > RIP: 0010:write_comp_data kernel/kcov.c:245 [inline]
> > RIP: 0010:__sanitizer_cov_trace_const_cmp4+0x8/0x90 kernel/kcov.c:314
> > Code: 89 44 11 20 e9 84 cb 49 ff cc 0f 1f 84 00 00 00 00 00 90 90 90 90 9=
0 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 48 8b 04 24 <65> 48 8b 15 58 0=
a a6 11 65 8b 0d 79 0a a6 11 81 e1 00 01 ff 00 74
> > RSP: 0018:ffffc9000502fcb0 EFLAGS: 00000246
> > RAX: ffffffff8273d85d RBX: ffffffff8273d78c RCX: ffff88807f523e00
> > RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
> > RBP: 0000000000000001 R08: ffffffff8273d78c R09: 0000000000000000
> > R10: 0000000000000000 R11: ffffffff8eb59c60 R12: dffffc0000000000
> > R13: ffff888026b8bc70 R14: ffff888026b8bc30 R15: ffff888026b8d000
> > FS:  00007fe18881d880(0000) GS:ffff888124f58000(0000) knlGS:0000000000000=
000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000200000e4c000 CR3: 0000000029310000 CR4: 0000000000350ef0
> > Call Trace:
> >  <TASK>
> >  kernfs_root+0xed/0x230 fs/kernfs/kernfs-internal.h:77
> >  kernfs_active fs/kernfs/dir.c:40 [inline]
> >  kernfs_dir_next_pos fs/kernfs/dir.c:1964 [inline]
> >  kernfs_fop_readdir+0x647/0x960 fs/kernfs/dir.c:1989
> >  iterate_dir+0x2e2/0x4d0 fs/readdir.c:110
> >  __do_sys_getdents64 fs/readdir.c:399 [inline]
> >  __se_sys_getdents64+0xf1/0x280 fs/readdir.c:384
> >  do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
> >  do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
> >  entry_SYSCALL_64_after_hwframe+0x77/0x7f
> > RIP: 0033:0x7fe1880f0d23
> > Code: 8b 05 d9 00 10 00 64 c7 00 16 00 00 00 31 c0 eb b0 66 0f 1f 44 00 0=
0 b8 ff ff ff 7f 48 39 c2 48 0f 47 d0 b8 d9 00 00 00 0f 05 <48> 3d 00 f0 ff f=
f 77 05 c3 0f 1f 40 00 48 8b 15 a1 00 10 00 f7 d8
> > RSP: 002b:00007ffc1ee77458 EFLAGS: 00000293 ORIG_RAX: 00000000000000d9
> > RAX: ffffffffffffffda RBX: 00005652ff7d3a20 RCX: 00007fe1880f0d23
> > RDX: 0000000000008000 RSI: 00005652ff7d3a50 RDI: 000000000000000d
> > RBP: 00005652ff7d3a24 R08: 00007fe1881f1ac0 R09: 0000000000000000
> > R10: 0000000000000003 R11: 0000000000000293 R12: 00005652ff7d3a50
> > R13: fffffffffffffe68 R14: 0000000000000002 R15: 00007ffc1ee77700
> >  </TASK>
> >=20
> >=20
> > ---
> > This report is generated by a bot. It may contain errors.
> > See https://goo.gl/tpsmEJ for more information about syzbot.
> > syzbot engineers can be reached at syzkaller@googlegroups.com.
> >=20
> > syzbot will keep track of this issue. See:
> > https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
> >=20
> > If the report is already addressed, let syzbot know by replying with:
> > #syz fix: exact-commit-title
> >=20
> > If you want to overwrite report's subsystems, reply with:
> > #syz set subsystems: new-subsystem
> > (See the list of subsystem names on the web dashboard)
> >=20
> > If the report is a duplicate of another one, reply with:
> > #syz dup: exact-subject-of-another-report
> >=20
> > If you want to undo deduplication, reply with:
> > #syz undup
>=20
>=20
> I've been doing some investigation on this problem, and I think I
> pretty much understand it now. There are actually a few different DoS
> vectors here. Most of them are fairly simple to patch (and I have a few
> patches for those problems).
>=20
> The hard problem here is that rpcbind registration is done
> synchronously under the nfsd_mutex. To talk to rpcbind, the kernel has
> to create a RPC client, which does a RPC ping first. If rpcbind is down
> then it can take up to a minute for the RPC ping to time out.=C2=A0rpcbind
> registration failure is not considered fatal, so if it fails the kernel
> keeps going on. If we couple those delays with a long list of
> listeners, then it's easy to see how to reproduce the hang.
>=20
> I think the only real fix here is to do the listener registration
> outside of the nfsd_mutex. We can either try to drop and reacquire the
> nfsd_mutex to do the registration or we could move to doing the
> registration asynchronously outside of the mutex.
>=20
> I personally like the latter idea better, but I haven't thought enough
> about how we'd deal with racing listener netlink calls in that case.
>=20
> Thoughts?

Why are we waiting a whole minute for a local service to respond?  If it
hasn't responded in 1 second, is it ever really likely to?
If rcpbind is down, we should be getting a network-level error,
shouldn't we?  Hmmm.  There is ENETUNREACH and EHOSTUNREACH but not
EPORTUNREACH - I'm sure you get something if a UDP port isn't open, but
ICMP for remote hosts but rpcbind isn't remote.

So I would rather we find a way to make rpc_ping fail more quickly.
But failing that I think that doing the ping async makes sense.  nfsd
doesn't need the registration, only clients do.  So delaying it only
means we don't get an error on startup which we currently do.  This is
not something that would be expected in practice.  Maybe a kernel
warning if registration fails, and hope the sysadmin notices?

NeilBrown
