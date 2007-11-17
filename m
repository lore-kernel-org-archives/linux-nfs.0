From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 10:19:57 -0800
Message-ID: <20071117101957.7562639d.akpm__2962.27797302908$1195332539$gmane$org@linux-foundation.org>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter-MRDXTZLjjMs8G+1z+Pypc6QD96bmaF075NbjCUgZEJk@public.gmane.org,
	Zijlstra <a.p.zijlstra@chello.nl>,
	LKML <linux-kernel@vger.kernel.org>,
	Torsten Kaiser <just.for.lkml@googlemail.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItSHX-0004Id-6l
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:21:01 -0800
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItSHc-0003ib-0R
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:20:45 -0800
In-Reply-To: <20071117180946.GA14055@elte.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 17 Nov 2007 19:09:46 +0100 Ingo Molnar <mingo@elte.hu> wrote:

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
> 

mutter.

Torsten, you could try CONFIG_SLAB=y, CONFIG_SLUB=n to see if you can make
some progress on the NFS problem.


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

