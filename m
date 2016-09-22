Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38036 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757383AbcIVUi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 16:38:58 -0400
Date: Thu, 22 Sep 2016 16:38:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/6] server-side NFS/RDMA patches proposed for v4.9
Message-ID: <20160922203857.GB313@fieldses.org>
References: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 13, 2016 at 10:52:33AM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> These are ready for you to consider for your "for v4.9" branch. They
> include:

Sorry for the delay--applying for for 4.9.--b.

> 
> - Fix a couple of reference counting issues
> - Introduce simple RDMA-CM private message exchange
> - Support Remote Invalidation
> 
> Available in the "nfsd-rdma-for-4.9" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.9
> 
> 
> Changes since v2:
> - Rebased on v4.8-rc6
> - "SUNRPC: Silence WARN_ON when NFSv4.1 over RDMA is in use" has been merged
> - Revert 64c59a3726f2 (add a "Cc: stable" if you think that's appropriate)
> 
> 
> Changes since v1:
> - Rebased on v4.8-rc3
> - Added Reviewed-by tags
> - Fixed additional bugs found in v4.8
> 
> 
> ---
> 
> Chuck Lever (6):
>       svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary allocation")
>       svcrdma: Tail iovec leaves an orphaned DMA mapping
>       svcrdma: Skip put_page() when send_reply() fails
>       rpcrdma: RDMA/CM private message data structure
>       svcrdma: Server-side support for rpcrdma_connect_private
>       svcrdma: support Remote Invalidation
> 
> 
>  include/linux/sunrpc/rpc_rdma.h            |   35 ++++++++++++
>  include/linux/sunrpc/svc_rdma.h            |   10 +++
>  net/sunrpc/auth_gss/svcauth_gss.c          |    5 +-
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    2 -
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |    2 -
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   82 ++++++++++++++++++++--------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c   |   60 +++++++++++++++++---
>  7 files changed, 159 insertions(+), 37 deletions(-)
> 
> --
> Chuck Lever
