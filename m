Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52946 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752054AbdHAVha (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Aug 2017 17:37:30 -0400
Date: Tue, 1 Aug 2017 17:37:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 0/4] NFS server clean ups for v4.14
Message-ID: <20170801213730.GH21491@fieldses.org>
References: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 01, 2017 at 11:59:41AM -0400, Chuck Lever wrote:
> Follow-on to Christoph's const-ification of the proc arrays, and a
> clean-up suggested by Dan Carpenter. More to come.

Those look good, thanks!

--b.

> 
> ---
> 
> Chuck Lever (4):
>       sunrpc: Const-ify instances of struct svc_xprt_ops
>       nfsd: Const-ify NFSv4 encoding and decoding ops arrays
>       sunrpc: Const-ify struct sv_serv_ops
>       svcrdma: Clean up svc_rdma_build_read_chunk()
> 
> 
>  fs/lockd/svc.c                           |    2 +-
>  fs/nfs/callback.c                        |   10 +++++-----
>  fs/nfsd/nfs4xdr.c                        |    4 ++--
>  fs/nfsd/nfssvc.c                         |    2 +-
>  include/linux/sunrpc/svc.h               |    6 +++---
>  include/linux/sunrpc/svc_xprt.h          |    4 ++--
>  net/sunrpc/svc.c                         |    6 +++---
>  net/sunrpc/svcsock.c                     |    6 +++---
>  net/sunrpc/xprtrdma/svc_rdma_rw.c        |    8 +++++---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++--
>  10 files changed, 27 insertions(+), 25 deletions(-)
> 
> --
> Chuck Lever
