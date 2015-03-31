Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33143 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbCaODF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 10:03:05 -0400
Received: by qgfa8 with SMTP id a8so15026890qgf.0
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 07:03:03 -0700 (PDT)
Date: Tue, 31 Mar 2015 10:02:51 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: require an explicit option to enable pNFS
Message-ID: <20150331100251.3108467f@tlielax.poochiereds.net>
In-Reply-To: <1427733989-30051-1-git-send-email-hch@lst.de>
References: <1427733989-30051-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Mar 2015 18:46:29 +0200
Christoph Hellwig <hch@lst.de> wrote:

> Turns out sending out layouts to any client is a bad idea if they
> can't get at the storage device, so require explicit admin action
> to enable pNFS.
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

Don't you also need to update the expflags array in fs/nfsd/export.c?
You won't see this flag reported in nfsd.export otherwise. Not sure how
big a problem that is however...

-- 
Jeff Layton <jeff.layton@primarydata.com>
