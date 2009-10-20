From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Tue, 20 Oct 2009 17:12:25 +0200
Message-ID: <4ADDD359.4090308@panasas.com>
References: <4ADDCA9A.3060004@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:32786 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751149AbZJTPMX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 11:12:23 -0400
In-Reply-To: <4ADDCA9A.3060004@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/20/2009 04:35 PM, Boaz Harrosh wrote:
> linux/nfsd/nfsfh.h defines some low level types which
> are needed by exportfs and though by filesystems.
>
> In the file, fh_lock() uses the sunrpc dprint facility which
> might cause a dependency of exportfs (and filesystems) on
> sunrpc which is unwanted.
>
> Remove the debug-print from fh_lock() and avoid this dependency.
>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>   
Bruce hi.

In light of the new patches Benny sent, and the new exportfs + xdr
facilities,
would you like this patch? Is that debugging-print still useful?

If you absolutely do need it, or anticipate other debugging needs, I
would like
to cook something special for exportfs + xdr guys and move nfsfh stuff
to that
debugging-prints.

Benny If this patch is accepted then we don't need the last patch I sent.

Thanks
Boaz

> ---
>  include/linux/nfsd/nfsfh.h |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
> index 94c1aee..b91760c 100644
> --- a/include/linux/nfsd/nfsfh.h
> +++ b/include/linux/nfsd/nfsfh.h
> @@ -20,7 +20,6 @@
>  # include <linux/fs.h>
>  #endif
>  #include <linux/nfsd/const.h>
> -#include <linux/nfsd/debug.h>
>  
>  /*
>   * This is the old "dentry style" Linux NFSv2 file handle.
> @@ -330,9 +329,6 @@ fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
>  	struct dentry	*dentry = fhp->fh_dentry;
>  	struct inode	*inode;
>  
> -	dfprintk(FILEOP, "nfsd: fh_lock(%s) locked = %d\n",
> -			SVCFH_fmt(fhp), fhp->fh_locked);
> -
>  	BUG_ON(!dentry);
>  
>  	if (fhp->fh_locked) {
>   

