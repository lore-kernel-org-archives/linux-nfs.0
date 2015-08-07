Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33549 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbbHGPaZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 11:30:25 -0400
Received: by pabyb7 with SMTP id yb7so58130290pab.0
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2015 08:30:24 -0700 (PDT)
Subject: Re: [PATCH v2 06/18] nfsd: hook up nfsd_read to the nfsd_file cache
To: Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-7-git-send-email-jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55C4CEF0.6040004@gmail.com>
Date: Fri, 7 Aug 2015 23:29:52 +0800
MIME-Version: 1.0
In-Reply-To: <1438809216-4846-7-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 8/6/2015 05:13, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/vfs.c | 20 +++++++-------------
>  1 file changed, 7 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 59234d1d8d8e..fd688c86af66 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -980,20 +980,14 @@ out_nfserr:
>  __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
>  {
> -	struct file *file;
> -	struct raparms	*ra;
> -	__be32 err;
> -
> -	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
> -	if (err)
> -		return err;
> -
> -	ra = nfsd_init_raparms(file);
> -	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
> -	if (ra)
> -		nfsd_put_raparams(file, ra);

Drop the raparms here ?

thanks,
Kinglong Mee

> -	fput(file);
> +	__be32			err;
> +	struct nfsd_file	*nf;
>  
> +	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
> +	if (err == nfs_ok)
> +		err = nfsd_vfs_read(rqstp, nf->nf_file, offset, vec, vlen,
> +					count);
> +	nfsd_file_put(nf);
>  	return err;
>  }
>  
> 
