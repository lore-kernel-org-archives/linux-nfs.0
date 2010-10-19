From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] svcrdma: NFSRDMA Server fixes for 2.6.37
Date: Tue, 19 Oct 2010 10:54:43 -0400
Message-ID: <20101019145443.GA16742@fieldses.org>
References: <20101012203332.22154.37230.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
To: Tom Tucker <tom@ogc.us>
Return-path: <linux-rdma-owner@vger.kernel.org>
In-Reply-To: <20101012203332.22154.37230.stgit-T4OLL4TyM9aNDNWfRnPdfg@public.gmane.org>
Sender: linux-rdma-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 12, 2010 at 03:33:46PM -0500, Tom Tucker wrote:
> Hi Bruce,
> 
> These fixes are ready for 2.6.37. They fix two bugs in the server-side
> NFSRDMA transport.

Both applied and pushed out, thanks.

--b.

> 
> Thanks,
> Tom
> ---
> 
> Tom Tucker (2):
>       svcrdma: Cleanup DMA unmapping in error paths.
>       svcrdma: Change DMA mapping logic to avoid the page_address kernel API
> 
> 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   19 ++++---
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   82 ++++++++++++++++++++++--------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   41 +++++++--------
>  3 files changed, 92 insertions(+), 50 deletions(-)
> 
> -- 
> Signed-off-by: Tom Tucker <tom@ogc.us>
