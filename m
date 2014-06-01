Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:65017 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbaFAJKT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Jun 2014 05:10:19 -0400
Received: by mail-wi0-f179.google.com with SMTP id bs8so3141232wib.6
        for <linux-nfs@vger.kernel.org>; Sun, 01 Jun 2014 02:10:17 -0700 (PDT)
Message-ID: <538AEDF6.8040301@gmail.com>
Date: Sun, 01 Jun 2014 12:10:14 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
CC: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] pNFS: Handle allocation errors correctly in objlayout_alloc_layout_hdr()
References: <1401409758-8035-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1401409758-8035-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/30/2014 03:29 AM, Trond Myklebust wrote:
> Return the NULL pointer when the allocation fails.
> 
> Cc: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/objlayout/objlayout.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index 2f955f671003..765d3f54e986 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -53,10 +53,10 @@ objlayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
>  	struct objlayout *objlay;
>  
>  	objlay = kzalloc(sizeof(struct objlayout), gfp_flags);
> -	if (objlay) {
> -		spin_lock_init(&objlay->lock);
> -		INIT_LIST_HEAD(&objlay->err_list);
> -	}
> +	if (!objlay)
> +		return NULL;
> +	spin_lock_init(&objlay->lock);
> +	INIT_LIST_HEAD(&objlay->err_list);
>  	dprintk("%s: Return %p\n", __func__, objlay);
>  	return &objlay->pnfs_layout;
>  }
> 

Thanks! ACK

BTW it was not a bug. &NULL->pnfs_layout will return 0 because it is at offset 0.
Which explains why it works.

Thanks again, good catch
Boaz

