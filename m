Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56014 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751763AbdDNRyB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Apr 2017 13:54:01 -0400
Date: Fri, 14 Apr 2017 13:54:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 00/14] Server-side NFS/RDMA changes proposed for v4.12
Message-ID: <20170414175400.GB8290@fieldses.org>
References: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170409163820.15073.43257.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 09, 2017 at 01:05:28PM -0400, Chuck Lever wrote:
> This series overhauls the "reply send" side of the RPC-over-RDMA
> transport to use the new rdma_rw API. No significant performance
> changes were noticed with this overhaul. Benefits include:
> 
> <> Better scalability -- fewer ib_post_send calls per RPC Reply
> 
> <> Better code modularity -- less code duplication with other ULPs
> 
> <> Ability for svcrdma to use any registration mode for RDMA Writes
> 
> <> Correct handling of RPCs that have both a Write and a Reply chunk
> 
> <> Correct handling of Write chunk overrun
> 
> This revision makes two scalability improvements that Christoph and
> Sagi requested in previous review comments:
> 
> 1. Use sg_alloc_table_chained to allocate the scatterlist for each
> rdma_rw_ctx. A permanent part of the scatterlist is used for smaller
> I/Os, and a chained part is allocated on demand when performing
> large I/Os. This reduces the amount of memory tied down per client.
> 
> 2. So far each rdma_rw_ctx has been posted individually. Now all
> rdma_rw_ctx's for one chunk are chained together and posted with a
> single ib_post_send. This reduces the number of ib_post_send
> operations for complex RPC Replies.
> 
> 
> Bruce, IMO these are ready for your review.

Thanks, applying for 4.12.--b.

> 
> 
> Available in the "nfsd-rdma-for-4.12" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.12
> 
> 
> Changes since v2:
> - Rebased on v4.11-rc5
> - Use chained sg_tables
> - Always one ib_post_send per chunk
> 
> 
> Changes since v1:
> - Rebased on v4.11-rc4
> - Dropped clean up of svc_rdma_post_recv
> - Postponed addition of code related to recvfrom
> - Made svc_rdma_{get,put}_rw_ctxt behave symmetrically
> - Converted scatterlist to sg_table
> - Moved transport header construction into svc_rdma_sendto.c
> 
> ---
> 
> Chuck Lever (14):
>       svcrdma: Move send_wr to svc_rdma_op_ctxt
>       svcrdma: Add svc_rdma_map_reply_hdr()
>       svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
>       svcrdma: Add helper to save pages under I/O
>       svcrdma: Clean up svc_rdma_get_inv_rkey()
>       svcrdma: Introduce local rdma_rw API helpers
>       svcrdma: Use rdma_rw API in RPC reply path
>       svcrdma: Clean up RDMA_ERROR path
>       svcrdma: Report Write/Reply chunk overruns
>       svcrdma: Clean up RPC-over-RDMA backchannel reply processing
>       svcrdma: Reduce size of sge array in struct svc_rdma_op_ctxt
>       svcrdma: Remove unused RDMA Write completion handler
>       svcrdma: Remove the req_map cache
>       svcrdma: Clean out old XDR encoders
> 
> 
>  include/linux/sunrpc/rpc_rdma.h            |    3 
>  include/linux/sunrpc/svc_rdma.h            |   75 +-
>  net/sunrpc/Kconfig                         |    1 
>  net/sunrpc/xprtrdma/Makefile               |    2 
>  net/sunrpc/xprtrdma/svc_rdma.c             |    8 
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   71 +-
>  net/sunrpc/xprtrdma/svc_rdma_marshal.c     |   89 ---
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   79 ++
>  net/sunrpc/xprtrdma/svc_rdma_rw.c          |  512 +++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  978 ++++++++++++++--------------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c   |  110 ---
>  11 files changed, 1131 insertions(+), 797 deletions(-)
>  create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c
> 
> --
> Chuck Lever
