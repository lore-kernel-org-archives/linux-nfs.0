Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:21462 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab2CLO5o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 10:57:44 -0400
Subject: Re: [PATCH] NFSD: Fix nfs4_verifier memory alignment
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120312142049.GB4752@fieldses.org>
Date: Mon, 12 Mar 2012 10:57:32 -0400
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <2418988F-A737-42F6-8AA0-99E85B9B8C66@oracle.com>
References: <20120302221251.13019.46002.stgit@degas.1015granger.net> <20120312142049.GB4752@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2012, at 10:20 AM, J. Bruce Fields wrote:

> On Fri, Mar 02, 2012 at 05:13:50PM -0500, Chuck Lever wrote:
>> Clean up due to code review.
>> 
>> The nfs4_verifier's data field is not guaranteed to be u32-aligned.
>> Casting an array of chars to a u32 * is considered generally
>> hazardous.
>> 
>> We can fix most of this by using a __be32 array to generate the
>> verifier's contents and then byte-copying it into the verifier field.
>> 
>> However, there is one spot where there is a backwards compatibility
>> constraint: the do_nfsd_create() call expects a verifier which is
>> 32-bit aligned.  Fix this spot by forcing the alignment of the create
>> verifier in the nfsd4_open args structure.
>> 
>> Also, sizeof(nfs4_verifer) is the size of the in-core verifier data
>> structure, but NFS4_VERIFIER_SIZE is the number of octets in an XDR'd
>> verifier.  The two are not interchangeable, even if they happen to
>> have the same value.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Hi Bruce-
>> 
>> Compile-tested only.  Does this look reasonable?
> 
> Looks fine, but the setclientid verifier stuff belongs in a separate
> patch.

Thanks for the review.  I'm not clear on exactly which hunks you would like split.  If you like to separate these as you prefer, I'd be happy to sign off on whatever you do.

> --b.
> 
>> 
>> 
>> fs/nfsd/nfs4proc.c  |   19 +++++++++++--------
>> fs/nfsd/nfs4state.c |    8 ++++----
>> fs/nfsd/nfs4xdr.c   |   28 ++++++++++++++--------------
>> fs/nfsd/xdr4.h      |    4 ++--
>> 4 files changed, 31 insertions(+), 28 deletions(-)
>> 
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 896da74..e4b5748 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -481,14 +481,20 @@ nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> 			   &access->ac_supported);
>> }
>> 
>> +static void gen_boot_verifier(nfs4_verifier *verifier)
>> +{
>> +	__be32 verf[2];
>> +
>> +	verf[0] = (__be32)nfssvc_boot.tv_sec;
>> +	verf[1] = (__be32)nfssvc_boot.tv_usec;
>> +	memcpy(verifier->data, verf, sizeof(verifier->data));
>> +}
>> +
>> static __be32
>> nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> 	     struct nfsd4_commit *commit)
>> {
>> -	u32 *p = (u32 *)commit->co_verf.data;
>> -	*p++ = nfssvc_boot.tv_sec;
>> -	*p++ = nfssvc_boot.tv_usec;
>> -
>> +	gen_boot_verifier(&commit->co_verf);
>> 	return nfsd_commit(rqstp, &cstate->current_fh, commit->co_offset,
>> 			     commit->co_count);
>> }
>> @@ -865,7 +871,6 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> {
>> 	stateid_t *stateid = &write->wr_stateid;
>> 	struct file *filp = NULL;
>> -	u32 *p;
>> 	__be32 status = nfs_ok;
>> 	unsigned long cnt;
>> 
>> @@ -887,9 +892,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> 
>> 	cnt = write->wr_buflen;
>> 	write->wr_how_written = write->wr_stable_how;
>> -	p = (u32 *)write->wr_verifier.data;
>> -	*p++ = nfssvc_boot.tv_sec;
>> -	*p++ = nfssvc_boot.tv_usec;
>> +	gen_boot_verifier(&write->wr_verifier);
>> 
>> 	status =  nfsd_write(rqstp, &cstate->current_fh, filp,
>> 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index c5cddd6..9f0e139 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1138,12 +1138,12 @@ static void gen_clid(struct nfs4_client *clp)
>> 
>> static void gen_confirm(struct nfs4_client *clp)
>> {
>> +	__be32 verf[2];
>> 	static u32 i;
>> -	u32 *p;
>> 
>> -	p = (u32 *)clp->cl_confirm.data;
>> -	*p++ = get_seconds();
>> -	*p++ = i++;
>> +	verf[0] = (__be32)get_seconds();
>> +	verf[1] = (__be32)i++;
>> +	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
>> }
>> 
>> static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 0ec5a1b..1701ad6 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -755,14 +755,14 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>> 				goto out;
>> 			break;
>> 		case NFS4_CREATE_EXCLUSIVE:
>> -			READ_BUF(8);
>> -			COPYMEM(open->op_verf.data, 8);
>> +			READ_BUF(NFS4_VERIFIER_SIZE);
>> +			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
>> 			break;
>> 		case NFS4_CREATE_EXCLUSIVE4_1:
>> 			if (argp->minorversion < 1)
>> 				goto xdr_error;
>> -			READ_BUF(8);
>> -			COPYMEM(open->op_verf.data, 8);
>> +			READ_BUF(NFS4_VERIFIER_SIZE);
>> +			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
>> 			status = nfsd4_decode_fattr(argp, open->op_bmval,
>> 				&open->op_iattr, &open->op_acl);
>> 			if (status)
>> @@ -994,8 +994,8 @@ nfsd4_decode_setclientid(struct nfsd4_compoundargs *argp, struct nfsd4_setclient
>> {
>> 	DECODE_HEAD;
>> 
>> -	READ_BUF(8);
>> -	COPYMEM(setclientid->se_verf.data, 8);
>> +	READ_BUF(NFS4_VERIFIER_SIZE);
>> +	COPYMEM(setclientid->se_verf.data, NFS4_VERIFIER_SIZE);
>> 
>> 	status = nfsd4_decode_opaque(argp, &setclientid->se_name);
>> 	if (status)
>> @@ -1020,9 +1020,9 @@ nfsd4_decode_setclientid_confirm(struct nfsd4_compoundargs *argp, struct nfsd4_s
>> {
>> 	DECODE_HEAD;
>> 
>> -	READ_BUF(8 + sizeof(nfs4_verifier));
>> +	READ_BUF(8 + NFS4_VERIFIER_SIZE);
>> 	COPYMEM(&scd_c->sc_clientid, 8);
>> -	COPYMEM(&scd_c->sc_confirm, sizeof(nfs4_verifier));
>> +	COPYMEM(&scd_c->sc_confirm, NFS4_VERIFIER_SIZE);
>> 
>> 	DECODE_TAIL;
>> }
>> @@ -2661,8 +2661,8 @@ nfsd4_encode_commit(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
>> 	__be32 *p;
>> 
>> 	if (!nfserr) {
>> -		RESERVE_SPACE(8);
>> -		WRITEMEM(commit->co_verf.data, 8);
>> +		RESERVE_SPACE(NFS4_VERIFIER_SIZE);
>> +		WRITEMEM(commit->co_verf.data, NFS4_VERIFIER_SIZE);
>> 		ADJUST_ARGS();
>> 	}
>> 	return nfserr;
>> @@ -3008,7 +3008,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>> 	if (resp->xbuf->page_len)
>> 		return nfserr_resource;
>> 
>> -	RESERVE_SPACE(8);  /* verifier */
>> +	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
>> 	savep = p;
>> 
>> 	/* XXX: Following NFSv3, we ignore the READDIR verifier for now. */
>> @@ -3209,9 +3209,9 @@ nfsd4_encode_setclientid(struct nfsd4_compoundres *resp, __be32 nfserr, struct n
>> 	__be32 *p;
>> 
>> 	if (!nfserr) {
>> -		RESERVE_SPACE(8 + sizeof(nfs4_verifier));
>> +		RESERVE_SPACE(8 + NFS4_VERIFIER_SIZE);
>> 		WRITEMEM(&scd->se_clientid, 8);
>> -		WRITEMEM(&scd->se_confirm, sizeof(nfs4_verifier));
>> +		WRITEMEM(&scd->se_confirm, NFS4_VERIFIER_SIZE);
>> 		ADJUST_ARGS();
>> 	}
>> 	else if (nfserr == nfserr_clid_inuse) {
>> @@ -3232,7 +3232,7 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
>> 		RESERVE_SPACE(16);
>> 		WRITE32(write->wr_bytes_written);
>> 		WRITE32(write->wr_how_written);
>> -		WRITEMEM(write->wr_verifier.data, 8);
>> +		WRITEMEM(write->wr_verifier.data, NFS4_VERIFIER_SIZE);
>> 		ADJUST_ARGS();
>> 	}
>> 	return nfserr;
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 2364747..8d1031a 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -216,7 +216,8 @@ struct nfsd4_open {
>> 	u32		op_createmode;      /* request */
>> 	u32		op_bmval[3];        /* request */
>> 	struct iattr	iattr;              /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
>> -	nfs4_verifier	verf;               /* EXCLUSIVE4 */
>> +	nfs4_verifier	op_verf __attribute__((aligned(32)));
>> +					    /* EXCLUSIVE4 */
>> 	clientid_t	op_clientid;        /* request */
>> 	struct xdr_netobj op_owner;           /* request */
>> 	u32		op_seqid;           /* request */
>> @@ -234,7 +235,6 @@ struct nfsd4_open {
>> 	struct nfs4_acl *op_acl;
>> };
>> #define op_iattr	iattr
>> -#define op_verf		verf
>> 
>> struct nfsd4_open_confirm {
>> 	stateid_t	oc_req_stateid		/* request */;
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




