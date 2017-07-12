Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:1061 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753870AbdGLRXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Jul 2017 13:23:41 -0400
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC v3 04/42] NFS OFFLOAD_STATUS xdr
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <6d091764-568e-1816-3bc8-074eb16d8f3f@gmail.com>
Date: Wed, 12 Jul 2017 13:23:35 -0400
CC: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Message-ID: <8B2DF11C-B157-419E-A061-F5BF61232061@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-5-kolga@netapp.com>
 <6d091764-568e-1816-3bc8-074eb16d8f3f@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Is there an ETA on when the casting patches will go in? If it=E2=80=99s =
soon, I would rebase then and fix the new calls.

> On Jul 11, 2017, at 5:01 PM, Anna Schumaker <schumaker.anna@gmail.com> =
wrote:
>=20
> Hi Olga,
>=20
> On 07/11/2017 12:43 PM, Olga Kornievskaia wrote:
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/nfs42xdr.c         | 87 =
+++++++++++++++++++++++++++++++++++++++++++++++
>> fs/nfs/nfs4proc.c         |  1 +
>> fs/nfs/nfs4xdr.c          |  1 +
>> include/linux/nfs4.h      |  1 +
>> include/linux/nfs_fs_sb.h |  1 +
>> include/linux/nfs_xdr.h   | 12 +++++++
>> 6 files changed, 103 insertions(+)
>>=20
>> diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
>> index 528362f..e369de1 100644
>> --- a/fs/nfs/nfs42xdr.c
>> +++ b/fs/nfs/nfs42xdr.c
>> @@ -25,6 +25,11 @@
>> 					 NFS42_WRITE_RES_SIZE + \
>> 					 1 /* cr_consecutive */ + \
>> 					 1 /* cr_synchronous */)
>> +#define encode_offload_status_maxsz	(op_encode_hdr_maxsz + \
>> +					 XDR_QUADLEN(NFS4_STATEID_SIZE))
>> +#define decode_offload_status_maxsz	(op_decode_hdr_maxsz + \
>> +					 2 /* osr_count */ + \
>> +					 1 + 1 /* osr_complete<1> */)
>> #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
>> 					 encode_fallocate_maxsz)
>> #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
>> @@ -74,6 +79,12 @@
>> 					 decode_putfh_maxsz + \
>> 					 decode_copy_maxsz + \
>> 					 decode_commit_maxsz)
>> +#define NFS4_enc_offload_status_sz	(compound_encode_hdr_maxsz + \
>> +					 encode_putfh_maxsz + \
>> +					 encode_offload_status_maxsz)
>> +#define NFS4_dec_offload_status_sz	(compound_decode_hdr_maxsz + \
>> +					 decode_putfh_maxsz + \
>> +					 decode_offload_status_maxsz)
>> #define NFS4_enc_deallocate_sz		=
(compound_encode_hdr_maxsz + \
>> 					 encode_putfh_maxsz + \
>> 					 encode_deallocate_maxsz + \
>> @@ -144,6 +155,14 @@ static void encode_copy(struct xdr_stream *xdr,
>> 	encode_uint32(xdr, 0); /* src server list */
>> }
>>=20
>> +static void encode_offload_status(struct xdr_stream *xdr,
>> +				  struct nfs42_offload_status_args =
*args,
>> +				  struct compound_hdr *hdr)
>> +{
>> +	encode_op_hdr(xdr, OP_OFFLOAD_STATUS, =
decode_offload_status_maxsz, hdr);
>> +	encode_nfs4_stateid(xdr, &args->osa_stateid);
>> +}
>> +
>> static void encode_deallocate(struct xdr_stream *xdr,
>> 			      struct nfs42_falloc_args *args,
>> 			      struct compound_hdr *hdr)
>> @@ -258,6 +277,24 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst =
*req,
>> }
>>=20
>> /*
>> + * Encode OFFLOAD_STATUS request
>> + */
>> +static void nfs4_xdr_enc_offload_status(struct rpc_rqst *req,
>> +					struct xdr_stream *xdr,
>> +					struct nfs42_offload_status_args =
*args)
>=20
> This last argument should now be: "const void *data"
>=20
>> +{
>> +	struct compound_hdr hdr =3D {
>> +		.minorversion =3D =
nfs4_xdr_minorversion(&args->osa_seq_args),
>> +	};
>> +
>> +	encode_compound_hdr(xdr, req, &hdr);
>> +	encode_sequence(xdr, &args->osa_seq_args, &hdr);
>> +	encode_putfh(xdr, args->osa_src_fh, &hdr);
>> +	encode_offload_status(xdr, args, &hdr);
>> +	encode_nops(&hdr);
>> +}
>> +
>> +/*
>>  * Encode DEALLOCATE request
>>  */
>> static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
>> @@ -406,6 +443,31 @@ static int decode_copy(struct xdr_stream *xdr, =
struct nfs42_copy_res *res)
>> 	return decode_copy_requirements(xdr, res);
>> }
>>=20
>> +static int decode_offload_status(struct xdr_stream *xdr,
>> +				 struct nfs42_offload_status_res *res)
>> +{
>> +	__be32 *p;
>> +	uint32_t count;
>> +	int status;
>> +
>> +	status =3D decode_op_hdr(xdr, OP_OFFLOAD_STATUS);
>> +	if (status)
>> +		return status;
>> +	p =3D xdr_inline_decode(xdr, 8 + 4);
>> +	if (unlikely(!p))
>> +		goto out_overflow;
>> +	p =3D xdr_decode_hyper(p, &res->osr_count);
>> +	count =3D be32_to_cpup(p++);
>> +	if (count) {
>> +		p =3D xdr_inline_decode(xdr, 4);
>> +		res->osr_status =3D nfs4_stat_to_errno(be32_to_cpup(p));
>> +	}
>> +	return 0;
>> +out_overflow:
>> +	print_overflow_msg(__func__, xdr);
>> +	return -EIO;
>> +}
>> +
>> static int decode_deallocate(struct xdr_stream *xdr, struct =
nfs42_falloc_res *res)
>> {
>> 	return decode_op_hdr(xdr, OP_DEALLOCATE);
>> @@ -504,6 +566,31 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst =
*rqstp,
>> }
>>=20
>> /*
>> + * Decode OFFLOAD_STATUS response
>> + */
>> +static int nfs4_xdr_dec_offload_status(struct rpc_rqst *rqstp,
>> +				       struct xdr_stream *xdr,
>> +				       struct nfs42_offload_status_res =
*res)
>=20
> And this one should be "void *data"
>=20
> Thanks,
> Anna
>=20
>> +{
>> +	struct compound_hdr hdr;
>> +	int status;
>> +
>> +	status =3D decode_compound_hdr(xdr, &hdr);
>> +	if (status)
>> +		goto out;
>> +	status =3D decode_sequence(xdr, &res->osr_seq_res, rqstp);
>> +	if (status)
>> +		goto out;
>> +	status =3D decode_putfh(xdr);
>> +	if (status)
>> +		goto out;
>> +	status =3D decode_offload_status(xdr, res);
>> +
>> +out:
>> +	return status;
>> +}
>> +
>> +/*
>>  * Decode DEALLOCATE request
>>  */
>> static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index dbfa189..90be5c1 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -9229,6 +9229,7 @@ static bool nfs4_match_stateid(const =
nfs4_stateid *s1,
>> 		| NFS_CAP_ATOMIC_OPEN_V1
>> 		| NFS_CAP_ALLOCATE
>> 		| NFS_CAP_COPY
>> +		| NFS_CAP_OFFLOAD_STATUS
>> 		| NFS_CAP_DEALLOCATE
>> 		| NFS_CAP_SEEK
>> 		| NFS_CAP_LAYOUTSTATS
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 3aebfdc..8b41f43 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -7561,6 +7561,7 @@ struct rpc_procinfo	nfs4_procedures[] =3D {
>> 	PROC(LAYOUTSTATS,	enc_layoutstats,	=
dec_layoutstats),
>> 	PROC(CLONE,		enc_clone,		dec_clone),
>> 	PROC(COPY,		enc_copy,		dec_copy),
>> +	PROC(OFFLOAD_STATUS,	enc_offload_status,	=
dec_offload_status),
>> #endif /* CONFIG_NFS_V4_2 */
>> };
>>=20
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 1b1ca04..d67c350 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -523,6 +523,7 @@ enum {
>> 	NFSPROC4_CLNT_LAYOUTSTATS,
>> 	NFSPROC4_CLNT_CLONE,
>> 	NFSPROC4_CLNT_COPY,
>> +	NFSPROC4_CLNT_OFFLOAD_STATUS,
>> };
>>=20
>> /* nfs41 types */
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index e418a10..36535ad 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -250,5 +250,6 @@ struct nfs_server {
>> #define NFS_CAP_LAYOUTSTATS	(1U << 22)
>> #define NFS_CAP_CLONE		(1U << 23)
>> #define NFS_CAP_COPY		(1U << 24)
>> +#define NFS_CAP_OFFLOAD_STATUS	(1U << 25)
>>=20
>> #endif
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index b28c834..eaaf540 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -1386,6 +1386,18 @@ struct nfs42_copy_res {
>> 	struct nfs_commitres		commit_res;
>> };
>>=20
>> +struct nfs42_offload_status_args {
>> +	struct nfs4_sequence_args	osa_seq_args;
>> +	struct nfs_fh			*osa_src_fh;
>> +	nfs4_stateid			osa_stateid;
>> +};
>> +
>> +struct nfs42_offload_status_res {
>> +	struct nfs4_sequence_res	osr_seq_res;
>> +	uint64_t			osr_count;
>> +	int				osr_status;
>> +};
>> +
>> struct nfs42_seek_args {
>> 	struct nfs4_sequence_args	seq_args;
>>=20
>>=20

