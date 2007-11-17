From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 11:33:56 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0711171128530.7986__38064.1722506427$1195332540$gmane$org@schroedinger.engr.sgi.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117100507.912c5e5c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML <linux-kernel@vger.kernel.org>,
	Torsten Kaiser <just.for.lkml@googlemail.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItTQS-0002gd-9w
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 11:33:56 -0800
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18XKkis7bzNXvm2l5GqnicBx2kebHJBUKo=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItTQW-0000o7-Q4
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 11:34:02 -0800
In-Reply-To: <20071117100507.912c5e5c.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 17 Nov 2007, Andrew Morton wrote:

> > Don't know who to bug about that.
> 
> That's slub.  It appears that list_lock is being taken from process context
> in one place and from softirq in another.

I kicked out some weird interrupt disable code in mm that was only run during
NUMA bootstrap.

This should fix it but isnt there some mechanism to convince lockdep that 
it is okay to do these things during bootstrap?

---
 mm/slub.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-11-17 11:31:21.044136631 -0800
+++ linux-2.6/mm/slub.c	2007-11-17 11:32:17.364386560 -0800
@@ -2044,7 +2044,9 @@ static struct kmem_cache_node *early_kme
 #endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
+	local_irq_disable();
 	add_partial(kmalloc_caches, page, 0);
+	local_irq_enable();
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

