Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33001 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbbLAAzd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 19:55:33 -0500
Received: by obbww6 with SMTP id ww6so142722933obb.0
        for <linux-nfs@vger.kernel.org>; Mon, 30 Nov 2015 16:55:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151130193313.5bb10791@synchrony.poochiereds.net>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
	<565A7A14.4010902@gmail.com>
	<20151129084614.42fb1272@tlielax.poochiereds.net>
	<565BBB03.7020206@gmail.com>
	<20151130213420.GA31564@fieldses.org>
	<20151130193313.5bb10791@synchrony.poochiereds.net>
Date: Mon, 30 Nov 2015 19:55:32 -0500
Message-ID: <CAHQdGtStdkFJhJDY6MaBwhOx-BGvmkqxSBAhC84U1VnpWjDg6Q@mail.gmail.com>
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 30, 2015 at 7:33 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
>
> On Mon, 30 Nov 2015 16:34:20 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
> > On Mon, Nov 30, 2015 at 10:57:07AM +0800, Kinglong Mee wrote:
> > > On 11/29/2015 21:46, Jeff Layton wrote:
> > > > On Sun, 29 Nov 2015 12:07:48 +0800
> > > > Kinglong Mee <kinglongmee@gmail.com> wrote:
> > > >
> > > >> I meet two problems with this patch,
> > > >>
> > > >
> > > > Ok, I was less sure of this patch than the other one. I think we will
> > > > need to serialize these operations, but this may not be the best way to
> > > > do it.
> > > >
> > > > Bruce if you want to back this one for now, then I'm fine with that. It
> > > > may be a bit before I can get to it.
> > > >
> > > >
> > > >> 1. a dump_stack messages printed in process_one_work() at kernel/workqueue.c.
> > > >>
> > > >> BUG: workqueue leaked lock or atomic: kworker/u2:4/0x00000000/98#012     last function: nfsd4_run_cb_work [nfsd]
> > > >> 1 lock held by kworker/u2:4/98:
> > > >> #0:  (&ls->ls_mutex){......}, at: [<ffffffffa0250d34>] nfsd4_cb_layout_prepare+0x24/0x40 [nfsd]
> > > >> CPU: 0 PID: 98 Comm: kworker/u2:4 Not tainted 4.4.0-rc2+ #333
> > > >> Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> > > >> Workqueue: nfsd4_callbacks nfsd4_run_cb_work [nfsd]
> > > >> ffff8800362b9e40 000000007fe9394f ffff880036353d58 ffffffff8136dc64
> > > >> ffff880036353dd8 ffffffff810a3f12 ffffffff810a3cbd 000000000000000a
> > > >> ffffffffa0261d78 ffffffff82902e20 0000000000000000 ffffffffa0259241
> > > >> Call Trace:
> > > >> [<ffffffff8136dc64>] dump_stack+0x19/0x25
> > > >> [<ffffffff810a3f12>] process_one_work+0x3c2/0x4c0
> > > >> [<ffffffff810a3cbd>] ? process_one_work+0x16d/0x4c0
> > > >> [<ffffffff810a405a>] worker_thread+0x4a/0x440
> > > >> [<ffffffff810a4010>] ? process_one_work+0x4c0/0x4c0
> > > >> [<ffffffff810a4010>] ? process_one_work+0x4c0/0x4c0
> > > >> [<ffffffff810a91e5>] kthread+0xf5/0x110
> > > >> [<ffffffff810a90f0>] ? kthread_create_on_node+0x240/0x240
> > > >> [<ffffffff81738d0f>] ret_from_fork+0x3f/0x70
> > > >> [<ffffffff810a90f0>] ? kthread_create_on_node+0x240/0x240
> > > >>
> > > >
> > > >
> > > > I guess this is just a general "hey you left a mutex locked" warning
> > > > when finishing a workqueue job? This patch actually does want to do
> > > > that, but I trying to tell that to lockdep may be tricky...
> > >
> > > Yes, it's just a warning.
> > > But, it's terrible that kernel prints it every time
> > > when calling nfsd4_cb_layout_prepare.
> > >
> > > >
> > > >
> > > >> 2. a mutex race between layoutrecall and layoutcommit,
> > > >>
> > > >> callback thread,
> > > >> nfsd4_cb_layout_prepare
> > > >>   --->mutex_lock(&ls->ls_mutex);
> > > >>
> > > >> layoutcommit thread,
> > > >> nfsd4_layoutcommit
> > > >>   ---> nfsd4_preprocess_layout_stateid
> > > >>      --> mutex_lock(&ls->ls_mutex);   <----------------  hang
> > > >>
> > > >> [  600.645142] INFO: task nfsd:11623 blocked for more than 120 seconds.
> > > >> [  600.646337]       Not tainted 4.4.0-rc2+ #332
> > > >> [  600.647404] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > >> [  600.648546] nfsd            D ffff880064277b80     0 11623      2 0x00000000
> > > >> [  600.649803]  ffff880064277b80 ffff880064278000 00000000ffffffff ffff88005dd241a8
> > > >> [  600.651021]  ffffffffa025e77c 0000000000000246 ffff880064277b98 ffffffff81733103
> > > >> [  600.652255]  ffff880063d7e100 ffff880064277ba8 ffffffff8173330e ffff880064277c28
> > > >> [  600.653512] Call Trace:
> > > >> [  600.654765]  [<ffffffffa025e77c>] ? nfsd4_preprocess_layout_stateid+0x37c/0x400 [nfsd]
> > > >> [  600.656084]  [<ffffffff81733103>] schedule+0x33/0x80
> > > >> [  600.657405]  [<ffffffff8173330e>] schedule_preempt_disabled+0xe/0x10
> > > >> [  600.658741]  [<ffffffff817357f5>] mutex_lock_nested+0x145/0x330
> > > >> [  600.660094]  [<ffffffffa025e77c>] ? nfsd4_preprocess_layout_stateid+0x37c/0x400 [nfsd]
> > > >> [  600.661696]  [<ffffffffa025e77c>] nfsd4_preprocess_layout_stateid+0x37c/0x400 [nfsd]
> > > >> [  600.663129]  [<ffffffffa025e405>] ? nfsd4_preprocess_layout_stateid+0x5/0x400 [nfsd]
> > > >> [  600.664558]  [<ffffffff81173b8f>] ? printk+0x56/0x72
> > > >> [  600.665990]  [<ffffffffa023e3ec>] nfsd4_layoutcommit+0x13c/0x200 [nfsd]
> > > >> [  600.667365]  [<ffffffffa023fb98>] nfsd4_proc_compound+0x388/0x660 [nfsd]
> > > >> [  600.668835]  [<ffffffffa022c148>] nfsd_dispatch+0xb8/0x200 [nfsd]
> > > >> [  600.670323]  [<ffffffffa0093d89>] svc_process_common+0x409/0x650 [sunrpc]
> > > >> [  600.671836]  [<ffffffffa0094e04>] svc_process+0xf4/0x190 [sunrpc]
> > > >> [  600.673328]  [<ffffffffa022bb05>] nfsd+0x135/0x1a0 [nfsd]
> > > >> [  600.674825]  [<ffffffffa022b9d5>] ? nfsd+0x5/0x1a0 [nfsd]
> > > >> [  600.676388]  [<ffffffffa022b9d0>] ? nfsd_destroy+0xb0/0xb0 [nfsd]
> > > >> [  600.677884]  [<ffffffff810a9175>] kthread+0xf5/0x110
> > > >> [  600.679373]  [<ffffffff810a9080>] ? kthread_create_on_node+0x240/0x240
> > > >> [  600.680874]  [<ffffffff81738ccf>] ret_from_fork+0x3f/0x70
> > > >> [  600.682398]  [<ffffffff810a9080>] ? kthread_create_on_node+0x240/0x240
> > > >> [  600.683893] 1 lock held by nfsd/11623:
> > > >> [  600.685449]  #0:  (&ls->ls_mutex){......}, at: [<ffffffffa025e77c>] nfsd4_preprocess_layout_stateid+0x37c/0x400 [nfsd]
> > > >> [  600.688778] Sending NMI to all CPUs:
> > > >> [  600.690854] NMI backtrace for cpu 0
> > > >> [  600.691909] CPU: 0 PID: 11 Comm: khungtaskd Not tainted 4.4.0-rc2+ #332
> > > >> [  600.692523] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> > > >> [  600.693821] task: ffff88007b900000 ti: ffff88007b8fc000 task.ti: ffff88007b8fc000
> > > >> [  600.694496] RIP: 0010:[<ffffffff81053aca>]  [<ffffffff81053aca>] native_write_msr_safe+0xa/0x10
> > > >> [  600.695185] RSP: 0018:ffff88007b8ffd70  EFLAGS: 00000046
> > > >> [  600.695861] RAX: 0000000000000400 RBX: 0000000000000286 RCX: 0000000000000830
> > > >> [  600.696539] RDX: 0000000000000000 RSI: 0000000000000400 RDI: 0000000000000830
> > > >> [  600.697204] RBP: ffff88007b8ffd70 R08: 0000000000000400 R09: 0000000000000000
> > > >> [  600.697862] R10: 00000000000000e4 R11: 0000000000000001 R12: ffff880063d7e100
> > > >> [  600.698513] R13: 00000000003fff3c R14: ffff880063d7e308 R15: 0000000000000004
> > > >> [  600.699156] FS:  0000000000000000(0000) GS:ffffffff81c27000(0000) knlGS:0000000000000000
> > > >> [  600.699823] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > >> [  600.700459] CR2: 00007f366afd4000 CR3: 000000005dd56000 CR4: 00000000001406f0
> > > >> [  600.701106] Stack:
> > > >> [  600.701745]  ffff88007b8ffd88 ffffffff8104a860 ffffffff81047340 ffff88007b8ffd98
> > > >> [  600.702404]  ffffffff8104a885 ffff88007b8ffda8 ffffffff8104735b ffff88007b8ffdd8
> > > >> [  600.703058]  ffffffff813723ad 0000000000000078 ffff880063d7e100 00000000003fff3c
> > > >> [  600.703712] Call Trace:
> > > >> [  600.704355]  [<ffffffff8104a860>] __x2apic_send_IPI_mask.isra.2+0x60/0x70
> > > >> [  600.705017]  [<ffffffff81047340>] ? setup_vector_irq+0x130/0x130
> > > >> [  600.705676]  [<ffffffff8104a885>] x2apic_send_IPI_mask+0x15/0x20
> > > >> [  600.706335]  [<ffffffff8104735b>] nmi_raise_cpu_backtrace+0x1b/0x20
> > > >> [  600.706989]  [<ffffffff813723ad>] nmi_trigger_all_cpu_backtrace+0x14d/0x1c0
> > > >> [  600.707693]  [<ffffffff810473b9>] arch_trigger_all_cpu_backtrace+0x19/0x20
> > > >> [  600.708362]  [<ffffffff8112c4cf>] watchdog+0x32f/0x370
> > > >> [  600.709031]  [<ffffffff8112c221>] ? watchdog+0x81/0x370
> > > >> [  600.709725]  [<ffffffff8112c1a0>] ? reset_hung_task_detector+0x20/0x20
> > > >> [  600.710398]  [<ffffffff810a9175>] kthread+0xf5/0x110
> > > >> [  600.711067]  [<ffffffff810a9080>] ? kthread_create_on_node+0x240/0x240
> > > >> [  600.711739]  [<ffffffff81738ccf>] ret_from_fork+0x3f/0x70
> > > >> [  600.712405]  [<ffffffff810a9080>] ? kthread_create_on_node+0x240/0x240
> > > >> [  600.713073] Code: 00 55 89 f9 48 89 e5 0f 32 45 31 c0 48 c1 e2 20 44 89 06 48 09 d0 5d c3 66 0f 1f 84 00 00 00 00 00 55 89 f0 89 f9 48 89 e5 0f 30 <31> c0 5d c3 66 90 55 89 f9 48 89 e5 0f 33 48 c1 e2 20 48 09 d0
> > > >> [  600.715196] Kernel panic - not syncing: hung_task: blocked tasks
> > > >> [  600.715889] CPU: 0 PID: 11 Comm: khungtaskd Not tainted 4.4.0-rc2+ #332
> > > >> [  600.716540] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> > > >> [  600.717910]  ffffffff81a4d19c 00000000480750be ffff88007b8ffd60 ffffffff8136dbf4
> > > >> [  600.718610]  ffff88007b8ffde8 ffffffff81173559 ffff880000000008 ffff88007b8ffdf8
> > > >> [  600.719302]  ffff88007b8ffd90 00000000480750be 0000000000000001 0000000000000001
> > > >> [  600.719984] Call Trace:
> > > >> [  600.720646]  [<ffffffff8136dbf4>] dump_stack+0x19/0x25
> > > >> [  600.721330]  [<ffffffff81173559>] panic+0xd3/0x212
> > > >> [  600.722009]  [<ffffffff8112c4db>] watchdog+0x33b/0x370
> > > >> [  600.722686]  [<ffffffff8112c221>] ? watchdog+0x81/0x370
> > > >> [  600.723213]  [<ffffffff8112c1a0>] ? reset_hung_task_detector+0x20/0x20
> > > >> [  600.723674]  [<ffffffff810a9175>] kthread+0xf5/0x110
> > > >> [  600.724107]  [<ffffffff810a9080>] ? kthread_create_on_node+0x240/0x240
> > > >> [  600.724509]  [<ffffffff81738ccf>] ret_from_fork+0x3f/0x70
> > > >> [  600.724903]  [<ffffffff810a9080>] ? kthread_create_on_node+0x240/0x240
> > > >>
> > > >> thanks,
> > > >> Kinglong Mee
> > > >>
> > > >
> > > > This is the bigger problem, I think. The question of course is why the
> > > > client didn't respond to the cb request? Still, holding a mutex across
> > > > the callback RPC is pretty ugly and now that I think about it, I don't
> > > > think it's really necessary anyway. Once we've copied the stateid, we
> > > > aren't really changing anything else so we can let other layout ops
> > > > proceed.
> > > >
> > > > Would a patch like this fix it?
> > >
> > > Yes, it's great.
> > > With this patch, every thing is okay.
> > >
> > > >
> > > > -----------------------8<--------------------------
> > > >
> > > > [PATCH] nfsd: don't hold ls_mutex across a layout recall
> > > >
> > > > We do need to serialize layout stateid morphing operations, but we
> > > > currently hold the ls_mutex across a layout recall which is pretty
> > > > ugly. It's also unnecessary -- once we've bumped the seqid and
> > > > copied it, we don't need to serialize the rest of the CB_LAYOUTRECALL
> > > > vs. anything else. Just drop the mutex once the copy is done.
> > > >
> > > > Fixes: cc8a55320b5f "nfsd: serialize layout stateid morphing operations"
> > > > Cc: stable@vger.kernel.org
> > > > Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> > > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > >
> > > Tested-by: Kinglong Mee <kinglongmee@gmail.com>
> >
> > Thanks for the report and the testing.
> >
> > It may be worth applying just as a stopgap, but I'm not convinced this
> > is right yet....
> >
> > I guess I'd expect the stateid bump to be atomic with the actual change
> > to the layout state.  We're bumping the layout stateid on sending the
> > callback, and modifying the actual layout state on receive.  So after
> > the below patch we've left a window during which nfsd threads see the
> > new layout stateid but the old layout state.  I wonder what the
> > practical consequences of that are?
> >
> > My temptation is to argue that the layout processing currently done in
> > the release method should be done on sending (doesn't look like it's
> > conditional on the result of the callback, so what are we waiting for?).
> > But I'm not sure that's right.  I'll go read the spec....
> >
> > --b.
> >
>
> Agreed. The basic rule (AIUI) is that if you change anything in the
> layout then you should bump the seqid.
>
> But... is the layout processing in that release method supposed to be
> done at all in CB_LAYOUTRECALL? The spec says:
>
> -------------------8<-----------------------
>    The client's processing for CB_LAYOUTRECALL is similar to CB_RECALL
>    (recall of file delegations) in that the client responds to the
>    request before actually returning layouts via the LAYOUTRETURN
>    operation.  While the client responds to the CB_LAYOUTRECALL
>    immediately, the operation is not considered complete (i.e.,
>    considered pending) until all affected layouts are returned to the
>    server via the LAYOUTRETURN operation
> -------------------8<-----------------------
>
> It doesn't seem like we ought to be tearing down layouts at that
> point, but rather just notifying the client that they should be
> returned. Revoking the layout while the client still might have it in
> use seems like it could be problematic. Is there something I'm missing
> there?
>
> Oh, but I note that we do always set clora_changed to true...is that
> what gives us carte blanche to go ahead and return the layouts? If so,
> then doing that in the "prepare" op does seem like the right thing to
> do...
>

Nope... You're not allowed to just pull the plug on the client like
that. That can, and will trigger a TEST_STATEID storm for no good
reason.
