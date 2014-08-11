Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55132 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbaHKUBT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2014 16:01:19 -0400
Date: Mon, 11 Aug 2014 16:01:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSD: Revert setting op_encode_lockowner_maxsz
Message-ID: <20140811200118.GG9095@fieldses.org>
References: <53E2EE2E.9040007@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53E2EE2E.9040007@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 07, 2014 at 11:10:38AM +0800, Kinglong Mee wrote:
> Commit 8c7424cff6 (nfsd4: don't try to encode conflicting owner if low on space)
> set op_encode_lockowner_maxsz to zero.
> 
> If setting op_encode_lockowner_maxsz to zero, nfsd will not encode
> the owner of conflock forever.

Right, so the problem is that the lock reply encoder is unique in that
it will happily adjust the xdr encoding if it's running out of space.

This came about with 8c7424cff6 "nfsd4: don't try to encode conflicting
owner if low on space".  The problem is that:

	- the maximum size of a lock reply is kind of big (the original
	  calculation below is actually wrong, IDMAP_NAMESZ should be
	  NFS4_OPAQUE_LIMIT).
	- we may not be the only server that's been sloppy about
	  enforcing the theoretical maximum here, and I'd rather be
	  forgiving to clients that don't insist on the theoretical
	  maximum maxresp_cached.

So best seems just to allow a LOCK even if space is insufficient and
just throw out the conflicting lockowner if there isn't enough space,
since large lockowners should be rare and we don't care about the
conflicting lockowner anyway.

So anyway we need to leave the maximum reserved in rq_reserved without
changing the check we make before executing the LOCK.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 084e46e..55635a8 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1417,8 +1417,7 @@ out:
>  #define op_encode_change_info_maxsz	(5)
>  #define nfs4_fattr_bitmap_maxsz		(4)
>  
> -/* We'll fall back on returning no lockowner if run out of space: */
> -#define op_encode_lockowner_maxsz	(0)
> +#define op_encode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
>  #define op_encode_lock_denied_maxsz	(8 + op_encode_lockowner_maxsz)
>  
>  #define nfs4_owner_maxsz		(1 + XDR_QUADLEN(IDMAP_NAMESZ))
> -- 
> 1.9.3
> 
