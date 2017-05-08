Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34941 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752924AbdEHUsx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 May 2017 16:48:53 -0400
Received: by mail-qk0-f193.google.com with SMTP id k74so11850778qke.2
        for <linux-nfs@vger.kernel.org>; Mon, 08 May 2017 13:48:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1494275480.10601.1.camel@primarydata.com>
References: <562173A5-AB4B-49F8-8C82-F220B6F8ECB5@netapp.com>
 <20170418160941.93724-1-kolga@netapp.com> <1494275480.10601.1.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 8 May 2017 16:48:52 -0400
Message-ID: <CAN-5tyFLGa3FG3PetdvYwm9Xf1RK19A83i6k5=XV94EjS=k_2A@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFS append COMMIT after synchronous COPY
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "kolga@netapp.com" <kolga@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 8, 2017 at 4:31 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> On Tue, 2017-04-18 at 12:09 -0400, Olga Kornievskaia wrote:
>> Instead of messing with the commit path which has been causing
>> issues,
>> add a COMMIT op after the COPY and ask for stable copies in the first
>> space.
>>
>> It saves a round trip, since after the COPY, the client sends a
>> COMMIT
>> anyway.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/internal.h  |  1 -
>>  fs/nfs/nfs42proc.c |  6 ------
>>  fs/nfs/nfs42xdr.c  | 19 +++++++++++++++++--
>>  fs/nfs/write.c     | 30 ------------------------------
>>  4 files changed, 17 insertions(+), 39 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 7b38fed..2989418 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -495,7 +495,6 @@ void nfs_mark_request_commit(struct nfs_page
>> *req,
>>                            u32 ds_commit_idx);
>>  int nfs_write_need_commit(struct nfs_pgio_header *);
>>  void nfs_writeback_update_inode(struct nfs_pgio_header *hdr);
>> -int nfs_commit_file(struct file *file, struct nfs_write_verifier
>> *verf);
>>  int nfs_generic_commit_list(struct inode *inode, struct list_head
>> *head,
>>                           int how, struct nfs_commit_info *cinfo);
>>  void nfs_retry_commit(struct list_head *page_list,
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index 1e486c7..9fee48d 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -174,12 +174,6 @@ static ssize_t _nfs42_proc_copy(struct file
>> *src,
>>       if (status)
>>               return status;
>>
>> -     if (res->write_res.verifier.committed != NFS_FILE_SYNC) {
>> -             status = nfs_commit_file(dst, &res-
>> >write_res.verifier.verifier);
>> -             if (status)
>> -                     return status;
>> -     }
>> -
>>       truncate_pagecache_range(dst_inode, pos_dst,
>>                                pos_dst + res->write_res.count);
>>
>> diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
>> index 6c72964..8bdf1d5 100644
>> --- a/fs/nfs/nfs42xdr.c
>> +++ b/fs/nfs/nfs42xdr.c
>> @@ -66,12 +66,14 @@
>>                                        encode_putfh_maxsz + \
>>                                        encode_savefh_maxsz + \
>>                                        encode_putfh_maxsz + \
>> -                                      encode_copy_maxsz)
>> +                                      encode_copy_maxsz + \
>> +                                      encode_commit_maxsz)
>>  #define NFS4_dec_copy_sz             (compound_decode_hdr_maxsz +
>> \
>>                                        decode_putfh_maxsz + \
>>                                        decode_savefh_maxsz + \
>>                                        decode_putfh_maxsz + \
>> -                                      decode_copy_maxsz)
>> +                                      decode_copy_maxsz + \
>> +                                      decode_commit_maxsz)
>>  #define NFS4_enc_deallocate_sz               (compound_encode_hdr_m
>> axsz + \
>>                                        encode_putfh_maxsz + \
>>                                        encode_deallocate_maxsz + \
>> @@ -222,6 +224,18 @@ static void nfs4_xdr_enc_allocate(struct
>> rpc_rqst *req,
>>       encode_nops(&hdr);
>>  }
>>
>> +static void encode_copy_commit(struct xdr_stream *xdr,
>> +                       struct nfs42_copy_args *args,
>> +                       struct compound_hdr *hdr)
>> +{
>> +     __be32 *p;
>> +
>> +     encode_op_hdr(xdr, OP_COMMIT, decode_commit_maxsz, hdr);
>> +     p = reserve_space(xdr, 12);
>> +     p = xdr_encode_hyper(p, args->dst_pos);
>> +     *p = cpu_to_be32(args->count);
>> +}
>> +
>>  /*
>>   * Encode COPY request
>>   */
>> @@ -239,6 +253,7 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst
>> *req,
>>       encode_savefh(xdr, &hdr);
>>       encode_putfh(xdr, args->dst_fh, &hdr);
>>       encode_copy(xdr, args, &hdr);
>> +     encode_copy_commit(xdr, args, &hdr);
>>       encode_nops(&hdr);
>>  }
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index abb2c8a..8d65d88 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1720,36 +1720,6 @@ void nfs_retry_commit(struct list_head
>> *page_list,
>>       return -ENOMEM;
>>  }
>>
>> -int nfs_commit_file(struct file *file, struct nfs_write_verifier
>> *verf)
>> -{
>> -     struct inode *inode = file_inode(file);
>> -     struct nfs_open_context *open;
>> -     struct nfs_commit_info cinfo;
>> -     struct nfs_page *req;
>> -     int ret;
>> -
>> -     open = get_nfs_open_context(nfs_file_open_context(file));
>> -     req  = nfs_create_request(open, NULL, NULL, 0,
>> i_size_read(inode));
>> -     if (IS_ERR(req)) {
>> -             ret = PTR_ERR(req);
>> -             goto out_put;
>> -     }
>> -
>> -     nfs_init_cinfo_from_inode(&cinfo, inode);
>> -
>> -     memcpy(&req->wb_verf, verf, sizeof(struct
>> nfs_write_verifier));
>> -     nfs_request_add_commit_list(req, &cinfo);
>> -     ret = nfs_commit_inode(inode, FLUSH_SYNC);
>> -     if (ret > 0)
>> -             ret = 0;
>> -
>> -     nfs_free_request(req);
>> -out_put:
>> -     put_nfs_open_context(open);
>> -     return ret;
>> -}
>> -EXPORT_SYMBOL_GPL(nfs_commit_file);
>> -
>>  /*
>>   * COMMIT call returned
>>   */
>
> Shouldn't we decode the reply from the server so that we can return an
> error message or retry if the commit failed and/or the verifiers don't
> match? Otherwise we won't notice if the flush to disk failed.

Good point. Let me see what I can come up with.

> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
