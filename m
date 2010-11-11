Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:47422 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753741Ab0KKPAa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 10:00:30 -0500
Message-ID: <4CDC0500.90805@panasas.com>
Date: Thu, 11 Nov 2010 17:00:16 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/18] pnfs-submit: change layout state seqlock to a spinlock
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com> <1288884151-11128-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-5-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-04 17:22, Fred Isaman wrote:
> This prepares for future changes, where the layout state needs
> to change atomically with several other variables.  In particular,
> it will need to know if lo->segs is empty.  Moreover, the
> layoutstateid is not really a read-mostly structure, as it is
> written on each LAYOUTGET.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/callback_proc.c |    8 +++---
>  fs/nfs/nfs4xdr.c       |    2 +
>  fs/nfs/pnfs.c          |   55 ++++++++++++++---------------------------------
>  fs/nfs/pnfs.h          |    4 +--
>  4 files changed, 24 insertions(+), 45 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 84c5a1b..3e022a8 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -135,12 +135,11 @@ static bool
>  pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
>  			    const nfs4_stateid stateid)
>  {
> -	int seqlock;
>  	bool res;
>  	u32 oldseqid, newseqid;
>  
> -	do {
> -		seqlock = read_seqbegin(&lo->seqlock);
> +	spin_lock(&lo->inode->i_lock);
> +	{
>  		oldseqid = be32_to_cpu(lo->stateid.stateid.seqid);
>  		newseqid = be32_to_cpu(stateid.stateid.seqid);
>  		res = !memcmp(lo->stateid.stateid.other,
> @@ -158,7 +157,8 @@ pnfs_is_next_layout_stateid(const struct pnfs_layout_hdr *lo,
>  			if (res)
>  				res = (newseqid == 1);
>  		}
> -	} while (read_seqretry(&lo->seqlock, seqlock));
> +	}
> +	spin_unlock(&lo->inode->i_lock);
>  
>  	return res;
>  }
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 6d9ef2b..b71a482 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1915,7 +1915,9 @@ encode_layoutreturn(struct xdr_stream *xdr,
>  		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
>  		p = xdr_encode_hyper(p, args->range.offset);
>  		p = xdr_encode_hyper(p, args->range.length);
> +		spin_lock(&args->inode->i_lock);
>  		pnfs_copy_layout_stateid(&stateid, NFS_I(args->inode)->layout);
> +		spin_unlock(&args->inode->i_lock);
>  		p = xdr_encode_opaque_fixed(p, &stateid.data,
>  					    NFS4_STATEID_SIZE);
>  		p = reserve_space(xdr, 4);
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 4e5c68b..01ecb95 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -456,7 +456,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>  	nfs4_stateid *old = &lo->stateid;
>  	bool overwrite = false;
>  
> -	write_seqlock(&lo->seqlock);
> +	assert_spin_locked(&lo->inode->i_lock);
>  	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
>  	    memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
>  		overwrite = true;
> @@ -470,54 +470,34 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>  	}
>  	if (overwrite)
>  		memcpy(&old->stateid, &new->stateid, sizeof(new->stateid));
> -	write_sequnlock(&lo->seqlock);
> -}
> -
> -static void
> -pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
> -			      struct nfs4_state *state)
> -{
> -	int seq;
> -
> -	dprintk("--> %s\n", __func__);
> -	write_seqlock(&lo->seqlock);
> -	do {
> -		seq = read_seqbegin(&state->seqlock);
> -		memcpy(lo->stateid.data, state->stateid.data,
> -		       sizeof(state->stateid.data));
> -	} while (read_seqretry(&state->seqlock, seq));
> -	set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
> -	write_sequnlock(&lo->seqlock);
> -	dprintk("<-- %s\n", __func__);
>  }
>  
>  /* Layoutreturn may use an invalid stateid, just copy what is there */
>  void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo)
>  {
> -	int seq;
> -
> -	do {
> -		seq = read_seqbegin(&lo->seqlock);
> -		memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
> -	} while (read_seqretry(&lo->seqlock, seq));
> +	assert_spin_locked(&lo->inode->i_lock);
> +	memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));

This function is just redundant now.
Let's just open code its two users.

Benny

>  }
>  
>  void
>  pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>  			struct nfs4_state *open_state)
>  {
> -	int seq;
> -
>  	dprintk("--> %s\n", __func__);
> -	do {
> -		seq = read_seqbegin(&lo->seqlock);
> -		if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
> -			/* This will trigger retry of the read */
> -			pnfs_layout_from_open_stateid(lo, open_state);
> -		} else
> -			memcpy(dst->data, lo->stateid.data,
> -			       sizeof(lo->stateid.data));
> -	} while (read_seqretry(&lo->seqlock, seq));
> +	spin_lock(&lo->inode->i_lock);
> +	if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state)) {
> +		int seq;
> +
> +		do {
> +			seq = read_seqbegin(&open_state->seqlock);
> +			memcpy(dst->data, open_state->stateid.data,
> +			       sizeof(open_state->stateid.data));
> +		} while (read_seqretry(&open_state->seqlock, seq));
> +		set_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
> +	} else
> +		memcpy(dst->data, lo->stateid.data,
> +		       sizeof(lo->stateid.data));
> +	spin_unlock(&lo->inode->i_lock);
>  	dprintk("<-- %s\n", __func__);
>  }
>  
> @@ -791,7 +771,6 @@ alloc_init_layout_hdr(struct inode *ino)
>  	lo->refcount = 1;
>  	INIT_LIST_HEAD(&lo->layouts);
>  	INIT_LIST_HEAD(&lo->segs);
> -	seqlock_init(&lo->seqlock);
>  	lo->inode = ino;
>  	return lo;
>  }
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 000acf0..de4eaa8 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -96,7 +96,6 @@ struct pnfs_layout_hdr {
>  	struct list_head	layouts;   /* other client layouts */
>  	struct list_head	segs;      /* layout segments list */
>  	int			roc_iomode;/* return on close iomode, 0=none */
> -	seqlock_t		seqlock;   /* Protects the stateid */
>  	nfs4_stateid		stateid;
>  	unsigned long		state;
>  	struct rpc_cred		*cred;     /* layoutcommit credential */
> @@ -224,9 +223,8 @@ static inline int lo_fail_bit(u32 iomode)
>  
>  static inline void pnfs_invalidate_layout_stateid(struct pnfs_layout_hdr *lo)
>  {
> -	write_seqlock(&lo->seqlock);
> +	assert_spin_locked(&lo->inode->i_lock);
>  	clear_bit(NFS_LAYOUT_STATEID_SET, &lo->state);
> -	write_sequnlock(&lo->seqlock);
>  }
>  
>  static inline void get_lseg(struct pnfs_layout_segment *lseg)
