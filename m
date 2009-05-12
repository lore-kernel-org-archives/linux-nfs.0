From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
 truncated by	the nfs rdma client.
Date: Mon, 11 May 2009 21:35:50 -0400
Message-ID: <1242092150.16618.15.camel@heimdal.trondhjem.org>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
	 <49F31A16.2080806@opengridcomputing.com>
	 <49F4AE86.4090908@opengridcomputing.com>
	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
	 <49F5ED55.1010607@opengridcomputing.com>
	 <1240855510.8818.9.camel@heimdal.trondhjem.org>
	 <1240856613.8818.16.camel@heimdal.trondhjem.org>
	 <49F60845.4010007@opengridcomputing.com>
	 <1240865214.8818.73.camel@heimdal.trondhjem.org>
	 <4A08A5C6.7040003@opengridcomputing.com>
	 <1242082203.1743.11.camel@heimdal.trondhjem.org>
	 <4A08BF1C.2050204@opengridcomputing.com>
	 <1242089066.1743.19.camel@heimdal.trondhjem.org>
	 <4a08cd7b.48c3f10a.6bb1.fffff6d3@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Wise <swise@opengridcomputing.com>,
	tom@opengridcomputing.com, linux-nfs@vger.kernel.org,
	vuhuong@mellanox.com
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:33339 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758066AbZELBfy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2009 21:35:54 -0400
In-Reply-To: <4a08cd7b.48c3f10a.6bb1.fffff6d3-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-05-11 at 21:14 -0400, Tom Talpey wrote:
> At 08:44 PM 5/11/2009, Trond Myklebust wrote:
> >On Mon, 2009-05-11 at 19:13 -0500, Steve Wise wrote:
> >> Trond Myklebust wrote:
> >> > On Mon, 2009-05-11 at 17:25 -0500, Steve Wise wrote:
> >> >   
> >> >> Hey Trond,
> >> >>
> >> >> Will this bug fix make 2.6.30?
> >> >>
> >> >> Thanks,
> >> >>
> >> >> Steve.
> >> >>     
> >> >
> >> > Not in the form it is in now. As I've said earlier, I'm not happy about
> >> > the sunrpc layer having to circumvent ordinary type checking on
> >> > non-sunrpc structures.
> >> >
> >> > Cheers
> >> >     Trond
> >> How is it circumventing?  It's currently incorrectly casting a pointer 
> >> into a u64.  That seems just broken to me.  Also, its really the sunrpc 
> >> rdma transport layer.  It deals specifically with rdma.  It _should_ 
> >> know about rdma interfaces and types.
> >
> >The fact is that I'm simply not interested enough in rdma to tolerate
> >hacks. If it isn't done cleanly, in a manner that I can maintain, then
> >the whole transport layer comes out...
> 
> I know exactly what you want - it's not what the code does now and
> it's not an accessor function to set the hardware's u64 field. What's
> needed is a new function to manage the entire RDMA triplet, and the
> memory registration behind it, in the OFA code side. Put the hardware
> goop below the line, IOW. I'll dust up Steve on this.

This does indeed sound like what I'd looking for.

There is a huge difference between having code that depends on well
defined rdma interfaces, and code that depends on rdma hacks. A piece of
code that requires casts from a non-local opaque type into another
protocol-dependent non-local type will definitely fall in the latter
category. I really don't care what the current code does, but a fix for
that code is something that does it _correctly_; it is not yet another
hack, whether or not it fixes a bug in the short term.

   Trond

