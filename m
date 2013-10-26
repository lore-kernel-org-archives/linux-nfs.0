Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60556 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150Ab3JZThq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Oct 2013 15:37:46 -0400
Date: Sat, 26 Oct 2013 15:37:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix Kconfig syntax
Message-ID: <20131026193738.GC17945@fieldses.org>
References: <20131015193322.GA31890@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131015193322.GA31890@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 12:33:22PM -0700, Christoph Hellwig wrote:
> The description text for CONFIG_NFSD_V4_SECURITY_LABEL has an unpaired
> quote sign which breaks syntax highlighting for the nfsd Kconfig file.
> Remove it.

Thanks, applying for 3.13.--b.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index dc8f1ef..f994e75 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -95,7 +95,7 @@ config NFSD_V4_SECURITY_LABEL
>  	Smack policies on NFSv4 files, say N.
>  
>  	WARNING: there is still a chance of backwards-incompatible protocol changes.
> -	For now we recommend "Y" only for developers and testers."
> +	For now we recommend "Y" only for developers and testers.
>  
>  config NFSD_FAULT_INJECTION
>  	bool "NFS server manual fault injection"
