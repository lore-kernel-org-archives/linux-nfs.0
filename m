Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57659 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab1CJUPh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 15:15:37 -0500
Subject: Re: [PATCH 3/8] NFS: Introduce nfs4_proc_get_mig_status()
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1299787139.3075.36.camel@heimdal.trondhjem.org>
Date: Thu, 10 Mar 2011 15:14:03 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <83F13912-ABA7-403E-9697-179425B4C9ED@oracle.com>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net> <20110310172959.8878.88948.stgit@matisse.1015granger.net> <1299787139.3075.36.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 10, 2011, at 2:58 PM, Trond Myklebust wrote:

> On Thu, 2011-03-10 at 12:29 -0500, Chuck Lever wrote: 
>> @@ -5915,6 +5962,37 @@ out:
>> 	return status;
>> }
>> 
>> +/*
>> + * Decode migration status probe
>> + */
>> +static int nfs4_xdr_dec_get_mig_status(struct rpc_rqst *req,
>> +				       struct xdr_stream *xdr,
>> +				       struct nfs4_fs_locations_res *res)
>> +{
>> +	struct compound_hdr hdr;
>> +	int status;
>> +
>> +	status = decode_compound_hdr(xdr, &hdr);
>> +	if (status)
>> +		goto out;
>> +	status = decode_sequence(xdr, &res->seq_res, req);
>> +	if (status)
>> +		goto out;
>> +	status = decode_putfh(xdr);
>> +	if (status)
>> +		goto out;
>> +	xdr_enter_page(xdr, PAGE_SIZE);
>> +	status = decode_getfattr(xdr, &res->fs_locations->fattr,
>> +				 res->fs_locations->server,
>> +				 !RPC_IS_ASYNC(req->rq_task));
>> +	if (status)
>> +		goto out;
>> +	if (res->renew)
>> +		status = decode_renew(xdr);
>> +out:
>> +	return status;
>> +}
>> +
>> #if defined(CONFIG_NFS_V4_1)
>> /*
>>  * Decode EXCHANGE_ID response
>> @@ -6255,6 +6333,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
>> 	PROC(GETACL,		enc_getacl,		dec_getacl),
>> 	PROC(SETACL,		enc_setacl,		dec_setacl),
>> 	PROC(FS_LOCATIONS,	enc_fs_locations,	dec_fs_locations),
>> +	PROC(GET_MIG_STATUS,	enc_get_mig_status,	dec_get_mig_status)
> 
> Yet more trouble for nfsstat...

Indeed.

>> ,
>> 	PROC(RELEASE_LOCKOWNER,	enc_release_lockowner,	dec_release_lockowner),
>> #if defined(CONFIG_NFS_V4_1)
>> 	PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
> 
> So looking at what you are doing in GET_MIG_STATUS, it appears to me
> that
> 
> 1) We don't need it for NFSv4.1: the existing fs_locations request just
> works for that.

> 2) The only new thing in NFSv4.0 is the renew operation...

It's true that NFSv4.1 doesn't require a RENEW, but we do still need a new op for migration support.  The original op uses PUTFH;LOOKUP;GETATTR(fs_locations).  We can't use a LOOKUP request to retrieve the fs_locations array for the root directory of an FSID.  So, the new op is substantively different than the original in more ways than the addition of the RENEW.

> So how about if we just modify the existing fs_locations call to append
> a RENEW request if/when we supply a clientid?

I'm willing to think more about this, but I don't see an easy way to reuse the existing fs_locations proc.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




