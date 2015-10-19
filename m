Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:2399 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbbJSS65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2015 14:58:57 -0400
Subject: Re: [PATCH v3 00/16] NFS/RDMA patches for merging into v4.4
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <56253D6D.9050003@Netapp.com>
Date: Mon, 19 Oct 2015 14:58:53 -0400
MIME-Version: 1.0
In-Reply-To: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!  I'll push these out to Trond by the end of the week.

Anna

On 10/16/2015 09:23 AM, Chuck Lever wrote:
> Introduce client-side support for bi-directional RPC/RDMA.
> Bi-directional RPC/RDMA is a pre-requisite for NFSv4.1 on RDMA
> transports.
> 
> Anna, these are ready for you to consider merging.
> 
> Also available in the "nfs-rdma-for-4.4" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.4
> 
> Changes since v2:
> - Rebased on v4.3-rc5
> - Updated Reviewed-by: and Tested-by: tags
> - Some interop testing at NFS Bake-a-thon
> 
> 
> Changes since v1:
> - Dropped "RFC" in Subject: line
> - Rebased on v4.3-rc4 + Steve W's recent fixes
> - NFS Server-side backchannel support postponed
> - "xprtrdma: Replace global lkey" dropped, already merged
> - Addressed Sagi's comments on "Replace send and receive arrays"
> - Addressed Jason's comment regarding ib_req_notify_cq return code
> - Moved RPC/RDMA reply handling into a work queue
> 
> ---
> 
> Chuck Lever (16):
>       xprtrdma: Enable swap-on-NFS/RDMA
>       xprtrdma: Re-arm after missed events
>       xprtrdma: Prevent loss of completion signals
>       xprtrdma: Refactor reply handler error handling
>       xprtrdma: Replace send and receive arrays
>       xprtrdma: Use workqueue to process RPC/RDMA replies
>       xprtrdma: Remove reply tasklet
>       xprtrdma: Saving IRQs no longer needed for rb_lock
>       SUNRPC: Abstract backchannel operations
>       xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers
>       xprtrdma: Pre-allocate Work Requests for backchannel
>       xprtrdma: Add support for sending backward direction RPC replies
>       xprtrdma: Handle incoming backward direction RPC calls
>       svcrdma: Add backward direction service for RPC/RDMA transport
>       SUNRPC: Remove the TCP-only restriction in bc_svc_process()
>       NFS: Enable client side NFSv4.1 backchannel to use other transports
> 
> 
>  fs/nfs/callback.c                        |   33 +-
>  include/linux/sunrpc/bc_xprt.h           |    5 
>  include/linux/sunrpc/svc_rdma.h          |    6 
>  include/linux/sunrpc/xprt.h              |    7 
>  net/sunrpc/backchannel_rqst.c            |   24 +-
>  net/sunrpc/svc.c                         |    5 
>  net/sunrpc/xprtrdma/Makefile             |    1 
>  net/sunrpc/xprtrdma/backchannel.c        |  373 +++++++++++++++++++++++
>  net/sunrpc/xprtrdma/rpc_rdma.c           |  148 ++++++---
>  net/sunrpc/xprtrdma/svc_rdma.c           |    6 
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   58 ++++
>  net/sunrpc/xprtrdma/transport.c          |   18 +
>  net/sunrpc/xprtrdma/verbs.c              |  479 +++++++++++++++---------------
>  net/sunrpc/xprtrdma/xprt_rdma.h          |   53 +++
>  net/sunrpc/xprtsock.c                    |   16 +
>  15 files changed, 916 insertions(+), 316 deletions(-)
>  create mode 100644 net/sunrpc/xprtrdma/backchannel.c
> 
> --
> Chuck Lever
> 

