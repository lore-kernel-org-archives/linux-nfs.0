Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546AbaEHPYL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 11:24:11 -0400
Date: Thu, 8 May 2014 11:24:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: cleanup unneeded including linux/export.h
Message-ID: <20140508152409.GA20976@fieldses.org>
References: <536A4C54.5090401@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <536A4C54.5090401@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 07, 2014 at 11:08:04PM +0800, Kinglong Mee wrote:
> commit 4ac7249ea5a0ceef9f8269f63f33cc873c3fac61 have remove all EXPORT_SYMBOL,
> linux/export.h is not needed, just clean it.

Thanks, applying.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4acl.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index babcc3c..42925db 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -36,7 +36,6 @@
>  
>  #include <linux/slab.h>
>  #include <linux/nfs_fs.h>
> -#include <linux/export.h>
>  #include "nfsfh.h"
>  #include "nfsd.h"
>  #include "acl.h"
> -- 
> 1.9.0
> 
