From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 21:10:44 +0100
Message-ID: <64bb37e0711171210x40dd500ap31e4ea4f8535349d__36553.2147036449$1195332542$gmane$org@mail.gmail.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117100507.912c5e5c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0711171128530.7986@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: "Christoph Lameter" <clameter@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItU0O-00069g-N0
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 12:11:05 -0800
Received: from py-out-1112.google.com ([64.233.166.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItU0U-00048a-FH
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 12:11:10 -0800
Received: by py-out-1112.google.com with SMTP id a25so1965950pyi
	for <nfs@lists.sourceforge.net>; Sat, 17 Nov 2007 12:10:48 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0711171128530.7986-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 17, 2007 8:33 PM, Christoph Lameter <clameter@sgi.com> wrote:
> On Sat, 17 Nov 2007, Andrew Morton wrote:
>
> > That's slub.  It appears that list_lock is being taken from process context
> > in one place and from softirq in another.
>
> I kicked out some weird interrupt disable code in mm that was only run during
> NUMA bootstrap.

I'm using NUMA (Opteron), so this indeed fixes it.

A kernel complied with SLUB now outputs the same message as the SLAB
one, that lockdep annotations are needed at the place where nfs hangs.

> This should fix it but isnt there some mechanism to convince lockdep that
> it is okay to do these things during bootstrap?
>
> ---
>  mm/slub.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c    2007-11-17 11:31:21.044136631 -0800
> +++ linux-2.6/mm/slub.c 2007-11-17 11:32:17.364386560 -0800
> @@ -2044,7 +2044,9 @@ static struct kmem_cache_node *early_kme
>  #endif
>         init_kmem_cache_node(n);
>         atomic_long_inc(&n->nr_slabs);
> +       local_irq_disable();
>         add_partial(kmalloc_caches, page, 0);
> +       local_irq_enable();
>         return n;
>  }
>
>
>

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

