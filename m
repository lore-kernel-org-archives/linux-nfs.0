Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4990 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756525Ab1BCT2w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 14:28:52 -0500
Subject: Re: [PATCH] Fix size argument to memset call in nfsacl_encode
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jesper Juhl <jj@chaosbits.net>, Milton Miller <miltonm@bga.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Neil Brown <neilb@suse.de>, bfields@fieldses.org
In-Reply-To: <alpine.LNX.2.00.1102032012540.15101@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1102032012540.15101@swampdragon.chaosbits.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Feb 2011 14:28:50 -0500
Message-ID: <1296761330.3015.22.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-03 at 20:15 +0100, Jesper Juhl wrote: 
> We want to give memset() the sizeof(struct posix_acl), not
> sizeof(struct posix_acl *).
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  nfsacl.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
> index 84c27d6..bc6d81b 100644
> --- a/fs/nfs_common/nfsacl.c
> +++ b/fs/nfs_common/nfsacl.c
> @@ -117,7 +117,7 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
>  		 * invoked in contexts where a memory allocation failure is
>  		 * fatal.  Fortunately this fake ACL is small enough to
>  		 * construct on the stack. */
> -		memset(acl2, 0, sizeof(acl2));
> +		memset(acl2, 0, sizeof(*acl2));
>  		posix_acl_init(acl2, 4);
>  
>  		/* Insert entries in canonical order: other orders seem

Ccing Milton Miller who also sent in the same patch.

Neither patch is correct afaics. posix_acl_init() will clobber the above
memset, and so the correct fix is just to get rid of it...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

