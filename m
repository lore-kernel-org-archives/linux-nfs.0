Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47652 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751524AbdBFWjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Feb 2017 17:39:19 -0500
Date: Mon, 6 Feb 2017 17:39:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/7] Server-side NFS/RDMA changes for v4.11
Message-ID: <20170206223918.GE19704@fieldses.org>
References: <20170131184623.14185.35480.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170131184623.14185.35480.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 31, 2017 at 01:52:42PM -0500, Chuck Lever wrote:
> These are largely clean-ups, except for the last patch. Switching
> completion polling from soft IRQ to a worker thread has a few
> benefits:
> 
> - svcrdma's completion handlers invoke svc_xprt_put(). We discovered
> recently svc_xprt_put() is supposed to be called only in a process
> context. This will become more important when NFS/RDMA supports
> multi-path.
> 
> - eventually we'd like to allocate pages for RDMA Read in the
> completion handler, and not defer RDMA Read to svc_rdma_recvfrom.
> Using GFP_KERNEL can sleep, which is not allowed in soft IRQ
> context.
> 
> - several places where BH's are disabled can be converted to simple
> spin_locks.
> 
> Bruce, would you consider these for v4.11?

Sure, looks fine to me.

Looks like you had a minor edit or two from Christoph's review, so I'm
assuming you'll resend.

--b.

> 
> 
> Available in the "nfsd-rdma-for-4.11" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.11
> 
> 
> Changes since v1:
> - Rebased on v4.10-rc6
> 
> ---
> 
> Chuck Lever (7):
>       svcrdma: Another sendto chunk list parsing update
>       svcrdma: Clean up RPC-over-RDMA Reply header encoder
>       svcrdma: Clean up RPC-over-RDMA Call header decoder
>       svcrdma: Clean up backchannel send header encoding
>       svcrdma: Remove unused sc_dto_q field
>       svcrdma: Combine list fields in struct svc_rdma_op_ctxt
>       svcrdma: Poll CQs in "workqueue" mode
> 
> 
>  include/linux/sunrpc/rpc_rdma.h            |    9 +
>  include/linux/sunrpc/svc_rdma.h            |   17 +
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   17 +
>  net/sunrpc/xprtrdma/svc_rdma_marshal.c     |  320 +++++++++++-----------------
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   20 +-
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   13 -
>  net/sunrpc/xprtrdma/svc_rdma_transport.c   |   61 +++--
>  7 files changed, 199 insertions(+), 258 deletions(-)
> 
> --
> Chuck Lever
