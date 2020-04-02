Return-Path: <SRS0=WoEm=5S=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 351D0C43331
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Apr 2020 16:14:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 07D26206F6
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Apr 2020 16:14:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UbtKw5o1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389718AbgDBQOp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 2 Apr 2020 12:14:45 -0400
Received: from mail-qv1-f68.google.com ([209.85.219.68]:37633 "EHLO
        mail-qv1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389679AbgDBQOp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2020 12:14:45 -0400
Received: by mail-qv1-f68.google.com with SMTP id n1so1952750qvz.4
        for <linux-nfs@vger.kernel.org>; Thu, 02 Apr 2020 09:14:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=Fw8EWqgt3W6+oL/8lWZ1wZLqVBWAeji50AX2NktR11U=;
        b=UbtKw5o1a8yURDwPMa95nc3ZMoC/7ZqkpW/ddPZweHzwcnQslh7zKfudrIlZVpQvQc
         xGcsyNBYmTFpaciYYvr/SyvakIZ6XayYUl64UL6PIzdDW0NYBcWdAX+dVIhMoo8Hhq/e
         jigCPA8VlY06CCaMT9laAeFt6dHrydEJnKrNuOvrw/V7q0AUQo1zbCHuW9bmcNvS3mdJ
         Vc+vNvAKxvkzLeRusMYaaFUih8Fk3TxDpVedNSexc1kmS1rY78AK/myQs7fIdHoJYI5H
         HAt/2G8hyFsN4NgDeXnShYPfnJOG3yP7eYclPuckuEkynb9MJzNItDAw7mjKTP5ZWVgF
         MHoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:to:references:from:message-id
         :date:user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=Fw8EWqgt3W6+oL/8lWZ1wZLqVBWAeji50AX2NktR11U=;
        b=XdAM31NCQFseq/1GY3b3qLsQerEW+6k9OXnRKTgd7zJwGPVLzLXxHzjjqlRka0hJke
         XJuMN0Wet7cI/lczSyc4NABXVAelvIxBHfYncd0XwbUKGW94xGxPQIZGywKI4U3PVddU
         KhvCLY2bLPpjquBJhNAsB7pRjFlCA2mtFB25lQaNbeYHNbqiqM93BAOtM6osp6U8wOUg
         IM0pU+AN1UFUgTtSJLpPSCbi9by87kAeUhYtvZ33Dn7/hZ/ayrfNyywsG4eGjzRGHtdg
         jZlaHLCvUtWC5oSsTp+3oLqYvJ+NeyEJwLDezqEruQZmIaQOMw3NfyVmdOCNgUabxkdc
         CH0Q==
X-Gm-Message-State: AGi0PuYI1uGUIreaa7/0svZCdJ38E/frOSKoigi19jyaXONihPCQAnpU
        BlCCcha39tDrvp/Aqb2sAvCY42+M
X-Google-Smtp-Source: APiQypKf06JyQU4naOgrmXhpy1CfE2jURXUJIKa44rSJBOXkvHByUVhUjXHUZsFp1dGAw0Tx1ZX3fA==
X-Received: by 2002:ad4:5807:: with SMTP id dd7mr3798225qvb.151.1585844083638;
        Thu, 02 Apr 2020 09:14:43 -0700 (PDT)
Received: from [192.168.1.43] (c-68-32-74-190.hsd1.mi.comcast.net. [68.32.74.190])
        by smtp.gmail.com with ESMTPSA id w28sm4085224qtc.27.2020.04.02.09.14.42
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 02 Apr 2020 09:14:43 -0700 (PDT)
Subject: Re: [PATCH 05/10] NFS: Fix memory leaks in
 nfs_pageio_stop_mirroring()
To:     trondmy@kernel.org, linux-nfs@vger.kernel.org
References: <20200401185652.1904777-1-trondmy@kernel.org>
 <20200401185652.1904777-2-trondmy@kernel.org>
 <20200401185652.1904777-3-trondmy@kernel.org>
 <20200401185652.1904777-4-trondmy@kernel.org>
 <20200401185652.1904777-5-trondmy@kernel.org>
 <20200401185652.1904777-6-trondmy@kernel.org>
From:   Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <c1a7808b-2bf5-0716-f720-d77fc5f09160@gmail.com>
Date:   Thu, 2 Apr 2020 12:14:41 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.6.0
MIME-Version: 1.0
In-Reply-To: <20200401185652.1904777-6-trondmy@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On 4/1/20 2:56 PM, trondmy@kernel.org wrote:
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
>
> If we just set the mirror count to 1 without first clearing out
> the mirrors, we can leak queued up requests.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/pagelist.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 99eb839c5778..1fd4862217e0 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -900,15 +900,6 @@ static void nfs_pageio_setup_mirroring(struct nfs_pageio_descriptor *pgio,
>  	pgio->pg_mirror_count = mirror_count;
>  }
>  
> -/*
> - * nfs_pageio_stop_mirroring - stop using mirroring (set mirror count to 1)
> - */
> -void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio)
> -{
> -	pgio->pg_mirror_count = 1;
> -	pgio->pg_mirror_idx = 0;
> -}
> -
>  static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
>  {
>  	pgio->pg_mirror_count = 1;
> @@ -1334,6 +1325,14 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
>  	}
>  }
>  
> +/*
> + * nfs_pageio_stop_mirroring - stop using mirroring (set mirror count to 1)
> + */
> +void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio)
> +{
> +	nfs_pageio_complete(pgio);
> +}
> +

Would it make sense to replace calls to nfs_pageio_stop_mirroring() with nfs_pageio_complete() instead?

Anna

>  int __init nfs_init_nfspagecache(void)
>  {
>  	nfs_page_cachep = kmem_cache_create("nfs_page",
