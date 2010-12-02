From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] (updated) Fix nfs_compat_user_ino64 so it doesn't
 cause problems if bit 31 or 63 are set in filei
Date: Thu, 02 Dec 2010 13:11:08 -0500
Message-ID: <1291313468.3445.1.camel@heimdal.trondhjem.org>
References: <1291312723.5075.25.camel@KPMH461.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: NFS List <linux-nfs@vger.kernel.org>, ffilz@us.ibm.com
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14617 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755378Ab0LBSLd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 13:11:33 -0500
In-Reply-To: <1291312723.5075.25.camel-LVD8ZR29O+mrIzol8Bc5pA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-12-02 at 09:58 -0800, Frank Filz wrote:
> The problem was use of an int32, which when converted to a uint64
> is sign extended resulting in a fileid that doesn't fit in 32 bits
> even though the intent of the function is to fit the fileid into
> 32 bits.
> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> ---
>  fs/nfs/inode.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 314f571..7fe18a0 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -89,7 +89,11 @@ int nfs_wait_bit_killable(void *word)
>   */
>  u64 nfs_compat_user_ino64(u64 fileid)
>  {
> -	int ino;
> +#ifdef CONIFG_COMPAT
          ^^^^^^^ typo
> +	compat_ulong_t ino;
> +#else	
> +	unsigned long ino;
> +#endif
>  
>  	if (enable_ino64)
>  		return fileid;

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

