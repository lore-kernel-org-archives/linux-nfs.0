Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:34253 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393AbcFPOET (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 10:04:19 -0400
Received: by mail-yw0-f175.google.com with SMTP id c72so43420222ywb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2016 07:04:18 -0700 (PDT)
Message-ID: <1466085855.3079.1.camel@redhat.com>
Subject: Re: [PATCH] NFS: Fix potential race in nfs_fhget()
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Date: Thu, 16 Jun 2016 10:04:15 -0400
In-Reply-To: <1466021128-62407-1-git-send-email-trond.myklebust@primarydata.com>
References: <1466021128-62407-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-06-15 at 16:05 -0400, Trond Myklebust wrote:
> If we don't set the mode correctly in nfs_init_locked(), then there
> is
> potential for a race with a second call to nfs_fhget that will cause
> inode aliasing.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/inode.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 52e7d6869e3b..dda689d7a8a7 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -282,6 +282,7 @@ nfs_init_locked(struct inode *inode, void
> *opaque)
>  	struct nfs_fattr	*fattr = desc->fattr;
>  
>  	set_nfs_fileid(inode, fattr->fileid);
> +	inode->i_mode = fattr->mode;
>  	nfs_copy_fh(NFS_FH(inode), desc->fh);
>  	return 0;
>  }

Good catch!

Reviewed-by: Jeff Layton <jlayton@redhat.com>
