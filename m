Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56123 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244Ab3LEO5Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 09:57:25 -0500
Date: Thu, 5 Dec 2013 09:57:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: get rid of unused function definition
Message-ID: <20131205145723.GB30113@fieldses.org>
References: <529FEDE8.50207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529FEDE8.50207@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Thu, Dec 05, 2013 at 11:07:20AM +0800, Kinglong Mee wrote:
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/vfs.h | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index a4be2e3..fd8c0cc 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -89,8 +89,6 @@ __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
>  __be32		nfsd_rename(struct svc_rqst *,
>  				struct svc_fh *, char *, int,
>  				struct svc_fh *, char *, int);
> -__be32		nfsd_remove(struct svc_rqst *,
> -				struct svc_fh *, char *, int);
>  __be32		nfsd_unlink(struct svc_rqst *, struct svc_fh *, int type,
>  				char *name, int len);
>  __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
> -- 
> 1.8.4.2
