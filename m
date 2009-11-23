From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/6] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Mon, 23 Nov 2009 17:17:05 -0500
Message-ID: <20091123221705.GF8534@fieldses.org>
References: <4B0AB039.6020608@panasas.com> <1258991910-25335-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45634 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757307AbZKWWQY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 17:16:24 -0500
In-Reply-To: <1258991910-25335-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2009 at 05:58:30PM +0200, Boaz Harrosh wrote:
> linux/nfsd/nfsfh.h defines some low level types which
> are needed by exportfs and though by filesystems.
> 
> In the file, fh_lock() uses the sunrpc dprint facility which
> might cause a dependency of exportfs (and filesystems) on

"might cause"?

Does mere inclusion of this .h (without referencing fh_lock_nested() or
its callers) actually create a dependency?

--b.

> sunrpc which is unwanted / unexpected.
> 
> Remove the debug-print from fh_lock() and avoid this dependency.
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
