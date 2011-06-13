Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47970 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab1FMP4l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 11:56:41 -0400
Received: by ywe9 with SMTP id 9so2069994ywe.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2011 08:56:40 -0700 (PDT)
In-Reply-To: <9203fc2b8c4edc9fcc695e2b0ccd7993727935bf.1307921138.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
	<9203fc2b8c4edc9fcc695e2b0ccd7993727935bf.1307921138.git.rees@umich.edu>
Date: Mon, 13 Jun 2011 11:56:40 -0400
Message-ID: <BANLkTimRKWgoP89FfF1HLDWVx_MDr+uACw@mail.gmail.com>
Subject: Re: [PATCH 18/34] pnfsblock: allow use of PG_owner_priv_1 flag
From: Fred Isaman <iisaman@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jun 12, 2011 at 7:44 PM, Jim Rees <rees@umich.edu> wrote:
> From: Fred Isaman <iisaman@citi.umich.edu>
>
> There is currently no good way for pnfs to communicate problems.  For
> example - the linux read code first tries to do readahead through
> nfs_readpages. Failure there is ignored, and it will later call
> nfs_readpage.  Failure there is also ignored, except that the lack of
> PG_uptodate is communicated back via -EIO.
>
> With pnfs, it would be useful to be able to communicate to
> nfs_readpage that direct disk IO failed on readahead, and that it
> should failover to using the MDS.
>
> Making the page flag PG_owner_priv_1 available as PG_pnfserr is one
> way to do so. (An alternative would be to embed this in the layout,
> but then pg_test can't easily access the info.)
>
> This may be better as generic pnfs code, in which case it should be
> put in pnfs.h, or even page-flags.h
>
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---

The error handling has changed a bit since this was written.  It is
currently very course grained for simplicity reasons.
Is there any reason you can't do similarly, and just use
NFS_LAYOUT_{RW|RO}_FAILED in lo->plh_flags?

Fred

>  fs/nfs/blocklayout/blocklayout.h |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index 21fa21c..293f009 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -35,6 +35,11 @@
>  #include <linux/nfs_fs.h>
>  #include "../pnfs.h"
>
> +#define PG_pnfserr PG_owner_priv_1
> +#define PagePnfsErr(page)      test_bit(PG_pnfserr, &(page)->flags)
> +#define SetPagePnfsErr(page)   set_bit(PG_pnfserr, &(page)->flags)
> +#define ClearPagePnfsErr(page) clear_bit(PG_pnfserr, &(page)->flags)
> +
>  struct block_mount_id {
>        spinlock_t                      bm_lock;    /* protects list */
>        struct list_head                bm_devlist; /* holds pnfs_block_dev */
> --
> 1.7.4.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
