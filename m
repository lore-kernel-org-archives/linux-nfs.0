Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36790 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbcLEU2O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2016 15:28:14 -0500
Received: by mail-yw0-f193.google.com with SMTP id r204so27204643ywb.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2016 12:28:13 -0800 (PST)
Subject: Re: [PATCH] NFS: Fix incorrect size revalidation when holding a
 delegation
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <20161204231008.31396-1-trond.myklebust@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <56cfbea2-4267-b39d-7bf2-e4c38c4abcff@gmail.com>
Date: Mon, 5 Dec 2016 15:28:11 -0500
MIME-Version: 1.0
In-Reply-To: <20161204231008.31396-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 12/04/2016 06:10 PM, Trond Myklebust wrote:
> We should only care about checking the attributes if the page cache
> is marked as dubious (using NFS_INO_REVAL_PAGECACHE) and the
> NFS_INO_REVAL_FORCED flag is set.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/file.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 9ea85ae23c32..64c11f399b3d 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -102,8 +102,11 @@ static int nfs_revalidate_file_size(struct inode *inode, struct file *filp)
>  {
>  	struct nfs_server *server = NFS_SERVER(inode);
>  	struct nfs_inode *nfsi = NFS_I(inode);
> +	const unsigned long force_reval = NFS_INO_REVAL_PAGECACHE|NFS_INO_REVAL_FORCED;

Would it make sense to declare this in a header file somewhere, rather than repeating this in file.c and inode.c? (and any other places we might need to "force_reval" in the future?)

Anna

> +	unsigned long cache_validity = nfsi->cache_validity;
>  
> -	if (nfs_have_delegated_attributes(inode))
> +	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) &&
> +	    (cache_validity & force_reval) != force_reval)
>  		goto out_noreval;
>  
>  	if (filp->f_flags & O_DIRECT)
> 
