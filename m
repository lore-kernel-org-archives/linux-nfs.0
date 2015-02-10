Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:44769 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543AbbBJNmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2015 08:42:39 -0500
Received: by iecar1 with SMTP id ar1so1753378iec.11
        for <linux-nfs@vger.kernel.org>; Tue, 10 Feb 2015 05:42:39 -0800 (PST)
Message-ID: <1423575756.4226.0.camel@primarydata.com>
Subject: Re: [patch] pnfs: delete an unintended goto
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Date: Tue, 10 Feb 2015 08:42:36 -0500
In-Reply-To: <20150210080322.GA8762@mwanda>
References: <20150210080322.GA8762@mwanda>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-02-10 at 11:03 +0300, Dan Carpenter wrote:
> There was an extra goto here where it shouldn't be, because of a merge
> error.
> 
> Fixes: e2c63e091e29 ('Merge branch 'flexfiles'')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 107b321..4f802b02 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1078,7 +1078,6 @@ bool pnfs_roc(struct inode *ino)
>  			goto out_noroc;
>  	}
>  
> -		goto out_noroc;
>  	pnfs_clear_retry_layoutget(lo);
>  	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
>  		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {

Thanks Dan! Applied to linux-next.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




