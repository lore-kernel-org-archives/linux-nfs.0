Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57154 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbaHJBAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Aug 2014 21:00:07 -0400
Date: Sat, 9 Aug 2014 21:00:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4 RFC] NFSD: Revert setting op_encode_lockowner_maxsz
Message-ID: <20140810010006.GA31913@fieldses.org>
References: <53BAAAFE.8090403@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53BAAAFE.8090403@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 07, 2014 at 10:13:18PM +0800, Kinglong Mee wrote:
> Commit 8c7424cff6 (nfsd4: don't try to encode conflicting owner if low on space)
> set op_encode_lockowner_maxsz to zero.
> 
> When testing nfsd4_lock with conflict lock (has right owner), dmesg gets
>   "[18668.241385] RPC request reserved 88 but used 108"
> because xdr_reserve_space don't return NULL in nfsd4_encode_lock_denied.
> 
> Just revert op_encode_lockowner_maxsz.

Thanks for the bug report here and apologies for the slow response, I
think this (and your more recent two patches) aren't the right fix, but
just haven't had the chance to take a closer look--I'll look at it
Monday.  We probably need to get both a minimum and maximum size for
some of these operations.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 846fd55..6217190 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1422,8 +1422,7 @@ out:
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
