From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] pnfs: get open context from nfs_page in pnfs_commit
Date: Thu, 01 Jul 2010 21:19:49 +0300
Message-ID: <4C2CDC45.6070900@panasas.com>
References: <1278008253-24666-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38694 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab0GASTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:19:54 -0400
Received: by wwb24 with SMTP id 24so176298wwb.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Jul 2010 11:19:53 -0700 (PDT)
In-Reply-To: <1278008253-24666-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.34-2010-07-01

Benny

On Jul. 01, 2010, 21:17 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> To fix a BUG_ON(!ctx) in pnfs_update_layout
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/pnfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index a4f50f6..784ea80 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -2015,7 +2015,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
>  	   before returning it, otherwise the data needs to be rewritten,
>  	   either with a new layout or to the MDS */
>  	result = pnfs_update_layout(data->inode,
> -				    NULL,
> +				    first->wb_context,
>  				    count,
>  				    first->wb_offset,
>  				    IOMODE_RW,

