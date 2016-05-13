Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46834 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211AbcEMUM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:12:57 -0400
Date: Fri, 13 May 2016 16:12:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/9] NFS/RDMA server patches proposed for v4.7
Message-ID: <20160513201256.GD5658@fieldses.org>
References: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160504144730.6602.89073.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 04, 2016 at 10:52:38AM -0400, Chuck Lever wrote:
> Shirley's server-side IPv6 patch, and a number of minor fixes and
> clean-ups found during code review.

Thanks, applying for 4.7.--b.

> 
> Available in the "nfsd-rdma-for-4.7" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.7
> 
> 
> Changes since v1:
> - Rebased on v4.6-rc6
> - Patch converting CQs to workqueue has been dropped for now
> - A number of clean-ups
> 
> ---
> 
> Chuck Lever (8):
>       svcrdma: Do not add XDR padding to xdr_buf page vector
>       svcrdma: svc_rdma_put_context() is invoked twice in Send error path
>       svcrdma: Remove superfluous line from rdma_read_chunks()
>       svcrdma: Post Receives only for forward channel requests
>       svcrdma: Drain QP before freeing svcrdma_xprt
>       svcrdma: Eliminate code duplication in svc_rdma_recvfrom()
>       svcrdma: Generalize svc_rdma_xdr_decode_req()
>       svcrdma: Simplify the check for backward direction replies
> 
> Shirley Ma (1):
>       svcrdma: Support IPv6 with NFS/RDMA
> 
> 
>  fs/nfsd/nfs3xdr.c                        |    2 -
>  include/linux/sunrpc/svc_rdma.h          |    2 -
>  net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   32 ++++++++++-----
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   65 ++++++++----------------------
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   28 ++++++-------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   17 +++++++-
>  6 files changed, 70 insertions(+), 76 deletions(-)
> 
> --
> Chuck Lever
