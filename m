Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:10251 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751849AbdDRQHG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 12:07:06 -0400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1] NFS append COMMIT after synchronous COPY
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <5ebc2df1-f209-fb9d-ee71-b2e64d0139e9@Netapp.com>
Date: Tue, 18 Apr 2017 12:06:55 -0400
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Message-ID: <562173A5-AB4B-49F8-8C82-F220B6F8ECB5@netapp.com>
References: <20170417211537.93047-1-kolga@netapp.com>
 <5ebc2df1-f209-fb9d-ee71-b2e64d0139e9@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 18, 2017, at 11:03 AM, Anna Schumaker =
<Anna.Schumaker@Netapp.com> wrote:
>=20
> Hi Olga,
>=20
> On 04/17/2017 05:15 PM, Olga Kornievskaia wrote:
>> Instead of messing with the commit path which has been causing =
issues,
>> add a COMMIT op after the COPY and ask for stable copies in the first
>> space.
>>=20
>> It saves a round trip, since after the COPY, the client sends a =
COMMIT
>> anyway.
>>=20
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/internal.h  |  1 -
>> fs/nfs/nfs42proc.c |  6 ------
>> fs/nfs/nfs42xdr.c  | 15 +++++++++++++++
>> fs/nfs/write.c     | 30 ------------------------------
>> 4 files changed, 15 insertions(+), 37 deletions(-)
>>=20
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 7b38fed..2989418 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -495,7 +495,6 @@ void nfs_mark_request_commit(struct nfs_page =
*req,
>> 			     u32 ds_commit_idx);
>> int nfs_write_need_commit(struct nfs_pgio_header *);
>> void nfs_writeback_update_inode(struct nfs_pgio_header *hdr);
>> -int nfs_commit_file(struct file *file, struct nfs_write_verifier =
*verf);
>> int nfs_generic_commit_list(struct inode *inode, struct list_head =
*head,
>> 			    int how, struct nfs_commit_info *cinfo);
>> void nfs_retry_commit(struct list_head *page_list,
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index 1e486c7..9fee48d 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -174,12 +174,6 @@ static ssize_t _nfs42_proc_copy(struct file =
*src,
>> 	if (status)
>> 		return status;
>>=20
>> -	if (res->write_res.verifier.committed !=3D NFS_FILE_SYNC) {
>> -		status =3D nfs_commit_file(dst, =
&res->write_res.verifier.verifier);
>> -		if (status)
>> -			return status;
>> -	}
>> -
>> 	truncate_pagecache_range(dst_inode, pos_dst,
>> 				 pos_dst + res->write_res.count);
>>=20
>> diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
>> index 6c72964..03f3c9e 100644
>> --- a/fs/nfs/nfs42xdr.c
>> +++ b/fs/nfs/nfs42xdr.c
>> @@ -25,6 +25,8 @@
>> 					 NFS42_WRITE_RES_SIZE + \
>> 					 1 /* cr_consecutive */ + \
>> 					 1 /* cr_synchronous */)
>> +#define decode_commit_maxsz		(op_decode_hdr_maxsz + \
>> +					 decode_verifier_maxsz)e
>=20
> nfs4xdr.c includes this file (it's a weird setup, I know), so this and =
the corresponding encode size should already be declared and available =
to us.  Can you add them to the NFS4_enc_copy_sz and NFS4_dec_copy_size =
values?

Got it. Thanks. Another version commit up.

>=20
> Thanks,
> Anna
>=20
>> #define encode_deallocate_maxsz		(op_encode_hdr_maxsz + \
>> 					 encode_fallocate_maxsz)
>> #define decode_deallocate_maxsz		(op_decode_hdr_maxsz)
>> @@ -222,6 +224,18 @@ static void nfs4_xdr_enc_allocate(struct =
rpc_rqst *req,
>> 	encode_nops(&hdr);
>> }
>>=20
>> +static void encode_copy_commit(struct xdr_stream *xdr,
>> +			  struct nfs42_copy_args *args,
>> +			  struct compound_hdr *hdr)
>> +{
>> +	__be32 *p;
>> +
>> +	encode_op_hdr(xdr, OP_COMMIT, decode_commit_maxsz, hdr);
>> +	p =3D reserve_space(xdr, 12);
>> +	p =3D xdr_encode_hyper(p, args->dst_pos);
>> +	*p =3D cpu_to_be32(args->count);
>> +}
>> +
>> /*
>>  * Encode COPY request
>>  */
>> @@ -239,6 +253,7 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst =
*req,
>> 	encode_savefh(xdr, &hdr);
>> 	encode_putfh(xdr, args->dst_fh, &hdr);
>> 	encode_copy(xdr, args, &hdr);
>> +	encode_copy_commit(xdr, args, &hdr);
>> 	encode_nops(&hdr);
>> }
>>=20
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index abb2c8a..8d65d88 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1720,36 +1720,6 @@ void nfs_retry_commit(struct list_head =
*page_list,
>> 	return -ENOMEM;
>> }
>>=20
>> -int nfs_commit_file(struct file *file, struct nfs_write_verifier =
*verf)
>> -{
>> -	struct inode *inode =3D file_inode(file);
>> -	struct nfs_open_context *open;
>> -	struct nfs_commit_info cinfo;
>> -	struct nfs_page *req;
>> -	int ret;
>> -
>> -	open =3D get_nfs_open_context(nfs_file_open_context(file));
>> -	req  =3D nfs_create_request(open, NULL, NULL, 0, =
i_size_read(inode));
>> -	if (IS_ERR(req)) {
>> -		ret =3D PTR_ERR(req);
>> -		goto out_put;
>> -	}
>> -
>> -	nfs_init_cinfo_from_inode(&cinfo, inode);
>> -
>> -	memcpy(&req->wb_verf, verf, sizeof(struct nfs_write_verifier));
>> -	nfs_request_add_commit_list(req, &cinfo);
>> -	ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> -	if (ret > 0)
>> -		ret =3D 0;
>> -
>> -	nfs_free_request(req);
>> -out_put:
>> -	put_nfs_open_context(open);
>> -	return ret;
>> -}
>> -EXPORT_SYMBOL_GPL(nfs_commit_file);
>> -
>> /*
>>  * COMMIT call returned
>>  */
>>=20

