Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44389 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974Ab1G0Td5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 15:33:57 -0400
Subject: Re: [PATCH v3 01/25] pnfs: GETDEVICELIST
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Wed, 27 Jul 2011 15:33:39 -0400
In-Reply-To: <1311792048-12551-2-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
	 <1311792048-12551-2-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311795219.25645.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-27 at 14:40 -0400, Jim Rees wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> The block driver uses GETDEVICELIST
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> [pass struct nfs_server * to getdevicelist]
> [get machince creds for getdevicelist]
> [fix getdevicelist decode sizing]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfs/nfs4proc.c       |   48 ++++++++++++++++++
>  fs/nfs/nfs4xdr.c        |  128 +++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/pnfs.h           |   12 ++++
>  include/linux/nfs4.h    |    1 +
>  include/linux/nfs_xdr.h |   11 ++++
>  5 files changed, 200 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 079614d..ebb6f1a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5834,6 +5834,54 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
>  	return status;
>  }
>  
> +/*
> + * Retrieve the list of Data Server devices from the MDS.
> + */
> +static int _nfs4_getdevicelist(struct nfs_server *server,
> +				    const struct nfs_fh *fh,
> +				    struct pnfs_devicelist *devlist)
> +{
> +	struct nfs4_getdevicelist_args args = {
> +		.fh = fh,
> +		.layoutclass = server->pnfs_curr_ld->id,
> +	};
> +	struct nfs4_getdevicelist_res res = {
> +		.devlist = devlist,
> +	};
> +	struct rpc_message msg = {
> +		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICELIST],
> +		.rpc_argp = &args,
> +		.rpc_resp = &res,
> +	};
> +	int status;
> +
> +	dprintk("--> %s\n", __func__);
> +	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args,
> +				&res.seq_res, 0);
> +	dprintk("<-- %s status=%d\n", __func__, status);
> +	return status;
> +}
> +
> +int nfs4_proc_getdevicelist(struct nfs_server *server,
> +			    const struct nfs_fh *fh,
> +			    struct pnfs_devicelist *devlist)
> +{
> +	struct nfs4_exception exception = { };
> +	int err;
> +
> +	do {
> +		err = nfs4_handle_exception(server,
> +				_nfs4_getdevicelist(server, fh, devlist),
> +				&exception);
> +	} while (exception.retry);
> +
> +	dprintk("%s: err=%d, num_devs=%u\n", __func__,
> +		err, devlist->num_devs);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL_GPL(nfs4_proc_getdevicelist);
> +
>  static int
>  _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
>  {
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index c191a9b..a82dd40 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -314,6 +314,17 @@ static int nfs4_stat_to_errno(int);
>  				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
>  #define encode_reclaim_complete_maxsz	(op_encode_hdr_maxsz + 4)
>  #define decode_reclaim_complete_maxsz	(op_decode_hdr_maxsz + 4)
> +#define encode_getdevicelist_maxsz (op_encode_hdr_maxsz + 4 + \
> +				encode_verifier_maxsz)
> +#define decode_getdevicelist_maxsz (op_decode_hdr_maxsz + \
> +				2 /* nfs_cookie4 gdlr_cookie */ + \
> +				decode_verifier_maxsz \
> +				  /* verifier4 gdlr_verifier */ + \
> +				1 /* gdlr_deviceid_list count */ + \
> +				XDR_QUADLEN(NFS4_PNFS_GETDEVLIST_MAXNUM * \
> +					    NFS4_DEVICEID4_SIZE) \
> +				  /* gdlr_deviceid_list */ + \
> +				1 /* bool gdlr_eof */)
>  #define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
>  				XDR_QUADLEN(NFS4_DEVICEID4_SIZE))
>  #define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
> @@ -748,6 +759,14 @@ static int nfs4_stat_to_errno(int);
>  #define NFS4_dec_reclaim_complete_sz	(compound_decode_hdr_maxsz + \
>  					 decode_sequence_maxsz + \
>  					 decode_reclaim_complete_maxsz)
> +#define NFS4_enc_getdevicelist_sz (compound_encode_hdr_maxsz + \
> +				encode_sequence_maxsz + \
> +				encode_putfh_maxsz + \
> +				encode_getdevicelist_maxsz)
> +#define NFS4_dec_getdevicelist_sz (compound_decode_hdr_maxsz + \
> +				decode_sequence_maxsz + \
> +				decode_putfh_maxsz + \
> +				decode_getdevicelist_maxsz)
>  #define NFS4_enc_getdeviceinfo_sz (compound_encode_hdr_maxsz +    \
>  				encode_sequence_maxsz +\
>  				encode_getdeviceinfo_maxsz)
> @@ -1855,6 +1874,26 @@ static void encode_sequence(struct xdr_stream *xdr,
>  
>  #ifdef CONFIG_NFS_V4_1
>  static void
> +encode_getdevicelist(struct xdr_stream *xdr,
> +		     const struct nfs4_getdevicelist_args *args,
> +		     struct compound_hdr *hdr)
> +{
> +	__be32 *p;
> +	nfs4_verifier dummy = {
> +		.data = "dummmmmy",
> +	};
> +
> +	p = reserve_space(xdr, 20);
> +	*p++ = cpu_to_be32(OP_GETDEVICELIST);
> +	*p++ = cpu_to_be32(args->layoutclass);
> +	*p++ = cpu_to_be32(NFS4_PNFS_GETDEVLIST_MAXNUM);
> +	xdr_encode_hyper(p, 0ULL);                          /* cookie */
> +	encode_nfs4_verifier(xdr, &dummy);
> +	hdr->nops++;
> +	hdr->replen += decode_getdevicelist_maxsz;
> +}
> +
> +static void
>  encode_getdeviceinfo(struct xdr_stream *xdr,
>  		     const struct nfs4_getdeviceinfo_args *args,
>  		     struct compound_hdr *hdr)
> @@ -2775,6 +2814,24 @@ static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
>  }
>  
>  /*
> + * Encode GETDEVICELIST request
> + */
> +static void nfs4_xdr_enc_getdevicelist(struct rpc_rqst *req,
> +				       struct xdr_stream *xdr,
> +				       struct nfs4_getdevicelist_args *args)
> +{
> +	struct compound_hdr hdr = {
> +		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
> +	};
> +
> +	encode_compound_hdr(xdr, req, &hdr);
> +	encode_sequence(xdr, &args->seq_args, &hdr);
> +	encode_putfh(xdr, args->fh, &hdr);
> +	encode_getdevicelist(xdr, args, &hdr);
> +	encode_nops(&hdr);
> +}
> +
> +/*
>   * Encode GETDEVICEINFO request
>   */
>  static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
> @@ -5268,6 +5325,50 @@ out_overflow:
>  }
>  
>  #if defined(CONFIG_NFS_V4_1)
> +/*
> + * TODO: Need to handle case when EOF != true;
> + */
> +static int decode_getdevicelist(struct xdr_stream *xdr,
> +				struct pnfs_devicelist *res)
> +{
> +	__be32 *p;
> +	int status, i;
> +	struct nfs_writeverf verftemp;
> +
> +	status = decode_op_hdr(xdr, OP_GETDEVICELIST);
> +	if (status)
> +		return status;
> +
> +	p = xdr_inline_decode(xdr, 8 + 8 + 4);
> +	if (unlikely(!p))
> +		goto out_overflow;
> +
> +	/* TODO: Skip cookie for now */
> +	p += 2;
> +
> +	/* Read verifier */
> +	p = xdr_decode_opaque_fixed(p, verftemp.verifier, 8);
> +
> +	res->num_devs = be32_to_cpup(p);
> +
> +	dprintk("%s: num_dev %d\n", __func__, res->num_devs);
> +
> +	if (res->num_devs > NFS4_PNFS_GETDEVLIST_MAXNUM)
> +		return -NFS4ERR_REP_TOO_BIG;

The client shouldn't ever be using NFS4ERR_REP_TOO_BIG (or any other NFS
protocol error) to pass messages to itself. For one thing, we can't map
that to a POSIX error, and secondly its use above conflicts with the
protocol meaning of the same error.

So please change the above to 'EIO', and perhaps add a ratelimited
printk() so that syslog can capture why the error is happening.


> @@ -6902,6 +7029,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
>  	PROC(GET_LEASE_TIME,	enc_get_lease_time,	dec_get_lease_time),
>  	PROC(RECLAIM_COMPLETE,	enc_reclaim_complete,	dec_reclaim_complete),
>  	PROC(GETDEVICEINFO,	enc_getdeviceinfo,	dec_getdeviceinfo),
> +	PROC(GETDEVICELIST,	enc_getdevicelist,	dec_getdevicelist),

This needs to go at the end of the list of procedures in order to work
correctly with nfsstat.

> 	PROC(LAYOUTGET,		enc_layoutget,		dec_layoutget),
>  	PROC(LAYOUTCOMMIT,	enc_layoutcommit,	dec_layoutcommit),
>  	PROC(LAYOUTRETURN,	enc_layoutreturn,	dec_layoutreturn),


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

