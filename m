From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] (try3-resend) Fix nfs_compat_user_ino64 so it doesn't
 cause problems if bit 31 or 63 are set in fileid
Date: Tue, 1 Feb 2011 09:54:10 -0500
Message-ID: <20110201095410.3a6ae6be@tlielax.poochiereds.net>
References: <1291318283.4140.6.camel@KPMH461.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>, ffilz@us.ibm.com
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757309Ab1BAOyS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Feb 2011 09:54:18 -0500
In-Reply-To: <1291318283.4140.6.camel-LVD8ZR29O+mrIzol8Bc5pA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 02 Dec 2010 11:31:23 -0800
Frank Filz <ffilzlnx@us.ibm.com> wrote:

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
> index 314f571..bc0b938 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -89,7 +89,11 @@ int nfs_wait_bit_killable(void *word)
>   */
>  u64 nfs_compat_user_ino64(u64 fileid)
>  {
> -	int ino;
> +#ifdef CONFIG_COMPAT
> +	compat_ulong_t ino;
> +#else	
> +	unsigned long ino;
> +#endif
>  
>  	if (enable_ino64)
>  		return fileid;

Looks like this patch fell through the cracks during the merge window?

In any case, it looks sane enough to me...

Reviewed-by: Jeff Layton <jlayton@redhat.com>
