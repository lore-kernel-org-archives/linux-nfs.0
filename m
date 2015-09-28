Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45877 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbI1Sr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 14:47:27 -0400
Date: Mon, 28 Sep 2015 11:46:18 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        mtk.manpages@gmail.com, andros@netapp.com, hch@infradead.org
Subject: Re: [PATCH v3 5/9] vfs: Copy shouldn't forbid ranges inside the same
 file
Message-ID: <20150928184618.GD850@birch.djwong.org>
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443214096-12769-6-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443214096-12769-6-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 25, 2015 at 04:48:11PM -0400, Anna Schumaker wrote:
> This is perfectly valid for BTRFS and XFS, so let's leave this up to
> filesystems to check.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> Reviewed-by: David Sterba <dsterba@suse.com>

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/read_write.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index f3d6c48..8e7cb33 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1371,10 +1371,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	    file_in->f_path.mnt != file_out->f_path.mnt)
>  		return -EXDEV;
>  
> -	/* forbid ranges in the same file */
> -	if (inode_in == inode_out)
> -		return -EINVAL;
> -
>  	if (len == 0)
>  		return 0;
>  
> -- 
> 2.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
