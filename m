Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:19062 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752261AbdIAUZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 16:25:59 -0400
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v1 04/18] NFSD: allow inter server COPY to have a STALE source server fh
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <20170901202312.GB2743@parsley.fieldses.org>
Date: Fri, 1 Sep 2017 16:25:53 -0400
CC: <linux-nfs@vger.kernel.org>
Message-ID: <48971F0D-086B-4DE1-9B69-0FD04E6558FD@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
 <20170302160142.30413-5-kolga@netapp.com>
 <20170901202312.GB2743@parsley.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 1, 2017, at 4:23 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>=20
> On Thu, Mar 02, 2017 at 11:01:28AM -0500, Olga Kornievskaia wrote:
>> From: Andy Adamson <andros@netapp.com>
>>=20
>> The inter server to server COPY source server filehandle
>> is guaranteed to be stale as the COPY is sent to the destination
>> server.
>=20
> This is definitely not true.  That filehandle could very well mean
> something to the source server, even if it's just by accident.
>=20
> In the case the source filehandle refers to a file on a different
> server, nfsd knows that, and should not call fh_verify on it at all.

At the time of processing the FH it doesn=E2=80=99t know that there is a =
COPY
operation coming in the compound. So how does it know it refers to=20
a file on a different server?

>=20
> --b.
>=20
>>=20
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfsd/nfs4proc.c | 47 =
++++++++++++++++++++++++++++++++++++++++++++++-
>> fs/nfsd/nfs4xdr.c  | 26 +++++++++++++++++++++++++-
>> fs/nfsd/nfsd.h     |  2 ++
>> fs/nfsd/xdr4.h     |  4 ++++
>> 4 files changed, 77 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index a680c8c..733a9aa 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -496,11 +496,19 @@ static __be32 nfsd4_open_omfg(struct svc_rqst =
*rqstp, struct nfsd4_compound_stat
>> nfsd4_putfh(struct svc_rqst *rqstp, struct nfsd4_compound_state =
*cstate,
>> 	    struct nfsd4_putfh *putfh)
>> {
>> +	__be32 ret;
>> +
>> 	fh_put(&cstate->current_fh);
>> 	cstate->current_fh.fh_handle.fh_size =3D putfh->pf_fhlen;
>> 	memcpy(&cstate->current_fh.fh_handle.fh_base, putfh->pf_fhval,
>> 	       putfh->pf_fhlen);
>> -	return fh_verify(rqstp, &cstate->current_fh, 0, =
NFSD_MAY_BYPASS_GSS);
>> +	ret =3D fh_verify(rqstp, &cstate->current_fh, 0, =
NFSD_MAY_BYPASS_GSS);
>> +	if (ret =3D=3D nfserr_stale && HAS_CSTATE_FLAG(cstate, =
NO_VERIFY_FH)) {
>> +		CLEAR_CSTATE_FLAG(cstate, NO_VERIFY_FH);
>> +		SET_CSTATE_FLAG(cstate, IS_STALE_FH);
>> +		ret =3D 0;
>> +	}
>> +	return ret;
>> }
>>=20
>> static __be32
>> @@ -533,6 +541,16 @@ static __be32 nfsd4_open_omfg(struct svc_rqst =
*rqstp, struct nfsd4_compound_stat
>> nfsd4_savefh(struct svc_rqst *rqstp, struct nfsd4_compound_state =
*cstate,
>> 	     void *arg)
>> {
>> +	/**
>> +	* This is either an inter COPY (most likely) or an intra COPY =
with a
>> +	* stale file handle. If the latter, nfsd4_copy will reset the =
PUTFH to
>> +	* return nfserr_stale. No fh_dentry, just copy the file handle
>> +	* to use with the inter COPY READ.
>> +	*/
>> +	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
>> +		cstate->save_fh =3D cstate->current_fh;
>> +		return nfs_ok;
>> +	}
>> 	if (!cstate->current_fh.fh_dentry)
>> 		return nfserr_nofilehandle;
>>=20
>> @@ -1067,6 +1085,13 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>> 	if (status)
>> 		goto out;
>>=20
>> +	/* Intra copy source fh is stale. PUTFH will fail with ESTALE */
>> +	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
>> +		CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
>> +		cstate->status =3D nfserr_copy_stalefh;
>> +		goto out_put;
>> +	}
>> +
>> 	bytes =3D nfsd_copy_file_range(src, copy->cp_src_pos,
>> 			dst, copy->cp_dst_pos, copy->cp_count);
>>=20
>> @@ -1081,6 +1106,7 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>> 		status =3D nfs_ok;
>> 	}
>>=20
>> +out_put:
>> 	fput(src);
>> 	fput(dst);
>> out:
>> @@ -1776,6 +1802,7 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
>> 	struct nfsd4_compound_state *cstate =3D &resp->cstate;
>> 	struct svc_fh *current_fh =3D &cstate->current_fh;
>> 	struct svc_fh *save_fh =3D &cstate->save_fh;
>> +	int		i;
>> 	__be32		status;
>>=20
>> 	svcxdr_init_encode(rqstp, resp);
>> @@ -1808,6 +1835,12 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
>> 		goto encode_op;
>> 	}
>>=20
>> +	/* NFSv4.2 COPY source file handle may be from a different =
server */
>> +	for (i =3D 0; i < args->opcnt; i++) {
>> +		op =3D &args->ops[i];
>> +		if (op->opnum =3D=3D OP_COPY)
>> +			SET_CSTATE_FLAG(cstate, NO_VERIFY_FH);
>> +	}
>> 	while (!status && resp->opcnt < args->opcnt) {
>> 		op =3D &args->ops[resp->opcnt++];
>>=20
>> @@ -1827,6 +1860,9 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
>>=20
>> 		opdesc =3D OPDESC(op);
>>=20
>> +		if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH))
>> +			goto call_op;
>> +
>> 		if (!current_fh->fh_dentry) {
>> 			if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
>> 				op->status =3D nfserr_nofilehandle;
>> @@ -1861,6 +1897,7 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
>>=20
>> 		if (opdesc->op_get_currentstateid)
>> 			opdesc->op_get_currentstateid(cstate, &op->u);
>> +call_op:
>> 		op->status =3D opdesc->op_func(rqstp, cstate, &op->u);
>>=20
>> 		if (!op->status) {
>> @@ -1881,6 +1918,14 @@ static void svcxdr_init_encode(struct svc_rqst =
*rqstp,
>> 			status =3D op->status;
>> 			goto out;
>> 		}
>> +		/* Only from intra COPY */
>> +		if (cstate->status =3D=3D nfserr_copy_stalefh) {
>> +			dprintk("%s NFS4.2 intra COPY stale src =
filehandle\n",
>> +				__func__);
>> +			status =3D nfserr_stale;
>> +			nfsd4_adjust_encode(resp);
>> +			goto out;
>> +		}
>> 		if (op->status =3D=3D nfserr_replay_me) {
>> 			op->replay =3D &cstate->replay_owner->so_replay;
>> 			nfsd4_encode_replay(&resp->xdr, op);
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index c632156..328ff9c 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -4619,15 +4619,28 @@ __be32 nfsd4_check_resp_size(struct =
nfsd4_compoundres *resp, u32 respsize)
>> 	return nfserr_rep_too_big;
>> }
>>=20
>> +/** Rewind the encoding to return nfserr_stale on the PUTFH
>> + * in this failed Intra COPY compound
>> + */
>> +void
>> +nfsd4_adjust_encode(struct nfsd4_compoundres *resp)
>> +{
>> +	__be32 *p;
>> +
>> +	p =3D resp->cstate.putfh_errp;
>> +	*p++ =3D nfserr_stale;
>> +}
>> +
>> void
>> nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct =
nfsd4_op *op)
>> {
>> 	struct xdr_stream *xdr =3D &resp->xdr;
>> 	struct nfs4_stateowner *so =3D resp->cstate.replay_owner;
>> +	struct nfsd4_compound_state *cstate =3D &resp->cstate;
>> 	struct svc_rqst *rqstp =3D resp->rqstp;
>> 	int post_err_offset;
>> 	nfsd4_enc encoder;
>> -	__be32 *p;
>> +	__be32 *p, *statp;
>>=20
>> 	p =3D xdr_reserve_space(xdr, 8);
>> 	if (!p) {
>> @@ -4636,9 +4649,20 @@ __be32 nfsd4_check_resp_size(struct =
nfsd4_compoundres *resp, u32 respsize)
>> 	}
>> 	*p++ =3D cpu_to_be32(op->opnum);
>> 	post_err_offset =3D xdr->buf->len;
>> +	statp =3D p;
>>=20
>> 	if (op->opnum =3D=3D OP_ILLEGAL)
>> 		goto status;
>> +
>> +	/** This is a COPY compound with a stale source server file =
handle.
>> +	 * If OP_COPY processing determines that this is an intra server =
to
>> +	 * server COPY, then this PUTFH should return nfserr_ stale so =
the
>> +	 * putfh_errp will be set to nfserr_stale. If this is an inter =
server
>> +	 * to server COPY, ignore the nfserr_stale.
>> +	 */
>> +	if (op->opnum =3D=3D OP_PUTFH && HAS_CSTATE_FLAG(cstate, =
IS_STALE_FH))
>> +		cstate->putfh_errp =3D statp;
>> +
>> 	BUG_ON(op->opnum < 0 || op->opnum >=3D ARRAY_SIZE(nfsd4_enc_ops) =
||
>> 	       !nfsd4_enc_ops[op->opnum]);
>> 	encoder =3D nfsd4_enc_ops[op->opnum];
>> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
>> index d966068..8d6fb0f 100644
>> --- a/fs/nfsd/nfsd.h
>> +++ b/fs/nfsd/nfsd.h
>> @@ -272,6 +272,8 @@ static inline bool nfsd4_spo_must_allow(struct =
svc_rqst *rqstp)
>> #define	nfserr_replay_me	cpu_to_be32(11001)
>> /* nfs41 replay detected */
>> #define	nfserr_replay_cache	cpu_to_be32(11002)
>> +/* nfs42 intra copy failed with nfserr_stale */
>> +#define nfserr_copy_stalefh	cpu_to_be32(1103)
>>=20
>> /* Check for dir entries '.' and '..' */
>> #define isdotent(n, l)	(l < 3 && n[0] =3D=3D '.' && (l =3D=3D 1 =
|| n[1] =3D=3D '.'))
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 38fcb4f..aa94295 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -45,6 +45,8 @@
>>=20
>> #define CURRENT_STATE_ID_FLAG (1<<0)
>> #define SAVED_STATE_ID_FLAG (1<<1)
>> +#define NO_VERIFY_FH (1<<2)
>> +#define IS_STALE_FH  (1<<3)
>>=20
>> #define SET_CSTATE_FLAG(c, f) ((c)->sid_flags |=3D (f))
>> #define HAS_CSTATE_FLAG(c, f) ((c)->sid_flags & (f))
>> @@ -63,6 +65,7 @@ struct nfsd4_compound_state {
>> 	size_t			iovlen;
>> 	u32			minorversion;
>> 	__be32			status;
>> +	__be32			*putfh_errp;
>> 	stateid_t	current_stateid;
>> 	stateid_t	save_stateid;
>> 	/* to indicate current and saved state id presents */
>> @@ -705,6 +708,7 @@ int nfs4svc_decode_compoundargs(struct svc_rqst =
*, __be32 *,
>> int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
>> 		struct nfsd4_compoundres *);
>> __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
>> +void nfsd4_adjust_encode(struct nfsd4_compoundres *);
>> void nfsd4_encode_operation(struct nfsd4_compoundres *, struct =
nfsd4_op *);
>> void nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op =
*op);
>> __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
>> --=20
>> 1.8.3.1
>>=20

