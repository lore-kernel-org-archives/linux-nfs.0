Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47660 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbaEWOS4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 10:18:56 -0400
Date: Fri, 23 May 2014 10:18:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] NFSD: Cleanup unneeded including
 linux/user_namespace.h
Message-ID: <20140523141855.GN25423@fieldses.org>
References: <537F44B1.6080507@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537F44B1.6080507@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied all five.

On Fri, May 23, 2014 at 08:53:05PM +0800, Kinglong Mee wrote:
> commit 4c1e1b34d5c800ad3ac9a7e2805b0bea70ad2278 using kuid/kgid for

In future, when referring to another commit, could you also include the
summary line?  E.g.: Commit 8f6c5ffc8987 ("kernel/groups.c: remove
return value of set_groups") removed the last use of "ret"....

--b.

> ex_anon_uid/ex_anon_gid, user_namespace.h is not needed now, clean it.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/auth.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
> index 2645be4..1042325 100644
> --- a/fs/nfsd/auth.c
> +++ b/fs/nfsd/auth.c
> @@ -1,7 +1,6 @@
>  /* Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de> */
>  
>  #include <linux/sched.h>
> -#include <linux/user_namespace.h>
>  #include "nfsd.h"
>  #include "auth.h"
>  
> -- 
> 1.9.3
> 
