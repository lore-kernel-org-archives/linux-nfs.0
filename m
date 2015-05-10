Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34438 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbEJQbu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 May 2015 12:31:50 -0400
Date: Mon, 11 May 2015 01:31:43 +0900 (JST)
Message-Id: <20150511.013143.706881749197692581.konishi.ryusuke@lab.ntt.co.jp>
To: NeilBrown <neilb@suse.de>
Cc: Josef Bacik <jbacik@fb.com>, Chris Mason <clm@fb.com>,
        Jan Kara <jack@suse.cz>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-nilfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NILFS2: support NFSv2 export
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
In-Reply-To: <20150508001623.31129.25102.stgit@notabene.brown>
References: <20150508001142.31129.7604.stgit@notabene.brown>
	<20150508001623.31129.25102.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 May 2015 10:16:23 +1000, NeilBrown <neilb@suse.de> wrote:
> The "fh_len" passed to ->fh_to_* is not guaranteed to be that same as
> that returned by encode_fh - it may be larger.
> 
> With NFSv2, the filehandle is fixed length, so it may appear longer
> than expected and be zero-padded.
> 
> So we must test that fh_len is at least some value, not exactly equal
> to it.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nilfs2/namei.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nilfs2/namei.c b/fs/nilfs2/namei.c
> index 22180836ec22..b65fb79d16fd 100644
> --- a/fs/nilfs2/namei.c
> +++ b/fs/nilfs2/namei.c
> @@ -496,8 +496,8 @@ static struct dentry *nilfs_fh_to_dentry(struct super_block *sb, struct fid *fh,
>  {
>  	struct nilfs_fid *fid = (struct nilfs_fid *)fh;
>  
> -	if ((fh_len != NILFS_FID_SIZE_NON_CONNECTABLE &&
> -	     fh_len != NILFS_FID_SIZE_CONNECTABLE) ||

> +	if ((fh_len < NILFS_FID_SIZE_NON_CONNECTABLE &&
> +	     fh_len < NILFS_FID_SIZE_CONNECTABLE) ||
>  	    (fh_type != FILEID_NILFS_WITH_PARENT &&
>  	     fh_type != FILEID_NILFS_WITHOUT_PARENT))
>  		return NULL;

A bit weird.  "fh_len < NILFS_FID_SIZE_CONNECTABLE" implies "fh_len <
NILFS_FID_SIZE_NON_CONNECTABLE".

How about the following fix ?

	if ((fh_type != FILEID_NILFS_WITH_PARENT ||
	     fh_len < NILFS_FID_SIZE_CONNECTABLE) &&
	    (fh_type != FILEID_NILFS_WITHOUT_PARENT ||
	     fh_len < NILFS_FID_SIZE_NON_CONNECTABLE))
		return NULL;

Regards,
Ryusuke Konishi

> @@ -510,7 +510,7 @@ static struct dentry *nilfs_fh_to_parent(struct super_block *sb, struct fid *fh,
>  {
>  	struct nilfs_fid *fid = (struct nilfs_fid *)fh;
>  
> -	if (fh_len != NILFS_FID_SIZE_CONNECTABLE ||
> +	if (fh_len < NILFS_FID_SIZE_CONNECTABLE ||
>  	    fh_type != FILEID_NILFS_WITH_PARENT)
>  		return NULL;
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nilfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
