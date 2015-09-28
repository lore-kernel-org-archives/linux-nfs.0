Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50747 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752982AbbI1VtT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 17:49:19 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
References: <20150921172423.9761.92399.stgit@build2.ogc.int> <20150921172428.9761.27838.stgit@build2.ogc.int> <56094F3D.2030002@opengridcomputing.com> <20150928210459.GC3190@fieldses.org>
In-Reply-To: <20150928210459.GC3190@fieldses.org>
Subject: RE: [PATCH 2/3] svcrdma: handle rdma read with a non-zero initial page offset
Date: Mon, 28 Sep 2015 16:49:21 -0500
Message-ID: <009001d0fa37$8871a980$9954fc80$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Monday, September 28, 2015 4:05 PM
> To: Steve Wise
> Cc: trond.myklebust@primarydata.com; linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Subject: Re: [PATCH 2/3] svcrdma: handle rdma read with a non-zero initial page offset
> 
> On Mon, Sep 28, 2015 at 09:31:25AM -0500, Steve Wise wrote:
> > On 9/21/2015 12:24 PM, Steve Wise wrote:
> > >The server rdma_read_chunk_lcl() and rdma_read_chunk_frmr() functions
> > >were not taking into account the initial page_offset when determining
> > >the rdma read length.  This resulted in a read who's starting address
> > >and length exceeded the base/bounds of the frmr.
> > >
> > >Most work loads don't tickle this bug apparently, but one test hit it
> > >every time: building the linux kernel on a 16 core node with 'make -j
> > >16 O=/mnt/0' where /mnt/0 is a ramdisk mounted via NFSRDMA.
> > >
> > >This bug seems to only be tripped with devices having small fastreg page
> > >list depths.  I didn't see it with mlx4, for instance.
> > >
> > >Fixes: 0bf4828983df ('svcrdma: refactor marshalling logic')
> > >Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> > >Tested-by: Chuck Lever <chuck.lever@oracle.com>
> > >---
> > >
> > >
> >
> > Hey Bruce, can this make 4.3-rc?  Also, what do you think about
> > pushing it to stable?
> 
> It looks like a reasonable candidate for stable.  Apologies, somehow I
> missed it when you posted it--would you mind resending?
> 
> --b.

resent this one patch.

What is your process for pushing to stable?

Thanks,

Steve.

