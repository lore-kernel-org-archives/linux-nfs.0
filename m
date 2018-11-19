Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A3D9C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 17:47:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 26E192145D
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 17:47:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="X4ZFDqxQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26E192145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729297AbeKTEMI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 23:12:08 -0500
Received: from mail-ua1-f67.google.com ([209.85.222.67]:33114 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728620AbeKTEMH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 23:12:07 -0500
Received: by mail-ua1-f67.google.com with SMTP id t8so3299123uap.0;
        Mon, 19 Nov 2018 09:47:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=op0U3yybTWDvutMlaJ4v/ON2CTAkYyNRkBkL6trniHM=;
        b=X4ZFDqxQab0OX/uGd2lZOKT4eLF8ypLqrS74el20CMHAW3XIIm3OXJr7sm4ArtJvZU
         tXjcXwVf+sztbsom7vTJVZ0pfOKW4Gf+cEkJCV5IqL8d+kJu7A9sf/Etcdbh+Ypu5m2U
         ZoiNlILQZUbS77fbNocWMC3+6RZz0D7g6JGtdbFai7ufB9rtoI/9C3cnuvIXJ9MfE3eB
         xo5Nqkx43g0QkP2yykg3KRAgE7Mh8lkxypHIACNGEp0WgSXEhDedPVEZGFdwIJp9VuOZ
         CdKNo/JwOlAiAB7yBYBBQ4FAywMx3h7Czt2r6OCEA+ie/pp+XnR21MSU+pflM+5b5YcF
         aRvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=op0U3yybTWDvutMlaJ4v/ON2CTAkYyNRkBkL6trniHM=;
        b=PdK7X6xmiubFhr2ndnSS5fOK8MfzJVW5cfpxMXeLk/yDW3WW3zbHggiLpqOmcVa5My
         taTj4MqYmerK6yB8YH3lP1EyCUspFfXoXIlY8/o9u9tyfsKZWO6mJPA4I1inUMlKfBke
         Aah+moulcM65Ij5jDEQN0zAP2agXcrD1b2i+f13/0zn6ojaECR2+jSpwKSPw5BXKuKOs
         xoaTQhfqLyH9XyvAQtRBPPm2uZjMytbgPMoMMspy+Gr3FBAecEkzBikar/St8nvZYlBg
         xZrqYFaY0NgYFZHD4LavGMfoTlFuR0uurV4fyqOvtqmi+tEOnD7BFRv6Ti96W8uRCPFq
         NQ+Q==
X-Gm-Message-State: AGRZ1gKyQt9xlL9ZoiB/JHB8fQItby8AJ28SgiX9jCJLB/M9ScsuRc2S
        uTk0uifh0mGuoIjoDTsiFjuWOAvFKUZmsmsZiEhnaA==
X-Google-Smtp-Source: AJdET5f0p1QUYw5lgsE3wdgQNJFXmflWsXFgoeC+j2o4JEKNYZxPyEpCkwAQatzbXhNHQZUhNc6zCAsXD2EDmdCBc+I=
X-Received: by 2002:ab0:60da:: with SMTP id g26mr9710870uam.104.1542649655575;
 Mon, 19 Nov 2018 09:47:35 -0800 (PST)
MIME-Version: 1.0
References: <20181119153707.10832.42881.stgit@manet.1015granger.net> <20181119154607.10832.92558.stgit@manet.1015granger.net>
In-Reply-To: <20181119154607.10832.92558.stgit@manet.1015granger.net>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 19 Nov 2018 12:47:23 -0500
Message-ID: <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 10:46 AM Chuck Lever <chuck.lever@oracle.com> wrote:
>
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

Is this just an "eye-catcher" or do you have plans to use it in
wireshark? If the latter, then can we really do that? while a linux
implementation may do that, other (or even possibly future linux)
implementation might not do this. Can we justify changing the
wireshark logic for it?

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
> -           int nsegs, bool writing, struct rpcrdma_mr **out)
> +           int nsegs, bool writing, u32 xid, struct rpcrdma_mr **out)
>  {
>         struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>         bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
> @@ -398,6 +398,7 @@
>         if (unlikely(n != mr->mr_nents))
>                 goto out_mapmr_err;
>
> +       ibmr->iova |= ((u64)cpu_to_be32(xid)) << 32;
>         key = (u8)(ibmr->rkey & 0x000000FF);
>         ib_update_fast_reg_key(ibmr, ++key);
>
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 9f53e02..89a2db2 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -357,7 +357,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
>
>         do {
>                 seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
> -                                                  false, &mr);
> +                                                  false, rqst->rq_xid, &mr);
>                 if (IS_ERR(seg))
>                         return PTR_ERR(seg);
>                 rpcrdma_mr_push(mr, &req->rl_registered);
> @@ -415,7 +415,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
>         nchunks = 0;
>         do {
>                 seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
> -                                                  true, &mr);
> +                                                  true, rqst->rq_xid, &mr);
>                 if (IS_ERR(seg))
>                         return PTR_ERR(seg);
>                 rpcrdma_mr_push(mr, &req->rl_registered);
> @@ -473,7 +473,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
>         nchunks = 0;
>         do {
>                 seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
> -                                                  true, &mr);
> +                                                  true, rqst->rq_xid, &mr);
>                 if (IS_ERR(seg))
>                         return PTR_ERR(seg);
>                 rpcrdma_mr_push(mr, &req->rl_registered);
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index a13ccb6..2ae1ee2 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -472,7 +472,7 @@ struct rpcrdma_memreg_ops {
>         struct rpcrdma_mr_seg *
>                         (*ro_map)(struct rpcrdma_xprt *,
>                                   struct rpcrdma_mr_seg *, int, bool,
> -                                 struct rpcrdma_mr **);
> +                                 u32, struct rpcrdma_mr **);
>         int             (*ro_send)(struct rpcrdma_ia *ia,
>                                    struct rpcrdma_req *req);
>         void            (*ro_reminv)(struct rpcrdma_rep *rep,
>
