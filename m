Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:46736 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbaK1BRz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Nov 2014 20:17:55 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so4195474qcx.17
        for <linux-nfs@vger.kernel.org>; Thu, 27 Nov 2014 17:17:55 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 27 Nov 2014 20:17:53 -0500
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: minor off by one checks in __write_versions()
Message-ID: <20141127201753.26753f9d@tlielax.poochiereds.net>
In-Reply-To: <20141127155854.GB21914@mwanda>
References: <20141127155854.GB21914@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 27 Nov 2014 18:58:54 +0300
Dan Carpenter <dan.carpenter@oracle.com> wrote:

> My static checker complains that if "len == remaining" then it means we
> have truncated the last character off the version string.
> 
> The intent of the code is that we print as many versions as we can
> without truncating a version.  Then we put a newline at the end.  If the
> newline can't fit we return -EINVAL.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 9506ea5..19ace74 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -608,7 +608,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  				       num);
>  			sep = " ";
>  
> -			if (len > remaining)
> +			if (len >= remaining)
>  				break;
>  			remaining -= len;
>  			buf += len;
> @@ -623,7 +623,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  						'+' : '-',
>  					minor);
>  
> -			if (len > remaining)
> +			if (len >= remaining)
>  				break;
>  			remaining -= len;
>  			buf += len;
> @@ -631,7 +631,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
>  		}
>  
>  	len = snprintf(buf, remaining, "\n");
> -	if (len > remaining)
> +	if (len >= remaining)
>  		return -EINVAL;
>  	return tlen + len;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks correct. Good catch.

Reviewed-by: Jeff Layton <jlayton@primarydata.com>
