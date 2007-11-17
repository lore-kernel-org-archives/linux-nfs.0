From: root-ml83lk9NYoCAxCfHYDuV95NvnLFust7K9Kp1ZRVAGBM@public.gmane.org (root)
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sun, 18 Nov 2007 00:00:49 +0100
Message-ID: <20071117230049.GA25905__48144.3376317204$1195352264$gmane$org@dyad>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	LKML <linux-kernel@vger.kernel.org>,
	Torsten Kaiser <just.for.lkml@googlemail.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Christoph Lameter <clameter@sgi.com>,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItWex-0005ER-Lb
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 15:01:07 -0800
Received: from viefep18-int.chello.at ([213.46.255.22]
	helo=viefep16-int.chello.at)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItWf0-0006u0-RM
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 15:01:13 -0800
In-Reply-To: <20071117180946.GA14055@elte.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Nov 17, 2007 at 07:09:46PM +0100, Ingo Molnar wrote:
> 
> * Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> 
> > Sadly lockdep does not work for me, as it gets turned off early:
> > [   39.851594] ---------------------------------
> > [   39.855963] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> > [   39.861981] swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
> > [   39.866963]  (&n->list_lock){-+..}, at: [<ffffffff802935c1>]
> 
> hey, that means it found a bug - which is not sad at all :-)

---
Subject: lockdep: slub: annotate boot time node->list_lock usage

inconsistent {softirq-on-W} -> {in-softirq-W} usage.
swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
 (&n->list_lock){-+..}, at: [<ffffffff802935c1>] add_partial+0x31/0xa0
{softirq-on-W} state was registered at:
  [<ffffffff80259fb8>] __lock_acquire+0x3e8/0x1140
  [<ffffffff80259838>] debug_check_no_locks_freed+0x188/0x1a0
  [<ffffffff8025ad65>] lock_acquire+0x55/0x70
  [<ffffffff802935c1>] add_partial+0x31/0xa0
  [<ffffffff805c76de>] _spin_lock+0x1e/0x30
  [<ffffffff802935c1>] add_partial+0x31/0xa0
  [<ffffffff80296f9c>] kmem_cache_open+0x1cc/0x330
  [<ffffffff805c7984>] _spin_unlock_irq+0x24/0x30
  [<ffffffff802974f4>] create_kmalloc_cache+0x64/0xf0
  [<ffffffff80295640>] init_alloc_cpu_cpu+0x70/0x90
  [<ffffffff8080ada5>] kmem_cache_init+0x65/0x1d0
  [<ffffffff807f1b4e>] start_kernel+0x23e/0x350
  [<ffffffff807f112d>] _sinittext+0x12d/0x140
  [<ffffffffffffffff>] 0xffffffffffffffff

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Christoph Lameter <clameter@sgi.com>
CC: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
---
 mm/slub.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -2155,6 +2155,7 @@ static struct kmem_cache_node *early_kme
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	unsigned long flags;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
@@ -2179,7 +2180,14 @@ static struct kmem_cache_node *early_kme
 #endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
+	/*
+	 * lockdep requires consistent irq usage for each lock
+	 * so even though there cannot be a race this early in
+	 * the boot sequence, we still disable irqs.
+	 */
+	local_irq_save(flags);
 	add_partial(kmalloc_caches, page, 0);
+	local_irq_restore(flags);
 	return n;
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

