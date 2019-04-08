Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA746C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:23:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6AE6420880
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:23:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="HWjOAv9Y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726951AbfDHUXD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 16:23:03 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:35565 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726220AbfDHUXD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 16:23:03 -0400
Received: by mail-vs1-f67.google.com with SMTP id d8so8425246vsp.2
        for <linux-nfs@vger.kernel.org>; Mon, 08 Apr 2019 13:23:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VeycDi2X6OdagTyqQ9N/ok51mIYZLpQABOvgLhaoxeM=;
        b=HWjOAv9YvvqNthYOSFpoN1L6V1O6dlte39+xQ6/z3RRJIGMOLVOjR9MDGmpBRJJNgF
         ozs3HTRb9+32OZNmOJn9oDSEnV31RlhxR8rKKmV0zQAyd/fVHejlR/eNkRMaYH5BQrOF
         UYc9vYjYE19GXt+Lvm9M0lf337cphzHS+lrY49Lx68UoWWKXi5LZbHsKStC5zqzd4H5V
         Jst00ojlVlAAZfEfN+pRh4aPn3RRkhrGDiYW0QbPlKhCE+c3KZ4ppPy0KSroAp8nTsSw
         VDiv899XHnqaZY3qc7Da2SkSE2oPcTVWie2PtQLPITtZsD5cJinW/v2FwArdKsjzY1Ey
         bsKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=VeycDi2X6OdagTyqQ9N/ok51mIYZLpQABOvgLhaoxeM=;
        b=PeyG5iJ8vRPiCPIkMovq5cTuAcjytyIgV2l3hMzwPB2EZnoNtUoNwps9wdZ8SwicIR
         Z71P+1Gt1kV7JJjFXHLBTvtYk8gSQVecObTVq4fg2stn3+47bGUdfFcWsJCVARj827j6
         xJUyNR5yz/pwWbu+5qiRVTaFVxn/pfxque3asrj8LAzADENyfMGhtUlgoa+tvNlP8a7A
         D7jAM9EpUBfnyLcGmMMKDrV6L2s/gkYZRmZfRyahN4Vs4RS39oS4i7JlZbWzx2fA3p0y
         QkQts7mpZtCAzWpqUSRHCEZoEyfBW2/Yw/6C9gpuWLEo5x+/WWQVqj5wmJMnHQXcZGVn
         r/mg==
X-Gm-Message-State: APjAAAVMURtW9C33z7p1sYKtnqGjflfWJXVkg0hIrMtRKK9ZchoA89du
        6DnAldTAvFKgwe4XcUJYs9NtzYl+UJvIkasNRPY=
X-Google-Smtp-Source: APXvYqzjiV4slI88KlJNUDHol70amRoanh/pbCMN+7o/N43YWy5sog9XsDqZfcCd66CTBsHxnXSE2Xm1wiWYwzqH/Xw=
X-Received: by 2002:a67:f714:: with SMTP id m20mr18471814vso.211.1554754982611;
 Mon, 08 Apr 2019 13:23:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190408200030.16366.22026.stgit@manet.1015granger.net>
In-Reply-To: <20190408200030.16366.22026.stgit@manet.1015granger.net>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 8 Apr 2019 16:22:51 -0400
Message-ID: <CAN-5tyHGhuMg1z_Nq9CM_zhfTa0Cbmo3fWD15-x6-T=q7pam_w@mail.gmail.com>
Subject: Re: [PATCH v1] NFS: Fix handling of reply page vector
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

Tested ACL and FS_LOCATION and it works.


On Mon, Apr 8, 2019 at 4:01 PM Chuck Lever <chuck.lever@oracle.com> wrote:
>
> NFSv4 GETACL and FS_LOCATIONS requests stopped working in v5.1-rc.
>
> These two need the extra padding to be added directly to the reply
> length.
>
> Reported-by: Olga Kornievskaia <aglo@umich.edu>
> Fixes: 02ef04e432ba ("NFS: Account for XDR pad of buf->pages")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfs/nfs4xdr.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index cfcabc3..6024461 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2589,7 +2589,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
>                         ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
>
>         rpc_prepare_reply_pages(req, args->acl_pages, 0,
> -                               args->acl_len, replen);
> +                               args->acl_len, replen + 1);
>         encode_nops(&hdr);
>  }
>
> @@ -2811,7 +2811,7 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
>         }
>
>         rpc_prepare_reply_pages(req, (struct page **)&args->page, 0,
> -                               PAGE_SIZE, replen);
> +                               PAGE_SIZE, replen + 1);
>         encode_nops(&hdr);
>  }
>
>
