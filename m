Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44776 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbbCZBCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2015 21:02:45 -0400
Date: Wed, 25 Mar 2015 21:02:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chengyu Song <csong84@gatech.edu>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, taesoo@gatech.edu,
        changwoo@gatech.edu, sanidhya@gatech.edu, blee@gatech.edu
Subject: Re: [PATCH 1/1] nfsd: NFSD_FAULT_INJECTION depends on DEBUG_FS
Message-ID: <20150326010243.GB20086@fieldses.org>
References: <1427315827-6323-1-git-send-email-csong84@gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427315827-6323-1-git-send-email-csong84@gatech.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2015 at 04:37:07PM -0400, Chengyu Song wrote:
> NFSD_FAULT_INJECTION depends on DEBUG_FS, otherwise the debugfs_create_*
> interface may return unexpected error -ENODEV, and cause system crash.

Thanks, applying for 4.1.--b.

> 
> Signed-off-by: Chengyu Song <csong84@gatech.edu>
> ---
>  fs/nfsd/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 683bf71..8b87b7a 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -107,7 +107,7 @@ config NFSD_V4_SECURITY_LABEL
>  
>  config NFSD_FAULT_INJECTION
>  	bool "NFS server manual fault injection"
> -	depends on NFSD_V4 && DEBUG_KERNEL
> +	depends on NFSD_V4 && DEBUG_KERNEL && DEBUG_FS
>  	help
>  	  This option enables support for manually injecting faults
>  	  into the NFS server.  This is intended to be used for
> -- 
> 2.1.0
