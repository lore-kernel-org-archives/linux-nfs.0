Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754975Ab2FNBhS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jun 2012 21:37:18 -0400
Date: Wed, 13 Jun 2012 21:37:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Hans de Bruin <jmdebruin@xmsnet.nl>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfsroot client will not start firefox or thunderbird from 3.4.0
 nfsserver
Message-ID: <20120613213714.6c1b6dcd@corrin.poochiereds.net>
In-Reply-To: <4FD8D991.7060002@xmsnet.nl>
References: <4FC3F9F6.7010107@xmsnet.nl>
	<20120610055208.05ea7ea7@tlielax.poochiereds.net>
	<4FD4A77B.2030506@xmsnet.nl>
	<20120611071142.44c33587@corrin.poochiereds.net>
	<4FD8D991.7060002@xmsnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 13 Jun 2012 20:18:57 +0200
Hans de Bruin <jmdebruin@xmsnet.nl> wrote:

> On 06/11/2012 01:11 PM, Jeff Layton wrote:
> > On Sun, 10 Jun 2012 15:56:11 +0200
> > Hans de Bruin<jmdebruin@xmsnet.nl>  wrote:
> >
> >> On 06/10/2012 11:52 AM, Jeff Layton wrote:
> >>> On Tue, 29 May 2012 00:19:34 +0200
> >>> Hans de Bruin<jmdebruin@xmsnet.nl>   wrote:
> >>>
> >>>> I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into
> >>>> some trouble. My laptop, a nfsroot client, will not run firefox and
> >>>> thunderbird anymore. When I start these programs from an xterm, the
> >>>> cursor goes to the next line and waits indefinitely.
> >>>>
> >>>> I do not know if there is any order is lsof's output. A lsof | grep
> >>>> firefox or thunderbird shows ......./.parentlock as the last line.
> >>>>
> >>>> It does not matter whether the client is running a 3.4.0 or a 3.3.0
> >>>> kernel, or if the server is running on top of xen or not.
> >>>>
> >>>> There is some noise in the servers dmesg:
> >>>>
> >>>> [  241.256684] INFO: task kworker/u:2:801 blocked for more than 120 seconds.
> >>>> [  241.256691] "echo 0>   /proc/sys/kernel/hung_task_timeout_secs"
> >>>> disables this message.
> >>>> [  241.256698] kworker/u:2     D 000000000000000c     0   801      2
> >>>> 0x00000000
> >>>> [  241.256710]  ffff8801390e5cf0 0000000000000046 0000000000012d00
> >>>> 0000000000012d00
> >>>> [  241.256721]  0000000000012d00 ffff880139f8bd50 0000000000012d00
> >>>> ffff8801390e5fd8
> >>>> [  241.256732]  ffff8801390e5fd8 0000000000012d00 ffff880139ce4420
> >>>> ffff880139f8bd50
> >>>> [  241.256743] Call Trace:
> >>>> [  241.256759]  [<ffffffff8158733e>] schedule+0x64/0x66
> >>>> [  241.256769]  [<ffffffff8120184e>] cld_pipe_upcall+0x95/0xd1
> >>>> [  241.256780]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
> >>>> [  241.256789]  [<ffffffff81201d06>] nfsd4_cld_grace_done+0x50/0x8a
> >>>> [  241.256798]  [<ffffffff81202233>] nfsd4_record_grace_done+0x18/0x1a
> >>>> [  241.256807]  [<ffffffff811fbdd7>] laundromat_main+0x4a/0x213
> >>>> [  241.256818]  [<ffffffff8106a06b>] ? need_resched+0x1e/0x28
> >>>> [  241.256826]  [<ffffffff8158725d>] ? __schedule+0x49d/0x4b5
> >>>> [  241.256835]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
> >>>> [  241.256844]  [<ffffffff8105be2d>] process_one_work+0x190/0x28d
> >>>> [  241.256854]  [<ffffffff8105ca67>] worker_thread+0x105/0x189
> >>>> [  241.256862]  [<ffffffff81587b8d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
> >>>> [  241.256872]  [<ffffffff8105c962>] ? manage_workers.clone.17+0x173/0x173
> >>>> [  241.256881]  [<ffffffff810604b0>] kthread+0x8a/0x92
> >>>> [  241.256891]  [<ffffffff815899a4>] kernel_thread_helper+0x4/0x10
> >>>> [  241.256900]  [<ffffffff81060426>] ?
> >>>> kthread_freezable_should_stop+0x47/0x47
> >>>> [  241.256909]  [<ffffffff815899a0>] ? gs_change+0x13/0x13
> >>>>
> >>>> or xenified:
> >>>>
> >>>>
> >>>> [  240.563448] "echo 0>   /proc/sys/kernel/hung_task_timeout_secs"
> >>>> disables this message.
> >>>> [  240.563458] kworker/u:2     D ffff88007fc12d00     0   808      2
> >>>> 0x00000000
> >>>> [  240.563479]  ffff88007532fcf0 0000000000000246 0000000000012d00
> >>>> 0000000000012d00
> >>>> [  240.563504]  0000000000012d00 ffff880075f7caf0 0000000000012d00
> >>>> ffff88007532ffd8
> >>>> [  240.563530]  ffff88007532ffd8 0000000000012d00 ffffffff81813020
> >>>> ffff880075f7caf0
> >>>> [  240.563555] Call Trace:
> >>>> [  240.563578]  [<ffffffff8158733e>] schedule+0x64/0x66
> >>>> [  240.563594]  [<ffffffff8120184e>] cld_pipe_upcall+0x95/0xd1
> >>>> [  240.563611]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
> >>>> [  240.563625]  [<ffffffff81201d06>] nfsd4_cld_grace_done+0x50/0x8a
> >>>> [  240.563640]  [<ffffffff81202233>] nfsd4_record_grace_done+0x18/0x1a
> >>>> [  240.563654]  [<ffffffff811fbdd7>] laundromat_main+0x4a/0x213
> >>>> [  240.563670]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
> >>>> [  240.563685]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
> >>>> [  240.563700]  [<ffffffff8105be2d>] process_one_work+0x190/0x28d
> >>>> [  240.563714]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
> >>>> [  240.563729]  [<ffffffff8105ca67>] worker_thread+0x105/0x189
> >>>> [  240.563743]  [<ffffffff81587b8d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
> >>>> [  240.563758]  [<ffffffff8105c962>] ? manage_workers.clone.17+0x173/0x173
> >>>> [  240.563772]  [<ffffffff810604b0>] kthread+0x8a/0x92
> >>>> [  240.563787]  [<ffffffff815899a4>] kernel_thread_helper+0x4/0x10
> >>>> [  240.563802]  [<ffffffff81587f38>] ? retint_restore_args+0x5/0x6
> >>>> [  240.563816]  [<ffffffff815899a0>] ? gs_change+0x13/0x13
> >>>>
> >>>>
> >>>
> >>> It sounds like you're not running the new nfsdcld daemon on the server,
> >>> and /var/lib/nfs/v4recovery does not exist. Is that correct?
> >>>
> >>
> >> Yes that correct. When I create the /var/lib/nfs/v4recovery directory my
> >> problems are gone.
> >>
> >> On the server and the client v3 and v4 are compiled into the kernel. Al
> >> mounts are v3. Should I either remove v4 from the kernels or upgrade
> >> nfs-utils-1.2.3 to something newer?
> >>
> >> (a search on the linux-nfs wiki for nfsdcld does not return any hits)
> >>
> >
> > Here's what I see on my machine when I remove the v4recovery dir and
> > don't run nfsdcld:
> >
> > [  109.715080] NFSD: starting 90-second grace period
> > [  229.984220] NFSD: Unable to end grace period: -110
> >
> > ...and -110 is -ETIMEDOUT. So, what happens is that nfsd kicks off the
> > laundromat job to run 90s after it starts. When it runs, it attempts to
> > talk to nfsdcld because the v4recovery dir isn't present. That fails
> > 30s later.
> >
> > Now, how that works is all rather convoluted. When we do the upcall, we
> > put the message on a rpc_pipefs pipe queue, and then set a delayed
> > workqueue job to walk that queue later and look for stuff that's been
> > sitting there for more than 30s. Anything that has will get the status
> > set to -ETIMEDOUT, and the task that submitted the upcall gets woken back up.
> >
> > It sounds like on your machine that the queue_timeout job isn't getting
> > run for some reason. That would leave the upcalling tasks sitting in
> > schedule for longer than 30s. Perhaps your workqueues are all blocking
> > and the cmwq infrastructure isn't able to spawn new ones?
> >
> > You may want to look at /proc/<pid>/stack for all of the kworker tasks
> > and see what they're doing...
> >
> 
> Attached is the output of this script which ran at the server:
> 
> #!/bin/bash
> cd /proc
> while :
> do
>    echo >> /root/log
>    date >> /root/log
>    echo >> /root/log
>    dmesg | tail -n 30 >> /root/log
>    echo >> /root/log
>    `ps ax|grep '[k]worker'| sed  's/ *\([0-9]*\) ?.*/tail \1\/stack/g'` 
>  >> /root/log
>    sleep 20
> done
> 
> 
> It dumps /proc/'pid'/stack for al the worker threads.
> 

I thought I had cc'ed you on the other thread, but I think we know what
the problem is now. This patch should fix it:

    [PATCH] rpc_pipefs: allow rpc_purge_list to take a NULL waitq pointer

-- 
Jeff Layton <jlayton@redhat.com>
