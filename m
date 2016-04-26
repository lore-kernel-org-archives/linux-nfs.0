Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linode.aoot.com ([69.164.194.13]:53520 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbcDZOek (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Apr 2016 10:34:40 -0400
Subject: Re: [PATCH v2 00/18] NFS/RDMA client patches for v4.7
To: Chuck Lever <chuck.lever@oracle.com>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        linux-nfs@vger.kernel.org
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <571F778B.5000306@opengridcomputing.com>
Date: Tue, 26 Apr 2016 09:13:31 -0500
MIME-Version: 1.0
In-Reply-To: <20160425185956.3566.64142.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck, I'm testing this series on cxgb4.    I'm running 'iozone -a 
-+d -I' on a share and watching the server stats.  Are the starve 
numbers expected?

Every 5.0s: for s in  /proc/sys/sunrpc/svc_rdma/rdma_* ; do echo -n 
"$(basename $s): "; cat $s; done                              Tue Apr 26 
07:10:17 2016

rdma_stat_read: 379872
rdma_stat_recv: 498144
rdma_stat_rq_poll: 0
rdma_stat_rq_prod: 0
rdma_stat_rq_starve: 675564
rdma_stat_sq_poll: 0
rdma_stat_sq_prod: 0
rdma_stat_sq_starve: 1748000
rdma_stat_write: 2805420


On 4/25/2016 2:20 PM, Chuck Lever wrote:
> Second version of NFS/RDMA client patches proposed for merge into
> v4.7. Thanks in advance for any review comments!
>
> Attempt to fence memory regions after a signal interrupts a
> synchronous RPC. This prevents a server from writing a reply into a
> client's memory after the memory has been released due to a signal.
>
> Support providing a Read list and Reply chunk together in one RPC
> call. This is a pre-requisite for using krb5i or krb5p on RPC/RDMA.
>
> In addition, the following changes and fixes are included:
>
> - Use new ib_drain_qp() API
> - Advertise max size of NFSv4.1 callbacks on RPC/RDMA
> - Prevent overflowing the server's receive buffers
> - Send small NFS WRITEs inline rather than using a Read chunk
> - Detect connection loss sooner
>
>
> Available in the "nfs-rdma-for-4.7" topic branch of this git repo:
>
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>
> Or for browsing:
>
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.7
>
>
> Changes since v1:
> - Rebased on v4.6-rc5
> - Updated patch description for "Avoid using Write list for ..."
>
> ---
>
> Chuck Lever (18):
>        sunrpc: Advertise maximum backchannel payload size
>        xprtrdma: Bound the inline threshold values
>        xprtrdma: Limit number of RDMA segments in RPC-over-RDMA headers
>        xprtrdma: Prevent inline overflow
>        xprtrdma: Avoid using Write list for small NFS READ requests
>        xprtrdma: Update comments in rpcrdma_marshal_req()
>        xprtrdma: Allow Read list and Reply chunk simultaneously
>        xprtrdma: Remove rpcrdma_create_chunks()
>        xprtrdma: Use core ib_drain_qp() API
>        xprtrdma: Rename rpcrdma_frwr::sg and sg_nents
>        xprtrdma: Save I/O direction in struct rpcrdma_frwr
>        xprtrdma: Reset MRs in frwr_op_unmap_sync()
>        xprtrdma: Refactor the FRWR recovery worker
>        xprtrdma: Move fr_xprt and fr_worker to struct rpcrdma_mw
>        xprtrdma: Refactor __fmr_dma_unmap()
>        xprtrdma: Add ro_unmap_safe memreg method
>        xprtrdma: Remove ro_unmap() from all registration modes
>        xprtrdma: Faster server reboot recovery
>
>
>   fs/nfs/nfs4proc.c                  |   10 -
>   include/linux/sunrpc/clnt.h        |    1
>   include/linux/sunrpc/xprt.h        |    1
>   include/linux/sunrpc/xprtrdma.h    |    4
>   net/sunrpc/clnt.c                  |   17 +
>   net/sunrpc/xprtrdma/backchannel.c  |   16 +
>   net/sunrpc/xprtrdma/fmr_ops.c      |  134 +++++++--
>   net/sunrpc/xprtrdma/frwr_ops.c     |  214 ++++++++-------
>   net/sunrpc/xprtrdma/physical_ops.c |   39 ++-
>   net/sunrpc/xprtrdma/rpc_rdma.c     |  517 ++++++++++++++++++++++--------------
>   net/sunrpc/xprtrdma/transport.c    |   16 +
>   net/sunrpc/xprtrdma/verbs.c        |   91 ++----
>   net/sunrpc/xprtrdma/xprt_rdma.h    |   42 ++-
>   net/sunrpc/xprtsock.c              |    6
>   14 files changed, 674 insertions(+), 434 deletions(-)
>
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

