Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34109 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655AbbHDKna (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 06:43:30 -0400
Received: by pawu10 with SMTP id u10so5640276paw.1
        for <linux-nfs@vger.kernel.org>; Tue, 04 Aug 2015 03:43:29 -0700 (PDT)
Subject: Re: [PATCH 3/7 v2] NFS: Check size by inode_newsize_ok in nfs_setattr
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55BA290B.2020704@gmail.com> <55BA2936.4030404@gmail.com>
 <55BA2996.9030804@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55C0973A.5020700@gmail.com>
Date: Tue, 4 Aug 2015 18:43:06 +0800
MIME-Version: 1.0
In-Reply-To: <55BA2996.9030804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/30/2015 21:41, Kinglong Mee wrote:
> Set rlimit for NFS's files is useless right now.
> For local process's rlimit, it should be checked by nfs client.
> 
> The same, CIFS also call inode_change_ok checking rlimit at its client
> in cifs_setattr_nounix() and cifs_setattr_unix().
> 
> v2, same as v1.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/inode.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 0adc7d2..9304dfd 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -513,15 +513,14 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
>  		attr->ia_valid &= ~ATTR_MODE;
>  
>  	if (attr->ia_valid & ATTR_SIZE) {
> -		loff_t i_size;
> -
>  		BUG_ON(!S_ISREG(inode->i_mode));
>  
> -		i_size = i_size_read(inode);
> -		if (attr->ia_size == i_size)
> +		error = inode_newsize_ok(inode, attr->ia_size);
> +		if (error)
> +			return error;

So sorry!

Use "error" will cause a bug for the following code of error out.
I will update it in the new version.

thanks,
Kinglong Mee
