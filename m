Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45985 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757617Ab3CEUFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 15:05:21 -0500
Date: Tue, 5 Mar 2013 15:05:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        jackm@dev.mellanox.co.il, ogerlitz@mellanox.com,
        roland@purestorage.com, dan.magenheimer@oracle.com,
        gregkh@linuxfoundation.org, vjaquez@igalia.com, rene.sapiens@ti.com,
        x0095078@ti.com, omar.ramirez@ti.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] nfsd: remove unused get_new_stid()
Message-ID: <20130305200511.GB15816@fieldses.org>
References: <1362513772-15174-1-git-send-email-tj@kernel.org>
 <1362513772-15174-2-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362513772-15174-2-git-send-email-tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 05, 2013 at 12:02:46PM -0800, Tejun Heo wrote:
> get_new_stid() is no longer used since 3abdb607125 ("nfsd4: simplify
> idr allocation").  Remove it.

Whoops, thanks for catching that.

Acked-by: J. Bruce Fields <bfields@redhat.com>

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> ---
>  fs/nfsd/nfs4state.c | 31 -------------------------------
>  1 file changed, 31 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 16d39c6..d91d6db 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -230,37 +230,6 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
>  		__nfs4_file_put_access(fp, oflag);
>  }
>  
> -static inline int get_new_stid(struct nfs4_stid *stid)
> -{
> -	static int min_stateid = 0;
> -	struct idr *stateids = &stid->sc_client->cl_stateids;
> -	int new_stid;
> -	int error;
> -
> -	error = idr_get_new_above(stateids, stid, min_stateid, &new_stid);
> -	/*
> -	 * Note: the necessary preallocation was done in
> -	 * nfs4_alloc_stateid().  The idr code caps the number of
> -	 * preallocations that can exist at a time, but the state lock
> -	 * prevents anyone from using ours before we get here:
> -	 */
> -	WARN_ON_ONCE(error);
> -	/*
> -	 * It shouldn't be a problem to reuse an opaque stateid value.
> -	 * I don't think it is for 4.1.  But with 4.0 I worry that, for
> -	 * example, a stray write retransmission could be accepted by
> -	 * the server when it should have been rejected.  Therefore,
> -	 * adopt a trick from the sctp code to attempt to maximize the
> -	 * amount of time until an id is reused, by ensuring they always
> -	 * "increase" (mod INT_MAX):
> -	 */
> -
> -	min_stateid = new_stid+1;
> -	if (min_stateid == INT_MAX)
> -		min_stateid = 0;
> -	return new_stid;
> -}
> -
>  static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
>  kmem_cache *slab)
>  {
> -- 
> 1.8.1.4
> 
