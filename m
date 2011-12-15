Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46574 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab1LOKmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 05:42:51 -0500
Message-ID: <4EE9CF1D.6030109@panasas.com>
Date: Thu, 15 Dec 2011 12:42:37 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Maxim Uvarov <maxim.uvarov@oracle.com>,
        NFS list <linux-nfs@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on nfs
References: <1323901667-3746-1-git-send-email-maxim.uvarov@oracle.com>
In-Reply-To: <1323901667-3746-1-git-send-email-maxim.uvarov@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forwarding to the NFS mailing list ...

On 12/15/2011 12:27 AM, Maxim Uvarov wrote:
> This issue was introduced with LTP inotify02 test.
> If file system is not NFS user inotify application
> gets IN_DELETE event. But on NFS code avoids d_delete()
> which sends this event. This patch makes notification
> on NFS the same as non-NFS. I.e. vfs_unlink still avoids
> deletion but it sends event for NFS sillyrenamed files.
> More details here:
> https://lkml.org/lkml/2011/11/29/421
> 
> Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>
> ---
>  fs/namei.c |   19 ++++++++++++++++---
>  1 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index a9a7166..44a997e 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -2737,10 +2737,23 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
>  	}
>  	mutex_unlock(&dentry->d_inode->i_mutex);
>  
> -	/* We don't d_delete() NFS sillyrenamed files--they still exist. */
> -	if (!error && !(dentry->d_flags & DCACHE_NFSFS_RENAMED)) {
> +
> +	if (!error) {
>  		fsnotify_link_count(dentry->d_inode);
> -		d_delete(dentry);
> +		if (!(dentry->d_flags & DCACHE_NFSFS_RENAMED))
> +			d_delete(dentry);
> +		else {
> +			/* We don't d_delete() NFS sillyrenamed files - they
> +			 * still exist. But from user side this file was
> +			 * deleted. So that we need to generate notify event
> +			 * about it.
> +			 */
> +			struct inode *inode;
> +			int isdir;
> +			inode = dentry->d_inode;
> +			isdir = S_ISDIR(inode->i_mode);
> +			fsnotify_nameremove(dentry, isdir);
> +		}
>  	}
>  
>  	return error;

