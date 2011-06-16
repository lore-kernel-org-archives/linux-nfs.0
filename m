Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:37312 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab1FPCuQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2011 22:50:16 -0400
Received: by vws1 with SMTP id 1so846174vws.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2011 19:50:15 -0700 (PDT)
Message-ID: <4DF96F5E.5010109@tonian.com>
Date: Wed, 15 Jun 2011 22:50:06 -0400
From: Benny Halevy <benny@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] FIXME: BUG wdata->mds_offset never gets set
References: <4DF9278A.5010103@panasas.com>
In-Reply-To: <4DF9278A.5010103@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-15 17:43, Boaz Harrosh wrote:
> 
> The fileslayout and blockslayout drivers had a set of
> wdata->mds_offset in their .write_pagelist member.
> 
> The objects driver did not. Which breaks layout_commit.
> 
> FIXME: Since all drivers set mds_offset in exactly the same place
> to the same value. And then never touch it. It calls for the
> generic layer to take care of it.
> (I'll send the fix tomorrow)

Thanks, that's indeed a fallout from 4b8ee2b
"nfs41: Correct offset for LAYOUTCOMMIT"

I merged this also for pnfs-all-2.6.39

Benny

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objlayout.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index dc3956c..96dd474 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -430,6 +430,8 @@ objlayout_write_pagelist(struct nfs_write_data *wdata,
>  	status = objio_write_pagelist(state, how & FLUSH_STABLE);
>   out:
>  	dprintk("%s: Return status %Zd\n", __func__, status);
> +	/* pnfs_set_layoutcommit needs this */
> +	wdata->mds_offset = wdata->args.offset;
>  	wdata->pnfs_error = status;
>  	return PNFS_ATTEMPTED;
>  }

-- 
Benny Halevy
CTO, Tonian Inc.

Tel: +972-54-802-8340
benny@tonian.com
