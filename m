Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:45444 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751484AbdI1UkS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Sep 2017 16:40:18 -0400
Received: by mail-it0-f68.google.com with SMTP id x15so3068726itb.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Sep 2017 13:40:17 -0700 (PDT)
Subject: Re: [PATCH v4 12/12] NFS add a simple sync nfs4_proc_commit after
 async COPY
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <20170928172819.50703-1-kolga@netapp.com>
 <20170928172819.50703-13-kolga@netapp.com>
 <81151f31-a9d1-6f75-30b3-1608bdc1d432@gmail.com>
 <CAN-5tyFQvHPJBK4dPdfWfOQncDz0eGmZL1MTExHNebg0FvCcJQ@mail.gmail.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <6ff26d9f-6f94-7a35-dfd1-c228dd0086e7@gmail.com>
Date: Thu, 28 Sep 2017 16:40:15 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFQvHPJBK4dPdfWfOQncDz0eGmZL1MTExHNebg0FvCcJQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/28/2017 04:34 PM, Olga Kornievskaia wrote:
> On Thu, Sep 28, 2017 at 4:13 PM, Anna Schumaker
> <schumaker.anna@gmail.com> wrote:
>>
>>
>> On 09/28/2017 01:28 PM, Olga Kornievskaia wrote:
>>> A COPY with unstable write data needs a simple commit that doesn't
>>> deal with inodes
>>>
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>>  fs/nfs/nfs42proc.c | 22 ++++++++++++++++++++++
>>>  fs/nfs/nfs4_fs.h   |  2 +-
>>>  fs/nfs/nfs4proc.c  | 33 +++++++++++++++++++++++++++++++++
>>>  3 files changed, 56 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>>> index b9e47a2..2064d11 100644
>>> --- a/fs/nfs/nfs42proc.c
>>> +++ b/fs/nfs/nfs42proc.c
>>> @@ -252,6 +252,28 @@ static ssize_t _nfs42_proc_copy(struct file *src,
>>>                       return status;
>>>       }
>>>
>>> +     if ((!res->synchronous || !args->sync) &&
>>> +                     res->write_res.verifier.committed != NFS_FILE_SYNC) {
>>> +             struct nfs_commitres cres;
>>> +
>>> +             cres.verf = kzalloc(sizeof(struct nfs_writeverf), GFP_NOFS);
>>> +             if (!cres.verf)
>>> +                     return -ENOMEM;
>>> +
>>> +             status = nfs4_proc_commit(dst, pos_dst, res->write_res.count,
>>> +                                       &cres);
>>> +             if (status) {
>>> +                     kfree(cres.verf);
>>> +                     return status;
>>> +             }
>>> +             if (!nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
>>> +                                         &cres.verf->verifier)) {
>>> +                     /* what are we suppose to do here ? */
>>> +                     dprintk("commit verf differs from copy verf\n");
>>
>> I assume you should retry the commit, but we're retrying the whole operation in the synchronous case so I'm not sure.
> 
> Urgh. I forgot about this. I guess I should retry the whole copy here..
> 
>>
>>> +             }
>>> +             kfree(cres.verf);
>>> +     }
>>> +
>>
>> _nfs42_proc_copy() does a lot of stuff right now.  Can you do the whole commit process into a separate function to make it easier to follow?
> 
> got it.
> 
>>
>>>       truncate_pagecache_range(dst_inode, pos_dst,
>>>                                pos_dst + res->write_res.count);
>>>
>>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>>> index c7225bb..5edb161 100644
>>> --- a/fs/nfs/nfs4_fs.h
>>> +++ b/fs/nfs/nfs4_fs.h
>>> @@ -475,7 +475,7 @@ extern int nfs4_sequence_done(struct rpc_task *task,
>>>                             struct nfs4_sequence_res *res);
>>>
>>>  extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp);
>>> -
>>> +extern int nfs4_proc_commit(struct file *dst, __u64 offset, __u32 count, struct nfs_commitres *res);
>>>  extern const nfs4_stateid zero_stateid;
>>>
>>>  /* nfs4super.c */
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index f1bf19e..30829ce 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -4829,6 +4829,39 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
>>>       nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
>>>  }
>>>
>>> +static int _nfs4_proc_commit(struct file *dst, struct nfs_commitargs *args,
>>> +                             struct nfs_commitres *res)
>>> +{
>>> +     struct inode *dst_inode = file_inode(dst);
>>> +     struct nfs_server *server = NFS_SERVER(dst_inode);
>>> +     struct rpc_message msg = {
>>> +             .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT],
>>> +             .rpc_argp = args,
>>> +             .rpc_resp = res,
>>> +     };
>>> +     return nfs4_call_sync(server->client, server, &msg,
>>> +                     &args->seq_args, &res->seq_res, 1);
>>> +}
>>> +
>>> +int nfs4_proc_commit(struct file *dst, __u64 offset, __u32 count, struct nfs_commitres *res)
>>> +{
>>> +     struct nfs_commitargs args = {
>>> +             .fh = NFS_FH(file_inode(dst)),
>>
>> How worried do we need to be about filehandles changing if we need to enter recovery during this operation?
> 
> This is the same thing we do in the copy and other operations (llseek, clone)?

Yeah, it's to match what we do in the other operations.  Otherwise  we could end up with a different filehandle if we need to do open recovery.

> 
>>
>> Thanks,
>> Anna
>>
>>> +             .offset = offset,
>>> +             .count = count,
>>> +     };
>>> +     struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
>>> +     struct nfs4_exception exception = { };
>>> +     int status;
>>> +
>>> +     do {
>>> +             status = _nfs4_proc_commit(dst, &args, res);> +         status = nfs4_handle_exception(dst_server, status, &exception);
>>> +     } while (exception.retry);
>>> +
>>> +     return status;
>>> +}
>>> +
>>>  struct nfs4_renewdata {
>>>       struct nfs_client       *client;
>>>       unsigned long           timestamp;
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
