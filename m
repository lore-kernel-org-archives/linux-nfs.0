Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:12540 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754756AbbAPVCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2015 16:02:52 -0500
Message-ID: <54B97C73.9000602@Netapp.com>
Date: Fri, 16 Jan 2015 16:02:43 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 00/20] NFS/RDMA client for 3.20
References: <20150113161440.14086.24801.stgit@manet.1015granger.net>
In-Reply-To: <20150113161440.14086.24801.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

You already answered my one question for this patch series, and I don't have any other comments.  Are these ready for me to take now?  Are you planning a v3?

Thanks,
Anna

On 01/13/2015 11:24 AM, Chuck Lever wrote:
> The following series of patches for the Linux NFS client breaks up
> the per-transport buffer pool data structures to help them scale
> better with the size of SEND/RECV buffers (the inline threshold),
> the maximum NFS r/wsize, and the number of RDMA credits (concurrent
> RPC requests).
> 
> The primary change is that the header send buffers have been split
> from struct rpcrdma_req. Specific benefits are outlined in the patch
> descriptions.
> 
> More pre-requisites are required. Changes to raise the maximum
> r/wsize and other limits are left for a future merge window.
> 
> See the topic branch "nfs-rdma-for-3.20" at:
> 
>   git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Changes since v1:
>  - Rebased on v3.19-rc4
>  - One short description fixed
>  - linux-rdma included this time (sorry for the noise)
> 
> ---
> 
> Chuck Lever (20):
>       xprtrdma: human-readable completion status
>       xprtrdma: Modernize htonl and ntohl
>       xprtrdma: Display XIDs in host byte order
>       xprtrdma: Clean up hdrlen
>       xprtrdma: Rename "xprt" and "rdma_connect" fields in struct rpcrdma_xprt
>       xprtrdma: Remove rpcrdma_ep::rep_ia
>       xprtrdma: Remove rl_mr field, and the mr_chunk union
>       xprtrdma: Move credit update to RPC reply handler
>       xprtrdma: Remove rpcrdma_ep::rep_func and ::rep_xprt
>       xprtrdma: Free the pd if ib_query_qp() fails
>       xprtrdma: Take struct ib_device_attr off the stack
>       xprtrdma: Take struct ib_qp_attr and ib_qp_init_attr off the stack
>       xprtrdma: Simplify synopsis of rpcrdma_buffer_create()
>       xprtrdma: Refactor rpcrdma_buffer_create() and rpcrdma_buffer_destroy()
>       xprtrdma: Add struct rpcrdma_regbuf and helpers
>       xprtrdma: Allocate RPC send buffer separately from struct rpcrdma_req
>       xprtrdma: Allocate RPC/RDMA send buffer separately from struct rpcrdma_req
>       xprtrdma: Allocate RPC/RDMA receive buffer separately from struct rpcrdma_rep
>       xprtrdma: Allocate zero pad separately from rpcrdma_buffer
>       xprtrdma: Clean up after adding regbuf management
> 
> 
>  include/linux/sunrpc/rpc_rdma.h |   14 +
>  include/linux/sunrpc/svc_rdma.h |    2 
>  net/sunrpc/xprtrdma/rpc_rdma.c  |  108 ++++++----
>  net/sunrpc/xprtrdma/transport.c |  179 +++++++----------
>  net/sunrpc/xprtrdma/verbs.c     |  411 ++++++++++++++++++++++++---------------
>  net/sunrpc/xprtrdma/xprt_rdma.h |  111 +++++++----
>  6 files changed, 478 insertions(+), 347 deletions(-)
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

