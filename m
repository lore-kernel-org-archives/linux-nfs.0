From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 14/24] pnfs_submit: use fsdata to pass lseg
Date: Wed, 09 Jun 2010 22:33:20 +0300
Message-ID: <4C0FEC80.1070908@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-2-git-send-email-iisaman@netapp.com> <1275970761-31806-3-git-send-email-iisaman@netapp.com> <1275970761-31806-4-git-send-email-iisaman@netapp.com> <1275970761-31806-5-git-send-email-iisaman@netapp.com> <1275970761-31806-6-git-send-email-iisaman@netapp.com> <1275970761-31806-7-git-send-email-iisaman@netapp.com> <1275970761-31806-8-git-send-email-iisaman@netapp.com> <1275970761-31806-9-git-send-email-iisaman@netapp.com> <1275970761-31806-10-git-send-email-iisaman@netapp.com> <1275970761-31806-11-git-send-email-iisaman@netapp.com> <1275970761-31806-12-git-send-email-iisaman@netapp.com> <1275970761-31806-13-git-send-email-iisaman@netapp.com> <1275970761-31806-14-git-send-email-iisaman@netapp.com> <1275970761-3
 1806-15-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45336 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757000Ab0FITdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 15:33:23 -0400
In-Reply-To: <1275970761-31806-15-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2010 07:19 AM, Fred Isaman wrote:
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

All files write layout?

Please lets separate this in two parts.
A) Something we can all test and should be clean and better then today.
B) B to A revert patch.

I'd say ask for the pages index. Server can set policy, just fine.

What if I write to an hole at 4Gb you still want offset zero?

(BTW the order of params to pnfs_update_layout is all wrong)

Boaz

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

