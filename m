From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 06/10] NFSD: Remove NFSv4 dependency on NFSv3
Date: Tue, 5 Feb 2008 15:24:45 -0500
Message-ID: <20080205202445.GJ8210@fieldses.org>
References: <20080205180912.32229.84694.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:47632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754078AbYBEUYy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 15:24:54 -0500
In-Reply-To: <20080205180912.32229.84694.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 05, 2008 at 01:09:12PM -0500, Chuck Lever wrote:
> Because NFSD_V4 "depends on" NFSD_V3, it appears as a child of the NFSD_V3
> menu entry, and is not visible if NFSD_V3 is unselected.

Are you really convinced this is a problem?

--b.

> 
> Replace the dependency on NFSD_V3 with a "select NFSD_V3".
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 9ad62a9..4c16789 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1723,7 +1723,8 @@ config NFSD_V3_ACL
>  
>  config NFSD_V4
>  	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
> -	depends on NFSD && NFSD_V3 && EXPERIMENTAL
> +	depends on NFSD && EXPERIMENTAL
> +	select NFSD_V3
>  	select RPCSEC_GSS_KRB5
>  	help
>  	  This option enables support in your system's NFS server for
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
