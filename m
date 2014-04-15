Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f182.google.com ([209.85.214.182]:42132 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbaDOO1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 10:27:19 -0400
Received: by mail-ob0-f182.google.com with SMTP id uz6so10770067obc.41
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 07:27:18 -0700 (PDT)
Message-ID: <1397572034.4709.2.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: Fix memroy leak for double mounts
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org
Date: Tue, 15 Apr 2014 10:27:14 -0400
In-Reply-To: <534CFA73.4040801@gmail.com>
References: <534CFA73.4040801@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-04-15 at 17:22 +0800, Kinglong Mee wrote:
> When double mounting same nfs filesystem, the devname saved in d_fsdata
> will be lost.The second mount should not change the devname that
> be saved in d_fsdata.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/getroot.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
> index 66984a9..b94f804 100644
> --- a/fs/nfs/getroot.c
> +++ b/fs/nfs/getroot.c
> @@ -120,7 +120,8 @@ struct dentry *nfs_get_root(struct super_block *sb,
> struct nfs_fh *mntfh,
> 
>  	security_d_instantiate(ret, inode);
>  	spin_lock(&ret->d_lock);
> -	if (IS_ROOT(ret) && !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
> +	if (IS_ROOT(ret) && !ret->d_fsdata &&
> +	    !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
>  		ret->d_fsdata = name;
>  		name = NULL;
>  	}

Applied. Thanks!

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


