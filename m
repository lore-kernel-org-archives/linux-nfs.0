Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:34938 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcEYLut (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2016 07:50:49 -0400
Received: by mail-yw0-f196.google.com with SMTP id n16so6190866ywd.2
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2016 04:50:49 -0700 (PDT)
Message-ID: <1464177046.3037.3.camel@poochiereds.net>
Subject: Re: [PATCH 2/4] nfsd: Can leak pnfs_block_extent on error
From: Jeff Layton <jlayton@poochiereds.net>
To: Tom Haynes <thomas.haynes@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Date: Wed, 25 May 2016 07:50:46 -0400
In-Reply-To: <1464152979-103988-3-git-send-email-loghyr@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
	 <1464152979-103988-3-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-05-24 at 22:09 -0700, Tom Haynes wrote:
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> ---
>  fs/nfsd/blocklayout.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index 248adb6..9a195f1 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -23,7 +23,7 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
>  	struct nfsd4_layout_seg *seg = &args->lg_seg;
>  	struct super_block *sb = inode->i_sb;
>  	u32 block_size = (1 << inode->i_blkbits);
> -	struct pnfs_block_extent *bex;
> +	struct pnfs_block_extent *bex = NULL;
>  	struct iomap iomap;
>  	u32 device_generation = 0;
>  	int error;
> @@ -105,9 +105,11 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
>  	return 0;
>  
>  out_error:
> +	kfree(bex);
>  	seg->length = 0;
>  	return nfserrno(error);
>  out_layoutunavailable:
> +	kfree(bex);
>  	seg->length = 0;
>  	return nfserr_layoutunavailable;
>  }

Nice catch! Might be reasonable for stable?

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
