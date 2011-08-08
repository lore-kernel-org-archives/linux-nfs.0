Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39631 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418Ab1HHPzn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2011 11:55:43 -0400
Date: Mon, 8 Aug 2011 11:55:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] headers, nfsd: Add missing #includes to
 <linux/nfsd/syscall.h>
Message-ID: <20110808155538.GB904@fieldses.org>
References: <1312810169.2591.1153.camel@deadeye>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312810169.2591.1153.camel@deadeye>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 08, 2011 at 02:29:29PM +0100, Ben Hutchings wrote:
> <linux/nfsd/syscall.h> uses the NFS_MAXPATHLEN and NFS_FHSIZE macros
> defined in <linux/nfs.h>, and struct knfsd_fh defined in
> <linux/nfsd/nfsfh.h>.

Well, the real bug is that this file exists at all.  Neil sent this
http://marc.info/?l=linux-nfs&m=130881392416899&w=2 in a while ago but I
didn't want to attempt to merge something that touched every arch
directory.  I wonder what we should do....

--b.

> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  include/linux/nfsd/syscall.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfsd/syscall.h b/include/linux/nfsd/syscall.h
> index 812bc1e..07b75f2 100644
> --- a/include/linux/nfsd/syscall.h
> +++ b/include/linux/nfsd/syscall.h
> @@ -10,7 +10,9 @@
>  #define NFSD_SYSCALL_H
>  
>  #include <linux/types.h>
> +#include <linux/nfs.h>
>  #include <linux/nfsd/export.h>
> +#include <linux/nfsd/nfsfh.h>
>  
>  /*
>   * Version of the syscall interface
> -- 
> 1.7.5.4
> 
> 
