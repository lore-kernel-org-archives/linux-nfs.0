Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754880Ab2EPMw0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:52:26 -0400
Date: Wed, 16 May 2012 08:52:25 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: Use __be32 for variable holding return value
Message-ID: <20120516125225.GA17471@fieldses.org>
References: <20120515213808.1518.81260.stgit@lebasque.1015granger.net>
 <20120515214216.1518.85136.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120515214216.1518.85136.stgit@lebasque.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 05:42:16PM -0400, Chuck Lever wrote:
> Clean up: Use __be32 constants and variables consistently when
> handling pre-encoded NFS error values.

I already have patches for these committed to my for-3.5 branch.  If you
see anything in there I've missed, let me know.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfs4state.c |   19 ++++++++++---------
>  1 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 27e6401..9235cfa 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -885,7 +885,7 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
>  	struct nfsd4_session *new;
>  	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
>  	int numslots, slotsize;
> -	int status;
> +	__be32 status;
>  	int idx;
>  
>  	/*
> @@ -1476,12 +1476,12 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		  struct nfsd4_exchange_id *exid)
>  {
>  	struct nfs4_client *unconf, *conf, *new;
> -	int status;
>  	unsigned int		strhashval;
>  	char			dname[HEXDIR_LEN];
>  	char			addr_str[INET6_ADDRSTRLEN];
>  	nfs4_verifier		verf = exid->verifier;
>  	struct sockaddr		*sa = svc_addr(rqstp);
> +	__be32 status;
>  
>  	rpc_ntop(sa, addr_str, sizeof(addr_str));
>  	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
> @@ -1673,7 +1673,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	struct nfsd4_session *new;
>  	struct nfsd4_clid_slot *cs_slot = NULL;
>  	bool confirm_me = false;
> -	int status = 0;
> +	__be32 status = nfs_ok;
>  
>  	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
>  		return nfserr_inval;
> @@ -1914,7 +1914,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	struct nfsd4_session *session;
>  	struct nfsd4_slot *slot;
>  	struct nfsd4_conn *conn;
> -	int status;
> +	__be32 status;
>  
>  	if (resp->opcnt != 1)
>  		return nfserr_sequence_pos;
> @@ -2019,7 +2019,7 @@ __be32
>  nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
>  {
>  	struct nfs4_client *conf, *unconf, *clp;
> -	int status = 0;
> +	__be32 status = nfs_ok;
>  
>  	nfs4_lock_state();
>  	unconf = find_unconfirmed_client(&dc->clientid);
> @@ -2055,7 +2055,7 @@ out:
>  __be32
>  nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_reclaim_complete *rc)
>  {
> -	int status = 0;
> +	__be32 status = nfs_ok;
>  
>  	if (rc->rca_one_fs) {
>  		if (!cstate->current_fh.fh_dentry)
> @@ -3330,7 +3330,8 @@ static bool stateid_generation_after(stateid_t *a, stateid_t *b)
>  	return (s32)a->si_generation - (s32)b->si_generation > 0;
>  }
>  
> -static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
> +static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref,
> +				       bool has_session)
>  {
>  	/*
>  	 * When sessions are used the stateid generation number is ignored
> @@ -4049,7 +4050,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct file *filp = NULL;
>  	struct file_lock file_lock;
>  	struct file_lock conflock;
> -	__be32 status = 0;
> +	__be32 status = nfs_ok;
>  	bool new_state = false;
>  	int lkflg;
>  	int err;
> @@ -4172,7 +4173,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		update_stateid(&lock_stp->st_stid.sc_stateid);
>  		memcpy(&lock->lk_resp_stateid, &lock_stp->st_stid.sc_stateid, 
>  				sizeof(stateid_t));
> -		status = 0;
> +		status = nfs_ok;
>  		break;
>  	case (EAGAIN):		/* conflock holds conflicting lock */
>  		status = nfserr_denied;
> 
