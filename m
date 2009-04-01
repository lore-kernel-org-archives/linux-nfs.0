From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Wed, 1 Apr 2009 00:33:01 -0400
Message-ID: <20090401043301.GA29339@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229069-8636-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50005 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbZDAEdD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 00:33:03 -0400
In-Reply-To: <1238229069-8636-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:31:09AM +0300, Benny Halevy wrote:
> Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL
> Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment

Stupid question: do we need CONFIG_NFSD_V4_1 at all?  How many people
will want to build a kernel with v4.0 but not v4.1?

(And: do we have an interface that allows turning off 4.1 at run-time?
That's more important than the config option.)

--b.

> 
> At the moment we're expecting folks trying out nfs41 to
> actively participate in the development process by helping us
> debug issues and ideally send patches to fix problems.
> 
> [trailing space fixed]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/Kconfig |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 503b9da..1f2f893 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -79,3 +79,12 @@ config NFSD_V4
>  	  available from http://linux-nfs.org/.
>  
>  	  If unsure, say N.
> +
> +config NFSD_V4_1
> +	bool "NFS server support for NFSv4.1 (DEVELOPER ONLY)"
> +	depends on NFSD_V4 && EXPERIMENTAL
> +	help
> +	  This option enables support for minor version 1 of the NFSv4 protocol
> +	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS server.
> +
> +	  Unless you're an NFS developer, say N.
> -- 
> 1.6.2.1
> 
