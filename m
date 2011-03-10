Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26942 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150Ab1CJT7F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 14:59:05 -0500
Subject: Re: [PATCH 3/8] NFS: Introduce nfs4_proc_get_mig_status()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110310172959.8878.88948.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
	 <20110310172959.8878.88948.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Mar 2011 14:58:59 -0500
Message-ID: <1299787139.3075.36.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-03-10 at 12:29 -0500, Chuck Lever wrote: 
> @@ -5915,6 +5962,37 @@ out:
>  	return status;
>  }
>  
> +/*
> + * Decode migration status probe
> + */
> +static int nfs4_xdr_dec_get_mig_status(struct rpc_rqst *req,
> +				       struct xdr_stream *xdr,
> +				       struct nfs4_fs_locations_res *res)
> +{
> +	struct compound_hdr hdr;
> +	int status;
> +
> +	status = decode_compound_hdr(xdr, &hdr);
> +	if (status)
> +		goto out;
> +	status = decode_sequence(xdr, &res->seq_res, req);
> +	if (status)
> +		goto out;
> +	status = decode_putfh(xdr);
> +	if (status)
> +		goto out;
> +	xdr_enter_page(xdr, PAGE_SIZE);
> +	status = decode_getfattr(xdr, &res->fs_locations->fattr,
> +				 res->fs_locations->server,
> +				 !RPC_IS_ASYNC(req->rq_task));
> +	if (status)
> +		goto out;
> +	if (res->renew)
> +		status = decode_renew(xdr);
> +out:
> +	return status;
> +}
> +
>  #if defined(CONFIG_NFS_V4_1)
>  /*
>   * Decode EXCHANGE_ID response
> @@ -6255,6 +6333,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
>  	PROC(GETACL,		enc_getacl,		dec_getacl),
>  	PROC(SETACL,		enc_setacl,		dec_setacl),
>  	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
> +	PROC(GET_MIG_STATUS,	enc_get_mig_status,	dec_get_mig_status)

Yet more trouble for nfsstat...

> ,
>  	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
>  #if defined(CONFIG_NFS_V4_1)
>  	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),

So looking at what you are doing in GET_MIG_STATUS, it appears to me
that

1) We don't need it for NFSv4.1: the existing fs_locations request just
works for that.
2) The only new thing in NFSv4.0 is the renew operation...

So how about if we just modify the existing fs_locations call to append
a RENEW request if/when we supply a clientid?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

