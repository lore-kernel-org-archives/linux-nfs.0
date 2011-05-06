Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56067 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470Ab1EFSBM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2011 14:01:12 -0400
Date: Fri, 6 May 2011 14:01:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Added TEST_STATEID call
Message-ID: <20110506180111.GB15365@fieldses.org>
References: <1304700595-5040-1-git-send-email-bjschuma@netapp.com>
 <20110506172944.GA15109@fieldses.org>
 <4DC431C8.6060104@netapp.com>
 <20110506174327.GA15365@fieldses.org>
 <4DC433CB.8060102@netapp.com>
 <4DC43622.60006@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DC43622.60006@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 06, 2011 at 01:55:46PM -0400, Bryan Schumaker wrote:
> On 05/06/2011 01:45 PM, Bryan Schumaker wrote:
> > On 05/06/2011 01:43 PM, J. Bruce Fields wrote:
> >> On Fri, May 06, 2011 at 01:37:12PM -0400, Bryan Schumaker wrote:
> >>> On 05/06/2011 01:29 PM, J. Bruce Fields wrote:
> >>>> On Fri, May 06, 2011 at 12:49:53PM -0400, bjschuma@netapp.com wrote:
> >>>>> From: Bryan Schumaker <bjschuma@netapp.com>
> >>>>>
> >>>>> This patch adds in the xdr for doing a TEST_STATEID call with a
> >>>>> single stateid. RFC 5661 allows multiple stateids to be tested in a
> >>>>> single call, but only testing one keeps things simpler for now.
> >>>>
> >>>> These are among the mandatory 4.1 ops that we haven't implemented on
> >>>> the server yet.  Anyone up for it?  It's probably not difficult.
> >>>
> >>> I have some server patches that I think will work.  I'm checking out
> >>> your linux.git tree from linux-nfs.org to make sure they still apply.
> >>
> >> OK, great.
> >>
> >>> Is there a branch that I should check against?
> >>
> >> Probably for-2.6.40.
> > 
> > Thanks, I'll submit once I'm convinced everything is still working.
> > 
> >>
> >>>> Also: how will it behave against a server that returns nfserr_notsupp?
> >>>
> >>> The FREE_STATEID won't be used, and the nfs v4.0 recovery functions will be called (these functions will be called after the FREE_STATEID anyway).
> >>
> >> Then it sounds like your patches cause no change in behavior in the case
> >> of a server that doesn't support the ops?
> > 
> > Right, no change in behavior in this case.
> 
> Actually, I think I got confused with what I did for SECINFO_NO_NAME.  Both TEST_STATEID and FREE_STATEID will be called and get nfserr_notsupp from the server in both cases.  It'll still call the v4.0 recovery functions when this happens.

OK, but still except for seeing those extra failed calls on the wire the
end result is the same.

--b.

> 
> > 
> >>
> >> --b.
> >>
> >>>
> >>>>
> >>>> --b.
> >>>>
> >>>>>
> >>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> >>>>> ---
> >>>>>  fs/nfs/nfs4proc.c       |   28 ++++++++++++++
> >>>>>  fs/nfs/nfs4xdr.c        |   91 +++++++++++++++++++++++++++++++++++++++++++++++
> >>>>>  include/linux/nfs4.h    |    1 +
> >>>>>  include/linux/nfs_xdr.h |   10 +++++
> >>>>>  4 files changed, 130 insertions(+), 0 deletions(-)
> >>>>>
> >>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >>>>> index 69c0f3c..044c151 100644
> >>>>> --- a/fs/nfs/nfs4proc.c
> >>>>> +++ b/fs/nfs/nfs4proc.c
> >>>>> @@ -5791,6 +5791,34 @@ out:
> >>>>>  	rpc_put_task(task);
> >>>>>  	return status;
> >>>>>  }
> >>>>> +static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
> >>>>> +{
> >>>>> +	int status;
> >>>>> +	struct nfs41_test_stateid_args args = {
> >>>>> +		.stateid = &state->stateid,
> >>>>> +	};
> >>>>> +	struct nfs41_test_stateid_res res;
> >>>>> +	struct rpc_message msg = {
> >>>>> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_TEST_STATEID],
> >>>>> +		.rpc_argp = &args,
> >>>>> +		.rpc_resp = &res,
> >>>>> +	};
> >>>>> +	args.seq_args.sa_session = res.seq_res.sr_session = NULL;
> >>>>> +	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 1);
> >>>>> +	return status;
> >>>>> +}
> >>>>> +
> >>>>> +static int nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
> >>>>> +{
> >>>>> +	struct nfs4_exception exception = { };
> >>>>> +	int err;
> >>>>> +	do {
> >>>>> +		err = nfs4_handle_exception(server,
> >>>>> +				_nfs41_test_stateid(server, state),
> >>>>> +				&exception);
> >>>>> +	} while (exception.retry);
> >>>>> +	return err;
> >>>>> +}
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  
> >>>>>  struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
> >>>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> >>>>> index c3ccd2c..2746616 100644
> >>>>> --- a/fs/nfs/nfs4xdr.c
> >>>>> +++ b/fs/nfs/nfs4xdr.c
> >>>>> @@ -338,6 +338,9 @@ static int nfs4_stat_to_errno(int);
> >>>>>  				1 /* layoutupdate4 layout type */ + \
> >>>>>  				1 /* NULL filelayout layoutupdate4 payload */)
> >>>>>  #define decode_layoutcommit_maxsz (op_decode_hdr_maxsz + 3)
> >>>>> +#define encode_test_stateid_maxsz	(op_encode_hdr_maxsz + 8 + \
> >>>>> +					 XDR_QUADLEN(NFS4_STATEID_SIZE))
> >>>>> +#define decode_test_stateid_maxsz	(op_decode_hdr_maxsz + 8 + 4)
> >>>>>  
> >>>>>  #else /* CONFIG_NFS_V4_1 */
> >>>>>  #define encode_sequence_maxsz	0
> >>>>> @@ -760,6 +763,12 @@ static int nfs4_stat_to_errno(int);
> >>>>>  				decode_putfh_maxsz + \
> >>>>>  				decode_layoutcommit_maxsz + \
> >>>>>  				decode_getattr_maxsz)
> >>>>> +#define NFS4_enc_test_stateid_sz	(compound_encode_hdr_maxsz + \
> >>>>> +					 encode_sequence_maxsz + \
> >>>>> +					 encode_test_stateid_maxsz)
> >>>>> +#define NFS4_dec_test_stateid_sz	(compound_decode_hdr_maxsz + \
> >>>>> +					 decode_sequence_maxsz + \
> >>>>> +					 decode_test_stateid_maxsz)
> >>>>>  
> >>>>>  
> >>>>>  const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
> >>>>> @@ -1889,6 +1898,20 @@ encode_layoutcommit(struct xdr_stream *xdr,
> >>>>>  	hdr->replen += decode_layoutcommit_maxsz;
> >>>>>  	return 0;
> >>>>>  }
> >>>>> +
> >>>>> +static void encode_test_stateid(struct xdr_stream *xdr,
> >>>>> +				struct nfs41_test_stateid_args *args,
> >>>>> +				struct compound_hdr *hdr)
> >>>>> +{
> >>>>> +	__be32 *p;
> >>>>> +
> >>>>> +	p = reserve_space(xdr, 8 + NFS4_STATEID_SIZE);
> >>>>> +	*p++ = cpu_to_be32(OP_TEST_STATEID);
> >>>>> +	*p++ = cpu_to_be32(1);
> >>>>> +	xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
> >>>>> +	hdr->nops++;
> >>>>> +	hdr->replen += decode_test_stateid_maxsz;
> >>>>> +}
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  
> >>>>>  /*
> >>>>> @@ -2722,6 +2745,23 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
> >>>>>  	encode_nops(&hdr);
> >>>>>  	return 0;
> >>>>>  }
> >>>>> +
> >>>>> +/*
> >>>>> + *  Encode TEST_STATEID request
> >>>>> + */
> >>>>> +static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
> >>>>> +				      struct xdr_stream *xdr,
> >>>>> +				      struct nfs41_test_stateid_args *args)
> >>>>> +{
> >>>>> +	struct compound_hdr hdr = {
> >>>>> +		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
> >>>>> +	};
> >>>>> +
> >>>>> +	encode_compound_hdr(xdr, req, &hdr);
> >>>>> +	encode_sequence(xdr, &args->seq_args, &hdr);
> >>>>> +	encode_test_stateid(xdr, args, &hdr);
> >>>>> +	encode_nops(&hdr);
> >>>>> +}
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  
> >>>>>  static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
> >>>>> @@ -5231,6 +5271,35 @@ out_overflow:
> >>>>>  	print_overflow_msg(__func__, xdr);
> >>>>>  	return -EIO;
> >>>>>  }
> >>>>> +
> >>>>> +static int decode_test_stateid(struct xdr_stream *xdr,
> >>>>> +			       struct nfs41_test_stateid_res *res)
> >>>>> +{
> >>>>> +	__be32 *p;
> >>>>> +	int status;
> >>>>> +	int num_res;
> >>>>> +
> >>>>> +	status = decode_op_hdr(xdr, OP_TEST_STATEID);
> >>>>> +	if (status)
> >>>>> +		return status;
> >>>>> +
> >>>>> +	p = xdr_inline_decode(xdr, 4);
> >>>>> +	if (unlikely(!p))
> >>>>> +		goto out_overflow;
> >>>>> +	num_res = be32_to_cpup(p++);
> >>>>> +	if (num_res != 1)
> >>>>> +		goto out;
> >>>>> +
> >>>>> +	p = xdr_inline_decode(xdr, 4);
> >>>>> +	if (unlikely(!p))
> >>>>> +		goto out_overflow;
> >>>>> +	res->status = be32_to_cpup(p++);
> >>>>> +	return res->status;
> >>>>> +out_overflow:
> >>>>> +	print_overflow_msg(__func__, xdr);
> >>>>> +out:
> >>>>> +	return -EIO;
> >>>>> +}
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  
> >>>>>  /*
> >>>>> @@ -6346,6 +6415,27 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
> >>>>>  out:
> >>>>>  	return status;
> >>>>>  }
> >>>>> +
> >>>>> +/*
> >>>>> + * Decode TEST_STATEID response
> >>>>> + */
> >>>>> +static int nfs4_xdr_dec_test_stateid(struct rpc_rqst *rqstp,
> >>>>> +				     struct xdr_stream *xdr,
> >>>>> +				     struct nfs41_test_stateid_res *res)
> >>>>> +{
> >>>>> +	struct compound_hdr hdr;
> >>>>> +	int status;
> >>>>> +
> >>>>> +	status = decode_compound_hdr(xdr, &hdr);
> >>>>> +	if (status)
> >>>>> +		goto out;
> >>>>> +	status = decode_sequence(xdr, &res->seq_res, rqstp);
> >>>>> +	if (status)
> >>>>> +		goto out;
> >>>>> +	status = decode_test_stateid(xdr, res);
> >>>>> +out:
> >>>>> +	return status;
> >>>>> +}
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  
> >>>>>  /**
> >>>>> @@ -6547,6 +6637,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
> >>>>>  	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
> >>>>>  	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
> >>>>>  	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
> >>>>> +	PROC(TEST_STATEID,	enc_test_stateid,	dec_test_stateid),
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  };
> >>>>>  
> >>>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> >>>>> index 178fafe..0df1eed 100644
> >>>>> --- a/include/linux/nfs4.h
> >>>>> +++ b/include/linux/nfs4.h
> >>>>> @@ -562,6 +562,7 @@ enum {
> >>>>>  	NFSPROC4_CLNT_LAYOUTGET,
> >>>>>  	NFSPROC4_CLNT_GETDEVICEINFO,
> >>>>>  	NFSPROC4_CLNT_LAYOUTCOMMIT,
> >>>>> +	NFSPROC4_CLNT_TEST_STATEID,
> >>>>>  };
> >>>>>  
> >>>>>  /* nfs41 types */
> >>>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> >>>>> index 890dce2..36f50dc 100644
> >>>>> --- a/include/linux/nfs_xdr.h
> >>>>> +++ b/include/linux/nfs_xdr.h
> >>>>> @@ -1062,6 +1062,16 @@ struct nfs41_reclaim_complete_args {
> >>>>>  struct nfs41_reclaim_complete_res {
> >>>>>  	struct nfs4_sequence_res	seq_res;
> >>>>>  };
> >>>>> +
> >>>>> +struct nfs41_test_stateid_args {
> >>>>> +	nfs4_stateid			*stateid;
> >>>>> +	struct nfs4_sequence_args	seq_args;
> >>>>> +};
> >>>>> +
> >>>>> +struct nfs41_test_stateid_res {
> >>>>> +	unsigned int			status;
> >>>>> +	struct nfs4_sequence_res	seq_res;
> >>>>> +};
> >>>>>  #endif /* CONFIG_NFS_V4_1 */
> >>>>>  
> >>>>>  struct nfs_page;
> >>>>> -- 
> >>>>> 1.7.5.1
> >>>>>
> >>>>> --
> >>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>>>> the body of a message to majordomo@vger.kernel.org
> >>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
