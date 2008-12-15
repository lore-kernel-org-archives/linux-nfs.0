From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 5/6] nfsd: last_byte_offset
Date: Mon, 15 Dec 2008 13:33:44 -0500
Message-ID: <B51B6907-263A-420C-AD5B-E5EE1D16E138@oracle.com>
References: <49469601.7020101@panasas.com> <1229362923-9847-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: " J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:56840 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbYLOSeT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 13:34:19 -0500
In-Reply-To: <1229362923-9847-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny-

On Dec 15, 2008, at 12:42 PM, Benny Halevy wrote:
> refactor the nfs4 server lock code to use last_byte_offset
> to compute the last byte covered by the lock.  Check for overflow
> so that the last byte is set to NFS4_MAX_UINT64 if offset + len
> wraps around.
>
> Also, use NFS4_MAX_UINT64 for ~(u64)0 where appropriate.

Comments below are more about the existing code than your patch.

> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> fs/nfsd/nfs4state.c  |   42 ++++++++++++++++++++++++++----------------
> include/linux/nfs4.h |    2 ++
> 2 files changed, 28 insertions(+), 16 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 977ef84..1835538 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2404,6 +2404,26 @@ out:
> #define LOCK_HASH_SIZE             (1 << LOCK_HASH_BITS)
> #define LOCK_HASH_MASK             (LOCK_HASH_SIZE - 1)
>
> +static inline u64
> +end_offset(u64 start, u64 len)
> +{
> +	u64 end;
> +
> +	end = start + len;
> +	return end >= start ? end: NFS4_MAX_UINT64;
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
> +	return end > start ? end - 1: NFS4_MAX_UINT64;
> +}
> +
> #define lockownerid_hashval(id) \
>         ((id) & LOCK_HASH_MASK)
>
> @@ -2506,8 +2526,8 @@ nfs4_set_lock_denied(struct file_lock *fl,  
> struct nfsd4_lock_denied *deny)
> 		deny->ld_clientid.cl_id = 0;
> 	}
> 	deny->ld_start = fl->fl_start;
> -	deny->ld_length = ~(u64)0;
> -	if (fl->fl_end != ~(u64)0)
> +	deny->ld_length = NFS4_MAX_UINT64;
> +	if (fl->fl_end != NFS4_MAX_UINT64)

Someone more expert with the locking code than I am should comment on  
this... but fl_end is a loff_t (long long) -- not a u64.  The check  
here should be for OFFSET_MAX, just like it is in lockd, right?  Is  
"long long" the same width on all hardware architectures?

> 		deny->ld_length = fl->fl_end - fl->fl_start + 1;
> 	deny->ld_type = NFS4_READ_LT;
> 	if (fl->fl_type != F_RDLCK)
> @@ -2604,7 +2624,7 @@ out:
> static int
> check_lock_length(u64 offset, u64 length)
> {
> -	return ((length == 0)  || ((length != ~(u64)0) &&
> +	return ((length == 0)  || ((length != NFS4_MAX_UINT64) &&
> 	     LOFF_OVERFLOW(offset, length)));
> }
>
> @@ -2724,11 +2744,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct  
> nfsd4_compound_state *cstate,
> 	file_lock.fl_lmops = &nfsd_posix_mng_ops;
>
> 	file_lock.fl_start = lock->lk_offset;
> -	if ((lock->lk_length == ~(u64)0) ||
> -			LOFF_OVERFLOW(lock->lk_offset, lock->lk_length))
> -		file_lock.fl_end = ~(u64)0;
> -	else
> -		file_lock.fl_end = lock->lk_offset + lock->lk_length - 1;
> +	file_lock.fl_end = last_byte_offset(lock->lk_offset, lock- 
> >lk_length);

Likewise, I think for proper interoperation with our VFS locking code,  
last_byte_offset should return a loff_t, and use OFFSET_MAX, not  
NFS4_MAX_UINT64 for the "biggest value I can think of" return.

This is a common issue for NFS -- the NFS/NLM wire data types for lock  
range values are u32 and u64, but Linux's internal types are  
loff_t's.  Our XDR code should manage this conversion and check that  
the incoming lock ranges can be supported by the implementation.

We don't actually have any unit test cases that check the behavior of  
this code around the file size and lock range maxima.

> 	nfs4_transform_lock_offset(&file_lock);
>
> 	/*
> @@ -2827,10 +2843,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct  
> nfsd4_compound_state *cstate,
> 	file_lock.fl_lmops = &nfsd_posix_mng_ops;
>
> 	file_lock.fl_start = lockt->lt_offset;
> -	if ((lockt->lt_length == ~(u64)0) || LOFF_OVERFLOW(lockt- 
> >lt_offset, lockt->lt_length))
> -		file_lock.fl_end = ~(u64)0;
> -	else
> -		file_lock.fl_end = lockt->lt_offset + lockt->lt_length - 1;
> +	file_lock.fl_end = last_byte_offset(lockt->lt_offset, lockt- 
> >lt_length);
>
> 	nfs4_transform_lock_offset(&file_lock);
>
> @@ -2894,10 +2907,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct  
> nfsd4_compound_state *cstate,
> 	file_lock.fl_lmops = &nfsd_posix_mng_ops;
> 	file_lock.fl_start = locku->lu_offset;
>
> -	if ((locku->lu_length == ~(u64)0) || LOFF_OVERFLOW(locku- 
> >lu_offset, locku->lu_length))
> -		file_lock.fl_end = ~(u64)0;
> -	else
> -		file_lock.fl_end = locku->lu_offset + locku->lu_length - 1;
> +	file_lock.fl_end = last_byte_offset(locku->lu_offset, locku- 
> >lu_length);
> 	nfs4_transform_lock_offset(&file_lock);
>
> 	/*
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index ea03667..b912311 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -88,6 +88,8 @@
> #define NFS4_ACE_GENERIC_EXECUTE              0x001200A0
> #define NFS4_ACE_MASK_ALL                     0x001F01FF
>
> +#define NFS4_MAX_UINT64	(~(u64)0)
> +
> enum nfs4_acl_whotype {
> 	NFS4_ACL_WHO_NAMED = 0,
> 	NFS4_ACL_WHO_OWNER,

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
