Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5419 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab1DVGw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 02:52:57 -0400
Message-ID: <4DB125BD.3040703@panasas.com>
Date: Fri, 22 Apr 2011 09:52:45 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 03/27] pnfs: layoutreturn
References: <4DAF0DE1.6020609@panasas.com>	 <1303320392-21068-1-git-send-email-bhalevy@panasas.com> <1303329221.23206.22.camel@lade.trondhjem.org>
In-Reply-To: <1303329221.23206.22.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-20 22:53, Trond Myklebust wrote:
> On Wed, 2011-04-20 at 20:26 +0300, Benny Halevy wrote:
>> @@ -1424,9 +1424,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>>   */
>>  void nfs4_evict_inode(struct inode *inode)
>>  {
>> -	pnfs_destroy_layout(NFS_I(inode));
>> +	pnfs_return_layout(inode, NULL, true);
> 
> Why does this want to come before the call to truncate_inode_pages()?

Actually, I don't see any good reason. :-/

> Is there any reason not to put pnfs_return_layout() and
> pnfs_destroy_layout into a single helper here?
> 

Looks like an overkill to me for this one call site.

>>  	truncate_inode_pages(&inode->i_data, 0);
>>  	end_writeback(inode);
>> +	pnfs_destroy_layout(NFS_I(inode));
>>  	/* If we are holding a delegation, return it! */
>>  	nfs_inode_return_delegation_noreclaim(inode);
>>  	/* First call standard NFS clear_inode() code */
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 9bf41ea..b03defb 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5662,6 +5662,103 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
>>  	return status;
>>  }
>>  
>> +static void
>> +nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
>> +{
>> +	struct nfs4_layoutreturn *lrp = calldata;
>> +
>> +	dprintk("--> %s\n", __func__);
>> +	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
>> +				&lrp->res.seq_res, 0, task))
>> +		return;
>> +	rpc_call_start(task);
>> +}
>> +
>> +static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
>> +{
>> +	struct nfs4_layoutreturn *lrp = calldata;
>> +	struct nfs_server *server;
>> +
>> +	dprintk("--> %s\n", __func__);
>> +
>> +	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
>> +		return;
>> +
>> +	if (lrp->args.return_type == RETURN_FILE)
>> +		server = NFS_SERVER(lrp->args.inode);
>> +	else
>> +		server = NULL;
>> +	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
>> +		nfs_restart_rpc(task, lrp->clp);
>> +		return;
>> +	}
>> +	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE)) {
>> +		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
>> +
>> +		spin_lock(&lo->plh_inode->i_lock);
>> +		if (lrp->res.lrs_present)
>> +			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
>> +		else
>> +			BUG_ON(!list_empty(&lo->plh_segs));
>> +		spin_unlock(&lo->plh_inode->i_lock);
>> +	}
>> +	dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +static void nfs4_layoutreturn_release(void *calldata)
>> +{
>> +	struct nfs4_layoutreturn *lrp = calldata;
>> +
>> +	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
>> +	if (lrp->args.return_type == RETURN_FILE) {
>> +		struct inode *ino = lrp->args.inode;
>> +		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
>> +
>> +		put_layout_hdr(lo);
>> +	}
>> +	kfree(calldata);
>> +	dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
>> +	.rpc_call_prepare = nfs4_layoutreturn_prepare,
>> +	.rpc_call_done = nfs4_layoutreturn_done,
>> +	.rpc_release = nfs4_layoutreturn_release,
>> +};
>> +
>> +int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
> 
> Why the 'issync' parameter?
> 

Hmm, you're right.  Currently all call sites use it as sync.

>> +{
>> +	struct rpc_task *task;
>> +	struct rpc_message msg = {
>> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTRETURN],
>> +		.rpc_argp = &lrp->args,
>> +		.rpc_resp = &lrp->res,
>> +	};
>> +	struct rpc_task_setup task_setup_data = {
>> +		.rpc_client = lrp->clp->cl_rpcclient,
>> +		.rpc_message = &msg,
>> +		.callback_ops = &nfs4_layoutreturn_call_ops,
>> +		.callback_data = lrp,
>> +		.flags = RPC_TASK_ASYNC,
>> +	};
>> +	int status = 0;
>> +
>> +	dprintk("--> %s\n", __func__);
>> +	task = rpc_run_task(&task_setup_data);
>> +	if (IS_ERR(task))
>> +		return PTR_ERR(task);
>> +	if (!issync)
>> +		goto out;
>> +	status = nfs4_wait_for_completion_rpc_task(task);
>> +	if (status != 0)
>> +		goto out;
>> +	status = task->tk_status;
>> +out:
>> +	dprintk("<-- %s\n", __func__);
>> +	rpc_put_task(task);
>> +	return status;
>> +}
>> +
>>  static int
>>  _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
>>  {
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index dddfb57..53ea3e5 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -338,7 +338,12 @@ static int nfs4_stat_to_errno(int);
>>  				1 /* layoutupdate4 layout type */ + \
>>  				1 /* NULL filelayout layoutupdate4 payload */)
>>  #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
>> -
>> +#define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
>> +				encode_stateid_maxsz + \
>> +				1 /* FIXME: opaque lrf_body always empty at
>> +				   *the moment */)
>> +#define decode_layoutreturn_maxsz (op_decode_hdr_maxsz + \
>> +				1 + decode_stateid_maxsz)
>>  #else /* CONFIG_NFS_V4_1 */
>>  #define encode_sequence_maxsz	0
>>  #define decode_sequence_maxsz	0
>> @@ -760,7 +765,14 @@ static int nfs4_stat_to_errno(int);
>>  				decode_putfh_maxsz + \
>>  				decode_layoutcommit_maxsz + \
>>  				decode_getattr_maxsz)
>> -
>> +#define NFS4_enc_layoutreturn_sz (compound_encode_hdr_maxsz + \
>> +				encode_sequence_maxsz + \
>> +				encode_putfh_maxsz + \
>> +				encode_layoutreturn_maxsz)
>> +#define NFS4_dec_layoutreturn_sz (compound_decode_hdr_maxsz + \
>> +				decode_sequence_maxsz + \
>> +				decode_putfh_maxsz + \
>> +				decode_layoutreturn_maxsz)
>>  
>>  const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
>>  				      compound_encode_hdr_maxsz +
>> @@ -1890,6 +1902,37 @@ encode_layoutcommit(struct xdr_stream *xdr,
>>  	hdr->replen += decode_layoutcommit_maxsz;
>>  	return 0;
>>  }
>> +
>> +static void
>> +encode_layoutreturn(struct xdr_stream *xdr,
>> +		    const struct nfs4_layoutreturn_args *args,
>> +		    struct compound_hdr *hdr)
>> +{
>> +	nfs4_stateid stateid;
>> +	__be32 *p;
>> +
>> +	p = reserve_space(xdr, 20);
>> +	*p++ = cpu_to_be32(OP_LAYOUTRETURN);
>> +	*p++ = cpu_to_be32(args->reclaim);
>> +	*p++ = cpu_to_be32(args->layout_type);
>> +	*p++ = cpu_to_be32(args->range.iomode);
>> +	*p = cpu_to_be32(args->return_type);
>> +	if (args->return_type == RETURN_FILE) {
>> +		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
>> +		p = xdr_encode_hyper(p, args->range.offset);
>> +		p = xdr_encode_hyper(p, args->range.length);
>> +		spin_lock(&args->inode->i_lock);
>> +		memcpy(stateid.data, NFS_I(args->inode)->layout->plh_stateid.data,
>> +		       NFS4_STATEID_SIZE);
>> +		spin_unlock(&args->inode->i_lock);
>> +		p = xdr_encode_opaque_fixed(p, &stateid.data,
>> +					    NFS4_STATEID_SIZE);
>> +		p = reserve_space(xdr, 4);
>> +		*p = cpu_to_be32(0);
>> +	}
>> +	hdr->nops++;
>> +	hdr->replen += decode_layoutreturn_maxsz;
>> +}
>>  #endif /* CONFIG_NFS_V4_1 */
>>  
>>  /*
>> @@ -2707,9 +2750,9 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
>>  /*
>>   *  Encode LAYOUTCOMMIT request
>>   */
>> -static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
>> -				     struct xdr_stream *xdr,
>> -				     struct nfs4_layoutcommit_args *args)
>> +static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
>> +				      struct xdr_stream *xdr,
>> +				      struct nfs4_layoutcommit_args *args)
>>  {
>>  	struct compound_hdr hdr = {
>>  		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
>> @@ -2721,7 +2764,24 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
>>  	encode_layoutcommit(xdr, args, &hdr);
>>  	encode_getfattr(xdr, args->bitmask, &hdr);
>>  	encode_nops(&hdr);
>> -	return 0;
>> +}
>> +
>> +/*
>> + * Encode LAYOUTRETURN request
>> + */
>> +static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
>> +				      struct xdr_stream *xdr,
>> +				      struct nfs4_layoutreturn_args *args)
>> +{
>> +	struct compound_hdr hdr = {
>> +		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
>> +	};
>> +
>> +	encode_compound_hdr(xdr, req, &hdr);
>> +	encode_sequence(xdr, &args->seq_args, &hdr);
>> +	encode_putfh(xdr, NFS_FH(args->inode), &hdr);
>> +	encode_layoutreturn(xdr, args, &hdr);
>> +	encode_nops(&hdr);
>>  }
>>  #endif /* CONFIG_NFS_V4_1 */
>>  
>> @@ -5202,6 +5262,27 @@ out_overflow:
>>  	return -EIO;
>>  }
>>  
>> +static int decode_layoutreturn(struct xdr_stream *xdr,
>> +			       struct nfs4_layoutreturn_res *res)
>> +{
>> +	__be32 *p;
>> +	int status;
>> +
>> +	status = decode_op_hdr(xdr, OP_LAYOUTRETURN);
>> +	if (status)
>> +		return status;
>> +	p = xdr_inline_decode(xdr, 4);
>> +	if (unlikely(!p))
>> +		goto out_overflow;
>> +	res->lrs_present = be32_to_cpup(p);
>> +	if (res->lrs_present)
>> +		status = decode_stateid(xdr, &res->stateid);
>> +	return status;
>> +out_overflow:
>> +	print_overflow_msg(__func__, xdr);
>> +	return -EIO;
>> +}
>> +
>>  static int decode_layoutcommit(struct xdr_stream *xdr,
>>  			       struct rpc_rqst *req,
>>  			       struct nfs4_layoutcommit_res *res)
>> @@ -6319,6 +6400,30 @@ out:
>>  }
>>  
>>  /*
>> + * Decode LAYOUTRETURN response
>> + */
>> +static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp,
>> +				     struct xdr_stream *xdr,
>> +				     struct nfs4_layoutreturn_res *res)
>> +{
>> +	struct compound_hdr hdr;
>> +	int status;
>> +
>> +	status = decode_compound_hdr(xdr, &hdr);
>> +	if (status)
>> +		goto out;
>> +	status = decode_sequence(xdr, &res->seq_res, rqstp);
>> +	if (status)
>> +		goto out;
>> +	status = decode_putfh(xdr);
>> +	if (status)
>> +		goto out;
>> +	status = decode_layoutreturn(xdr, res);
>> +out:
>> +	return status;
>> +}
>> +
>> +/*
>>   * Decode LAYOUTCOMMIT response
>>   */
>>  static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
>> @@ -6544,6 +6649,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
>>  	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
>>  	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
>>  	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
>> +	PROC(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),
>>  #endif /* CONFIG_NFS_V4_1 */
>>  };
>>  
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index d9ab972..89e7725 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -321,6 +321,36 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>>  	return invalid - removed;
>>  }
>>  
>> +/* Returns false if there was nothing to do, true otherwise */
>> +static bool
>> +pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
>> +		     struct pnfs_layout_range *range)
>> +{
>> +	struct pnfs_layout_segment *lseg, *next;
>> +	bool rv = false;
>> +
>> +	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
>> +		__func__, lo, range->offset, range->length, range->iomode);
>> +	assert_spin_locked(&lo->plh_inode->i_lock);
> 
> Not needed in the case of nfs4_evict_inode.
> 

True.  I can remove the assert
but the lock better be taken if called while the inode is alive.

>> +	if (list_empty(&lo->plh_segs)) {
>> +		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
>> +			put_layout_hdr_locked(lo);
>> +		return 0;
>> +	}
>> +	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
>> +		if (should_free_lseg(lseg->pls_range.iomode, range->iomode)) {
>> +			dprintk("%s: freeing lseg %p iomode %d "
>> +				"offset %llu length %llu\n", __func__,
>> +				lseg, lseg->pls_range.iomode,
>> +				lseg->pls_range.offset,
>> +				lseg->pls_range.length);
>> +			mark_lseg_invalid(lseg, tmp_list);
>> +			rv = true;
>> +		}
>> +	dprintk("%s:Return %d\n", __func__, rv);
>> +	return rv;
>> +}
>> +
>>  /* note free_me must contain lsegs from a single layout_hdr */
>>  void
>>  pnfs_free_lseg_list(struct list_head *free_me)
>> @@ -539,6 +569,72 @@ out_err_free:
>>  	return NULL;
>>  }
>>  
>> +static int
>> +return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
>> +{
>> +	struct nfs4_layoutreturn *lrp;
>> +	struct nfs_server *server = NFS_SERVER(ino);
>> +	int status = -ENOMEM;
>> +
>> +	dprintk("--> %s\n", __func__);
>> +
>> +	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
>> +	if (lrp == NULL) {
>> +		put_layout_hdr(NFS_I(ino)->layout);
>> +		goto out;
>> +	}
>> +	lrp->args.reclaim = 0;
>> +	lrp->args.layout_type = server->pnfs_curr_ld->id;
>> +	lrp->args.return_type = RETURN_FILE;
>> +	lrp->args.range = *range;
>> +	lrp->args.inode = ino;
>> +	lrp->clp = server->nfs_client;
>> +
>> +	status = nfs4_proc_layoutreturn(lrp, wait);
>> +out:
>> +	dprintk("<-- %s status: %d\n", __func__, status);
>> +	return status;
>> +}
>> +
>> +/* Initiates a LAYOUTRETURN(FILE) */
>> +int
>> +_pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
> 
> What are the 'range' and 'wait' parameters for? We don't have any users
> other than nfs4_evict_inode.
> 

OK, I'll introduce these with their usage.

>> +{
>> +	struct pnfs_layout_hdr *lo = NULL;
>> +	struct nfs_inode *nfsi = NFS_I(ino);
>> +	struct pnfs_layout_range arg;
>> +	LIST_HEAD(tmp_list);
>> +	int status = 0;
>> +
>> +	dprintk("--> %s\n", __func__);
>> +
>> +	arg.iomode = range ? range->iomode : IOMODE_ANY;
>> +	arg.offset = 0;
>> +	arg.length = NFS4_MAX_UINT64;
>> +
>> +	spin_lock(&ino->i_lock);
>> +	lo = nfsi->layout;
>> +	if (!lo || !pnfs_clear_lseg_list(lo, &tmp_list, &arg)) {
>> +		spin_unlock(&ino->i_lock);
>> +		dprintk("%s: no layout segments to return\n", __func__);
>> +		goto out;
>> +	}
>> +	/* Reference matched in nfs4_layoutreturn_release */
>> +	get_layout_hdr(lo);
>> +	spin_unlock(&ino->i_lock);
>> +	pnfs_free_lseg_list(&tmp_list);
>> +
>> +	/* Return layout even if layoutcommit fails */
>> +	status = pnfs_layoutcommit_inode(ino, wait);
> 
> Why is this needed? Again, by the time we get to nfs4_evict_inode, the
> inode is guaranteed to be clean.
> 

OK, let me just add a WARN_ON if we get here and layout commit is
required. Does that work for you?

>> +	if (status)
>> +		dprintk("%s: layoutcommit failed, status=%d. Returning layout anyway\n",
>> +			__func__, status);
>> +	status = return_layout(ino, &arg, wait);
>> +out:
>> +	dprintk("<-- %s status: %d\n", __func__, status);
>> +	return status;
>> +}
>> +
>>  bool pnfs_roc(struct inode *ino)
>>  {
>>  	struct pnfs_layout_hdr *lo;
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 4cb0a0d..a308f3c 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -123,6 +123,7 @@ extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
>>  extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
>>  				   struct pnfs_device *dev);
>>  extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>> +extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
>>  
>>  /* pnfs.c */
>>  void get_layout_hdr(struct pnfs_layout_hdr *lo);
>> @@ -158,6 +159,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>> +int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
>>  
>>  static inline int lo_fail_bit(u32 iomode)
>>  {
>> @@ -226,6 +228,19 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
>>  		put_lseg(req->wb_commit_lseg);
>>  }
>>  
>> +static inline int pnfs_return_layout(struct inode *ino,
>> +				     struct pnfs_layout_range *range,
>> +				     bool wait)
>> +{
>> +	struct nfs_inode *nfsi = NFS_I(ino);
>> +	struct nfs_server *nfss = NFS_SERVER(ino);
>> +
>> +	if (pnfs_enabled_sb(nfss) && nfsi->layout)
>> +		return _pnfs_return_layout(ino, range, wait);
>> +
>> +	return 0;
>> +}
>> +
>>  #else  /* CONFIG_NFS_V4_1 */
>>  
>>  static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
>> @@ -267,6 +282,13 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
>>  	return PNFS_NOT_ATTEMPTED;
>>  }
>>  
>> +static inline int pnfs_return_layout(struct inode *ino,
>> +				     struct pnfs_layout_range *range,
>> +				     bool wait)
>> +{
>> +	return 0;
>> +}
>> +
>>  static inline bool
>>  pnfs_roc(struct inode *ino)
>>  {
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 178fafe..9376eaf 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -562,6 +562,7 @@ enum {
>>  	NFSPROC4_CLNT_LAYOUTGET,
>>  	NFSPROC4_CLNT_GETDEVICEINFO,
>>  	NFSPROC4_CLNT_LAYOUTCOMMIT,
>> +	NFSPROC4_CLNT_LAYOUTRETURN,
>>  };
>>  
>>  /* nfs41 types */
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 78b101e..455ddfb 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -266,6 +266,29 @@ struct nfs4_layoutcommit_data {
>>  	struct nfs4_layoutcommit_res res;
>>  };
>>  
>> +struct nfs4_layoutreturn_args {
>> +	__u32   reclaim;
>> +	__u32   layout_type;
>> +	__u32   return_type;
> 
> Why do we need a 'return_type'? As far as I can see, this will always be
> RETURN_FILE.
> 

Yeah, we can remove this for now.

Benny

>> +	struct pnfs_layout_range range;
>> +	struct inode *inode;
>> +	struct nfs4_sequence_args seq_args;
>> +};
>> +
>> +struct nfs4_layoutreturn_res {
>> +	struct nfs4_sequence_res seq_res;
>> +	u32 lrs_present;
>> +	nfs4_stateid stateid;
>> +};
>> +
>> +struct nfs4_layoutreturn {
>> +	struct nfs4_layoutreturn_args args;
>> +	struct nfs4_layoutreturn_res res;
>> +	struct rpc_cred *cred;
>> +	struct nfs_client *clp;
>> +	int rpc_status;
>> +};
>> +
>>  /*
>>   * Arguments to the open call.
>>   */
> 

