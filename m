From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/11] NFSD: Move "select FS_POSIX_ACL if NFSD_V4"
Date: Tue, 12 Feb 2008 17:33:31 -0500
Message-ID: <20080212223331.GQ18625@fieldses.org>
References: <20080211221224.1047.77017.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42109 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbYBLWdj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 17:33:39 -0500
In-Reply-To: <20080211221224.1047.77017.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 05:12:24PM -0500, Chuck Lever wrote:
> Clean up: since FS_POSIX_ACL is a non-visible boolean entry, it can be
> selected safely under the NFSD_V4 entry (also a boolean).

I've applied this too.--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 9ee288f..e94ca09 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -411,7 +411,7 @@ config JFS_STATISTICS
>  	  to be made available to the user in the /proc/fs/jfs/ directory.
>  
>  config FS_POSIX_ACL
> -# Posix ACL utility routines (for now, only ext2/ext3/jfs/reiserfs)
> +# Posix ACL utility routines (for now, only ext2/ext3/jfs/reiserfs/nfs4)
>  #
>  # NOTE: you can implement Posix ACLs without these helpers (XFS does).
>  # 	Never use this symbol for ifdefs.
> @@ -1661,7 +1661,6 @@ config NFSD
>  	select NFS_ACL_SUPPORT if NFSD_V2_ACL
>  	select CRYPTO_MD5 if NFSD_V4
>  	select CRYPTO if NFSD_V4
> -	select FS_POSIX_ACL if NFSD_V4
>  	help
>  	  Choose Y here if you want to allow other computers to access
>  	  files residing on this system using Sun's Network File System
> @@ -1722,6 +1721,7 @@ config NFSD_V3_ACL
>  config NFSD_V4
>  	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
>  	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
> +	select FS_POSIX_ACL
>  	select RPCSEC_GSS_KRB5
>  	help
>  	  This option enables support in your system's NFS server for
> 
