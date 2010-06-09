From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 14/24] pnfs_submit: use fsdata to pass lseg
Date: Wed, 09 Jun 2010 13:38:09 +0300
Message-ID: <4C0F6F11.7050602@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-2-git-send-email-iisaman@netapp.com> <1275970761-31806-3-git-send-email-iisaman@netapp.com> <1275970761-31806-4-git-send-email-iisaman@netapp.com> <1275970761-31806-5-git-send-email-iisaman@netapp.com> <1275970761-31806-6-git-send-email-iisaman@netapp.com> <1275970761-31806-7-git-send-email-iisaman@netapp.com> <1275970761-31806-8-git-send-email-iisaman@netapp.com> <1275970761-31806-9-git-send-email-iisaman@netapp.com> <1275970761-31806-10-git-send-email-iisaman@netapp.com> <1275970761-31806-11-git-send-email-iisaman@netapp.com> <1275970761-31806-12-git-send-email-iisaman@netapp.com> <1275970761-31806-13-git-send-email-iisaman@netapp.com> <1275970761-31806-14-git-send-email-iisaman@netapp.com> <1275970761-3
 1806-15-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39610 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757369Ab0FIKiO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 06:38:14 -0400
Received: by bwz11 with SMTP id 11so1505604bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jun 2010 03:38:12 -0700 (PDT)
In-Reply-To: <1275970761-31806-15-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fred, how does that patch interact with
285052f pnfs_post_submit: Restore "pnfs: pnfs_do_flush"
and the latter patches that depend on it?

Benny

On Jun. 08, 2010, 7:19 +0300, Fred Isaman <iisaman@netapp.com> wrote:
> Preparing for LAYUTGET invocation in nfs_write_begin to be the
> only invocation in the write path.
> 
> It isn't used at all yet, but it should be properly referenced/dereferenced
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/file.c |   16 +++++++++++++---
>  1 files changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 03601d2..fde6cb5 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -420,6 +420,8 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>  		file->f_path.dentry->d_name.name,
>  		mapping->host->i_ino, len, (long long) pos);
>  
> +	pnfs_update_layout(mapping->host, NULL, NFS4_MAX_UINT64, 0, IOMODE_RW,
> +			   (struct pnfs_layout_segment **) fsdata);
>  start:
>  	/*
>  	 * Prevent starvation issues if someone is doing a consistency
> @@ -428,11 +430,13 @@ start:
>  	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
>  			nfs_wait_bit_killable, TASK_KILLABLE);
>  	if (ret)
> -		return ret;
> +		goto out;
>  
>  	page = grab_cache_page_write_begin(mapping, index, flags);
> -	if (!page)
> -		return -ENOMEM;
> +	if (!page) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
>  	*pagep = page;
>  
>  	ret = nfs_flush_incompatible(file, page);
> @@ -447,6 +451,11 @@ start:
>  		if (!ret)
>  			goto start;
>  	}
> + out:
> +	if (ret) {
> +		put_lseg(*fsdata);
> +		*fsdata = NULL;
> +	}
>  	return ret;
>  }
>  
> @@ -486,6 +495,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
>  
>  	unlock_page(page);
>  	page_cache_release(page);
> +	put_lseg(fsdata);
>  
>  	if (status < 0)
>  		return status;

