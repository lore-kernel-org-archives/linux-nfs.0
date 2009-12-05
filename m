From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 01/12] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Fri, 4 Dec 2009 20:01:02 -0500
Message-ID: <20091205010102.GD22497@fieldses.org>
References: <4B1802D0.8060206@panasas.com> <1259864884-4661-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46622 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757576AbZLEA7x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 19:59:53 -0500
In-Reply-To: <1259864884-4661-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2009 at 08:28:04PM +0200, Boaz Harrosh wrote:
> linux/nfsd/nfsfh.h defines some low level types which
> are needed by exportfs and though by filesystems.
> 
> In the file, fh_lock() uses the sunrpc dprint facility which
> might cause a dependency of exportfs (and filesystems) on
> sunrpc which is unwanted / unexpected.
> 
> Remove the debug-print from fh_lock() and avoid this dependency.

"might cause a dependency" is a little vague.

Applied but just with the comment that we don't seem to use the dprintk
anyway.

--b.

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  include/linux/nfsd/nfsfh.h |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
> index 8f641c9..2973e11 100644
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
> @@ -329,9 +328,6 @@ fh_lock_nested(struct svc_fh *fhp, unsigned int subclass)
>  	struct dentry	*dentry = fhp->fh_dentry;
>  	struct inode	*inode;
>  
> -	dfprintk(FILEOP, "nfsd: fh_lock(%s) locked = %d\n",
> -			SVCFH_fmt(fhp), fhp->fh_locked);
> -
>  	BUG_ON(!dentry);
>  
>  	if (fhp->fh_locked) {
> -- 
> 1.6.5.2
> 
