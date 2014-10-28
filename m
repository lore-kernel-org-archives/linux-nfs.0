Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45513 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbaJ1OYv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 10:24:51 -0400
Date: Tue, 28 Oct 2014 10:24:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Cc: linux-nfs@vger.kernel.org
Subject: Re: massive memory leak in 3.1[3-5] with nfs4+kerberos
Message-ID: <20141028142449.GC32743@fieldses.org>
References: <20141011033627.GA6850@fisica.ufpr.br>
 <20141013135840.GA32584@fieldses.org>
 <20141013235026.GA10153@fisica.ufpr.br>
 <20141014204245.GB15960@fieldses.org>
 <20141028141428.GA17735@fisica.ufpr.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141028141428.GA17735@fisica.ufpr.br>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 28, 2014 at 12:14:28PM -0200, Carlos Carvalho wrote:
> J. Bruce Fields (bfields@fieldses.org) wrote on Tue, Oct 14, 2014 at 05:42:45PM BRT:
> > On Mon, Oct 13, 2014 at 08:50:27PM -0300, Carlos Carvalho wrote:
> > > J. Bruce Fields (bfields@fieldses.org) wrote on Mon, Oct 13, 2014 at 10:58:40AM BRT:
> > > Note the big xprt_alloc. slabinfo is found in the kernel tree at tools/vm.
> > > Another way to see it:
> > > 
> > > urquell# sort -n /sys/kernel/slab/kmalloc-2048/alloc_calls | tail -n 2
> > >    1519 nfsd4_create_session+0x24a/0x810 age=189221/25894524/71426273 pid=5372-5436 cpus=0-11,13-16,19-20 nodes=0-1
> > > 3380755 xprt_alloc+0x1e/0x190 age=5/27767270/71441075 pid=6-32599 cpus=0-31 nodes=0-1
> > 
> > Agreed that the xprt_alloc is suspicious, though I don't really
> > understand these statistics.
> > 
> > Since you have 4.1 clients, maybe this would be explained by a leak in
> > the backchannel code.
> 
> We've set clients to use 4.0 and it only made the problem worse; the growth in
> unreclaimable memory was faster.
> 
> > It could certainly still be worth testing 3.17 if possible.
> 
> We tested it and it SEEMS the problem doesn't appear in 3.17.1; the SUnreclaim
> value oscillates up and down as usual, instead of increasing monotonically.
> However it didn't last long enough for us to get conclusive numbers because
> after about 5-6h the machine fills the screen with "NMI watchdog CPU #... is
> locked for more than 22s".

Are the backtraces with those messages?

--b.

> It spits these messages for many cores at once, and
> becomes unresponsive; we have to reboot it from the console with alt+sysreq.
> 
> Do these 2 new pieces of info give a clue?
