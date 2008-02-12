From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/11] NFSD: Remove redundant "select" clauses in
	fs/Kconfig
Date: Tue, 12 Feb 2008 17:34:33 -0500
Message-ID: <20080212223433.GS18625@fieldses.org>
References: <20080211221238.1047.92046.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42115 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751494AbYBLWem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 17:34:42 -0500
In-Reply-To: <20080211221238.1047.92046.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 05:12:38PM -0500, Chuck Lever wrote:
> As far as I can tell, selecting the CRYPTO and CRYPTO_MD5 entries under
> CONFIG_NFSD is redundant, since CONFIG_NFSD_V4 already selects
> RPCSEC_GSS_KRB5, which selects these entries.
> 
> Testing with "make menuconfig" shows that the entries under CRYPTO still
> properly reflect "Y" or "M" based on the setting of CONFIG_NFSD after this
> change is applied.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

And applied this.  The rest I left alone for now.

--b.

> ---
> 
>  fs/Kconfig |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index fcaf61e..267ff73 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1658,8 +1658,6 @@ config NFSD
>  	select SUNRPC
>  	select EXPORTFS
>  	select NFS_ACL_SUPPORT if NFSD_V2_ACL
> -	select CRYPTO_MD5 if NFSD_V4
> -	select CRYPTO if NFSD_V4
>  	help
>  	  Choose Y here if you want to allow other computers to access
>  	  files residing on this system using Sun's Network File System
> 
