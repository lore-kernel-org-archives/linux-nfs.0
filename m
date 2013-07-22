Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:34055 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933127Ab3GVS7D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 14:59:03 -0400
Message-ID: <51ED80F4.9080102@netapp.com>
Date: Mon, 22 Jul 2013 14:59:00 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 2/5] NFSD: Implement the COPY call
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com> <1374267830-30154-3-git-send-email-bjschuma@netapp.com> <20130722180527.GA10109@fieldses.org>
In-Reply-To: <20130722180527.GA10109@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/22/2013 02:05 PM, J. Bruce Fields wrote:
> On Fri, Jul 19, 2013 at 05:03:47PM -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> I only implemented the sync version of this call, since it's the
>> easiest.  I can simply call vfs_copy_range() and have the vfs do the
>> right thing for the filesystem being exported.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfsd/nfs4proc.c   |  75 ++++++++++++++++++++++++++++---
>>  fs/nfsd/nfs4state.c  |   4 +-
>>  fs/nfsd/nfs4xdr.c    | 121 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>>  fs/nfsd/state.h      |   2 +-
>>  fs/nfsd/vfs.c        |   9 ++++
>>  fs/nfsd/vfs.h        |   1 +
>>  fs/nfsd/xdr4.h       |  24 ++++++++++
>>  include/linux/nfs4.h |   3 ++
>>  8 files changed, 230 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index a7cee86..d4584ea 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -780,8 +780,9 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  
>>  	nfs4_lock_state();
>>  	/* check stateid */
>> -	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
>> -						 cstate, &read->rd_stateid,
>> +	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +						 &cstate->current_fh,
>> +						 &read->rd_stateid,
>>  						 RD_STATE, &read->rd_filp))) {
>>  		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
>>  		goto out;
>> @@ -931,7 +932,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
>>  		nfs4_lock_state();
>>  		status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> -			&setattr->sa_stateid, WR_STATE, NULL);
>> +			&cstate->current_fh, &setattr->sa_stateid, WR_STATE, NULL);
>>  		nfs4_unlock_state();
>>  		if (status) {
>>  			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
>> @@ -999,8 +1000,9 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  		return nfserr_inval;
>>  
>>  	nfs4_lock_state();
>> -	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
>> -					cstate, stateid, WR_STATE, &filp);
>> +	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +					    &cstate->current_fh, stateid,
>> +					    WR_STATE, &filp);
>>  	if (status) {
>>  		nfs4_unlock_state();
>>  		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
>> @@ -1028,6 +1030,63 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>  	return status;
>>  }
>>  
>> +static __be32
>> +nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		  struct nfsd4_copy *copy, struct file **src, struct file **dst)
>> +{
>> +	__be32 status;
>> +	/* only support copying data to an existing file */
>> +	if (!cstate->current_fh.fh_dentry || !cstate->save_fh.fh_dentry)
>> +		return nfserr_nofilehandle;
>> +
>> +	nfs4_lock_state();
>> +	/* check stateids */
>> +	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +						 &cstate->save_fh,
>> +						 &copy->cp_src_stateid,
>> +						 RD_STATE, src))){
>> +		dprintk("NFSD: nfsd4_copy: couldn't process src stateid!\n");
>> +		goto out;
>> +	}
>> +
>> +	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
>> +						 &cstate->current_fh,
>> +						 &copy->cp_dst_stateid,
>> +						 WR_STATE, dst))){
>> +		dprintk("NFSD: nfsd4_copy: couldn't process dst stateid!\n");
>> +		goto out;
>> +	}
>> +
>> +out:
>> +	nfs4_unlock_state();
>> +	return status;
>> +}
>> +
>> +static __be32
>> +nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		struct nfsd4_copy *copy)
>> +{
>> +	__be32 status;
>> +	struct file *src = NULL, *dst = NULL;
>> +
>> +	status = nfsd4_verify_copy(rqstp, cstate, copy, &src, &dst);
>> +	if (status)
>> +		return status;
>> +
>> +	status = nfsd_copy_range(src, copy->cp_src_pos,
>> +				 dst, copy->cp_dst_pos,
>> +				 copy->cp_count);
>> +
>> +	if (status == nfs_ok) {
>> +		copy->cp_res.wr_stateid = NULL;
>> +		copy->cp_res.wr_bytes_written = copy->cp_count;
>> +		copy->cp_res.wr_stable_how = NFS_FILE_SYNC;
>> +		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
>> +	}
>> +
>> +	return status;
>> +}
>> +
>>  /* This routine never returns NFS_OK!  If there are no other errors, it
>>   * will return NFSERR_SAME or NFSERR_NOT_SAME depending on whether the
>>   * attributes matched.  VERIFY is implemented by mapping NFSERR_SAME
>> @@ -1840,6 +1899,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
>>  		.op_get_currentstateid = (stateid_getter)nfsd4_get_freestateid,
>>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>>  	},
>> +
>> +	/* NFSv4.2 operations */
>> +	[OP_COPY] = {
>> +		.op_func = (nfsd4op_func)nfsd4_copy,
>> +		.op_name = "OP_COPY",
> 
> This needs more fields filled in.  Probably take the OP_WRITE entry as a
> starting point.

I'll look, thanks for the tip!

> 
>> +	}
>>  };
>>  
>>  #ifdef NFSD_DEBUG
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 280acef..c4e270e 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -3613,12 +3613,12 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
>>  */
>>  __be32
>>  nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
>> -			   stateid_t *stateid, int flags, struct file **filpp)
>> +			   struct svc_fh *current_fh, stateid_t *stateid,
>> +			   int flags, struct file **filpp)
>>  {
>>  	struct nfs4_stid *s;
>>  	struct nfs4_ol_stateid *stp = NULL;
>>  	struct nfs4_delegation *dp = NULL;
>> -	struct svc_fh *current_fh = &cstate->current_fh;
>>  	struct inode *ino = current_fh->fh_dentry->d_inode;
>>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>>  	__be32 status;
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 0c0f3ea9..8f84e9e 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1485,6 +1485,26 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>>  }
>>  
>>  static __be32
>> +nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
>> +{
>> +	DECODE_HEAD;
>> +
>> +	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
>> +	if (status)
>> +		return status;
>> +	status = nfsd4_decode_stateid(argp, &copy->cp_dst_stateid);
>> +	if (status)
>> +		return status;
>> +
>> +	READ_BUF(24);
>> +	READ64(copy->cp_src_pos);
>> +	READ64(copy->cp_dst_pos);
>> +	READ64(copy->cp_count);
>> +
>> +	DECODE_TAIL;
>> +}
>> +
>> +static __be32
>>  nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
>>  {
>>  	return nfs_ok;
>> @@ -1599,6 +1619,70 @@ static nfsd4_dec nfsd41_dec_ops[] = {
>>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
>>  };
>>  
>> +static nfsd4_dec nfsd42_dec_ops[] = {
>> +	[OP_ACCESS]		= (nfsd4_dec)nfsd4_decode_access,
>> +	[OP_CLOSE]		= (nfsd4_dec)nfsd4_decode_close,
>> +	[OP_COMMIT]		= (nfsd4_dec)nfsd4_decode_commit,
>> +	[OP_CREATE]		= (nfsd4_dec)nfsd4_decode_create,
>> +	[OP_DELEGPURGE]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_DELEGRETURN]	= (nfsd4_dec)nfsd4_decode_delegreturn,
>> +	[OP_GETATTR]		= (nfsd4_dec)nfsd4_decode_getattr,
>> +	[OP_GETFH]		= (nfsd4_dec)nfsd4_decode_noop,
>> +	[OP_LINK]		= (nfsd4_dec)nfsd4_decode_link,
>> +	[OP_LOCK]		= (nfsd4_dec)nfsd4_decode_lock,
>> +	[OP_LOCKT]		= (nfsd4_dec)nfsd4_decode_lockt,
>> +	[OP_LOCKU]		= (nfsd4_dec)nfsd4_decode_locku,
>> +	[OP_LOOKUP]		= (nfsd4_dec)nfsd4_decode_lookup,
>> +	[OP_LOOKUPP]		= (nfsd4_dec)nfsd4_decode_noop,
>> +	[OP_NVERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
>> +	[OP_OPEN]		= (nfsd4_dec)nfsd4_decode_open,
>> +	[OP_OPENATTR]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_OPEN_CONFIRM]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_OPEN_DOWNGRADE]	= (nfsd4_dec)nfsd4_decode_open_downgrade,
>> +	[OP_PUTFH]		= (nfsd4_dec)nfsd4_decode_putfh,
>> +	[OP_PUTPUBFH]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_PUTROOTFH]		= (nfsd4_dec)nfsd4_decode_noop,
>> +	[OP_READ]		= (nfsd4_dec)nfsd4_decode_read,
>> +	[OP_READDIR]		= (nfsd4_dec)nfsd4_decode_readdir,
>> +	[OP_READLINK]		= (nfsd4_dec)nfsd4_decode_noop,
>> +	[OP_REMOVE]		= (nfsd4_dec)nfsd4_decode_remove,
>> +	[OP_RENAME]		= (nfsd4_dec)nfsd4_decode_rename,
>> +	[OP_RENEW]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_RESTOREFH]		= (nfsd4_dec)nfsd4_decode_noop,
>> +	[OP_SAVEFH]		= (nfsd4_dec)nfsd4_decode_noop,
>> +	[OP_SECINFO]		= (nfsd4_dec)nfsd4_decode_secinfo,
>> +	[OP_SETATTR]		= (nfsd4_dec)nfsd4_decode_setattr,
>> +	[OP_SETCLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_SETCLIENTID_CONFIRM]= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_VERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
>> +	[OP_WRITE]		= (nfsd4_dec)nfsd4_decode_write,
>> +	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +
>> +	/* new operations for NFSv4.1 */
>> +	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_backchannel_ctl,
>> +	[OP_BIND_CONN_TO_SESSION]= (nfsd4_dec)nfsd4_decode_bind_conn_to_session,
>> +	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
>> +	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
>> +	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
>> +	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_free_stateid,
>> +	[OP_GET_DIR_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_secinfo_no_name,
>> +	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
>> +	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_test_stateid,
>> +	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
>> +	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
>> +
>> +	/* new operations for NFS v4.2 */
>> +	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
>> +};
>> +
>>  struct nfsd4_minorversion_ops {
>>  	nfsd4_dec *decoders;
>>  	int nops;
>> @@ -1607,7 +1691,7 @@ struct nfsd4_minorversion_ops {
>>  static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
>>  	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
>>  	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
>> -	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
>> +	[2] = { nfsd42_dec_ops, ARRAY_SIZE(nfsd42_dec_ops) },
>>  };
>>  
>>  static __be32
>> @@ -3518,6 +3602,38 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
>>  	return nfserr;
>>  }
>>  
>> +static void
>> +nfsd42_encode_write_res(struct nfsd4_compoundres *resp, struct nfsd42_write_res *write)
>> +{
>> +	__be32 *p;
>> +
>> +	RESERVE_SPACE(4);
>> +
>> +	if (write->wr_stateid == NULL) {
>> +		WRITE32(0);
>> +		ADJUST_ARGS();
>> +	} else {
>> +		WRITE32(1);
>> +		ADJUST_ARGS();
>> +		nfsd4_encode_stateid(resp, write->wr_stateid);
>> +	}
>> +
>> +	RESERVE_SPACE(12 + NFS4_VERIFIER_SIZE);
>> +	WRITE64(write->wr_bytes_written);
>> +	WRITE32(write->wr_stable_how);
>> +	WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
>> +	ADJUST_ARGS();
> 
> If I'm reading
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19 14.1.2
> correctly....  This should be just an offset in the error case, right?

Yeah, I think it should be... I'll fix that up once I figure out where I can find an offset!

> 
> Also, may as well share code in the succesful case with
> nfsd4_encode_write().

Okay, I'll see what I can do.  Thanks!

- Bryan
> 
> --b.
> 
>> +}
>> +
>> +static __be32
>> +nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
>> +		  struct nfsd4_copy *copy)
>> +{
>> +	if (!nfserr)
>> +		nfsd42_encode_write_res(resp, &copy->cp_res);
>> +	return nfserr;
>> +}
>> +
>>  static __be32
>>  nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
>>  {
>> @@ -3590,6 +3706,9 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>>  	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
>>  	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
>>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
>> +
>> +	/* NFSv4.2 operations */
>> +	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
>>  };
>>  
>>  /*
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index 424d8f5..2478805 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -455,7 +455,7 @@ struct nfsd4_compound_state;
>>  struct nfsd_net;
>>  
>>  extern __be32 nfs4_preprocess_stateid_op(struct net *net,
>> -		struct nfsd4_compound_state *cstate,
>> +		struct nfsd4_compound_state *cstate, struct svc_fh *,
>>  		stateid_t *stateid, int flags, struct file **filp);
>>  extern void nfs4_lock_state(void);
>>  extern void nfs4_unlock_state(void);
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 8ff6a00..d77958d 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -649,6 +649,15 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  }
>>  #endif
>>  
>> +__be32 nfsd_copy_range(struct file *src, u64 src_pos,
>> +		       struct file *dst, u64 dst_pos,
>> +		       u64 count)
>> +{
>> +	int err = vfs_copy_range(src, src_pos, dst, dst_pos, count);
>> +	if (err < 0)
>> +		return nfserrno(err);
>> +	return vfs_fsync_range(dst, dst_pos, dst_pos + count, 0);
>> +}
>>  #endif /* defined(CONFIG_NFSD_V4) */
>>  
>>  #ifdef CONFIG_NFSD_V3
>> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
>> index a4be2e3..0f26c3b 100644
>> --- a/fs/nfsd/vfs.h
>> +++ b/fs/nfsd/vfs.h
>> @@ -86,6 +86,7 @@ __be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
>>  				struct svc_fh *res, struct iattr *);
>>  __be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
>>  				char *, int, struct svc_fh *);
>> +__be32		nfsd_copy_range(struct file *, u64, struct file *, u64, u64);
>>  __be32		nfsd_rename(struct svc_rqst *,
>>  				struct svc_fh *, char *, int,
>>  				struct svc_fh *, char *, int);
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index b3ed644..55b9ef7 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -430,6 +430,27 @@ struct nfsd4_reclaim_complete {
>>  	u32 rca_one_fs;
>>  };
>>  
>> +struct nfsd42_write_res {
>> +	stateid_t		*wr_stateid;
>> +	u64			wr_bytes_written;
>> +	u32			wr_stable_how;
>> +	nfs4_verifier		wr_verifier;
>> +};
>> +
>> +struct nfsd4_copy {
>> +	/* request */
>> +	stateid_t	cp_src_stateid;
>> +	stateid_t	cp_dst_stateid;
>> +
>> +	u64		cp_src_pos;
>> +	u64		cp_dst_pos;
>> +
>> +	u64		cp_count;
>> +
>> +	/* response */
>> +	struct nfsd42_write_res	cp_res;
>> +};
>> +
>>  struct nfsd4_op {
>>  	int					opnum;
>>  	__be32					status;
>> @@ -475,6 +496,9 @@ struct nfsd4_op {
>>  		struct nfsd4_reclaim_complete	reclaim_complete;
>>  		struct nfsd4_test_stateid	test_stateid;
>>  		struct nfsd4_free_stateid	free_stateid;
>> +
>> +		/* NFSv4.2 */
>> +		struct nfsd4_copy		copy;
>>  	} u;
>>  	struct nfs4_replay *			replay;
>>  };
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index e36dee5..ebf60c6 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -110,6 +110,9 @@ enum nfs_opnum4 {
>>  	OP_DESTROY_CLIENTID = 57,
>>  	OP_RECLAIM_COMPLETE = 58,
>>  
>> +	/* nfs42 */
>> +	OP_COPY = 59,
>> +
>>  	OP_ILLEGAL = 10044,
>>  };
>>  
>> -- 
>> 1.8.3.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

