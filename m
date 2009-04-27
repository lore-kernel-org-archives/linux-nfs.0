From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
 truncated by	the nfs rdma client.
Date: Mon, 27 Apr 2009 14:05:10 -0400
Message-ID: <1240855510.8818.9.camel@heimdal.trondhjem.org>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
	 <49F31A16.2080806@opengridcomputing.com>
	 <49F4AE86.4090908@opengridcomputing.com>
	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
	 <49F5ED55.1010607@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Talpey <tmtalpey@gmail.com>, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34508 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757068AbZD0SFk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2009 14:05:40 -0400
In-Reply-To: <49F5ED55.1010607@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-04-27 at 12:37 -0500, Steve Wise wrote:
> Tom Talpey wrote:
> > At 02:57 PM 4/26/2009, Steve Wise wrote:
> >   
> >> Hey Trond,
> >>
> >> Turns out the server side is fine.  So this patch is good to go.
> >>     
> >
> > I'll ACK the patch, but I do wonder if the code will compile cleanly on all
> > platforms. The iova_start is a u64, whereas the mr_dma is a dma_addr_t,
> > which is variable sized, depending on platform. Would a (u64) cast be a
> > safer patch, warning-wise?
> >
> >   
> 
> Well, if dma_addr_t is smaller, I don't think you'll get a warning, will 
> you?  And if its larger than 64b, then you _want_ the warning, because 
> nothing will work. :)
> 
> Its up to you and/or Trond.

It looks looks as though the bug is really that the IB code is using a
u64 to store dma handles. As an external user of the IB api, we really
shouldn't have to perform this sort of transformation. If it is
absolutely necessary, then it should be done by means of specialised
accessor functions to initialise/read iova_start value when given a
dma_addr_t.

I'd therefore prefer the no-cast version (with eventual compiler
warnings), in the hope that eventually the IB folks will fix their
interface.

Cheers
   Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
