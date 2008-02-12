From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/11] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 12 Feb 2008 16:04:15 -0500
Message-ID: <20080212210415.GI18625@fieldses.org>
References: <20080211221139.1047.36246.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46669 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765381AbYBLVE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 16:04:27 -0500
In-Reply-To: <20080211221139.1047.36246.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 05:11:39PM -0500, Chuck Lever wrote:
> Likewise, distros usually leave CONFIG_NFSD_TCP enabled.
> 
> TCP support in the Linux NFS server is stable enough that we can leave it
> on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and defaults to
> "Y" anyway.

Applied, thanks!--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig       |   10 ----------
>  fs/nfsd/nfssvc.c |    2 --
>  2 files changed, 0 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 4965fd8..9c2c24b 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1646,7 +1646,6 @@ config NFSD
>  	select EXPORTFS
>  	select NFSD_V2_ACL if NFSD_V3_ACL
>  	select NFS_ACL_SUPPORT if NFSD_V2_ACL
> -	select NFSD_TCP if NFSD_V4
>  	select CRYPTO_MD5 if NFSD_V4
>  	select CRYPTO if NFSD_V4
>  	select FS_POSIX_ACL if NFSD_V4
> @@ -1705,15 +1704,6 @@ config NFSD_V4
>  	  should only be used if you are interested in helping to test NFSv4.
>  	  If unsure, say N.
>  
> -config NFSD_TCP
> -	bool "Provide NFS server over TCP support"
> -	depends on NFSD
> -	default y
> -	help
> -	  If you want your NFS server to support TCP connections, say Y here.
> -	  TCP connections usually perform better than the default UDP when
> -	  the network is lossy or congested.  If unsure, say Y.
> -
>  config ROOT_NFS
>  	bool "Root file system on NFS"
>  	depends on NFS_FS=y && IP_PNP
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 9647b0f..941041f 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -244,7 +244,6 @@ static int nfsd_init_socks(int port)
>  	if (error < 0)
>  		return error;
>  
> -#ifdef CONFIG_NFSD_TCP
>  	error = lockd_up(IPPROTO_TCP);
>  	if (error >= 0) {
>  		error = svc_create_xprt(nfsd_serv, "tcp", port,
> @@ -254,7 +253,6 @@ static int nfsd_init_socks(int port)
>  	}
>  	if (error < 0)
>  		return error;
> -#endif
>  	return 0;
>  }
>  
> 
