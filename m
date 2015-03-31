Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49475 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611AbbCaNo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 09:44:56 -0400
Date: Tue, 31 Mar 2015 09:44:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: require an explicit option to enable pNFS
Message-ID: <20150331134454.GI6901@fieldses.org>
References: <1427733989-30051-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427733989-30051-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 06:46:29PM +0200, Christoph Hellwig wrote:
> Turns out sending out layouts to any client is a bad idea if they
> can't get at the storage device, so require explicit admin action
> to enable pNFS.

Thanks, I'll pass along this and the accumulated fixes for 4.0 soon.

--b.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4layouts.c            | 2 +-
>  include/uapi/linux/nfsd/export.h | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index f4e8da2..9a8254b 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -118,7 +118,7 @@ void nfsd4_setup_layout_type(struct svc_export *exp)
>  {
>  	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
>  
> -	if (exp->ex_flags & NFSEXP_NOPNFS)
> +	if (!(exp->ex_flags & NFSEXP_PNFS))
>  		return;
>  
>  	if (sb->s_export_op->get_uuid &&
> diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
> index 4742f2c..d3bd6ffe 100644
> --- a/include/uapi/linux/nfsd/export.h
> +++ b/include/uapi/linux/nfsd/export.h
> @@ -47,7 +47,7 @@
>   * exported filesystem.
>   */
>  #define	NFSEXP_V4ROOT		0x10000
> -#define NFSEXP_NOPNFS		0x20000
> +#define NFSEXP_PNFS		0x20000
>  
>  /* All flags that we claim to support.  (Note we don't support NOACL.) */
>  #define NFSEXP_ALLFLAGS		0x3FE7F
> -- 
> 1.9.1
