Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36326 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab0HRU0D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:26:03 -0400
Date: Wed, 18 Aug 2010 16:25:59 -0400
From: Christoph Hellwig <hch@infradead.org>
To: andros@netapp.com
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/50] pnfs_submit: pnfs and nfslayoutdriver kconfig
Message-ID: <20100818202559.GA16851@infradead.org>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1281735122-1496-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 13, 2010 at 05:31:17PM -0400, andros@netapp.com wrote:
> From: The pNFS Team <linux-nfs@vger.kernel.org>
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

If you split out the Kconfig from the code it guards it should come last
in the series so that the code can't be enabled until it's complete.

>  	depends on NFS_V4 && EXPERIMENTAL
>  	help
>  	  This option enables support for minor version 1 of the NFSv4 protocol
> -	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
> +	  (RFC5661) including support for the parallel NFS (pNFS) features
> +	  in the kernel's NFS client.
> +
> +	  Unless you're an NFS developer, say N.

How much code does the pnfs support add to the nfs.ko module?  Just
including this unconditionally might not be an all that good idea.

Also Trond seemed to be pretty determined to split up nfs.ko into
version specific modules, and pnfs and the various layout drivers are
pretty good candidates for that.  Maybe the pnfs patches should be ontop
of that?

> +config PNFS_FILE_LAYOUT
> +	tristate "NFS client support for the pNFS nfs-files layout (DEVELOPER ONLY)"
> +	depends on NFS_FS && NFS_V4_1

is it really developers-only at this point?  And if it is so why doesn't
it depend on EXPERIMENTAL

> +	default y

defaulting to y for random fringe features is frowned upon.

