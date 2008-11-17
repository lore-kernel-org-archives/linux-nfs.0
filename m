From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 20/51] nfsd: last_byte_offset
Date: Mon, 17 Nov 2008 16:06:03 +0200
Message-ID: <49217A4B.2000007@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350050-10848-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:10063 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752195AbYKQOGI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:06:08 -0500
In-Reply-To: <1226350050-10848-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:47 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> refactor the nfs4 server lock code to use last_byte_offset
> to compute the last byte covered by the lock.  Check for overflow
> so that the last byte is set to NFS4_LENGTH_EOF if offset + len
> wraps around.
> 
> Also, use NFS4_LENGTH_EOF for ~(u64)0 where appropriate.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-12: check what cases are covered by pynfs testing,
add more cases as Andy captured.

Move this patch forward into the misc. section.

> ---
>  fs/nfsd/nfs4state.c |   42 ++++++++++++++++++++++++++----------------
>  1 files changed, 26 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index db79c0c..ca2e3e0 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2544,6 +2544,26 @@ out:
>  #define LOCK_HASH_SIZE             (1 << LOCK_HASH_BITS)
>  #define LOCK_HASH_MASK             (LOCK_HASH_SIZE - 1)
>  
> +static inline u64
> +end_offset(u64 start, u64 len)
> +{
> +	u64 end;
> +
> +	end = start + len;
> +	return end >= start ? end: NFS4_LENGTH_EOF;
> +}
> +
> +/* last octet in a range */
> +static inline u64
> +last_byte_offset(u64 start, u64 len)
> +{
> +	u64 end;
> +
> +	BUG_ON(!len);
> +	end = start + len;
> +	return end > start ? end - 1: NFS4_LENGTH_EOF;
> +}
> +
>  #define lockownerid_hashval(id) \
>          ((id) & LOCK_HASH_MASK)
>  
> @@ -2646,8 +2666,8 @@ nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
>  		deny->ld_clientid.cl_id = 0;
>  	}
>  	deny->ld_start = fl->fl_start;
> -	deny->ld_length = ~(u64)0;
> -	if (fl->fl_end != ~(u64)0)
> +	deny->ld_length = NFS4_LENGTH_EOF;
> +	if (fl->fl_end != NFS4_LENGTH_EOF)
>  		deny->ld_length = fl->fl_end - fl->fl_start + 1;        
>  	deny->ld_type = NFS4_READ_LT;
>  	if (fl->fl_type != F_RDLCK)
> @@ -2745,7 +2765,7 @@ out:
>  static int
>  check_lock_length(u64 offset, u64 length)
>  {
> -	return ((length == 0)  || ((length != ~(u64)0) &&
> +	return ((length == 0)  || ((length != NFS4_LENGTH_EOF) &&
>  	     LOFF_OVERFLOW(offset, length)));
>  }
>  
> @@ -2870,11 +2890,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	file_lock.fl_lmops = &nfsd_posix_mng_ops;
>  
>  	file_lock.fl_start = lock->lk_offset;
> -	if ((lock->lk_length == ~(u64)0) || 
> -			LOFF_OVERFLOW(lock->lk_offset, lock->lk_length))
> -		file_lock.fl_end = ~(u64)0;
> -	else
> -		file_lock.fl_end = lock->lk_offset + lock->lk_length - 1;
> +	file_lock.fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
>  	nfs4_transform_lock_offset(&file_lock);
>  
>  	/*
> @@ -2978,10 +2994,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	file_lock.fl_lmops = &nfsd_posix_mng_ops;
>  
>  	file_lock.fl_start = lockt->lt_offset;
> -	if ((lockt->lt_length == ~(u64)0) || LOFF_OVERFLOW(lockt->lt_offset, lockt->lt_length))
> -		file_lock.fl_end = ~(u64)0;
> -	else
> -		file_lock.fl_end = lockt->lt_offset + lockt->lt_length - 1;
> +	file_lock.fl_end = last_byte_offset(lockt->lt_offset, lockt->lt_length);
>  
>  	nfs4_transform_lock_offset(&file_lock);
>  
> @@ -3045,10 +3058,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	file_lock.fl_lmops = &nfsd_posix_mng_ops;
>  	file_lock.fl_start = locku->lu_offset;
>  
> -	if ((locku->lu_length == ~(u64)0) || LOFF_OVERFLOW(locku->lu_offset, locku->lu_length))
> -		file_lock.fl_end = ~(u64)0;
> -	else
> -		file_lock.fl_end = locku->lu_offset + locku->lu_length - 1;
> +	file_lock.fl_end = last_byte_offset(locku->lu_offset, locku->lu_length);
>  	nfs4_transform_lock_offset(&file_lock);
>  
>  	/*
