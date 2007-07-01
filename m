From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Re: soft lockup
Date: Sat, 30 Jun 2007 20:58:34 -0700
Message-ID: <20070701035833.GA20145@ligo.caltech.edu>
References: <20070628235249.GM32531@ligo.caltech.edu>
	<1183088891.6163.119.camel@heimdal.trondhjem.org>
	<20070629155831.GA14875@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4qaF-0002zg-0S
	for nfs@lists.sourceforge.net; Sat, 30 Jun 2007 20:58:47 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I4qaH-0007L0-1u
	for nfs@lists.sourceforge.net; Sat, 30 Jun 2007 20:58:50 -0700
In-Reply-To: <20070629155831.GA14875@ligo.caltech.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Here is another soft lockup after running dmesg -s 90000 that shows a deeper
call trace, but still has EOI. The 19 occurances after this one are back
to the shallower call trace. Do I have to recompile the kernel to get a
larger kernel ring buffer for dmesg to query?

Thanks.

kernel: BUG: soft lockup detected on CPU#0!
kernel: 
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff8025a17c>] softlockup_tick+0xfc/0x140
kernel:  [<ffffffff80237ed7>] update_process_times+0x57/0x90
kernel:  [<ffffffff802160e4>] smp_local_timer_interrupt+0x34/0x60
kernel:  [<ffffffff80216789>] smp_apic_timer_interrupt+0x59/0x80
kernel:  [<ffffffff8020a7b6>] apic_timer_interrupt+0x66/0x70
kernel:  [<ffffffff80404670>] ip_finish_output+0x0/0x1b0
kernel:  [<ffffffff803e90a2>] dev_queue_xmit+0x102/0x2b0
kernel:  [<ffffffff80404db8>] ip_output+0x208/0x260
kernel:  [<ffffffff80404616>] ip_queue_xmit+0x446/0x4a0
kernel:  [<ffffffff880fbcd3>] :ip_conntrack:__ip_ct_refresh_acct+0x73/0xa0
kernel:  [<ffffffff880fea3f>] :ip_conntrack:tcp_packet+0xa3f/0xa90
kernel:  [<ffffffff80415390>] tcp_transmit_skb+0x6d0/0x710
kernel:  [<ffffffff803e08bf>] __alloc_skb+0x8f/0x160
kernel:  [<ffffffff80413f61>] tcp_rcv_established+0x631/0x9b0
kernel:  [<ffffffff8041b84f>] tcp_v4_do_rcv+0x3f/0x330
kernel:  [<ffffffff803f902c>] nf_iterate+0x5c/0xa0
kernel:  [<ffffffff8041ca8e>] tcp_v4_rcv+0x8ce/0x940
kernel:  [<ffffffff803ff0c1>] ip_local_deliver+0x131/0x1d0
kernel:  [<ffffffff803ff63e>] ip_rcv+0x4de/0x550
kernel:  [<ffffffff803e9516>] process_backlog+0xa6/0x150
kernel:  [<ffffffff803e6e14>] net_rx_action+0x84/0x180
kernel:  [<ffffffff80233fa3>] __do_softirq+0x63/0xd0
kernel:  [<ffffffff881254a0>] :sunrpc:rpc_async_schedule+0x0/0x10
kernel:  [<ffffffff8020ad0c>] call_softirq+0x1c/0x30
kernel:  [<ffffffff8020cb6c>] do_softirq+0x2c/0x90
kernel:  [<ffffffff8020cca9>] do_IRQ+0xd9/0x100
kernel:  [<ffffffff8020a101>] ret_from_intr+0x0/0xa
kernel:  <EOI>  [<ffffffff88126700>] :sunrpc:unx_validate+0x0/0x70
kernel:  [<ffffffff803272e1>] _raw_spin_lock+0xb1/0x150
kernel:  [<ffffffff8817a310>] :nfs:nfs3_xdr_readres+0x0/0x170
kernel:  [<ffffffff8043d74d>] lock_kernel+0x1d/0x30
kernel:  [<ffffffff8811ef7a>] :sunrpc:call_decode+0x5ba/0x660
kernel:  [<ffffffff881254a0>] :sunrpc:rpc_async_schedule+0x0/0x10
kernel:  [<ffffffff8812521e>] :sunrpc:__rpc_execute+0x8e/0x280
kernel:  [<ffffffff8023fd6e>] run_workqueue+0xae/0x160
kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
kernel:  [<ffffffff80240031>] worker_thread+0x151/0x190
kernel:  [<ffffffff80229490>] default_wake_function+0x0/0x10
kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
kernel:  [<ffffffff80243b79>] kthread+0xd9/0x120
kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
kernel:  [<ffffffff80243aa0>] kthread+0x0/0x120
kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
kernel: 


On Fri, Jun 29, 2007 at 08:58:31AM -0700, Stuart Anderson wrote:
> On Thu, Jun 28, 2007 at 11:48:11PM -0400, Trond Myklebust wrote:
> > On Thu, 2007-06-28 at 16:52 -0700, Stuart Anderson wrote:
> > > I am currently getting a soft lockup every few minutes on a Sun X4600M2
> > > (8 x Opteron 8218) running 2.6.20.14 plus Tronds revalidate-the-fsid patch
> > > and Jeff's O_EXCL-OPEN patch. The machine is still usable but a bit slow and
> > > currently the rpciod/0 thread is being reported as using 100%CPU by top.
> > > 
> > > Any ideas?
> > > 
> > > Thanks.
> > > 
> > > kernel: BUG: soft lockup detected on CPU#0!
> > > kernel: 
> > > kernel: Call Trace:
> > > kernel:  <IRQ>  [<ffffffff8025a17c>] softlockup_tick+0xfc/0x140
> > > kernel:  [<ffffffff80237ed7>] update_process_times+0x57/0x90
> > > kernel:  [<ffffffff802160e4>] smp_local_timer_interrupt+0x34/0x60
> > > kernel:  [<ffffffff80216789>] smp_apic_timer_interrupt+0x59/0x80
> > > kernel:  [<ffffffff8020a7b6>] apic_timer_interrupt+0x66/0x70
> > > kernel:  <EOI>  [<ffffffff8817a310>] :nfs:nfs3_xdr_readres+0x0/0x170
> > > kernel:  [<ffffffff803272e1>] _raw_spin_lock+0xb1/0x150
> > > kernel:  [<ffffffff8817a310>] :nfs:nfs3_xdr_readres+0x0/0x170
> > > kernel:  [<ffffffff8043d74d>] lock_kernel+0x1d/0x30
> > > kernel:  [<ffffffff88123f3f>] :sunrpc:rpc_exit_task+0x1f/0x90
> > > kernel:  [<ffffffff8812521e>] :sunrpc:__rpc_execute+0x8e/0x280
> > > kernel:  [<ffffffff8023fd6e>] run_workqueue+0xae/0x160
> > > kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
> > > kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
> > > kernel:  [<ffffffff80240031>] worker_thread+0x151/0x190
> > > kernel:  [<ffffffff80229490>] default_wake_function+0x0/0x10
> > > kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
> > > kernel:  [<ffffffff80243b79>] kthread+0xd9/0x120
> > > kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
> > > kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
> > > kernel:  [<ffffffff80243aa0>] kthread+0x0/0x120
> > > kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
> > > kernel: 
> > 
> > I don't see how anything could lock up in nfs3_xdr_readres(). There
> > should be no loops in that routine at all.
> > 
> > What is that "<EOI>" in the above dump? Is that syslog failing to record
> > something?
> 
> syslog is working as far as I can tell. What does EOI indicate (End Of Input?)
> 
> > If so, could you please try using 'dmesg -s 90000' in order to recover
> > the missing info?
> 
> I have increased the buffer for the next occurance. However, after getting
> 268 soft lockups yesterday they are no longer occuring today. The rpciod/0
> kernel thread is now using "just" ~70% of one cpu compared to 100% when we
> where getting the lockups yesterday.
> 
> Only about half of the soft lockups refer to nfs3_xdr_readres. They all
> have an <EOI> and all but one has "sunrpc:__rpc_execute"
> 
> Here is example that does not refer to nfs3_xdr_readres. Perhaps this
> is more general than NFS? though we did not see these until we started
> using NFSV4 client mounts. The other change we made when adding NFSV4
> mounts was updating nfs-utils to 1.0.9-16 (CentOS 5 patches) to avoid
> some of the known memory leaks/spin loops in rpc.idmapd and rpc.mountd.
> 
> kernel: BUG: soft lockup detected on CPU#0!
> kernel: 
> kernel: Call Trace:
> kernel:  <IRQ>  [<ffffffff8025a17c>] softlockup_tick+0xfc/0x140
> kernel:  [<ffffffff80237ed7>] update_process_times+0x57/0x90
> kernel:  [<ffffffff802160e4>] smp_local_timer_interrupt+0x34/0x60
> kernel:  [<ffffffff80216789>] smp_apic_timer_interrupt+0x59/0x80
> kernel:  [<ffffffff8020a7b6>] apic_timer_interrupt+0x66/0x70
> kernel:  <EOI>  [<ffffffff803272e1>] _raw_spin_lock+0xb1/0x150
> kernel:  [<ffffffff8043d74d>] lock_kernel+0x1d/0x30
> kernel:  [<ffffffff88123fd0>] :sunrpc:rpc_release_calldata+0x20/0x50
> kernel:  [<ffffffff881253ff>] :sunrpc:__rpc_execute+0x26f/0x280
> kernel:  [<ffffffff8023fd6e>] run_workqueue+0xae/0x160
> kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
> kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
> kernel:  [<ffffffff80240031>] worker_thread+0x151/0x190
> kernel:  [<ffffffff80229490>] default_wake_function+0x0/0x10
> kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
> kernel:  [<ffffffff80243b79>] kthread+0xd9/0x120
> kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
> kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
> kernel:  [<ffffffff80243aa0>] kthread+0x0/0x120
> kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
> kernel: 
> 

-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
