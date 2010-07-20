Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41983 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab0GTN4u convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 09:56:50 -0400
Received: by yxn35 with SMTP id 35so1280448yxn.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jul 2010 06:56:49 -0700 (PDT)
In-Reply-To: <1279605456-7349-1-git-send-email-bhalevy@panasas.com>
References: <4C453A50.7070009@panasas.com>
	<1279605456-7349-1-git-send-email-bhalevy@panasas.com>
Date: Tue, 20 Jul 2010 09:50:21 -0400
Message-ID: <AANLkTinv670aR9NSYb7O=KdJAhhsRHo3gZTcSrj0MHY_@mail.gmail.com>
Subject: Re: [PATCH 2/3] SQUASHME: pnfs-submit: filelayout: add nr_pages back
	to write_pagelist api
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The file layout does not use nr_pages. The calculation is easy. No
need to pass the extra parameter. Why not just call
nfs_page_array_len() in the layout drivers that need it?

-->Andy

On Tue, Jul 20, 2010 at 1:57 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4filelayout.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 9b6ba8d..b2ce478 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -244,7 +244,7 @@ filelayout_read_pagelist(struct nfs_read_data *data, unsigned nr_pages)
>
>  /* Perform async writes. */
>  static enum pnfs_try_status
> -filelayout_write_pagelist(struct nfs_write_data *data, int sync)
> +filelayout_write_pagelist(struct nfs_write_data *data, unsigned nr_pages, int sync)
>  {
>        struct pnfs_layout_segment *lseg = data->pdata.lseg;
>        struct nfs4_pnfs_ds *ds;
> --
> 1.7.1.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
