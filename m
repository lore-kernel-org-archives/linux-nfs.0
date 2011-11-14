Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38861 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab1KNLPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 06:15:03 -0500
Received: by fagn18 with SMTP id n18so2879237fag.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 03:15:02 -0800 (PST)
Message-ID: <4EC0F831.2060200@tonian.com>
Date: Mon, 14 Nov 2011 13:14:57 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Benny Halevy <benny@tonian.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: pnfsd: Don't call fs_layout_return on a none-file
References: <4EBC5538.7010002@panasas.com>
In-Reply-To: <4EBC5538.7010002@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-11 00:50, Boaz Harrosh wrote:
> 
> If we had a layout on the file the nfs4_file would be referenced and we should
> have found it. Since we don't then it means all layouts where ROC and at this
> point we returned all of them on file close.
> 
> So why does the Linux wonderful forgetfull client returnes it's ROC layouts on
> inode evict() (I hit this on umount at client). Actually this is on me, because
> it is a bug in Generic client code, but can only manifest with pnf-obj after an
> IO error.
> 
> Sign-off-by: Boaz Harrosh
> ---
>  fs/nfsd/nfs4pnfsd.c |   13 ++++++++++++-
>  1 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index f30fa65..eb4a044 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -1109,7 +1109,15 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
>  			printk(KERN_ERR "%s: RETURN_FILE: no nfs4_file for "
>  				"ino %p:%lu\n",
>  				__func__, ino, ino ? ino->i_ino : 0L);
> -			goto out;
> +			/* If we had a layout on the file the nfs4_file would
> +			 * be referenced and we should have found it. Since we
> +			 * don't then it means all layouts where ROC and at this

I'll s/where/were/

> +			 * point we returned all of them on file close.
> +			 * TODO:
> +			 * Benny this is what Bruce calls a client spam, we might
> +			 * want to degrade the print level to dprintk.

Agreed, if this case is not an exception no need to shout about it.
I'll make this change.

Benny

> +			 */
> +			goto out_no_fs_call;
>  		}
>  
>  		/* Check the stateid */
> @@ -1163,6 +1173,7 @@ out:
>  	/* call exported filesystem layout_return (ignore return-code) */
>  	fs_layout_return(sb, ino, lrp, 0, recall_cookie);
>  
> +out_no_fs_call:
>  	dprintk("pNFS %s: exit status %d \n", __func__, status);
>  	return status;
>  }
