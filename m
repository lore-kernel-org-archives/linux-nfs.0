Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57751 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbaJNUmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2014 16:42:47 -0400
Date: Tue, 14 Oct 2014 16:42:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Cc: linux-nfs@vger.kernel.org
Subject: Re: massive memory leak in 3.1[3-5] with nfs4+kerberos
Message-ID: <20141014204245.GB15960@fieldses.org>
References: <20141011033627.GA6850@fisica.ufpr.br>
 <20141013135840.GA32584@fieldses.org>
 <20141013235026.GA10153@fisica.ufpr.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141013235026.GA10153@fisica.ufpr.br>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 13, 2014 at 08:50:27PM -0300, Carlos Carvalho wrote:
> J. Bruce Fields (bfields@fieldses.org) wrote on Mon, Oct 13, 2014 at 10:58:40AM BRT:
> > On Sat, Oct 11, 2014 at 12:36:27AM -0300, Carlos Carvalho wrote:
> > > We're observing a big memory leak in 3.1[3-5]. We've gone until 3.15.8 and back
> > > to 3.14 because of LTS. Today we're running 3.14.21. The problem has existed
> > > for several months but recently has become a show-stopper.
> > 
> > Is there an older version that you know was OK?
> 
> Perhaps something as old as 3.8 but I'm not sure if it still worked. We jumped
> from 3.8 to 3.13 and this one certainly leaks.
...
>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
...
> 3374235 3374199  99%    2.07K 224949       15   7198368K kmalloc-2048

> urquell# ./slabinfo -r kmalloc-2048
...
> kmalloc-2048: Kernel object allocation
> -----------------------------------------------------------------------
...
> 3377159 xprt_alloc+0x1e/0x190 age=0/27663979/71308304 pid=6-32599 cpus=0-31 nodes=0-1
...
> Note the big xprt_alloc. slabinfo is found in the kernel tree at tools/vm.
> Another way to see it:
> 
> urquell# sort -n /sys/kernel/slab/kmalloc-2048/alloc_calls | tail -n 2
>    1519 nfsd4_create_session+0x24a/0x810 age=189221/25894524/71426273 pid=5372-5436 cpus=0-11,13-16,19-20 nodes=0-1
> 3380755 xprt_alloc+0x1e/0x190 age=5/27767270/71441075 pid=6-32599 cpus=0-31 nodes=0-1

Agreed that the xprt_alloc is suspicious, though I don't really
understand these statistics.

Since you have 4.1 clients, maybe this would be explained by a leak in
the backchannel code.

> Yet another puzzling thing for us is that the number of allocs and frees is
> nearly equal:
> 
> urquell# awk '{summ += $1} END {print summ}' /sys/kernel/slab/kmalloc-2048/alloc_calls
> 3385122
> urquell# awk '{summ += $1} END {print summ}' /sys/kernel/slab/kmalloc-2048/free_calls
> 3385273

I can't tell what these numbers actually mean.  (E.g. is it really
tracking every single alloc and free since the kernel booted, or does
this just represent recent behavior?)

> 
> > It would also be interesting to know whether the problem is with nfs4 or
> > krb5.  But I don't know if you have an easy way to test that.  (E.g.
> > temporarily downgrade to nfs3 while keeping krb5 and see if that
> > matters?)
> 
> That'd be quite hard to do...
> 
> > Do you know if any of your clients are using NFSv4.1?
> 
> All of them. Clients are a few general login servers and about a hundred
> terminals. All of them are diskless and mount their root via nfs3 without
> kerberos. The login servers mount the user home dirs with nfs4.1 WITHOUT
> kerberos. The terminals run ubuntu and mount with nfs4.1 AND kerberos. Here is
> their /proc/version:

OK, thanks.  I'm not seeing it yet.

I don't see any relevant-looking fix in recent git history, though there
might have overlooked something, especially in the recent rewrite of the
NFSv4 state code.

It could certainly still be worth testing 3.17 if possible.

--b.
