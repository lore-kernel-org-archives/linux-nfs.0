From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/5] NFS: NFS_V4 and NFSD_V4 should depend on SUNRPC_GSS
Date: Mon, 17 Mar 2008 12:00:01 -0400
Message-ID: <1205769601.11303.10.camel@heimdal.trondhjem.org>
References: <20080314181525.29889.35370.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17215 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbYCQQH7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2008 12:07:59 -0400
In-Reply-To: <20080314181525.29889.35370.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-03-14 at 14:15 -0400, Chuck Lever wrote:
> There is a guideline in Documentation/kbuild/kconfig-language.txt that
> states "In general use select only for non-visible symbols (no prompts
> anywhere) and for symbols with no dependencies." Both CONFIG_NFS_V4 and
> CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5, which is visible, and has
> dependencies.
> 
> For the sake of addressing the kconfig-language recommendation, 
> "select RPCSEC_GSS_KRB5" to "select SUNRPC_GSS".
> 
> The server side requires it to build properly, and the client side has it
> to provide support for loading GSS capabilities, which RFC 3530 makes
> mandatory for NFS version 4.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index bbc8e52..28b7ba5 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1628,7 +1628,7 @@ config NFS_V3_ACL
>  config NFS_V4
>  	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
>  	depends on NFS_FS && EXPERIMENTAL
> -	select RPCSEC_GSS_KRB5
> +	select SUNRPC_GSS
>  	help
>  	  This option enables support for version 4 of the NFS protocol 
>  	  (RFC 3530) in the kernel's NFS client.
> @@ -1719,7 +1719,7 @@ config NFSD_V4
>  	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
>  	depends on NFSD && PROC_FS && EXPERIMENTAL
>  	select NFSD_V3
> -	select RPCSEC_GSS_KRB5
> +	select SUNRPC_GSS
>  	help
>  	  This option enables support in your system's NFS server for
>  	  version 4 of the NFS protocol (RFC 3530).

NACK. Selecting SUNRPC_GSS is _not_ equivalent to what we have today.
Currently, if you select NFSv4, it will force compilation of the
KerberosV mechanism too. AFAICS, this patch regresses that behaviour.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
