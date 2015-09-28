Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50052 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933470AbbI1Ou5 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2015 10:50:57 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Anna Schumaker'" <Anna.Schumaker@netapp.com>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>
References: <20150921172423.9761.92399.stgit@build2.ogc.int> <56094F16.3040608@opengridcomputing.com> <56095286.6030201@Netapp.com>
In-Reply-To: <56095286.6030201@Netapp.com>
Subject: RE: [PATCH 1/3] xprtrdma: disconnect and flush cqs before freeing buffers
Date: Mon, 28 Sep 2015 09:50:58 -0500
Message-ID: <005401d0f9fd$16399920$42accb60$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Anna Schumaker [mailto:Anna.Schumaker@netapp.com]
> Sent: Monday, September 28, 2015 9:45 AM
> To: Steve Wise; trond.myklebust@primarydata.com; bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Subject: Re: [PATCH 1/3] xprtrdma: disconnect and flush cqs before freeing buffers
> 
> Hi Steve,
> 
> On 09/28/2015 10:30 AM, Steve Wise wrote:
> > On 9/21/2015 12:24 PM, Steve Wise wrote:
> >> Otherwise a FRMR completion can cause a touch-after-free crash.
> >>
> >> In xprt_rdma_destroy(), call rpcrdma_buffer_destroy() only after calling
> >> rpcrdma_ep_destroy().
> >>
> >> In rpcrdma_ep_destroy(), disconnect the cm_id first which should flush the
> >> qp, then drain the cqs, then destroy the qp, and finally destroy the cqs.
> >>
> >> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> >> Tested-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >
> > Hey Trond,  I'm hoping this can make 4.3-rc (and stable if you agree).
> 
> This patch looks fine to me.  I'll pass it on to Trond!
> 
> I'll save patch 3/3 for the Linux 4.4 merge.
> 
> Thanks,
> Anna
> 

Thanks.  Going forward I'll make sure you are CC'd for client patches too!  I wasn't sure if you are formally taking all xprtrdma patches and sending them to Trond...

Steve.


