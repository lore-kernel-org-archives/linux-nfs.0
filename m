From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: kernel BUG at kernel/workqueue.c:291
Date: Tue, 03 Mar 2009 10:16:53 -0500
Message-ID: <1236093413.9631.58.camel@heimdal.trondhjem.org>
References: <49A84376.6030800@aei.mpg.de> <49ABBA44.1060302@aei.mpg.de>
	 <20090302232643.7c7ca284.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39990 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbZCCPRC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2009 10:17:02 -0500
In-Reply-To: <20090302232643.7c7ca284.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-03-02 at 23:26 -0800, Andrew Morton wrote:
> On Mon, 02 Mar 2009 11:51:48 +0100 Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org> wrote:
> 
> > Hi again,
> > 
> > in the mean time 43 of our nodes were struck with this error. It seems
> > that the jobs of a certain user can trigger this bug, however I have no
> > clue how to really trigger it manually.
> 
> That's a lot of nodes.
> 
> > My questions:
> > Is this a know bug for 2.6.27.14 (we can upgrade to .19 if necessary),
> > but as this file was not modyfied recently, I suspect there is no ready
> > fix for that.
> > 
> > Do you need any more info of our systems (Intel X3220 based Supermirco
> > systems), the kernel config (deadline scheduler in use,...) or something
> > else?
> 
> Let's cc the NFS developers, see if this rpciod crash is familiar to them?

Nope. I've never seen it before.

struct rpc_task does admittedly share storage for the work queue and the
rpc wait queue links, but if that were to be causing the reported
corruption, then it would mean that an rpc_task is simultaneously on a
wait queue and trying to execute on a work queue. I have no history of
that ever having happened.

Trond

> > Carsten Aulbert schrieb:
> > > [228704.928037] ------------[ cut here ]------------
> > > [228704.928224] kernel BUG at kernel/workqueue.c:291!
> > > [228704.928404] invalid opcode: 0000 [1] SMP
> > > [228704.928647] CPU 0
> > > [228704.928852] Modules linked in: lm92 w83793 w83781d hwmon_vid hwmon nfs nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs autofs4 netconsole configfs ipmi_si ipmi_devintf ipmi_watchdog ipmi_poweroff ipmi_msghandler e1000e i2c_i801 8250_pnp 8250 serial_core i2c_core
> > > [228704.930002] Pid: 1609, comm: rpciod/0 Not tainted 2.6.27.14-nodes #1
> > > [228704.930002] RIP: 0010:[<ffffffff8023c6db>]  [<ffffffff8023c6db>] run_workqueue+0x6f/0x102
> > > [228704.930002] RSP: 0018:ffff880214bcdec0  EFLAGS: 00010207
> > > [228704.930002] RAX: 0000000000000000 RBX: ffff880214b82f40 RCX: ffff880215444418
> > > [228704.930002] RDX: ffff880187d07d58 RSI: ffff880214bcdee0 RDI: ffff880215444410
> > > [228704.930002] RBP: ffffffffa0077186 R08: ffff880214bcc000 R09: ffff88021491f808
> > > [228704.930002] R10: 0000000000000246 R11: ffff880187d07d50 R12: ffff880214ad7d28
> > > [228704.930002] R13: ffffffff806065a0 R14: ffffffff80607280 R15: 0000000000000000
> > > [228704.930002] FS:  0000000000000000(0000) GS:ffffffff80636040(0000) knlGS:0000000000000000
> > > [228704.930002] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > > [228704.930002] CR2: 00007fc056333fd8 CR3: 00000001ed270000 CR4: 00000000000006e0
> > > [228704.930002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > [228704.930002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > [228704.930002] Process rpciod/0 (pid: 1609, threadinfo ffff880214bcc000, task ffff880217b08780)
> > > [228704.930002] Stack:  ffff880214b82f40 ffff880214b82f40 ffff880214b82f58 ffffffff8023cff3
> > > [228704.930002]  0000000000000000 ffff880217b08780 ffffffff8023f7d7 ffff880214bcdef8
> > > [228704.930002]  ffff880214bcdef8 ffffffff806065a0 ffffffff80607280 ffff880214b82f40
> > > [228704.930002] Call Trace:
> > > [228704.930002]  [<ffffffff8023cff3>] ? worker_thread+0x90/0x9b
> > > [228704.930002]  [<ffffffff8023f7d7>] ? autoremove_wake_function+0x0/0x2e
> > > [228704.930002]  [<ffffffff8023cf63>] ? worker_thread+0x0/0x9b
> > > [228704.930002]  [<ffffffff8023f6c2>] ? kthread+0x47/0x75
> > > [228704.930002]  [<ffffffff8022afa8>] ? schedule_tail+0x27/0x5f
> > > [228704.930002]  [<ffffffff8020ccb9>] ? child_rip+0xa/0x11
> > > [228704.930002]  [<ffffffff8023f67b>] ? kthread+0x0/0x75
> > > [228704.930002]  [<ffffffff8020ccaf>] ? child_rip+0x0/0x11
> > > [228704.930002]
> > > [228704.930002]
> > > [228704.930002] Code: 6f 18 48 89 7b 30 48 8b 11 48 8b 41 08 48 89 42 08 48 89 10 48 89 49 08 48 89 09 fe 03 fb 48 8b 41 f8 48 83 e0 fc 48 39 d8 74 04 <0f> 0b eb fe f0 80 61 f8 fe ff d5 65 48 8b 04 25 10 00 00 00 8b
> > > [228704.930002] RIP  [<ffffffff8023c6db>] run_workqueue+0x6f/0x102
> > > [228704.930002]  RSP <ffff880214bcdec0>
> > > [228704.941003] ---[ end trace deef6e5387b5a584 ]---
> > 
> > Thanks for any input, for reight now I'm quite helpless....
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

