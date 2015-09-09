Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39814 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986AbbIIJT0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 05:19:26 -0400
Date: Wed, 9 Sep 2015 11:18:39 +0200
From: David Sterba <dsterba@suse.cz>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v1 4/8] btrfs: Add mountpoint checking during
 btrfs_copy_file_range
Message-ID: <20150909091838.GE8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1441397823-1203-5-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441397823-1203-5-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 04, 2015 at 04:16:58PM -0400, Anna Schumaker wrote:
> We need to verify that both the source and the destination files are
> part of the same filesystem, otherwise we can't create a reflink.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/btrfs/ioctl.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
> index 62ae286..9c0c955 100644
> --- a/fs/btrfs/ioctl.c
> +++ b/fs/btrfs/ioctl.c
> @@ -3856,6 +3856,10 @@ ssize_t btrfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>  	ssize_t ret;
>  
> +	if (inode_in->i_sb != inode_out->i_sb ||
> +	    file_in->f_path.mnt != file_out->f_path.mnt)
> +		return -EXDEV;

The same check exists in btrfs_clone_files (added in the previous
patch), what's the reason to add it here again?

> +
>  	ret = btrfs_clone_files(file_out, file_in, pos_in, len, pos_out);
