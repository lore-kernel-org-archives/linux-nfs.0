Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C603C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:26:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3B00C2080A
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:26:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H2WzqQ4b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B00C2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725941AbeLAIgz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:36:55 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:33358 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAIgz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:36:55 -0500
Received: by mail-io1-f65.google.com with SMTP id t24so5730898ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 13:26:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=g8vdWWcITSfOILO63bC0wvAVl8S6+/rue2bn/GCms2o=;
        b=H2WzqQ4bhLsE95SuVOCDjydoxzGCV1jQRsDYokjrmYC3mGdDI2X7W3sm4rdqTCW5e4
         c6WQIJcdvbkl0A2jXJ0FL7rsGZJFfuT2vBSyxZsFfULAHA3BK+fv0Hr5BF45cOusjFZu
         sm4+mJkrhAsus2Is4L1NPyh5JelQ2lOzzo0chErnJlRvDpQ6xpsmLPxgG3xgZ9Mg09pv
         FQhSvv+ET1T2yGdHbiK/+mSCjzpgpJ5hc0khUDi9EI2izu24Yk7aaZ/M0WSmSksigQjz
         nSK2eIgojHng5mStvXdU1iWu/r1l7PBD5Pz2ZDrfRSPu3uj/+LXSqTRKkgJMwxFDvoR7
         FMDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=g8vdWWcITSfOILO63bC0wvAVl8S6+/rue2bn/GCms2o=;
        b=kqKFwvI9AuhkyeTJWn2gv8PgXpmUU8o+8DNhYXOKKC7s9iu3vgB3L6gSgXA8oZEgLa
         MNqZgONZ2UYY4+VLr0b0Gb0iqgyLIuQmK8z251l9H30LlNL1TYBJUI4VAJ+wTGMcErZR
         tN66buL+cZycZKRreHdd/x7l1dpsAIFeWWdlqi6LkvZXqe4ueGkOxbI8TUcBLNG0e+WN
         D+Ku6QCAxZ/a1F4s08VF9L7PgbD6GDDoyYft5MRAf2Uhgu8/AHPgk++FDw2Diw7OYdyo
         54mJgR02ByVye5InOQN4FOUdXpPOOl/yajM9OYSyS/DoLD6y0NUYBIRW13iT/aP/EoBF
         89uw==
X-Gm-Message-State: AA+aEWaKxaojTiPDs1jazC5AwDF/ax4VfKDqqxRuX9kB3e5zTdznuwbD
        +goNsJ2i90PuTx4SUS217NZO6hA=
X-Google-Smtp-Source: AFSGD/U71M+3RDMChzwzc1yeQjhhtvHN6YUbV4GMyUzmIJpYXJt+qAyqHW3Buif3iiFGCyW5bEoEWQ==
X-Received: by 2002:a5e:da09:: with SMTP id x9mr6525767ioj.241.1543613176895;
        Fri, 30 Nov 2018 13:26:16 -0800 (PST)
Received: from leira (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id q197sm173521itb.22.2018.11.30.13.26.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 13:26:16 -0800 (PST)
Message-ID: <eaa3259a1aa12e29b8bd824f7cd417d6346239f9.camel@gmail.com>
Subject: Re: [PATCH v2 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
From:   Trond Myklebust <trondmy@gmail.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date:   Fri, 30 Nov 2018 16:26:15 -0500
In-Reply-To: <9D04832A-FC88-409C-8742-CBF742B6CB4A@oracle.com>
References: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
         <20181130211846.89000-2-trond.myklebust@hammerspace.com>
         <20181130211846.89000-3-trond.myklebust@hammerspace.com>
         <9D04832A-FC88-409C-8742-CBF742B6CB4A@oracle.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 (3.30.2-2.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-11-30 at 16:23 -0500, Chuck Lever wrote:
> > On Nov 30, 2018, at 4:18 PM, Trond Myklebust <trondmy@gmail.com>
> > wrote:
> > 
> > A call to gss_wrap_req_priv() will end up replacing the original
> > array
> > in rqstp->rq_snd_buf.pages with a new one containing the encrypted
> > data. In order to avoid having the rqstp->rq_snd_buf.bvec point to
> > the
> > wrong page data, we need to refresh that too.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> > net/sunrpc/xprtsock.c | 1 +
> > 1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index ae77c71c1f64..615ef2397fc5 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -843,6 +843,7 @@ static int xs_nospace(struct rpc_rqst *req)
> > static void
> > xs_stream_prepare_request(struct rpc_rqst *req)
> > {
> > +	xdr_free_bvec(&req->rq_rcv_buf);
> 
> I've added a pr_warn that fires whenever rq_rcv_buf.bvec != NULL,
> and it never made a peep. Am I missing something?
> 

It may be non-NULL, but contain an array of pointers to the wrong
pages. That's going to be the case when we re-encode the request,
because (as your patch pointed out) we free the old array of
rq_enc_pages (and its contents) and allocate a whole new array + set of
pages.

> 
> > 	req->rq_task->tk_status = xdr_alloc_bvec(&req->rq_rcv_buf,
> > GFP_NOIO);
> > }
> > 
> > -- 
> > 2.19.2
> > 
> 
> --
> Chuck Lever
> 
> 
> 

