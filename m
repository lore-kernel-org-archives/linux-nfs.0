From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs:include <linux/prefetch.h> to fix compiling error
Date: Fri, 19 Aug 2011 17:38:05 -0400
Message-ID: <1313789885.26701.2.camel@lade.trondhjem.org>
References: <1313788762-2562-1-git-send-email-wanlong.gao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Wanlong Gao <gaowanlong@cn.fujitsu.com>
To: Wanlong Gao <wanlong.gao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18545 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab1HSViF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 17:38:05 -0400
In-Reply-To: <1313788762-2562-1-git-send-email-wanlong.gao@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2011-08-20 at 05:19 +0800, Wanlong Gao wrote: 
> From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> 
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_read':
> fs/nfs/blocklayout/blocklayout.c:201:4: error: implicit
> declaration of function 'prefetchw'
> make[4]: *** [fs/nfs/blocklayout/blocklayout.o] Error 1
> make[3]: *** [fs/nfs/blocklayout] Error 2
> make[2]: *** [fs/nfs] Error 2
> make[1]: *** [fs] Error 2
> 
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index e56564d..9561c8f 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -36,6 +36,7 @@
>  #include <linux/namei.h>
>  #include <linux/bio.h>		/* struct bio */
>  #include <linux/buffer_head.h>	/* various write calls */
> +#include <linux/prefetch.h>
>  
>  #include "blocklayout.h"
>  

A similar patch has already been merged upstream. See commit
88c9e42196285a7c573e2abda11a4b5037c669bc (nfs: add missing prefetch.h
include).

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

