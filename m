Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34455 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbcBEKTY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 05:19:24 -0500
Received: by mail-yw0-f171.google.com with SMTP id h129so47492273ywb.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 02:19:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203155130.13868.17835.stgit@klimt.1015granger.net>
References: <20160203154411.13868.48268.stgit@klimt.1015granger.net> <20160203155130.13868.17835.stgit@klimt.1015granger.net>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Fri, 5 Feb 2016 15:41:47 +0530
Message-ID: <CANjDDBgOqfXSaVCTCXaV-E5Hd2MCBPYvZpWBycjuJF9ueK+B3Q@mail.gmail.com>
Subject: Re: [PATCH v1 01/10] svcrdma: Do not send XDR roundup bytes for a
 write chunk
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks Good to me.

On Wed, Feb 3, 2016 at 9:21 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> When the Linux server writes an odd-length data item into a Write
> chunk, it finishes with XDR pad bytes. If the data item is smaller
> than the Write chunk, the pad bytes are written at the end of the
> data item, but still inside the chunk. That can expose these zero
> bytes to the RPC consumer on the client.
>
> XDR pad bytes are inserted in order to preserve the XDR alignment
> of the next XDR data item in an XDR stream. But Write chunks do not
> appear in the payload XDR stream, and only one data item is allowed
> in each chunk. So XDR padding is unneeded.
>
> Thus the server should not write XDR pad bytes in Write chunks.
>
> I believe this is not an operational problem. Short NFS READs that
> are returned in a Write chunk would be affected by this issue. But
> they happen only when the read request goes past the EOF. Those are
> zero bytes anyway, and there's no file data in the client's buffer
> past EOF.
>
> Otherwise, current NFS clients provide a separate extra segment for
> catching XDR padding. If an odd-size data item fills the chunk,
> then the XDR pad will be written to the extra segment.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index df57f3c..8591314 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -308,7 +308,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>                              struct svc_rqst *rqstp,
>                              struct svc_rdma_req_map *vec)
>  {
> -       u32 xfer_len = rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
> +       u32 xfer_len = rqstp->rq_res.page_len;
>         int write_len;
>         u32 xdr_off;
>         int chunk_off;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
