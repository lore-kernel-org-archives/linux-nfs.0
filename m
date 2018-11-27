Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16ED9C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 21:23:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF6AC208E4
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 21:23:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF6AC208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=talpey.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726713AbeK1IWh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 03:22:37 -0500
Received: from p3plsmtpa08-08.prod.phx3.secureserver.net ([173.201.193.109]:45806
        "EHLO p3plsmtpa08-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726273AbeK1IWh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 03:22:37 -0500
X-Greylist: delayed 438 seconds by postgrey-1.27 at vger.kernel.org; Wed, 28 Nov 2018 03:22:36 EST
Received: from [192.168.0.55] ([24.218.182.144])
        by :SMTPAUTH: with ESMTPSA
        id RkiDgimjvbCsiRkiDggWUk; Tue, 27 Nov 2018 14:16:06 -0700
Subject: Re: [PATCH v1] svcrdma: Optimize the logic that selects the R_key to
 invalidate
To:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20181127161016.6997.69002.stgit@klimt.1015granger.net>
From:   Tom Talpey <tom@talpey.com>
Message-ID: <14c5a1e8-115b-a58b-7c65-4e207caf3d33@talpey.com>
Date:   Tue, 27 Nov 2018 16:16:05 -0500
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20181127161016.6997.69002.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfKLDY4Sn+ExvTFJtLmc1ZFZ1Z0TgU23lVWJEzrYj5UcCI2qEqHlDU4M1KAGx7jyqVt1lcjtNZX+UtIjxL1Mi+Vj4gtr9oJuSA5x/WUrqMyGJkxVN8Ejo
 +4xl5sDUyHiGzNohbYHJuwvrx8XK5t+KxnRYKB51USFHlmCqVZRrANUI2hYtcCtbUlRKb9cA9zklX7hUCQIC+VVvQmbXTPtE9n/CmAwdxMno+JmPgrwEp67N
 w7alh3gCGNu9qJx8/rnHpA==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11/27/2018 11:11 AM, Chuck Lever wrote:
> o Select the R_key to invalidate while the CPU cache still contains
>    the received RPC Call transport header, rather than waiting until
>    we're about to send the RPC Reply.
> 
> o Choose Send With Invalidate if there is exactly one distinct R_key
>    in the received transport header. If there's more than one, the
>    client will have to perform local invalidation after it has
>    already waited for remote invalidation.

What's the reason for remote-invalidating only if exactly one
region is targeted? It seems valuable to save the client the work,
no matter how many regions are used.

Put another way, why the change?

Tom.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Hi-
> 
> Please consider this NFS server-side patch for v4.21.
> 
> 
>   include/linux/sunrpc/svc_rdma.h         |    1
>   net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   63 +++++++++++++++++++++++++++++++
>   net/sunrpc/xprtrdma/svc_rdma_sendto.c   |   53 ++++++--------------------
>   3 files changed, 77 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index e6e2691..7e22681 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -135,6 +135,7 @@ struct svc_rdma_recv_ctxt {
>   	u32			rc_byte_len;
>   	unsigned int		rc_page_count;
>   	unsigned int		rc_hdr_count;
> +	u32			rc_inv_rkey;
>   	struct page		*rc_pages[RPCSVC_MAXPAGES];
>   };
>   
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index b24d5b8..828b149 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -485,6 +485,68 @@ static __be32 *xdr_check_reply_chunk(__be32 *p, const __be32 *end)
>   	return p;
>   }
>   
> +/* RPC-over-RDMA Version One private extension: Remote Invalidation.
> + * Responder's choice: requester signals it can handle Send With
> + * Invalidate, and responder chooses one R_key to invalidate.
> + *
> + * If there is exactly one distinct R_key in the received transport
> + * header, set rc_inv_rkey to that R_key. Otherwise, set it to zero.
> + *
> + * Perform this operation while the received transport header is
> + * still in the CPU cache.
> + */
> +static void svc_rdma_get_inv_rkey(struct svcxprt_rdma *rdma,
> +				  struct svc_rdma_recv_ctxt *ctxt)
> +{
> +	__be32 inv_rkey, *p;
> +	u32 i, segcount;
> +
> +	ctxt->rc_inv_rkey = 0;
> +
> +	if (!rdma->sc_snd_w_inv)
> +		return;
> +
> +	inv_rkey = xdr_zero;
> +	p = ctxt->rc_recv_buf;
> +	p += rpcrdma_fixed_maxsz;
> +
> +	/* Read list */
> +	while (*p++ != xdr_zero) {
> +		p++;	/* position */
> +		if (inv_rkey == xdr_zero)
> +			inv_rkey = *p;
> +		else if (inv_rkey != *p)
> +			return;
> +		p += 4;
> +	}
> +
> +	/* Write list */
> +	while (*p++ != xdr_zero) {
> +		segcount = be32_to_cpup(p++);
> +		for (i = 0; i < segcount; i++) {
> +			if (inv_rkey == xdr_zero)
> +				inv_rkey = *p;
> +			else if (inv_rkey != *p)
> +				return;
> +			p += 4;
> +		}
> +	}
> +
> +	/* Reply chunk */
> +	if (*p++ != xdr_zero) {
> +		segcount = be32_to_cpup(p++);
> +		for (i = 0; i < segcount; i++) {
> +			if (inv_rkey == xdr_zero)
> +				inv_rkey = *p;
> +			else if (inv_rkey != *p)
> +				return;
> +			p += 4;
> +		}
> +	}
> +
> +	ctxt->rc_inv_rkey = be32_to_cpu(inv_rkey);
> +}
> +
>   /* On entry, xdr->head[0].iov_base points to first byte in the
>    * RPC-over-RDMA header.
>    *
> @@ -746,6 +808,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
>   		svc_rdma_recv_ctxt_put(rdma_xprt, ctxt);
>   		return ret;
>   	}
> +	svc_rdma_get_inv_rkey(rdma_xprt, ctxt);
>   
>   	p += rpcrdma_fixed_maxsz;
>   	if (*p != xdr_zero)
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 8602a5f..d48bc6d 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -484,32 +484,6 @@ static void svc_rdma_get_write_arrays(__be32 *rdma_argp,
>   		*reply = NULL;
>   }
>   
> -/* RPC-over-RDMA Version One private extension: Remote Invalidation.
> - * Responder's choice: requester signals it can handle Send With
> - * Invalidate, and responder chooses one rkey to invalidate.
> - *
> - * Find a candidate rkey to invalidate when sending a reply.  Picks the
> - * first R_key it finds in the chunk lists.
> - *
> - * Returns zero if RPC's chunk lists are empty.
> - */
> -static u32 svc_rdma_get_inv_rkey(__be32 *rdma_argp,
> -				 __be32 *wr_lst, __be32 *rp_ch)
> -{
> -	__be32 *p;
> -
> -	p = rdma_argp + rpcrdma_fixed_maxsz;
> -	if (*p != xdr_zero)
> -		p += 2;
> -	else if (wr_lst && be32_to_cpup(wr_lst + 1))
> -		p = wr_lst + 2;
> -	else if (rp_ch && be32_to_cpup(rp_ch + 1))
> -		p = rp_ch + 2;
> -	else
> -		return 0;
> -	return be32_to_cpup(p);
> -}
> -
>   static int svc_rdma_dma_map_page(struct svcxprt_rdma *rdma,
>   				 struct svc_rdma_send_ctxt *ctxt,
>   				 struct page *page,
> @@ -672,7 +646,7 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
>    *
>    * RDMA Send is the last step of transmitting an RPC reply. Pages
>    * involved in the earlier RDMA Writes are here transferred out
> - * of the rqstp and into the ctxt's page array. These pages are
> + * of the rqstp and into the sctxt's page array. These pages are
>    * DMA unmapped by each Write completion, but the subsequent Send
>    * completion finally releases these pages.
>    *
> @@ -680,32 +654,31 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
>    * - The Reply's transport header will never be larger than a page.
>    */
>   static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
> -				   struct svc_rdma_send_ctxt *ctxt,
> -				   __be32 *rdma_argp,
> +				   struct svc_rdma_send_ctxt *sctxt,
> +				   struct svc_rdma_recv_ctxt *rctxt,
>   				   struct svc_rqst *rqstp,
>   				   __be32 *wr_lst, __be32 *rp_ch)
>   {
>   	int ret;
>   
>   	if (!rp_ch) {
> -		ret = svc_rdma_map_reply_msg(rdma, ctxt,
> +		ret = svc_rdma_map_reply_msg(rdma, sctxt,
>   					     &rqstp->rq_res, wr_lst);
>   		if (ret < 0)
>   			return ret;
>   	}
>   
> -	svc_rdma_save_io_pages(rqstp, ctxt);
> +	svc_rdma_save_io_pages(rqstp, sctxt);
>   
> -	ctxt->sc_send_wr.opcode = IB_WR_SEND;
> -	if (rdma->sc_snd_w_inv) {
> -		ctxt->sc_send_wr.ex.invalidate_rkey =
> -			svc_rdma_get_inv_rkey(rdma_argp, wr_lst, rp_ch);
> -		if (ctxt->sc_send_wr.ex.invalidate_rkey)
> -			ctxt->sc_send_wr.opcode = IB_WR_SEND_WITH_INV;
> +	if (rctxt->rc_inv_rkey) {
> +		sctxt->sc_send_wr.opcode = IB_WR_SEND_WITH_INV;
> +		sctxt->sc_send_wr.ex.invalidate_rkey = rctxt->rc_inv_rkey;
> +	} else {
> +		sctxt->sc_send_wr.opcode = IB_WR_SEND;
>   	}
>   	dprintk("svcrdma: posting Send WR with %u sge(s)\n",
> -		ctxt->sc_send_wr.num_sge);
> -	return svc_rdma_send(rdma, &ctxt->sc_send_wr);
> +		sctxt->sc_send_wr.num_sge);
> +	return svc_rdma_send(rdma, &sctxt->sc_send_wr);
>   }
>   
>   /* Given the client-provided Write and Reply chunks, the server was not
> @@ -809,7 +782,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>   	}
>   
>   	svc_rdma_sync_reply_hdr(rdma, sctxt, svc_rdma_reply_hdr_len(rdma_resp));
> -	ret = svc_rdma_send_reply_msg(rdma, sctxt, rdma_argp, rqstp,
> +	ret = svc_rdma_send_reply_msg(rdma, sctxt, rctxt, rqstp,
>   				      wr_lst, rp_ch);
>   	if (ret < 0)
>   		goto err1;
> 
> 
> 
