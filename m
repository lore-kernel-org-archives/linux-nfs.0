Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:8686 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932080AbbLOThH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Dec 2015 14:37:07 -0500
Subject: Re: [PATCH v3 00/11] NFS/RDMA client patches for 4.5
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
CC: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <56706BE0.7010609@Netapp.com>
Date: Tue, 15 Dec 2015 14:37:04 -0500
MIME-Version: 1.0
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, Chuck!

Everything looks okay to me, so I'll apply these patches and send them to Trond before the holiday.

On 12/14/2015 04:17 PM, Chuck Lever wrote:
> For 4.5, I'd like to address the send queue accounting and
> invalidation/unmap ordering issues Jason brought up a couple of
> months ago.
> 
> In preparation for Doug's final topic branch, Anna, I've rebased
> these on Christoph's ib_device_attr branch, but there were no merge
> conflicts or other changes needed. Could you begin preparing these
> for linux-next and other final testing and review?

No merge conflicts is nice, and we might not need to worry about ordering the pull request.

Thanks,
Anna

> 
> Also available in the "nfs-rdma-for-4.5" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.5
> 
> 
> Changes since v2:
> - Rebased on Christoph's ib_device_attr branch
> 
> 
> Changes since v1:
> 
> - Rebased on v4.4-rc3
> - Receive buffer safety margin patch dropped
> - Backchannel pr_err and pr_info converted to dprintk
> - Backchannel spin locks converted to work queue-safe locks
> - Fixed premature release of backchannel request buffer
> - NFSv4.1 callbacks tested with for-4.5 server
> 
> ---
> 
> Chuck Lever (11):
>       xprtrdma: Fix additional uses of spin_lock_irqsave(rb_lock)
>       xprtrdma: xprt_rdma_free() must not release backchannel reqs
>       xprtrdma: Disable RPC/RDMA backchannel debugging messages
>       xprtrdma: Move struct ib_send_wr off the stack
>       xprtrdma: Introduce ro_unmap_sync method
>       xprtrdma: Add ro_unmap_sync method for FRWR
>       xprtrdma: Add ro_unmap_sync method for FMR
>       xprtrdma: Add ro_unmap_sync method for all-physical registration
>       SUNRPC: Introduce xprt_commit_rqst()
>       xprtrdma: Invalidate in the RPC reply handler
>       xprtrdma: Revert commit e7104a2a9606 ('xprtrdma: Cap req_cqinit').
> 
> 
>  include/linux/sunrpc/xprt.h        |    1 
>  net/sunrpc/xprt.c                  |   14 +++
>  net/sunrpc/xprtrdma/backchannel.c  |   22 ++---
>  net/sunrpc/xprtrdma/fmr_ops.c      |   64 +++++++++++++
>  net/sunrpc/xprtrdma/frwr_ops.c     |  175 +++++++++++++++++++++++++++++++-----
>  net/sunrpc/xprtrdma/physical_ops.c |   13 +++
>  net/sunrpc/xprtrdma/rpc_rdma.c     |   14 +++
>  net/sunrpc/xprtrdma/transport.c    |    3 +
>  net/sunrpc/xprtrdma/verbs.c        |   13 +--
>  net/sunrpc/xprtrdma/xprt_rdma.h    |   12 +-
>  10 files changed, 283 insertions(+), 48 deletions(-)
> 
> --
> Chuck Lever
> 

