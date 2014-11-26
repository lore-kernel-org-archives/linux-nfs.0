Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11818 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041AbaKZQZf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 11:25:35 -0500
Message-ID: <5475FEFD.8070302@Netapp.com>
Date: Wed, 26 Nov 2014 11:25:33 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 00/10] NFS/RDMA patches for 3.19
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

I've applied these to two different branches - one for the RDMA changes and another for the generic client side changes.  Both have been sent to Trond to be merged with 3.19.

Anna

On 11/08/2014 08:14 PM, Chuck Lever wrote:
> Hi-
> 
> This is a set of fixes and clean-ups for xprtrdma. Also available
> in the nfs-rdma-for-3.19 topic branch at
> 
>   git://linux-nfs.org/projects/cel/cel-2.6.git
> 
> I've run cthon04, iozone, dbench, multi-process kernel build and
> xfstests with NFSv3 and NFSv4.0 against a Linux and a Solaris
> NFS server via RDMA, with all three memory registration modes.
> 
> Changes since v1:
> 
> - Merged up to v3.18-rc3
> - Dropped patches that enable NFSv4.1 support for now
> - CQ completion vector spinning dropped for now
> - Addressed Anna's review comments
> - Several bug fixes
> 
> ---
> 
> Chuck Lever (10):
>       xprtrdma: Return an errno from rpcrdma_register_external()
>       xprtrdma: Cap req_cqinit
>       xprtrdma: unmap all FMRs during transport disconnect
>       xprtrdma: Refactor tasklet scheduling
>       xprtrdma: Re-write rpcrdma_flush_cqs()
>       xprtrdma: Enable pad optimization
>       xprtrdma: Display async errors
>       SUNRPC: serialize iostats updates
>       NFS: SETCLIENTID XDR buffer sizes are incorrect
>       NFS: Clean up nfs4_init_callback()
> 
> 
>  fs/nfs/nfs4client.c             |   31 +++++------
>  fs/nfs/nfs4xdr.c                |   10 ++-
>  include/linux/sunrpc/metrics.h  |    3 +
>  net/sunrpc/stats.c              |   21 +++++--
>  net/sunrpc/xprtrdma/transport.c |    4 +
>  net/sunrpc/xprtrdma/verbs.c     |  114 ++++++++++++++++++++++++++++++++++-----
>  net/sunrpc/xprtrdma/xprt_rdma.h |    6 ++
>  7 files changed, 146 insertions(+), 43 deletions(-)
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

