From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 09/11] NFSD: Move "select NFSD_V2_ACL if NFSD_V3_ACL"
Date: Tue, 12 Feb 2008 17:33:59 -0500
Message-ID: <20080212223359.GR18625@fieldses.org>
References: <20080211221231.1047.73886.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42112 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbYBLWeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 17:34:07 -0500
In-Reply-To: <20080211221231.1047.73886.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 05:12:31PM -0500, Chuck Lever wrote:
> Clean up: since NFSD_V2_ACL is a boolean, it can be selected safely
> under the NFSD_V3_ACL entry (also a boolean).
> 

Applied.--b.

> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index e94ca09..fcaf61e 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1657,7 +1657,6 @@ config NFSD
>  	select LOCKD
>  	select SUNRPC
>  	select EXPORTFS
> -	select NFSD_V2_ACL if NFSD_V3_ACL
>  	select NFS_ACL_SUPPORT if NFSD_V2_ACL
>  	select CRYPTO_MD5 if NFSD_V4
>  	select CRYPTO if NFSD_V4
> @@ -1699,6 +1698,7 @@ config NFSD_V3
>  config NFSD_V3_ACL
>  	bool "NFS server support for the NFSv3 ACL protocol extension"
>  	depends on NFSD_V3
> +	select NFSD_V2_ACL
>  	help
>  	  Solaris NFS servers support an auxiliary NFSv3 ACL protocol that
>  	  never became an official part of the NFS version 3 protocol.
> 
