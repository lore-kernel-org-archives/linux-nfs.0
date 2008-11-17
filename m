From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 16/51] nfsd41: stateid handling
Date: Mon, 17 Nov 2008 16:02:46 +0200
Message-ID: <49217986.5070409@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349967-10697-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:12709 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753152AbYKQOCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:02:49 -0500
In-Reply-To: <1226349967-10697-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:46 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Propagate the minorversion from open to the stateowner.
> 
> On first open set seqid to 1 and mark state confirmed
> 
> Skip seqid processing for NFSv4.1
> 
> 4.1 is allowed to ignore the generation number when it is zero
> whereas 4.0 returns bad_stateid or stale stateid.
> Propagate minorversion to all stateful ops and down to check_stateid_generation.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-12: look into using a minorversion in the coumpound cstate/args/res
rather than adding a minorversion member to each op's xdr struct.
* update_stateid should skip over seqid 0 when wrapping around;

> ---
>  fs/nfsd/nfs4proc.c         |   20 +++++++++++++++-----
>  fs/nfsd/nfs4state.c        |   37 +++++++++++++++++++++++++++++++------
>  fs/nfsd/nfs4xdr.c          |    8 ++++++++
>  include/linux/nfsd/state.h |    2 ++
>  include/linux/nfsd/xdr4.h  |    5 +++++
>  5 files changed, 61 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 876f285..b17948b 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -511,6 +511,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	   struct nfsd4_read *read)
>  {
>  	__be32 status;
> +	int flags = 0;
>  
>  	/* no need to check permission - this will be done in nfsd_read() */
>  
> @@ -518,11 +519,14 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (read->rd_offset >= OFFSET_MAX)
>  		return nfserr_inval;
>  
> +	flags = CHECK_FH | RD_STATE;
> +	if (read->rd_minorversion == 1)
> +		flags |= NFS_4_1;
>  	nfs4_lock_state();
>  	/* check stateid */
>  	if ((status = nfs4_preprocess_stateid_op(&cstate->current_fh,
>  				&read->rd_stateid,
> -				CHECK_FH | RD_STATE, &read->rd_filp))) {
> +				flags, &read->rd_filp))) {
>  		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
>  		goto out;
>  	}
> @@ -649,12 +653,15 @@ static __be32
>  nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	      struct nfsd4_setattr *setattr)
>  {
> -	__be32 status = nfs_ok;
> +	__be32 status = nfs_ok, flags = 0;
>  
>  	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
> +		flags = CHECK_FH | WR_STATE;
> +		if (setattr->sa_minorversion == 1)
> +			flags |= NFS_4_1;
>  		nfs4_lock_state();
>  		status = nfs4_preprocess_stateid_op(&cstate->current_fh,
> -			&setattr->sa_stateid, CHECK_FH | WR_STATE, NULL);
> +			&setattr->sa_stateid, flags, NULL);
>  		nfs4_unlock_state();
>  		if (status) {
>  			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
> @@ -684,16 +691,19 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	stateid_t *stateid = &write->wr_stateid;
>  	struct file *filp = NULL;
>  	u32 *p;
> -	__be32 status = nfs_ok;
> +	__be32 status = nfs_ok, flags = 0;
>  
>  	/* no need to check permission - this will be done in nfsd_write() */
>  
>  	if (write->wr_offset >= OFFSET_MAX)
>  		return nfserr_inval;
>  
> +	flags = CHECK_FH | WR_STATE;
> +	if (write->wr_minorversion == 1)
> +		flags |= NFS_4_1;
>  	nfs4_lock_state();
>  	status = nfs4_preprocess_stateid_op(&cstate->current_fh, stateid,
> -					CHECK_FH | WR_STATE, &filp);
> +					flags, &filp);
>  	if (filp)
>  		get_file(filp);
>  	nfs4_unlock_state();
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 23e83e2..2e6e9d5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1115,6 +1115,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>  	sop->so_client = clp;
>  	sop->so_seqid = open->op_seqid;
>  	sop->so_confirmed = 0;
> +	sop->so_minorversion = open->op_minorversion;
>  	rp = &sop->so_replay;
>  	rp->rp_status = nfserr_serverfault;
>  	rp->rp_buflen = 0;
> @@ -1524,6 +1525,9 @@ nfsd4_process_open1(struct nfsd4_open *open)
>  		open->op_stateowner = NULL;
>  		goto renew;
>  	}
> +	/* Skip seqid processing for NFSv4.1 */
> +	if (open->op_minorversion == 1)
> +		goto renew;
>  	if (open->op_seqid == sop->so_seqid - 1) {
>  		if (sop->so_replay.rp_buflen)
>  			return nfserr_replay_me;
> @@ -1852,9 +1856,14 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
>  			release_stateid(stp, OPEN_STATE);
>  			goto out;
>  		}
> +		if (open->op_minorversion == 1)
> +			update_stateid(&stp->st_stateid);
>  	}
>  	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
>  
> +	if (open->op_minorversion == 1)
> +		open->op_stateowner->so_confirmed = 1;
> +
>  	/*
>  	* Attempt to hand out a delegation. No error return, because the
>  	* OPEN succeeds even if we fail.
> @@ -1875,7 +1884,7 @@ out:
>  	* To finish the open response, we just need to set the rflags.
>  	*/
>  	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
> -	if (!open->op_stateowner->so_confirmed)
> +	if (!open->op_stateowner->so_confirmed && !open->op_minorversion)
>  		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
>  
>  	return status;
> @@ -2096,8 +2105,16 @@ io_during_grace_disallowed(struct inode *inode, int flags)
>  		&& mandatory_lock(inode);
>  }
>  
> -static int check_stateid_generation(stateid_t *in, stateid_t *ref)
> +static int check_stateid_generation(stateid_t *in, stateid_t *ref,
> +				    u32 minorversion)

review 11-12: rename to bool check_zero_seq

>  {
> +	/*
> +	 * 4.1 is allowed to ignore the generation number when it is zero
> +	 * whereas 4.0 returns bad_stateid or stale stateid.
> +	 */
> +	if (minorversion && in->si_generation == 0)
> +		goto out;
> +
>  	/* If the client sends us a stateid from the future, it's buggy: */
>  	if (in->si_generation > ref->si_generation)
>  		return nfserr_bad_stateid;
> @@ -2113,6 +2130,7 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref)
>  	 */
>  	if (in->si_generation < ref->si_generation)
>  		return nfserr_old_stateid;
> +out:
>  	return nfs_ok;
>  }
>  
> @@ -2164,7 +2182,8 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
>  			goto out;
>  		stidp = &stp->st_stateid;
>  	}
> -	status = check_stateid_generation(stateid, stidp);
> +	status = check_stateid_generation(stateid, stidp,
> +					  (flags & NFS_4_1) != 0);
>  	if (status)
>  		goto out;
>  	if (stp) {
> @@ -2275,7 +2294,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
>  	*  For the moment, we ignore the possibility of 
>  	*  generation number wraparound.
>  	*/
> -	if (seqid != sop->so_seqid)
> +	if (sop->so_minorversion == 0 && seqid != sop->so_seqid)
>  		goto check_replay;
>  
>  	if (sop->so_confirmed && flags & CONFIRM) {
> @@ -2288,7 +2307,8 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
>  				" confirmed yet!\n");
>  		return nfserr_bad_stateid;
>  	}
> -	status = check_stateid_generation(stateid, &stp->st_stateid);
> +	status = check_stateid_generation(stateid, &stp->st_stateid,
> +					  sop->so_minorversion);
>  	if (status)
>  		return status;
>  	renew_client(sop->so_client);
> @@ -2480,13 +2500,17 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		  struct nfsd4_delegreturn *dr)
>  {
>  	__be32 status;
> +	int flags = 0;
>  
>  	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
>  		goto out;
>  
>  	nfs4_lock_state();
> +	flags |= DELEG_RET;
> +	if (dr->dr_minorversion == 1)
> +		flags |= NFS_4_1;
>  	status = nfs4_preprocess_stateid_op(&cstate->current_fh,
> -					    &dr->dr_stateid, DELEG_RET, NULL);
> +					    &dr->dr_stateid, flags, NULL);
>  	nfs4_unlock_state();
>  out:
>  	return status;
> @@ -2659,6 +2683,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>  	 * case of new lockowners; so increment the lock seqid manually: */
>  	sop->so_seqid = lock->lk_new_lock_seqid + 1;
>  	sop->so_confirmed = 1;
> +	sop->so_minorversion = open_stp->st_stateowner->so_minorversion;
>  	rp = &sop->so_replay;
>  	rp->rp_status = nfserr_serverfault;
>  	rp->rp_buflen = 0;
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index f7dec05..9b26ba9 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -633,6 +633,8 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  	open->op_iattr.ia_valid = 0;
>  	open->op_stateowner = NULL;
>  
> +	open->op_minorversion = argp->minorversion;
> +
>  	/* seqid, share_access, share_deny, clientid, ownerlen */
>  	READ_BUF(16 + sizeof(clientid_t));
>  	READ32(open->op_seqid);
> @@ -756,6 +758,8 @@ nfsd4_decode_read(struct nfsd4_compoundargs *argp, struct nfsd4_read *read)
>  {
>  	DECODE_HEAD;
>  
> +	read->rd_minorversion = argp->minorversion;
> +
>  	status = nfsd4_decode_stateid(argp, &read->rd_stateid);
>  	if (status)
>  		return status;
> @@ -850,6 +854,8 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
>  {
>  	__be32 status;
>  
> +	setattr->sa_minorversion = argp->minorversion;
> +
>  	status = nfsd4_decode_stateid(argp, &setattr->sa_stateid);
>  	if (status)
>  		return status;
> @@ -939,6 +945,8 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
>  	int len;
>  	DECODE_HEAD;
>  
> +	write->wr_minorversion = argp->minorversion;
> +
>  	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
>  	if (status)
>  		return status;
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 85cdaf1..5cb4142 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -290,6 +290,7 @@ struct nfs4_stateowner {
>  	u32                     so_seqid;
>  	struct xdr_netobj       so_owner;     /* open owner name */
>  	int                     so_confirmed; /* successful OPEN_CONFIRM? */
> +	u32			so_minorversion;
>  	struct nfs4_replay	so_replay;
>  };
>  
> @@ -349,6 +350,7 @@ struct nfs4_stateid {
>  #define WR_STATE	        0x00000020
>  #define CLOSE_STATE             0x00000040
>  #define DELEG_RET               0x00000080
> +#define NFS_4_1			0x00000100

review 11-12: rename to CHECK_ZERO_SEQ

>  
>  #define seqid_mutating_err(err)                       \
>  	(((err) != nfserr_stale_clientid) &&    \
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 88f7cd6..81c249c 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -105,6 +105,7 @@ struct nfsd4_create {
>  
>  struct nfsd4_delegreturn {
>  	stateid_t	dr_stateid;
> +	u32		dr_minorversion;
>  };
>  
>  struct nfsd4_getattr {
> @@ -223,6 +224,7 @@ struct nfsd4_open {
>  	u32		op_recall;          /* recall */
>  	struct nfsd4_change_info  op_cinfo; /* response */
>  	u32		op_rflags;          /* response */
> +	u32		op_minorversion;    /* used during processing */
>  	int		op_truncate;        /* used during processing */
>  	struct nfs4_stateowner *op_stateowner; /* used during processing */
>  	struct nfs4_acl *op_acl;
> @@ -255,6 +257,7 @@ struct nfsd4_read {
>  	
>  	struct svc_rqst *rd_rqstp;          /* response */
>  	struct svc_fh * rd_fhp;             /* response */
> +	u32		rd_minorversion;    /* processing */
>  };
>  
>  struct nfsd4_readdir {
> @@ -304,6 +307,7 @@ struct nfsd4_secinfo {
>  
>  struct nfsd4_setattr {
>  	stateid_t	sa_stateid;         /* request */
> +	u32		sa_minorversion;    /* processing */
>  	u32		sa_bmval[2];        /* request */
>  	struct iattr	sa_iattr;           /* request */
>  	struct nfs4_acl *sa_acl;
> @@ -345,6 +349,7 @@ struct nfsd4_write {
>  	u32		wr_bytes_written;   /* response */
>  	u32		wr_how_written;     /* response */
>  	nfs4_verifier	wr_verifier;        /* response */
> +	u32		wr_minorversion;    /* processing */
>  };
>  
>  struct nfsd4_op {
