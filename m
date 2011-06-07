Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63426 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab1FGSO7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 14:14:59 -0400
Subject: Re: [PATCH] Fix build on Fedora 13.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1307469531-20595-1-git-send-email-greearb@candelatech.com>
Date: Tue, 7 Jun 2011 14:14:46 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <E9E39B04-8045-44EF-970B-A1F1779C5A69@oracle.com>
References: <1307469531-20595-1-git-send-email-greearb@candelatech.com>
To: greearb@candelatech.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Ben-

On Jun 7, 2011, at 1:58 PM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> Need sys/stat.h for S_ISDIR and S_ISREG symbols.

Can you tell when this problem was introduced?  What ./configure options might be relevant?

> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 99618c9... e057c5c... M	utils/exportfs/exportfs.c
> :100644 100644 2aa3d4f... a8ce028... M	utils/mount/mount.c
> utils/exportfs/exportfs.c |    4 ++++
> utils/mount/mount.c       |    3 +++
> 2 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 99618c9..e057c5c 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -12,6 +12,10 @@
> #include <config.h>
> #endif
> 
> +#ifdef HAVE_SYS_STAT_H
> +#include <sys/stat.h>
> +#endif
> +
> #include <unistd.h>
> #include <stdlib.h>
> #include <string.h>
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index 2aa3d4f..a8ce028 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -20,6 +20,9 @@
> 
> #include "config.h"
> #include <unistd.h>
> +#ifdef HAVE_SYS_STAT_H
> +#include <sys/stat.h>
> +#endif
> #include <sys/types.h>
> #include <stdio.h>
> #include <string.h>
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




