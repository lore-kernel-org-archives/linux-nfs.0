Return-Path: <SRS0=NNg4=PC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C212EC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 25 Dec 2018 22:12:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 85AB32171F
	for <linux-nfs@archiver.kernel.org>; Tue, 25 Dec 2018 22:12:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P8fiLfK0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725885AbeLYWMW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 Dec 2018 17:12:22 -0500
Received: from mail-ot1-f66.google.com ([209.85.210.66]:38335 "EHLO
        mail-ot1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725863AbeLYWMW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Dec 2018 17:12:22 -0500
Received: by mail-ot1-f66.google.com with SMTP id e12so12944416otl.5;
        Tue, 25 Dec 2018 14:12:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=H+F/7kpffcrmNLAFlA4wQutLgELa0cIpQ4uv5/ujSEk=;
        b=P8fiLfK03yMTM7XE6f2Ds0glYoRxzHGPBtcnafPmETZmxn2VXTEdfWJd9F2Ty5Oe8q
         p4LrWRFIrjDz1iojSp/BL072c9uq5QPStsI9F3SEjJ+E7ACN0360Qq0xpxgRfWGqbBEZ
         LQDaDkxA6qpIGyHZZieRtMfVMo2up6++yVWGnNRo56Xw662d+B7vf5dRAMwy9BNIajf1
         zocs3wv94Xj9ntP5wp+A4wrIbKyaHVVG7Y8zKcgEEjiz1audCsNhvghteIDLh2n7ukBP
         CRpWw0klrXRLCMfADzygTeD7ir4BUNs10eM7j7d4c47YnGeYy5BK/z6seNiNu4Xnc0jd
         fiQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=H+F/7kpffcrmNLAFlA4wQutLgELa0cIpQ4uv5/ujSEk=;
        b=YxPOpEGljWxg9uJp0QSMRnLdRCsNwoLZScrcDmbYzjyQ0GuyOcOPBc0vfFJFOuLCLq
         18aal3TsR8I6VJED4umNIMx6gPxy+xzwUV0xytGYeytbtGd1UKztevcYgnXv9diOheqk
         ekooUZBAQZDp2LhoUJ7AuKB+joDdzZTnIYDuOHLrPljrLL6j5nS5dtLkNwSnhbUfauQi
         c/9/AUEZquCEDUE+1Af498Y0WMDAKZItd4/O9P2ihikmntKatO2LoyZcsKALEp2b3GxV
         ljqEixOEwu41seS5MKvVSuTf+NBdjqNiMNWnkWz/xtNM7NZbzczH2ELY6I4bNNAa8CWT
         EIgQ==
X-Gm-Message-State: AJcUukcw+65B0ARtRjITjeeqq5CD1RJ9+Tv+iZM9+vrllT1zp+DvNAda
        KTVPnygpHZHCOnswP0FuCqG7u9SbA5UF4+3gkFw=
X-Google-Smtp-Source: ALg8bN4n4DoI/o7renZYLXiIcxQ2lByhvr3lHP4BDQo8lgAspVaSh51vTURsuGN8CRhRA0nPmv65YYMl/iKxwsNGF7M=
X-Received: by 2002:a9d:734e:: with SMTP id l14mr11308345otk.270.1545775940592;
 Tue, 25 Dec 2018 14:12:20 -0800 (PST)
MIME-Version: 1.0
Received: by 2002:a9d:6c19:0:0:0:0:0 with HTTP; Tue, 25 Dec 2018 14:12:20
 -0800 (PST)
In-Reply-To: <alpine.DEB.2.21.1812232304130.2940@hadrien>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
 <CAKR_QVJefW1vxYb7-qiU8=0YdbFghYo15SK2eGjOC-dntRfyYA@mail.gmail.com> <alpine.DEB.2.21.1812232304130.2940@hadrien>
From:   Tom Psyborg <pozega.tomislav@gmail.com>
Date:   Tue, 25 Dec 2018 23:12:20 +0100
Message-ID: <CAKR_QVLeZBL43W4x1mzcfcakSZyyh9L81vgUMxfnSccKawEfdg@mail.gmail.com>
Subject: Re: [PATCH 00/20] drop useless LIST_HEAD
To:     Julia Lawall <julia.lawall@lip6.fr>
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

there was discussion about this just some days ago. CC 4-5 lists is
more than enough

On 23/12/2018, Julia Lawall <julia.lawall@lip6.fr> wrote:
>
>
> On Sun, 23 Dec 2018, Tom Psyborg wrote:
>
>> Why do you CC this to so many lists?
>
> Because the different files are in different subsystems.  The cover letter
> goes to a list for each file, or to a person if there is no list.  The
> patches go to the people and lists associated with the affected files.
>
> julia
>
>>
>> On 23/12/2018, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
>> > Drop LIST_HEAD where the variable it declares is never used.
>> >
>> > ---
>> >
>> >  drivers/dma/at_hdmac.c                                |    5 -----
>> >  drivers/dma/dw/core.c                                 |    1 -
>> >  drivers/dma/pl330.c                                   |    1 -
>> >  drivers/dma/sa11x0-dma.c                              |    2 --
>> >  drivers/dma/st_fdma.c                                 |    3 ---
>> >  drivers/infiniband/ulp/ipoib/ipoib_ib.c               |    1 -
>> >  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |    5 -----
>> >  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c       |    3 ---
>> >  drivers/net/ethernet/mellanox/mlxsw/spectrum.c        |    1 -
>> >  drivers/net/wireless/st/cw1200/queue.c                |    1 -
>> >  drivers/scsi/lpfc/lpfc_nvme.c                         |    2 --
>> >  drivers/scsi/lpfc/lpfc_scsi.c                         |    2 --
>> >  drivers/scsi/lpfc/lpfc_sli.c                          |    1 -
>> >  drivers/scsi/qla2xxx/qla_init.c                       |    1 -
>> >  drivers/xen/xenbus/xenbus_dev_frontend.c              |    2 --
>> >  fs/btrfs/relocation.c                                 |    1 -
>> >  fs/nfs/nfs4client.c                                   |    1 -
>> >  fs/nfsd/nfs4layouts.c                                 |    1 -
>> >  fs/xfs/xfs_buf.c                                      |    1 -
>> >  fs/xfs/xfs_fsops.c                                    |    1 -
>> >  20 files changed, 36 deletions(-)
>> >
>>
>
