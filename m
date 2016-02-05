Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:34490 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbcBEK7r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 05:59:47 -0500
Received: by mail-yw0-f170.google.com with SMTP id h129so48151439ywb.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 02:59:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203154411.13868.48268.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 16:29:07 +0530
Message-ID: <CANjDDBhaEfkssb+HzGovpJUn+9mVFm=H4mcLyYR6Lf7=cOC7LA@mail.gmail.com>
Subject: Re: [PATCH v1 00/10] NFS/RDMA server patches for v4.6
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While there are some bug fixes for ocrdma are on the way, I tested
this series with a modified ocrdma driver.
following tests passed:
iozone, cable-pull short duration, cable pull long duration (more than 5 mins).

Series Reviewed-By: Devesh Sharma <devesh.sharma@broadcom.com>
Series Tested-By: Devesh Sharma <devesh.sharma@broadcom.com>




On Wed, Feb 3, 2016 at 9:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> For review.
>
> - Fix XDR round-up in write chunks (take 3)
> - Pre-allocate FRWRs when accepting a connection
> - Add proper handling of bad header XDR
> - Convert the server to use the new core CQ API added in v4.5.
>
> Also available in the "nfsd-rdma-for-4.6" topic branch of this git
> repo:
>
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>
> Or for browsing:
>
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.6
>
> ---
>
> Chuck Lever (10):
>       svcrdma: Do not send XDR roundup bytes for a write chunk
>       svcrdma: Make svc_rdma_get_frmr() not sleep
>       svcrdma: svc_rdma_post_recv() should close connection on error
>       rpcrdma: Add missing XDR union fields for RDMA errors
>       svcrdma: Make RDMA_ERROR messages work
>       svcrdma: Use correct XID in error replies
>       svcrdma: Hook up the logic to return ERR_CHUNK
>       svcrdma: Remove close_out exit path
>       svcrdma: Use new CQ API for RPC-over-RDMA server receive CQs
>       svcrdma: Use new CQ API for RPC-over-RDMA server send CQs
>
>
>  include/linux/sunrpc/rpc_rdma.h            |   13 +
>  include/linux/sunrpc/svc_rdma.h            |   18 +
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   15 -
>  net/sunrpc/xprtrdma/svc_rdma_marshal.c     |   62 ++--
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   61 +---
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   79 ++++-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c   |  488 +++++++++++-----------------
>  7 files changed, 346 insertions(+), 390 deletions(-)
>
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
