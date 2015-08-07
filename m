Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33581 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114AbbHGPZ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 11:25:58 -0400
Received: by pabyb7 with SMTP id yb7so58055809pab.0
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2015 08:25:57 -0700 (PDT)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH v2 02/18] nfsd: move some file caching helpers to a common
 header
To: Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-3-git-send-email-jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Message-ID: <55C4CDE7.1080101@gmail.com>
Date: Fri, 7 Aug 2015 23:25:27 +0800
MIME-Version: 1.0
In-Reply-To: <1438809216-4846-3-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/6/2015 05:13, Jeff Layton wrote:
> We'll want to reuse some of this for common open file caching
> infrastructure.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/filecache.h | 25 +++++++++++++++++++++++++
>  fs/nfsd/nfs4state.c | 17 ++---------------
>  2 files changed, 27 insertions(+), 15 deletions(-)
>  create mode 100644 fs/nfsd/filecache.h
> 
> diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
> new file mode 100644
> index 000000000000..9051ee54faa3
> --- /dev/null
> +++ b/fs/nfsd/filecache.h
> @@ -0,0 +1,25 @@
> +#ifndef _FS_NFSD_FILECACHE_H
> +#define _FS_NFSD_FILECACHE_H
> +
> +#include <linux/jhash.h>
> +#include <linux/sunrpc/xdr.h>
> +
> +#include "export.h"
> +
> +/* hash table for nfs4_file */
> +#define NFSD_FILE_HASH_BITS                   8
> +#define NFSD_FILE_HASH_SIZE                  (1 << NFSD_FILE_HASH_BITS)
> +
> +static inline unsigned int
> +nfsd_fh_hashval(struct knfsd_fh *fh)
> +{
> +	return jhash2(fh->fh_base.fh_pad, XDR_QUADLEN(fh->fh_size), 0);
> +}
> +
> +static inline unsigned int
> +file_hashval(struct knfsd_fh *fh)

Update to nfsd_file_hashval maybe better ?

thanks,
Kinglong Mee

> +{
> +	return nfsd_fh_hashval(fh) & (NFSD_FILE_HASH_SIZE - 1);
> +}
> +
> +#endif /* _FS_NFSD_FILECACHE_H */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 43903abd6189..b3b306bd1830 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -49,6 +49,7 @@
>  
>  #include "netns.h"
>  #include "pnfs.h"
> +#include "filecache.h"
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
> @@ -381,21 +382,7 @@ static unsigned int ownerstr_hashval(struct xdr_netobj *ownername)
>  	return ret & OWNER_HASH_MASK;
>  }
>  
> -/* hash table for nfs4_file */
> -#define FILE_HASH_BITS                   8
> -#define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
> -
> -static unsigned int nfsd_fh_hashval(struct knfsd_fh *fh)
> -{
> -	return jhash2(fh->fh_base.fh_pad, XDR_QUADLEN(fh->fh_size), 0);
> -}
> -
> -static unsigned int file_hashval(struct knfsd_fh *fh)
> -{
> -	return nfsd_fh_hashval(fh) & (FILE_HASH_SIZE - 1);
> -}
> -
> -static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
> +static struct hlist_head file_hashtbl[NFSD_FILE_HASH_SIZE];
>  
>  static void
>  __nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> 
