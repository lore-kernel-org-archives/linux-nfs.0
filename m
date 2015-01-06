Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:63130 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbbAFLCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 06:02:38 -0500
Received: by mail-qa0-f54.google.com with SMTP id i13so13876527qae.41
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 03:02:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54AB0519.7000008@Netapp.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
 <1419405208-25975-23-git-send-email-loghyr@primarydata.com> <54AB0519.7000008@Netapp.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Tue, 6 Jan 2015 19:02:17 +0800
Message-ID: <CAKVebiX2B7CStPCCx3ZFRq_L-Z7So2r+sZSrKt_Y_kQ83pPPgg@mail.gmail.com>
Subject: Re: [PATCH v2 22/49] nfs: save server READ/WRITE/COMMIT status
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 6, 2015 at 5:41 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hey Peng,
>
> Can you add this to NFS v2 as well?  Then we'll be covered if we ever want to re-use this variable somewhere else! :)
>
Yup, sure. I'll add it in the next version.

Thanks,
Tao

> Thanks,
> Anna
>
> On 12/24/2014 02:13 AM, Tom Haynes wrote:
>> From: Peng Tao <tao.peng@primarydata.com>
>>
>> Flexfiles layout would want to use them to report DS IO status.
>>
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
>> ---
>>  fs/nfs/nfs3xdr.c        | 3 +++
>>  fs/nfs/nfs4xdr.c        | 3 +++
>>  include/linux/nfs_xdr.h | 2 ++
>>  3 files changed, 8 insertions(+)
>>
>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>> index 8f4cbe7..2a932fd 100644
>> --- a/fs/nfs/nfs3xdr.c
>> +++ b/fs/nfs/nfs3xdr.c
>> @@ -1636,6 +1636,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
>>       error = decode_post_op_attr(xdr, result->fattr);
>>       if (unlikely(error))
>>               goto out;
>> +     result->op_status = status;
>>       if (status != NFS3_OK)
>>               goto out_status;
>>       error = decode_read3resok(xdr, result);
>> @@ -1708,6 +1709,7 @@ static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
>>       error = decode_wcc_data(xdr, result->fattr);
>>       if (unlikely(error))
>>               goto out;
>> +     result->op_status = status;
>>       if (status != NFS3_OK)
>>               goto out_status;
>>       error = decode_write3resok(xdr, result);
>> @@ -2323,6 +2325,7 @@ static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
>>       error = decode_wcc_data(xdr, result->fattr);
>>       if (unlikely(error))
>>               goto out;
>> +     result->op_status = status;
>>       if (status != NFS3_OK)
>>               goto out_status;
>>       error = decode_writeverf3(xdr, &result->verf->verifier);
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index cb4376b..7d8d7a4 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -6567,6 +6567,7 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
>>       int status;
>>
>>       status = decode_compound_hdr(xdr, &hdr);
>> +     res->op_status = hdr.status;
>>       if (status)
>>               goto out;
>>       status = decode_sequence(xdr, &res->seq_res, rqstp);
>> @@ -6592,6 +6593,7 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
>>       int status;
>>
>>       status = decode_compound_hdr(xdr, &hdr);
>> +     res->op_status = hdr.status;
>>       if (status)
>>               goto out;
>>       status = decode_sequence(xdr, &res->seq_res, rqstp);
>> @@ -6621,6 +6623,7 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
>>       int status;
>>
>>       status = decode_compound_hdr(xdr, &hdr);
>> +     res->op_status = hdr.status;
>>       if (status)
>>               goto out;
>>       status = decode_sequence(xdr, &res->seq_res, rqstp);
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 467c84e..962f461 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -513,6 +513,7 @@ struct nfs_pgio_res {
>>       struct nfs4_sequence_res        seq_res;
>>       struct nfs_fattr *      fattr;
>>       __u32                   count;
>> +     __u32                   op_status;
>>       int                     eof;            /* used by read */
>>       struct nfs_writeverf *  verf;           /* used by write */
>>       const struct nfs_server *server;        /* used by write */
>> @@ -532,6 +533,7 @@ struct nfs_commitargs {
>>
>>  struct nfs_commitres {
>>       struct nfs4_sequence_res        seq_res;
>> +     __u32                   op_status;
>>       struct nfs_fattr        *fattr;
>>       struct nfs_writeverf    *verf;
>>       const struct nfs_server *server;
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
