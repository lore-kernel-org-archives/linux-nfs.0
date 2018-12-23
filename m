Return-Path: <SRS0=dMO4=PA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98559C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 22:06:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6EC83217D7
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 22:06:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725899AbeLWWGN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 Dec 2018 17:06:13 -0500
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:33701
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725828AbeLWWGN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Dec 2018 17:06:13 -0500
X-IronPort-AV: E=Sophos;i="5.56,389,1539640800"; 
   d="scan'208";a="290014683"
Received: from abo-91-111-68.mrs.modulonet.fr (HELO hadrien) ([85.68.111.91])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Dec 2018 23:06:08 +0100
Date:   Sun, 23 Dec 2018 23:06:07 +0100 (CET)
From:   Julia Lawall <julia.lawall@lip6.fr>
X-X-Sender: jll@hadrien
To:     Tom Psyborg <pozega.tomislav@gmail.com>
cc:     Julia Lawall <Julia.Lawall@lip6.fr>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        kernel-janitors@vger.kernel.org, dmaengine@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Dan Williams <dan.j.williams@intel.com>,
        linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org,
        Stefano Stabellini <sstabellini@kernel.org>,
        xen-devel@lists.xenproject.org, linux-wireless@vger.kernel.org
Subject: Re: [PATCH 00/20] drop useless LIST_HEAD
In-Reply-To: <CAKR_QVJefW1vxYb7-qiU8=0YdbFghYo15SK2eGjOC-dntRfyYA@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1812232304130.2940@hadrien>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr> <CAKR_QVJefW1vxYb7-qiU8=0YdbFghYo15SK2eGjOC-dntRfyYA@mail.gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On Sun, 23 Dec 2018, Tom Psyborg wrote:

> Why do you CC this to so many lists?

Because the different files are in different subsystems.  The cover letter
goes to a list for each file, or to a person if there is no list.  The
patches go to the people and lists associated with the affected files.

julia

>
> On 23/12/2018, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> > Drop LIST_HEAD where the variable it declares is never used.
> >
> > ---
> >
> >  drivers/dma/at_hdmac.c                                |    5 -----
> >  drivers/dma/dw/core.c                                 |    1 -
> >  drivers/dma/pl330.c                                   |    1 -
> >  drivers/dma/sa11x0-dma.c                              |    2 --
> >  drivers/dma/st_fdma.c                                 |    3 ---
> >  drivers/infiniband/ulp/ipoib/ipoib_ib.c               |    1 -
> >  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |    5 -----
> >  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c       |    3 ---
> >  drivers/net/ethernet/mellanox/mlxsw/spectrum.c        |    1 -
> >  drivers/net/wireless/st/cw1200/queue.c                |    1 -
> >  drivers/scsi/lpfc/lpfc_nvme.c                         |    2 --
> >  drivers/scsi/lpfc/lpfc_scsi.c                         |    2 --
> >  drivers/scsi/lpfc/lpfc_sli.c                          |    1 -
> >  drivers/scsi/qla2xxx/qla_init.c                       |    1 -
> >  drivers/xen/xenbus/xenbus_dev_frontend.c              |    2 --
> >  fs/btrfs/relocation.c                                 |    1 -
> >  fs/nfs/nfs4client.c                                   |    1 -
> >  fs/nfsd/nfs4layouts.c                                 |    1 -
> >  fs/xfs/xfs_buf.c                                      |    1 -
> >  fs/xfs/xfs_fsops.c                                    |    1 -
> >  20 files changed, 36 deletions(-)
> >
>
