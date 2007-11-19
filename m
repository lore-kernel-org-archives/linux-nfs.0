From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Mon, 19 Nov 2007 14:50:03 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0711191449360.15054__5498.41060205853$1195536025$gmane$org@schroedinger.engr.sgi.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu> <20071117230049.GA25905@dyad>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	LKML <linux-kernel@vger.kernel.org>,
	Torsten Kaiser <just.for.lkml@googlemail.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>, Ingo Molnar <mingo@elte.hu>,
	Jan Blunck <jblunck@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: root <root-//MPyowsN0/ufwbnZn8s221VskVaOSLqXqFh9Ls21Oc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuFRK-00010e-UO
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 14:50:04 -0800
Received: from relay1.sgi.com ([192.48.171.29] helo=relay.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuFRP-0003O3-PE
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 14:50:08 -0800
In-Reply-To: <20071117230049.GA25905@dyad>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sun, 18 Nov 2007, root wrote:

> @@ -2155,6 +2155,7 @@ static struct kmem_cache_node *early_kme
>  {
>  	struct page *page;
>  	struct kmem_cache_node *n;
> +	unsigned long flags;
>  
>  	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
>  

Well local_irq_save is a bit of an overkill. We know that interrupts are 
enabled during this phase of the boot sequence.


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

