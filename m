Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:33394 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbcBOO2r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 09:28:47 -0500
Received: by mail-yk0-f175.google.com with SMTP id z13so60624516ykd.0
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2016 06:28:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160212210618.5278.28591.stgit@manet.1015granger.net>
References: <20160212205107.5278.55938.stgit@manet.1015granger.net> <20160212210618.5278.28591.stgit@manet.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Mon, 15 Feb 2016 19:58:07 +0530
Message-ID: <CANjDDBj+Psb=mSTutaLWfHY66NALF7J8vdzGBUbbSWSXL_X-ag@mail.gmail.com>
Subject: Re: [PATCH v1 3/8] rpcrdma: Add RPCRDMA_HDRLEN_ERR
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good.

On Sat, Feb 13, 2016 at 2:36 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Error headers are shorter than either RDMA_MSG or RDMA_NOMSG.
>
> Since HDRLEN_MIN is already used in several other places that would
> be annoying to change, add RPCRDMA_HDRLEN_ERR for the one or two
> spots where the shorter length is needed.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  include/linux/sunrpc/rpc_rdma.h |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
> index f33c5a4..8c6d23c 100644
> --- a/include/linux/sunrpc/rpc_rdma.h
> +++ b/include/linux/sunrpc/rpc_rdma.h
> @@ -102,6 +102,7 @@ struct rpcrdma_msg {
>   * Smallest RPC/RDMA header: rm_xid through rm_type, then rm_nochunks
>   */
>  #define RPCRDMA_HDRLEN_MIN     (sizeof(__be32) * 7)
> +#define RPCRDMA_HDRLEN_ERR     (sizeof(__be32) * 5)
>
>  enum rpcrdma_errcode {
>         ERR_VERS = 1,
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
