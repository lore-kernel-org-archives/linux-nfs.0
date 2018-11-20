Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98793C41536
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 18:02:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 32A94206BB
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 18:02:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SxNwqh/W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32A94206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727607AbeKUEdB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 23:33:01 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:33292 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726062AbeKUEdB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 23:33:01 -0500
Received: by mail-io1-f65.google.com with SMTP id f12-v6so2072210iog.0;
        Tue, 20 Nov 2018 10:02:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Vb/3qd0e0uqFasXA1Ijn5NbUAUyeSIVn37QZjUdnPE8=;
        b=SxNwqh/WsBBgeFrghgjSuSUeDGMWLPGCFNRYSeIbuCrkaT5UMKpmYUAjnaZ64D4sdF
         IN0Xhp2sGGgmaiCcIy/GyRGSBzLi+DYmeFV2fHajnPdpai5mIcs84Ys8kOrN7svTMZhJ
         hMo0ta1BV7LidRfCoCXDzfik1JIQv5Ff2O77jq2hnbP2Nk52e6j/w9ILLbu68I1usthV
         5spcDGFd4AK9uBDU6E64+4W5DIpGNGD019r7vsCWwRdRhHcRGSpjRZgSCbf7A3VAm5TO
         UrB6aA2RUHIsRhwTBAcmj518bA4ZC9Xf1B2GxppDxqsY4ZnAp2yU9Ct5oOmncLxINjdc
         jqrw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Vb/3qd0e0uqFasXA1Ijn5NbUAUyeSIVn37QZjUdnPE8=;
        b=j4ljPfesX56dod57YnQIymFIHKiXcYQi8KELoTOLCLfnPnq3bwzIbQo8VXbTQ5TRpp
         NDBH9i9Cwn0hZXZAqJH/X62WU6EQ5GjBWtCZg/NKqrXEh/TlECOd4eu6hDILcjRUx2SC
         L/OsrHDJ3c+xfJ3DhfLf/mZYXT8ITgOqJjdx3dRz/T9am33gax0o3juZqQZKKOppTB6L
         Am/ujKxYDgFbHvxIYJz0yOicC06nNNiqlPn4SuXhgy8pwPrI78JYNNlJw9G95gzBD9vQ
         t0gangK2ujJEg13/vBfNUDt91aYLY0I6ETX1tmdxTqbC3x4uCbBBofGZmgO+jE1499uo
         2mSw==
X-Gm-Message-State: AA+aEWalFV2m2vszRLG+slNSpRFPw0VoVqOpSXlrbTsXRgBBiywF0F99
        A6low8p7UE/gx1il2sg682zC9LkYp+s=
X-Google-Smtp-Source: AFSGD/VipJAAsBiEcO3wAdbyzc/NnIc+IETQdamK7saG06KDq/yDsPw3okKqfzr0obI2DpX31pSorQ==
X-Received: by 2002:a6b:3945:: with SMTP id g66mr2249028ioa.131.1542736956709;
        Tue, 20 Nov 2018 10:02:36 -0800 (PST)
Received: from gouda.nowheycreamery.com (99-9-112-69.lightspeed.livnmi.sbcglobal.net. [99.9.112.69])
        by smtp.googlemail.com with ESMTPSA id v202sm4056595ita.13.2018.11.20.10.02.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Nov 2018 10:02:35 -0800 (PST)
Message-ID: <f1d83adeef9acf690c523df43c2f542b97a0bc33.camel@gmail.com>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Date:   Tue, 20 Nov 2018 13:02:34 -0500
In-Reply-To: <20181119154607.10832.92558.stgit@manet.1015granger.net>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
         <20181119154607.10832.92558.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

On Mon, 2018-11-19 at 10:46 -0500, Chuck Lever wrote:
> Place the associated RPC transaction's XID in the upper 32 bits of
> each RDMA segment's rdma_offset field. These bits are currently
> always zero.
> 
> There are two reasons to do this:
> 
> - The R_key only has 8 bits that are different from registration to
>   registration. The XID adds more uniqueness to each RDMA segment to
>   reduce the likelihood of a software bug on the server reading from
>   or writing into memory it's not supposed to.
> 
> - On-the-wire RDMA Read and Write operations do not otherwise carry
>   any identifier that matches them up to an RPC. The XID in the
>   upper 32 bits will act as an eye-catcher in network captures.
> 
> Suggested-by: Tom Talpey <ttalpey@microsoft.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/frwr_ops.c  |    3 ++-
>  net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
>  net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 49b314d..3b260d2 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -344,7 +344,7 @@
>   */
>  static struct rpcrdma_mr_seg *
>  frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
> -	    int nsegs, bool writing, struct rpcrdma_mr **out)
> +	    int nsegs, bool writing, u32 xid, struct rpcrdma_mr **out)
>  {
>  	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>  	bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
> @@ -398,6 +398,7 @@
>  	if (unlikely(n != mr->mr_nents))
>  		goto out_mapmr_err;
>  
> +	ibmr->iova |= ((u64)cpu_to_be32(xid)) << 32;

My mount command hangs once we make this change (I got bored and killed it after
about 5 minutes).  This is with NFS over soft-RoCE in a kvm virtual machine, and
I see the behavior with all NFS versions.

I hope this helps!
Anna

>  	key = (u8)(ibmr->rkey & 0x000000FF);
>  	ib_update_fast_reg_key(ibmr, ++key);
>  
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 9f53e02..89a2db2 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -357,7 +357,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt
> *r_xprt,
>  
>  	do {
>  		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
> -						   false, &mr);
> +						   false, rqst->rq_xid, &mr);
>  		if (IS_ERR(seg))
>  			return PTR_ERR(seg);
>  		rpcrdma_mr_push(mr, &req->rl_registered);
> @@ -415,7 +415,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt
> *r_xprt,
>  	nchunks = 0;
>  	do {
>  		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
> -						   true, &mr);
> +						   true, rqst->rq_xid, &mr);
>  		if (IS_ERR(seg))
>  			return PTR_ERR(seg);
>  		rpcrdma_mr_push(mr, &req->rl_registered);
> @@ -473,7 +473,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt
> *r_xprt,
>  	nchunks = 0;
>  	do {
>  		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
> -						   true, &mr);
> +						   true, rqst->rq_xid, &mr);
>  		if (IS_ERR(seg))
>  			return PTR_ERR(seg);
>  		rpcrdma_mr_push(mr, &req->rl_registered);
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index a13ccb6..2ae1ee2 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -472,7 +472,7 @@ struct rpcrdma_memreg_ops {
>  	struct rpcrdma_mr_seg *
>  			(*ro_map)(struct rpcrdma_xprt *,
>  				  struct rpcrdma_mr_seg *, int, bool,
> -				  struct rpcrdma_mr **);
> +				  u32, struct rpcrdma_mr **);
>  	int		(*ro_send)(struct rpcrdma_ia *ia,
>  				   struct rpcrdma_req *req);
>  	void		(*ro_reminv)(struct rpcrdma_rep *rep,
> 

