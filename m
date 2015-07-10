Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34029 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334AbbGJKZG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 06:25:06 -0400
Received: by pabvl15 with SMTP id vl15so166205678pab.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 03:25:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150709204159.26247.44592.stgit@manet.1015granger.net>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
	<20150709204159.26247.44592.stgit@manet.1015granger.net>
Date: Fri, 10 Jul 2015 15:55:06 +0530
Message-ID: <CANjDDBh1LS8eDwK2LXkOiQGEMcyfFv8TPsErjTLtDr8Q-pH+LA@mail.gmail.com>
Subject: Re: [PATCH v1 02/12] xprtrdma: Raise maximum payload size to one megabyte
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good

Reviewed-By: Devesh Sharma <devesh.sharma@avagotech.com>

On Fri, Jul 10, 2015 at 2:11 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> The point of larger rsize and wsize is to reduce the per-byte cost
> of memory registration and deregistration. Modern HCAs can typically
> handle a megabyte or more with a single registration operation.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index f49dd8b..abee472 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -165,8 +165,7 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
>   * struct rpcrdma_buffer. N is the max number of outstanding requests.
>   */
>
> -/* temporary static scatter/gather max */
> -#define RPCRDMA_MAX_DATA_SEGS  (64)    /* max scatter/gather */
> +#define RPCRDMA_MAX_DATA_SEGS  ((1 * 1024 * 1024) / PAGE_SIZE)
>  #define RPCRDMA_MAX_SEGS       (RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
>
>  struct rpcrdma_buffer;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
