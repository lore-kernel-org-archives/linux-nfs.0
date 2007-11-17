From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 19:09:46 +0100
Message-ID: <20071117180946.GA14055__2723.12460369921$1195332536$gmane$org@elte.hu>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItS7R-0003I6-Ry
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:10:13 -0800
Received: from mx3.mail.elte.hu ([157.181.1.138])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItS7V-0000Og-8Q
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:10:19 -0800
In-Reply-To: <64bb37e0711170953p67d1be49lf4eaa190d662e2b4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


* Torsten Kaiser <just.for.lkml@googlemail.com> wrote:

> Sadly lockdep does not work for me, as it gets turned off early:
> [   39.851594] ---------------------------------
> [   39.855963] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> [   39.861981] swapper/0 [HC0[0]:SC1[1]:HE0:SE0] takes:
> [   39.866963]  (&n->list_lock){-+..}, at: [<ffffffff802935c1>]

hey, that means it found a bug - which is not sad at all :-)

	Ingo

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

