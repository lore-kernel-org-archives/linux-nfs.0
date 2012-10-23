Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:58248 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab2JWTt3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 15:49:29 -0400
From: Nix <nix@esperi.org.uk>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, "Ted Ts'o" <tytso@mit.edu>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Schumaker\, Bryan" <Bryan.Schumaker@netapp.com>,
        Peng Tao <bergwolf@gmail.com>,
        "gregkh\@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: Heads-up: 3.6.2 / 3.6.3 NFS server oops: 3.6.2+ regression? (also an unrelated ext4 data loss bug)
References: <87objupjlr.fsf@spindle.srvr.nix>
	<20121023013343.GB6370@fieldses.org> <87mwzdnuww.fsf@spindle.srvr.nix>
	<20121023143019.GA3040@fieldses.org>
	<874nllxi7e.fsf_-_@spindle.srvr.nix>
	<20121023164621.GC3040@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90928CA6F@SACEXCMBX04-PRD.hq.netapp.com>
	<87vce1w241.fsf@spindle.srvr.nix> <87r4opw0og.fsf@spindle.srvr.nix>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90928CD7F@SACEXCMBX04-PRD.hq.netapp.com>
	<1351015039.4622.23.camel@lade.trondhjem.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90928CF49@SACEXCMBX04-PRD.hq.netapp.com>
Date: Tue, 23 Oct 2012 20:49:13 +0100
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90928CF49@SACEXCMBX04-PRD.hq.netapp.com>
	(Trond Myklebust's message of "Tue, 23 Oct 2012 18:23:48 +0000")
Message-ID: <87fw55hsue.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 Oct 2012, Trond Myklebust outgrape:

> On Tue, 2012-10-23 at 13:57 -0400, Trond Myklebust wrote:
>> On Tue, 2012-10-23 at 17:44 +0000, Myklebust, Trond wrote:
>> > You can't hold a spinlock while sleeping. Both mutex_lock() and nsm_create() can definitely sleep.
>> > 
>> > The correct way to do this is to grab the spinlock and recheck the value of ln->nsm_users inside the 'if (!IS_ERR())' condition. If it is still zero, bump it and set ln->nsm_clnt, otherwise bump it, get the existing ln->nsm_clnt and call rpc_shutdown_clnt() on the redundant nsm client after dropping the spinlock.
>> > 
>> > Cheers
>> >   Trond
>> 
>> Can you please check if the following patch fixes the issue?
>> 
>> Cheers
>>   Trond
>> 
> Meh... This one gets rid of the 100% redundant mutex...

No help, I'm afraid:

[  894.005699] ------------[ cut here ]------------
[  894.005929] kernel BUG at fs/lockd/mon.c:159!
[  894.006156] invalid opcode: 0000 [#1] SMP
[  894.006451] Modules linked in: firewire_ohci firewire_core [last unloaded: microcode]
[  894.007005] CPU 1
[  894.007050] Pid: 1035, comm: lockd Not tainted 3.6.3-dirty #1 empty empty/S7010
[  894.007669] RIP: 0010:[<ffffffff8120fbbc>]  [<ffffffff8120fbbc>] nsm_mon_unmon+0x64/0x98
[  894.008126] RSP: 0018:ffff880620a23ce0  EFLAGS: 00010246
[  894.008355] RAX: ffff880620a23ce8 RBX: 0000000000000000 RCX: 0000000000000000
[  894.008591] RDX: ffff880620a23d58 RSI: 0000000000000002 RDI: ffff880620a23d30
[  894.008827] RBP: ffff880620a23d40 R08: 0000000000000000 R09: ffffea00188e4f00
[  894.009063] R10: ffffffff814d032f R11: 0000000000000020 R12: 0000000000000000
[  894.009300] R13: ffff88061f067e40 R14: ffff88061f067ee8 R15: ffff88062393dc00
[  894.009537] FS:  0000000000000000(0000) GS:ffff88063fc40000(0000) knlGS:0000000000000000
[  894.009956] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  894.010187] CR2: 00007f056a9a6ff0 CR3: 0000000001a0b000 CR4: 00000000000027e0
[  894.010422] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  894.010659] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  894.010896] Process lockd (pid: 1035, threadinfo ffff880620a22000, task ffff8806208b5900)
[  894.011310] Stack:
[  894.011528]  0000000000000010 ffff8806102d3db1 00000003000186b5 ffffffff00000010
[  894.012083]  ffff8806102d3dc1 000000000000008c 0000000000000000 ffff880620a23ce8
[  894.012637]  ffff880620a23d58 0000000000000000 ffff88061f067ee8 ffff8806102d3d00
[  894.013190] Call Trace:
[  894.013413]  [<ffffffff8120ff07>] nsm_monitor+0x123/0x17e
[  894.013645]  [<ffffffff81211b72>] nlm4svc_retrieve_args+0x62/0xd7
[  894.013879]  [<ffffffff81211f71>] nlm4svc_proc_lock+0x3c/0xb5
[  894.014112]  [<ffffffff812116a3>] ? nlm4svc_decode_lockargs+0x47/0xb2
[  894.014349]  [<ffffffff814d89fa>] svc_process+0x3bf/0x6a1
[  894.014581]  [<ffffffff8120d5f0>] lockd+0x127/0x164
[  894.014810]  [<ffffffff8120d4c9>] ? set_grace_period+0x8a/0x8a
[  894.015046]  [<ffffffff8107bcbc>] kthread+0x8b/0x93
[  894.015277]  [<ffffffff81501334>] kernel_thread_helper+0x4/0x10
[  894.015511]  [<ffffffff8107bc31>] ? kthread_worker_fn+0xe1/0xe1
[  894.015744]  [<ffffffff81501330>] ? gs_change+0xb/0xb
[  894.015972] Code: b8 10 00 00 00 48 89 45 c0 48 8d 81 8c 00 00 00 b9 08 00 00 00 48 89 45 c8 89 d8 f3 ab 48 8d 45 a8 48 89 55 e0 48 89 45 d8 75 02 <0f> 0b 89 f6 48 c7 02 00 00 00 00 4c 89 c7 48 6b f6 38 ba 00 04
[  894.018895] RIP  [<ffffffff8120fbbc>] nsm_mon_unmon+0x64/0x98
[  894.019163]  RSP <ffff880620a23ce0>
[  894.019401] ---[ end trace b8ef5cb81bec72c8 ]---

Slightly different timing, but still boom.
