Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60311 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbaDRNCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 09:02:21 -0400
Date: Fri, 18 Apr 2014 09:02:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Checking whether kill_suid by should_remove_suid()
Message-ID: <20140418130220.GF18612@fieldses.org>
References: <534AA92B.8010805@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <534AA92B.8010805@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 13, 2014 at 11:11:39PM +0800, Kinglong Mee wrote:
> As local filesystem, writing data to the file by non-owner will
> clears the SUID+SGID, owner will not.

Are you sure about this?  (Do you have a test case that fails?)

I don't see an owner check in should_remove_suid.

And I think that an nfsd thread will always have CAP_FSETID set (see
cap_raise_nfsd_set and the definition of CAP_NFSD_SET), so that
should_remove_suid() will always return 0.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/vfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 16f0673..19c0931 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -943,7 +943,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh
> *fhp, struct file *file,
>  	fsnotify_modify(file);
> 
>  	/* clear setuid/setgid flag after write */
> -	if (inode->i_mode & (S_ISUID | S_ISGID))
> +	if (should_remove_suid(dentry))
>  		kill_suid(dentry);
> 
>  	if (stable) {
> -- 
> 1.9.0
> 
