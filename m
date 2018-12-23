Return-Path: <SRS0=dMO4=PA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34A83C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 21:49:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F34792184D
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 21:49:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sqmG7zha"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725956AbeLWVtR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 Dec 2018 16:49:17 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:46308 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725828AbeLWVtQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Dec 2018 16:49:16 -0500
Received: by mail-oi1-f194.google.com with SMTP id x202so8852941oif.13;
        Sun, 23 Dec 2018 13:49:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=5nekOVn8E/3y11Wo6lTFqhZbWWcKF/FGPvFqNszBb1k=;
        b=sqmG7zha9a8arZm/X7CV2fl+4oV0LbyPT8EBSQbBxKB0whPF8XlxdZM0oSqMLQJXyn
         joMCDNL5WrXT8/OfMgNNHApIlNCCPG7WWzwyE0HrzwNMkm3KdON3LM6/d6KmEKcXudmt
         kT31BC8Y/50ZRKMOshvjsw7ArHAIQoDmRG86OXG9N6YATRlfOZxIEdj8bUVizSS4XqLJ
         3+GXl271HxkkDYqkRuaV6d1ylrX3aTFr7rfYgGdsP5Q21gkDa0GEY/qAhBK9CczfbomS
         soDZP1VtzZGGAlnFz9TTnW9dx6kxFBdDTUZ3AcgVbsEtiCz0xKpS00QNUbOIvIsU9yTB
         W51g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=5nekOVn8E/3y11Wo6lTFqhZbWWcKF/FGPvFqNszBb1k=;
        b=tT4ak7n38hIuIiAIxUiCzcDRdPPjQDabDiiR+KcErHft5l19Rtwxck8VbNqA4VEXIb
         uu+aL8PJogZcuPhXKljXurq0gl8o+3tWX4MJ1GV/U+jnVjnOJ2zGWX0IMRjbhlQonjed
         RqeVZZJkMM/GOju4pdC/bUnRovZ2FFhFXMAHXD7WSd+29hxjO50L3fmr4pwqtbxeX46W
         x6bwgjafUI8Rp8i+pr2aaUqWtCm83lL2rEJLgYYisMmpDHI85aGInbyKtWO1UsTq+RoM
         65rlTLnSUHsDJzT39591yInRBns1mbDvwHrcefH06sbhqBOx8rx4lgOTtn8FRaDSFXxo
         TjvA==
X-Gm-Message-State: AA+aEWYU3HXDazsngpOJiASdPkLRmOAySBenVzxUW5FHIGRcvRlGvuYp
        6esRhVaZtXzCzwRf59vVxqK6sSKX+1YbpSustK4=
X-Google-Smtp-Source: AFSGD/UqXb98WoWfMxLkqUQYnQn7mtTCDKGW00IBAS1v8MbnRQJr1YDat9XwmyF+K2O+jIuVsXUH7mfx8rGd9U04T3I=
X-Received: by 2002:aca:4709:: with SMTP id u9mr6355601oia.212.1545601755567;
 Sun, 23 Dec 2018 13:49:15 -0800 (PST)
MIME-Version: 1.0
Received: by 2002:a9d:6c19:0:0:0:0:0 with HTTP; Sun, 23 Dec 2018 13:49:15
 -0800 (PST)
In-Reply-To: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
From:   Tom Psyborg <pozega.tomislav@gmail.com>
Date:   Sun, 23 Dec 2018 22:49:15 +0100
Message-ID: <CAKR_QVJefW1vxYb7-qiU8=0YdbFghYo15SK2eGjOC-dntRfyYA@mail.gmail.com>
Subject: Re: [PATCH 00/20] drop useless LIST_HEAD
To:     Julia Lawall <Julia.Lawall@lip6.fr>
Cc:     Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        kernel-janitors@vger.kernel.org, dmaengine@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Dan Williams <dan.j.williams@intel.com>,
        linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org,
        Stefano Stabellini <sstabellini@kernel.org>,
        xen-devel@lists.xenproject.org, linux-wireless@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Why do you CC this to so many lists?

On 23/12/2018, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> Drop LIST_HEAD where the variable it declares is never used.
>
> ---
>
>  drivers/dma/at_hdmac.c                                |    5 -----
>  drivers/dma/dw/core.c                                 |    1 -
>  drivers/dma/pl330.c                                   |    1 -
>  drivers/dma/sa11x0-dma.c                              |    2 --
>  drivers/dma/st_fdma.c                                 |    3 ---
>  drivers/infiniband/ulp/ipoib/ipoib_ib.c               |    1 -
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |    5 -----
>  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c       |    3 ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c        |    1 -
>  drivers/net/wireless/st/cw1200/queue.c                |    1 -
>  drivers/scsi/lpfc/lpfc_nvme.c                         |    2 --
>  drivers/scsi/lpfc/lpfc_scsi.c                         |    2 --
>  drivers/scsi/lpfc/lpfc_sli.c                          |    1 -
>  drivers/scsi/qla2xxx/qla_init.c                       |    1 -
>  drivers/xen/xenbus/xenbus_dev_frontend.c              |    2 --
>  fs/btrfs/relocation.c                                 |    1 -
>  fs/nfs/nfs4client.c                                   |    1 -
>  fs/nfsd/nfs4layouts.c                                 |    1 -
>  fs/xfs/xfs_buf.c                                      |    1 -
>  fs/xfs/xfs_fsops.c                                    |    1 -
>  20 files changed, 36 deletions(-)
>
