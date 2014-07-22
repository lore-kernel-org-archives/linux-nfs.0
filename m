Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52662 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752460AbaGVUQU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jul 2014 16:16:20 -0400
Date: Tue, 22 Jul 2014 16:16:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH 4/4] nfsd: Do not let nfs4_file pin the struct inode
Message-ID: <20140722201616.GR8438@fieldses.org>
References: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
 <1406047784-1578-5-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406047784-1578-5-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 22, 2014 at 12:49:44PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Remove the fi_inode field in struct nfs4_file in order to remove the
> possibility of struct nfs4_file pinning the inode when it does not have
> any open state.
> 
> Add a field to struct nfs4_ol_stateid, so that the lock stateid
> may continue to check for existing lock state before being released.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 31 +++++++++++++++----------------
>  fs/nfsd/state.h     |  2 +-
>  2 files changed, 16 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4c9404500a8e..9b5775f2af57 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -70,7 +70,7 @@ static u64 current_sessionid = 1;
>  #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
>  
>  /* forward declarations */
> -static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
> +static int check_for_locks(struct inode *inode, struct nfs4_lockowner *lowner);
>  
>  /* Locking: */
>  
> @@ -259,7 +259,6 @@ put_nfs4_file(struct nfs4_file *fi)
>  	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
>  		hlist_del(&fi->fi_hash);
>  		spin_unlock(&state_lock);
> -		iput(fi->fi_inode);
>  		nfsd4_free_file(fi);
>  	}
>  }
> @@ -2845,8 +2844,7 @@ static struct nfs4_file *nfsd4_alloc_file(void)
>  }
>  
>  /* OPEN Share state helper functions */
> -static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
> -		struct knfsd_fh *fh)
> +static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
>  {
>  	unsigned int hashval = file_hashval(fh);
>  
> @@ -2856,8 +2854,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
>  	spin_lock_init(&fp->fi_lock);
>  	INIT_LIST_HEAD(&fp->fi_stateids);
>  	INIT_LIST_HEAD(&fp->fi_delegations);
> -	ihold(ino);
> -	fp->fi_inode = ino;
>  	fh_copy_shallow(&fp->fi_fhandle, fh);
>  	fp->fi_had_conflict = false;
>  	fp->fi_lease = NULL;
> @@ -3065,14 +3061,14 @@ find_file(struct knfsd_fh *fh)
>  }
>  
>  static struct nfs4_file *
> -find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
> +find_or_add_file(struct nfs4_file *new, struct knfsd_fh *fh)
>  {
>  	struct nfs4_file *fp;
>  
>  	spin_lock(&state_lock);
>  	fp = find_file_locked(fh);
>  	if (fp == NULL) {
> -		nfsd4_init_file(new, ino, fh);
> +		nfsd4_init_file(new, fh);
>  		fp = new;
>  	}
>  	spin_unlock(&state_lock);
> @@ -3716,7 +3712,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>  	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
>  	struct nfs4_file *fp = NULL;
> -	struct inode *ino = current_fh->fh_dentry->d_inode;
>  	struct nfs4_ol_stateid *stp = NULL;
>  	struct nfs4_delegation *dp = NULL;
>  	__be32 status;
> @@ -3726,7 +3721,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  	 * and check for delegations in the process of being recalled.
>  	 * If not found, create the nfs4_file struct
>  	 */
> -	fp = find_or_add_file(ino, open->op_file, &current_fh->fh_handle);
> +	fp = find_or_add_file(open->op_file, &current_fh->fh_handle);
>  	if (fp != open->op_file) {
>  		status = nfs4_check_deleg(cl, open, &dp);
>  		if (status)
> @@ -4206,7 +4201,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
>  {
>  	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
>  
> -	if (check_for_locks(stp->st_file, lo))
> +	if (check_for_locks(stp->st_inode, lo))
>  		return nfserr_locks_held;
>  	release_lockowner_if_empty(lo);
>  	return nfs_ok;
> @@ -4665,7 +4660,9 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>  }
>  
>  static struct nfs4_ol_stateid *
> -alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
> +alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
> +		struct inode *inode,
> +		struct nfs4_ol_stateid *open_stp)
>  {
>  	struct nfs4_ol_stateid *stp;
>  	struct nfs4_client *clp = lo->lo_owner.so_client;
> @@ -4677,6 +4674,8 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
>  	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
>  	stp->st_stateowner = &lo->lo_owner;
>  	get_nfs4_file(fp);
> +	ihold(inode);

Don't we need a corresponding put somewhere?  Am I overlooking it?

--b.

> +	stp->st_inode = inode;
>  	stp->st_file = fp;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = open_stp->st_deny_bmap;
> @@ -4725,6 +4724,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
>  	struct nfs4_file *fi = ost->st_file;
>  	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
>  	struct nfs4_client *cl = oo->oo_owner.so_client;
> +	struct inode *inode = cstate->current_fh.fh_dentry->d_inode;
>  	struct nfs4_lockowner *lo;
>  	unsigned int strhashval;
>  	struct nfsd_net *nn = net_generic(cl->net, nfsd_net_id);
> @@ -4745,7 +4745,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
>  
>  	*lst = find_lock_stateid(lo, fi);
>  	if (*lst == NULL) {
> -		*lst = alloc_init_lock_stateid(lo, fi, ost);
> +		*lst = alloc_init_lock_stateid(lo, fi, inode, ost);
>  		if (*lst == NULL) {
>  			release_lockowner_if_empty(lo);
>  			return nfserr_jukebox;
> @@ -5098,10 +5098,9 @@ out_nfserr:
>   * 	0: no locks held by lockowner
>   */
>  static int
> -check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
> +check_for_locks(struct inode *inode, struct nfs4_lockowner *lowner)
>  {
>  	struct file_lock **flpp;
> -	struct inode *inode = filp->fi_inode;
>  	int status = 0;
>  
>  	spin_lock(&inode->i_lock);
> @@ -5160,7 +5159,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  	lo = lockowner(sop);
>  	/* see if there are still any locks associated with it */
>  	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
> -		if (check_for_locks(stp->st_file, lo))
> +		if (check_for_locks(stp->st_inode, lo))
>  			goto out;
>  	}
>  
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 33cf950b3873..ba711c66561e 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -397,7 +397,6 @@ struct nfs4_file {
>  	struct file_lock	*fi_lease;
>  	atomic_t		fi_delegees;
>  	struct knfsd_fh		fi_fhandle;
> -	struct inode		*fi_inode;
>  	bool			fi_had_conflict;
>  };
>  
> @@ -412,6 +411,7 @@ struct nfs4_ol_stateid {
>  	unsigned char                 st_access_bmap;
>  	unsigned char                 st_deny_bmap;
>  	struct nfs4_ol_stateid         * st_openstp;
> +	struct inode		    * st_inode;
>  };
>  
>  static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
> -- 
> 1.9.3
> 
