Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15656 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab1FJDtm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 23:49:42 -0400
Message-ID: <4DF1944D.50806@panasas.com>
Date: Thu, 09 Jun 2011 23:49:33 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH 1/2] nfsd4: fix break_lease flags on nfsd open
References: <20110609224459.GA22215@fieldses.org>
In-Reply-To: <20110609224459.GA22215@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-09 18:44, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> Thanks to Casey Bodley for pointing out that on a read open we pass 0,
> instead of O_RDONLY, to break_lease, with the result that a read open is
> treated like a write open for the purposes of lease breaking!
> 
> Reported-by: Casey Bodley <cbodley@citi.umich.edu>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/vfs.c |   15 +++++++++------
>  1 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f3fb61b..848a4af 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -696,7 +696,15 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
>  }
>  #endif /* CONFIG_NFSD_V3 */
>  
> +static int nfsd_open_break_lease(struct inode *inode, int access)
> +{
> +	unsigned int mode;
>  
> +	if (access & NFSD_MAY_NOT_BREAK_LEASE)
> +		return 0;
> +	mode = (access & NFSD_MAY_WRITE) ? O_WRONLY : O_RDONLY;
> +	return break_lease(inode, mode | O_NONBLOCK);
> +}
>  
>  /*
>   * Open an existing file or directory.
> @@ -744,12 +752,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
>  	if (!inode->i_fop)
>  		goto out;
>  
> -	/*
> -	 * Check to see if there are any leases on this file.
> -	 * This may block while leases are broken.
> -	 */
> -	if (!(access & NFSD_MAY_NOT_BREAK_LEASE))
> -		host_err = break_lease(inode, O_NONBLOCK | ((access & NFSD_MAY_WRITE) ? O_WRONLY : 0));
> +	 host_err = nfsd_open_break_lease(inode, access);

nit: looks like there's an extra space before "host_err ="...

Benny

>  	if (host_err) /* NOMEM or WOULDBLOCK */
>  		goto out_nfserr;
>  
