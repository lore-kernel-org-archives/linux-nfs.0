Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58598 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755042Ab0I3WNO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 18:13:14 -0400
Date: Thu, 30 Sep 2010 18:13:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: BUG() in fs/nfs/nfs4proc.c
Message-ID: <20100930221300.GI15207@fieldses.org>
References: <20100930215256.GG15207@fieldses.org>
 <20100930220805.GH15207@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100930220805.GH15207@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 06:08:05PM -0400, J. Bruce Fields wrote:
> Bah, sorry, mixed up the Subject: and cc: lines!  Resending....
> 
> On Thu, Sep 30, 2010 at 05:52:56PM -0400, bfields wrote:
> > Have you seen this one before?
> > 
> > This is something 36-rc4-based.  Could be something I did, I don't know.
> 
> I haven't touched the client much.  What I meant was: could very well
> have been a weird server response that was the trigger.

Har.  Yes, all fields of the create_session reply were 0.

--b.

> 
> --b.
> 
> > 
> > This is the BUG_ON here:
> > 
> >         ret = nfs41_setup_sequence(data->clp->cl_session,
> >                                    &data->args->la_seq_args,
> >                                    &data->res->lr_seq_res, 0, task);
> > 
> >         BUG_ON(ret == -EAGAIN);
> > 
> > --b.
> > 
> > mount.nfs4 used greatest stack depth: 2752 bytes left
> > ------------[ cut here ]------------
> > kernel BUG at fs/nfs/nfs4proc.c:4630!
> > invalid opcode: 0000 [#1] PREEMPT 
> > last sysfs file: /sys/devices/virtio-pci/virtio2/net/eth0/broadcast
> > CPU 0 
> > Modules linked in: [last unloaded: scsi_wait_scan]
> > 
> > Pid: 7813, comm: 192.168.122.101 Not tainted 2.6.36-rc4-00061-g6e9e178 #511 /Bochs
> > RIP: 0010:[<ffffffff8123d5be>]  [<ffffffff8123d5be>] nfs4_get_lease_time_prepare+0x8e/0xa0
> > RSP: 0018:ffff88001ca33c40  EFLAGS: 00010246
> > RAX: 00000000fffffff5 RBX: ffff88001e9fc078 RCX: 0000000000000000
> > RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff8123d397
> > RBP: ffff88001ca33c50 R08: 0000000000000000 R09: 0000000000000001
> > R10: 0000000000000001 R11: 0000000000000001 R12: ffff88001ca33d90
> > R13: 0000000000000000 R14: 0000000000000000 R15: ffff88001e1b4f38
> > FS:  0000000000000000(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 00007fa8e9834000 CR3: 000000001c921000 CR4: 00000000000006f0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process 192.168.122.101 (pid: 7813, threadinfo ffff88001ca32000, task ffff88001c96e090)
> > Stack:
> >  ffff88001e9fc078 ffff88001e9fc0e8 ffff88001ca33c60 ffffffff81901fd3
> > <0> ffff88001ca33ca0 ffffffff81902bc2 ffff88001e9fc078 ffff88001e9fc078
> > <0> ffff88001e9fc078 ffff88001faf7d10 ffff88001faf7ce8 ffff88001e1b4f38
> > Call Trace:
> >  [<ffffffff81901fd3>] rpc_prepare_task+0x13/0x20
> >  [<ffffffff81902bc2>] __rpc_execute+0xa2/0x230
> >  [<ffffffff81902d91>] rpc_execute+0x41/0x50
> >  [<ffffffff818fb188>] rpc_run_task+0xd8/0x120
> >  [<ffffffff812364e2>] nfs4_proc_get_lease_time+0xc2/0x130
> >  [<ffffffff810305b1>] ? get_parent_ip+0x11/0x50
> >  [<ffffffff81968e95>] ? _raw_spin_unlock+0x35/0x60
> >  [<ffffffff81248ce1>] nfs41_setup_state_renewal+0x21/0x80
> >  [<ffffffff8123e83f>] ? nfs4_proc_create_session+0x16f/0x220
> >  [<ffffffff8124a516>] nfs41_init_clientid+0x56/0x70
> >  [<ffffffff81249d5d>] nfs4_run_state_manager+0x2ed/0x550
> >  [<ffffffff81249a70>] ? nfs4_run_state_manager+0x0/0x550
> >  [<ffffffff81059376>] kthread+0x96/0xa0
> >  [<ffffffff810030f4>] kernel_thread_helper+0x4/0x10
> >  [<ffffffff8103254b>] ? finish_task_switch.clone.3+0x7b/0xd0
> >  [<ffffffff819694be>] ? restore_args+0x0/0x30
> >  [<ffffffff810592e0>] ? kthread+0x0/0xa0
> >  [<ffffffff810030f0>] ? kernel_thread_helper+0x0/0x10
> > Code: 30 0e a3 81 48 c7 c7 08 a2 c8 81 31 c0 e8 4d 77 72 00 eb a4 48 c7 c6 30 0e a3 81 48 c7 c7 10 a2 c8 81 31 c0 e8 36 77 72 00 eb cd <0f> 0b eb fe 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 
> > RIP  [<ffffffff8123d5be>] nfs4_get_lease_time_prepare+0x8e/0xa0
> >  RSP <ffff88001ca33c40>
> > ---[ end trace 4b8872d8457a518d ]---
