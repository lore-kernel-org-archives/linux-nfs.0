Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56515 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753406AbaHLSsv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 14:48:51 -0400
Date: Tue, 12 Aug 2014 14:48:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna.Schumaker@netapp.com
Subject: Re: [PATCH] nfsd: mark CONFIG_NFSD_FAULT_INJECTION as deprecated
Message-ID: <20140812184849.GA25914@fieldses.org>
References: <1407351771-11435-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407351771-11435-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 06, 2014 at 03:02:51PM -0400, Jeff Layton wrote:
> The fault injection code is shaky at best. If you have a lot of stateful
> objects, then you can end up overflowing the client's refcount. The code
> is not widely used and is starting to become a maintenance burden mark
> it DEPRECATED and document that we'll remove it in v3.19.

I doubt anyone will notice a config text change on upgrade.

If we think a deprecation warning's necessary then it would be more
useful to put it in a printk() that fires the first time somebody uses
one of these.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/Kconfig | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index f994e750e0d1..aad734c0b48a 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -98,11 +98,14 @@ config NFSD_V4_SECURITY_LABEL
>  	For now we recommend "Y" only for developers and testers.
>  
>  config NFSD_FAULT_INJECTION
> -	bool "NFS server manual fault injection"
> +	bool "NFS server manual fault injection (DEPRECATED)"
>  	depends on NFSD_V4 && DEBUG_KERNEL
>  	help
>  	  This option enables support for manually injecting faults
>  	  into the NFS server.  This is intended to be used for
>  	  testing error recovery on the NFS client.
>  
> +	  This feature should not be enabled on production systems
> +	  and will be removed in v3.19.
> +
>  	  If unsure, say N.
> -- 
> 1.9.3
> 
