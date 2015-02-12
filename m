Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bh-25.webhostbox.net ([208.91.199.152]:44162 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbbBLXCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 18:02:15 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YM2ly-001qbP-1w
	for linux-nfs@vger.kernel.org; Thu, 12 Feb 2015 23:02:14 +0000
Date: Thu, 12 Feb 2015 15:02:01 -0800
From: Guenter Roeck <linux@roeck-us.net>
To: Bas Peters <baspeters93@gmail.com>
Cc: bfields@fieldses.org, hch@lst.de, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Subject: Re: [PATCH] fs: nfsd:xdr4.h: add missing conditional group
 CONFIG_NFSD_V3
Message-ID: <20150212230201.GB17998@roeck-us.net>
References: <1423778953-28307-1-git-send-email-baspeters93@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1423778953-28307-1-git-send-email-baspeters93@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 12, 2015 at 11:09:13PM +0100, Bas Peters wrote:
> This patch adds a missing conditional group that has been causing build
> breakages due to undefined struct members being referenced when
> CONFIG_NFSD_v3 is not set.
> 
> This patch applies against linux-next.
> 
> Signed-off-by: Bas Peters <baspeters93@gmail.com>
> ---
>  fs/nfsd/xdr4.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 0bda93e..5d1597f 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -630,9 +630,11 @@ void warn_on_nonidempotent_op(struct nfsd4_op *op);
>  static inline void
>  set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
>  {
> +	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
> +
> +#ifdef CONFIG_NFSD_V3
>  	BUG_ON(!fhp->fh_pre_saved);
>  	cinfo->atomic = fhp->fh_post_saved;
> -	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
>  
>  	cinfo->before_change = fhp->fh_pre_change;
>  	cinfo->after_change = fhp->fh_post_change;
> @@ -640,7 +642,7 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
>  	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
>  	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
>  	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
> -
> +#endif
>  }

You'll want to include and example of the build failure in the description,
bisect results after the '---' line, and a Fixes: line pointing to the patch
breaking the build.

In this case, I am not sure if the above really fixes the problem,
or if it just hides it behind an #ifdef. To determine that, it will
probably be necessary to know which patch actually caused the problem.
This even more true since the code in question was not changed since 
around 2010, so making it conditional looks really suspicious.

In the curent case, I suspect that the problem may have been introduced by
commit 9cf514ccfac ("nfsd: implement pNFS operations"). That is just a guess,
though; I didn't run bisect myself. The key really is to figure out why the
code now fails to build, and not just to comment out the code that is causing
the failure.

Thanks,
Guenter
