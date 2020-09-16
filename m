Return-Path: <SRS0=3Pxj=CZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93A78C2D0E3
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Sep 2020 00:51:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3F59620936
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Sep 2020 00:51:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bIpGCEMB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726524AbgIPAvk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Sep 2020 20:51:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46768 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726216AbgIPAvi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2020 20:51:38 -0400
Received: from mail-pf1-x443.google.com (mail-pf1-x443.google.com [IPv6:2607:f8b0:4864:20::443])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 360F4C06174A
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2020 17:51:38 -0700 (PDT)
Received: by mail-pf1-x443.google.com with SMTP id o20so2927813pfp.11
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2020 17:51:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=gIytwv4XTDks1RzUVPSw8zLP11VLG9XBEFCA97ER3Eg=;
        b=bIpGCEMBLxgMLj6cugFwT7fqAe+ucN5t5wrKk3qq1a6s3wEYCLPFNgPrShq0c9CqWa
         OaezzBApKMG130xcl5zRjZzJP+c1b2hff01hi83LcQ564BUAEt/QexN8QIERsANiw/X6
         mqxZN3HhVHSPGjZMHjUYFKSlMXzdgzDzC4qFJfxP6C6Ei0YdtQ6xBNMTjjzg3Bb1ZYe7
         4EdX+xQAwlC5aQc/SQjulOxOD6MWYGp5vQbXfXHg/7Vzlk/LdSSRwmPZtnDsaswdkHKL
         voxXm2DPnQqAIFJCWy9sRx2Ari5B2g+MTkmaHaTWjevwWWWWRG7L5FRDD++RNSQS6d3M
         gU+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=gIytwv4XTDks1RzUVPSw8zLP11VLG9XBEFCA97ER3Eg=;
        b=K6458wbZlh7G/EqH9faWXry8dFXUxB/F0JtIWW+bjRsXXKXXNQwL+45MKfoGScYQUW
         pSzkSShsqRTrjXFD5TEK4LnvrgmOzG4TnqJ4l4iP4Ymi+Zi7oIkP10daRxrdfitdawCx
         cu9ZXKjcSNTyj05k5EUw5ZZa0LPiaC9zqF+LuyxWqexthIvlIE6X3UnJUw7Qa0rsHVMv
         Dua+nCWNEJteOO1Qr3GccyeuwXo2vIqZ5aspp5BttmV9WFuzelEmxZW3xz4vTu0NZl92
         XxSQUVSI8jS5z7GyCAXfF32P4ywK8W4lFnpBjQxvdbHC+HilE2BGRA5E/+Jqe+Vnl/vx
         +Npg==
X-Gm-Message-State: AOAM530qTxL0mmY/osarJldWQmxCcaZfxhIeyrodW5BGzF4Dv3HBbupP
        jg+aGsB/AwxYO74K01AdnIE=
X-Google-Smtp-Source: ABdhPJzb3QRJlpMgy8xrW2wFCyOxWQYMA/ThW8ucpJYsm6GuvOuST/43fkSAQ/ELyFMMUeUBnOFIJA==
X-Received: by 2002:a63:1d5c:: with SMTP id d28mr15767944pgm.82.1600217497585;
        Tue, 15 Sep 2020 17:51:37 -0700 (PDT)
Received: from localhost ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id md10sm603055pjb.45.2020.09.15.17.51.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2020 17:51:36 -0700 (PDT)
Date:   Wed, 16 Sep 2020 08:51:29 +0800
From:   Murphy Zhou <jencce.kernel@gmail.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, jencce.kernel@gmail.com
Subject: Re: [PATCH 1/1] NFSv4.2: fix client's attribute cache management for
 copy_file_range
Message-ID: <20200916005129.ferojvuzniecdsbm@xzhoux.usersys.redhat.com>
References: <20200914202334.7536-1-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200914202334.7536-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Sep 14, 2020 at 04:23:34PM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> After client is done with the COPY operation, it needs to invalidate
> its pagecache (as it did no reading or writing of the data locally)
> and it needs to invalidate it's attributes just like it would have
> for a read on the source file and write on the destination file.
> 
> Once the linux server started giving out read delegations to
> read+write opens, the destination file of the copy_file range
> started having delegations and not doing syncup on close of the
> file leading to xfstest failures for generic/430,431,432,433,565.

Tested OK. ltp and xfstests on v3/v4.* looks fine.

The other issue generic/464 warning I reported before is still
there with Olga's patch. For the record.
 
Thanks!
> 
> Reported-by: Murphy Zhou <jencce.kernel@gmail.com>
> Fixes: 2e72448b07dc ("NFS: Add COPY nfs operation")
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs42proc.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 142225f0af59..a9074f3366fa 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -356,7 +356,11 @@ static ssize_t _nfs42_proc_copy(struct file *src,
>  
>  	truncate_pagecache_range(dst_inode, pos_dst,
>  				 pos_dst + res->write_res.count);
> -
> +	NFS_I(dst_inode)->cache_validity |= (NFS_INO_REVAL_PAGECACHE |
> +			NFS_INO_REVAL_FORCED | NFS_INO_INVALID_SIZE |
> +			NFS_INO_INVALID_ATTR | NFS_INO_INVALID_DATA);
> +	NFS_I(src_inode)->cache_validity |= (NFS_INO_REVAL_PAGECACHE |
> +			NFS_INO_REVAL_FORCED | NFS_INO_INVALID_ATIME);
>  	status = res->write_res.count;
>  out:
>  	if (args->sync)
> -- 
> 2.18.1
> 

-- 
Murphy
