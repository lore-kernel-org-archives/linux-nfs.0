Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34906 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1JCOsv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Oct 2011 10:48:51 -0400
Received: by wwf22 with SMTP id 22so6015092wwf.1
        for <linux-nfs@vger.kernel.org>; Mon, 03 Oct 2011 07:48:50 -0700 (PDT)
Message-ID: <4E89CA1C.4050107@tonian.com>
Date: Mon, 03 Oct 2011 16:43:40 +0200
From: Benny Halevy <bhalevy@tonian.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
References: <20110919131415.GB32498@fieldses.org> <1316438143-1057-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1316438143-1057-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce, it seems with this patch, doing si_opaque.so_id = current_stateid
makes all stateid's unique, regardless of their type.
Is find_stateid_by_type still needed?

And if the opaque part of the stateid isn't unique,
shouldn't find_stateid_by_type go over the hash bucket by itself
to look for other stateid's sharing the same opaque but having
the type it is looking for?

Benny

On 2011-09-19 16:15, J. Bruce Fields wrote:
> Including the full clientid in the on-the-wire stateid allows more
> reliable detection of bad vs. expired stateid's, simplifies code, and
> ensures we won't reuse the opaque part of the stateid (as we currently
> do when the same openowner closes and reopens the same file).
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |   58 +++++++++++---------------------------------------
>  fs/nfsd/state.h     |   18 ++++-----------
>  2 files changed, 18 insertions(+), 58 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index fdd03f6..922f47d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -49,9 +49,7 @@
>  time_t nfsd4_lease = 90;     /* default lease time */
>  time_t nfsd4_grace = 90;
>  static time_t boot_time;
> -static u32 current_ownerid = 1;
> -static u32 current_fileid = 1;
> -static u32 current_delegid = 1;
> +static u32 current_stateid = 1;
>  static stateid_t zerostateid;             /* bits all 0 */
>  static stateid_t onestateid;              /* bits all 1 */
>  static u64 current_sessionid = 1;
> @@ -136,11 +134,6 @@ unsigned int max_delegations;
>  #define OPEN_OWNER_HASH_SIZE             (1 << OPEN_OWNER_HASH_BITS)
>  #define OPEN_OWNER_HASH_MASK             (OPEN_OWNER_HASH_SIZE - 1)
>  
> -static unsigned int open_ownerid_hashval(const u32 id)
> -{
> -	return id & OPEN_OWNER_HASH_MASK;
> -}
> -
>  static unsigned int open_ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
>  {
>  	unsigned int ret;
> @@ -150,7 +143,6 @@ static unsigned int open_ownerstr_hashval(u32 clientid, struct xdr_netobj *owner
>  	return ret & OPEN_OWNER_HASH_MASK;
>  }
>  
> -static struct list_head	open_ownerid_hashtbl[OPEN_OWNER_HASH_SIZE];
>  static struct list_head	open_ownerstr_hashtbl[OPEN_OWNER_HASH_SIZE];
>  
>  /* hash table for nfs4_file */
> @@ -255,9 +247,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
>  	dp->dl_file = fp;
>  	dp->dl_type = type;
>  	dp->dl_stid.sc_type = NFS4_DELEG_STID;
> -	dp->dl_stid.sc_stateid.si_boot = boot_time;
> -	dp->dl_stid.sc_stateid.si_stateownerid = current_delegid++;
> -	dp->dl_stid.sc_stateid.si_fileid = 0;
> +	dp->dl_stid.sc_stateid.si_opaque.so_clid = clp->cl_clientid;
> +	dp->dl_stid.sc_stateid.si_opaque.so_id = current_stateid++;
>  	dp->dl_stid.sc_stateid.si_generation = 1;
>  	hash_stid(&dp->dl_stid);
>  	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
> @@ -457,7 +448,6 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
>  {
>  	struct nfs4_ol_stateid *stp;
>  
> -	list_del(&lo->lo_owner.so_idhash);
>  	list_del(&lo->lo_owner.so_strhash);
>  	list_del(&lo->lo_perstateid);
>  	while (!list_empty(&lo->lo_owner.so_stateids)) {
> @@ -502,7 +492,6 @@ static void unhash_openowner(struct nfs4_openowner *oo)
>  {
>  	struct nfs4_ol_stateid *stp;
>  
> -	list_del(&oo->oo_owner.so_idhash);
>  	list_del(&oo->oo_owner.so_strhash);
>  	list_del(&oo->oo_perclient);
>  	while (!list_empty(&oo->oo_owner.so_stateids)) {
> @@ -1081,9 +1070,8 @@ static void gen_confirm(struct nfs4_client *clp)
>  static int
>  same_stateid(stateid_t *id_one, stateid_t *id_two)
>  {
> -	if (id_one->si_stateownerid != id_two->si_stateownerid)
> -		return 0;
> -	return id_one->si_fileid == id_two->si_fileid;
> +	return 0 == memcmp(&id_one->si_opaque, &id_two->si_opaque,
> +					sizeof(stateid_opaque_t));
>  }
>  
>  static struct nfs4_stid *find_stateid(stateid_t *t)
> @@ -2198,7 +2186,6 @@ alloc_init_file(struct inode *ino)
>  		INIT_LIST_HEAD(&fp->fi_stateids);
>  		INIT_LIST_HEAD(&fp->fi_delegations);
>  		fp->fi_inode = igrab(ino);
> -		fp->fi_id = current_fileid++;
>  		fp->fi_had_conflict = false;
>  		fp->fi_lease = NULL;
>  		memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
> @@ -2295,7 +2282,6 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
>  	sop->so_owner.len = owner->len;
>  
>  	INIT_LIST_HEAD(&sop->so_stateids);
> -	sop->so_id = current_ownerid++;
>  	sop->so_client = clp;
>  	init_nfs4_replay(&sop->so_replay);
>  	return sop;
> @@ -2303,10 +2289,6 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
>  
>  static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, unsigned int strhashval)
>  {
> -	unsigned int idhashval;
> -
> -	idhashval = open_ownerid_hashval(oo->oo_owner.so_id);
> -	list_add(&oo->oo_owner.so_idhash, &open_ownerid_hashtbl[idhashval]);
>  	list_add(&oo->oo_owner.so_strhash, &open_ownerstr_hashtbl[strhashval]);
>  	list_add(&oo->oo_perclient, &clp->cl_openowners);
>  }
> @@ -2331,6 +2313,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>  static inline void
>  init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
>  	struct nfs4_openowner *oo = open->op_openowner;
> +	struct nfs4_client *clp = oo->oo_owner.so_client;
>  
>  	INIT_LIST_HEAD(&stp->st_lockowners);
>  	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> @@ -2339,9 +2322,8 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd
>  	stp->st_stateowner = &oo->oo_owner;
>  	get_nfs4_file(fp);
>  	stp->st_file = fp;
> -	stp->st_stid.sc_stateid.si_boot = boot_time;
> -	stp->st_stid.sc_stateid.si_stateownerid = oo->oo_owner.so_id;
> -	stp->st_stid.sc_stateid.si_fileid = fp->fi_id;
> +	stp->st_stid.sc_stateid.si_opaque.so_clid = clp->cl_clientid;
> +	stp->st_stid.sc_stateid.si_opaque.so_id = current_stateid++;
>  	/* note will be incremented before first return to client: */
>  	stp->st_stid.sc_stateid.si_generation = 0;
>  	hash_stid(&stp->st_stid);
> @@ -3095,8 +3077,6 @@ nfs4_laundromat(void)
>  				test_val = u;
>  			break;
>  		}
> -		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",
> -			oo->oo_owner.so_id);
>  		release_openowner(oo);
>  	}
>  	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
> @@ -3141,7 +3121,7 @@ nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
>  static int
>  STALE_STATEID(stateid_t *stateid)
>  {
> -	if (stateid->si_boot == boot_time)
> +	if (stateid->si_opaque.so_clid.cl_boot == boot_time)
>  		return 0;
>  	dprintk("NFSD: stale stateid " STATEID_FMT "!\n",
>  		STATEID_VAL(stateid));
> @@ -3710,11 +3690,6 @@ last_byte_offset(u64 start, u64 len)
>  	return end > start ? end - 1: NFS4_MAX_UINT64;
>  }
>  
> -static unsigned int lockownerid_hashval(u32 id)
> -{
> -	return id & LOCK_HASH_MASK;
> -}
> -
>  static inline unsigned int
>  lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
>  		struct xdr_netobj *ownername)
> @@ -3724,7 +3699,6 @@ lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
>  		& LOCK_HASH_MASK;
>  }
>  
> -static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
>  static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
>  
>  /*
> @@ -3795,10 +3769,6 @@ find_lockowner_str(struct inode *inode, clientid_t *clid,
>  
>  static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp)
>  {
> -	unsigned int idhashval;
> -
> -	idhashval = lockownerid_hashval(lo->lo_owner.so_id);
> -	list_add(&lo->lo_owner.so_idhash, &lock_ownerid_hashtbl[idhashval]);
>  	list_add(&lo->lo_owner.so_strhash, &lock_ownerstr_hashtbl[strhashval]);
>  	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
>  }
> @@ -3831,6 +3801,7 @@ static struct nfs4_ol_stateid *
>  alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
>  {
>  	struct nfs4_ol_stateid *stp;
> +	struct nfs4_client *clp = lo->lo_owner.so_client;
>  
>  	stp = nfs4_alloc_stateid();
>  	if (stp == NULL)
> @@ -3841,9 +3812,8 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
>  	stp->st_stid.sc_type = NFS4_LOCK_STID;
>  	get_nfs4_file(fp);
>  	stp->st_file = fp;
> -	stp->st_stid.sc_stateid.si_boot = boot_time;
> -	stp->st_stid.sc_stateid.si_stateownerid = lo->lo_owner.so_id;
> -	stp->st_stid.sc_stateid.si_fileid = fp->fi_id;
> +	stp->st_stid.sc_stateid.si_opaque.so_clid = clp->cl_clientid;
> +	stp->st_stid.sc_stateid.si_opaque.so_id = current_stateid++;
>  	/* note will be incremented before first return to client: */
>  	stp->st_stid.sc_stateid.si_generation = 0;
>  	hash_stid(&stp->st_stid);
> @@ -4252,7 +4222,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  	 * data structures. */
>  	INIT_LIST_HEAD(&matches);
>  	for (i = 0; i < LOCK_HASH_SIZE; i++) {
> -		list_for_each_entry(sop, &lock_ownerid_hashtbl[i], so_idhash) {
> +		list_for_each_entry(sop, &lock_ownerstr_hashtbl[i], so_strhash) {
>  			if (!same_owner_str(sop, owner, clid))
>  				continue;
>  			list_for_each_entry(stp, &sop->so_stateids,
> @@ -4398,12 +4368,10 @@ nfs4_state_init(void)
>  	}
>  	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
>  		INIT_LIST_HEAD(&open_ownerstr_hashtbl[i]);
> -		INIT_LIST_HEAD(&open_ownerid_hashtbl[i]);
>  	}
>  	for (i = 0; i < STATEID_HASH_SIZE; i++)
>  		INIT_LIST_HEAD(&stateid_hashtbl[i]);
>  	for (i = 0; i < LOCK_HASH_SIZE; i++) {
> -		INIT_LIST_HEAD(&lock_ownerid_hashtbl[i]);
>  		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
>  	}
>  	memset(&onestateid, ~0, sizeof(stateid_t));
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index e807abb..d6aec4f 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -45,24 +45,20 @@ typedef struct {
>  } clientid_t;
>  
>  typedef struct {
> -	u32             so_boot;
> -	u32             so_stateownerid;
> -	u32             so_fileid;
> +	clientid_t	so_clid;
> +	u32		so_id;
>  } stateid_opaque_t;
>  
>  typedef struct {
>  	u32                     si_generation;
>  	stateid_opaque_t        si_opaque;
>  } stateid_t;
> -#define si_boot           si_opaque.so_boot
> -#define si_stateownerid   si_opaque.so_stateownerid
> -#define si_fileid         si_opaque.so_fileid
>  
>  #define STATEID_FMT	"(%08x/%08x/%08x/%08x)"
>  #define STATEID_VAL(s) \
> -	(s)->si_boot, \
> -	(s)->si_stateownerid, \
> -	(s)->si_fileid, \
> +	(s)->si_opaque.so_clid.cl_boot, \
> +	(s)->si_opaque.so_clid.cl_id, \
> +	(s)->si_opaque.so_id, \
>  	(s)->si_generation
>  
>  struct nfsd4_callback {
> @@ -353,11 +349,9 @@ struct nfs4_replay {
>  */
>  
>  struct nfs4_stateowner {
> -	struct list_head        so_idhash;   /* hash by so_id */
>  	struct list_head        so_strhash;   /* hash by op_name */
>  	struct list_head        so_stateids;
>  	int			so_is_open_owner; /* 1=openowner,0=lockowner */
> -	u32                     so_id;
>  	struct nfs4_client *    so_client;
>  	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
>  	 * sequence id expected from the client: */
> @@ -415,8 +409,6 @@ struct nfs4_file {
>  	struct file_lock	*fi_lease;
>  	atomic_t		fi_delegees;
>  	struct inode		*fi_inode;
> -	u32                     fi_id;      /* used with stateowner->so_id 
> -					     * for stateid_hashtbl hash */
>  	bool			fi_had_conflict;
>  };
>  
