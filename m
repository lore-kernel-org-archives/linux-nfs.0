From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch for 2.6.30? 1/1] lockd: fix FILE_LOCKING=n build error
Date: Wed, 13 May 2009 15:59:53 -0400
Message-ID: <20090513195953.GF13420@fieldses.org>
References: <200905122047.n4CKlP24029339@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	randy.dunlap@oracle.com
To: akpm@linux-foundation.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44221 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597AbZEMT76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 15:59:58 -0400
In-Reply-To: <200905122047.n4CKlP24029339-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 12, 2009 at 01:28:09PM -0700, akpm@linux-foundation.org wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> lockd/svclock.c is missing a header file <linux/fs.h>.
> 
> <linux/fs.h> is missing a definition of locks_release_private()
> for the config case of FILE_LOCKING=n, causing a build error:
> 
> fs/lockd/svclock.c:330: error: implicit declaration of function 'locks_release_private'
> 

Thanks, applied for 2.6.31.

--b.

> lockd without FILE_LOCKING doesn't make sense, so make LOCKD and LOCKD_V4
> depend on FILE_LOCKING, and make NFS depend on FILE_LOCKING.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Bruce Fields <bfields@fieldses.org>
> Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/Kconfig     |    2 ++
>  fs/nfs/Kconfig |    2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff -puN fs/Kconfig~lockd-fix-file_locking=n-build-error fs/Kconfig
> --- a/fs/Kconfig~lockd-fix-file_locking=n-build-error
> +++ a/fs/Kconfig
> @@ -236,10 +236,12 @@ source "fs/nfsd/Kconfig"
>  
>  config LOCKD
>  	tristate
> +	depends on FILE_LOCKING
>  
>  config LOCKD_V4
>  	bool
>  	depends on NFSD_V3 || NFS_V3
> +	depends on FILE_LOCKING
>  	default y
>  
>  config EXPORTFS
> diff -puN fs/nfs/Kconfig~lockd-fix-file_locking=n-build-error fs/nfs/Kconfig
> --- a/fs/nfs/Kconfig~lockd-fix-file_locking=n-build-error
> +++ a/fs/nfs/Kconfig
> @@ -1,6 +1,6 @@
>  config NFS_FS
>  	tristate "NFS client support"
> -	depends on INET
> +	depends on INET && FILE_LOCKING
>  	select LOCKD
>  	select SUNRPC
>  	select NFS_ACL_SUPPORT if NFS_V3_ACL
> _
