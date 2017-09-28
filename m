Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34057 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751345AbdI1Ulq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Sep 2017 16:41:46 -0400
Received: by mail-io0-f193.google.com with SMTP id g32so1600737ioj.1
        for <linux-nfs@vger.kernel.org>; Thu, 28 Sep 2017 13:41:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <183b0ab6-b865-6912-5854-c4f7a205fd16@Netapp.com>
References: <20170928172819.50703-1-kolga@netapp.com> <20170928172819.50703-5-kolga@netapp.com>
 <183b0ab6-b865-6912-5854-c4f7a205fd16@Netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 28 Sep 2017 16:41:44 -0400
Message-ID: <CAN-5tyEOX8gobd-=QyHqMqTEG3RVGgE4+5MYF3dBU-xG-0tUwg@mail.gmail.com>
Subject: Re: [PATCH v4 04/12] NFS OFFLOAD_STATUS op
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 4:32 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> Hi Olga,
>
> On 09/28/2017 01:28 PM, Olga Kornievskaia wrote:
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/nfs42.h     |  5 ++++-
>>  fs/nfs/nfs42proc.c | 42 ++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 46 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
>> index b6cd153..6b9decf 100644
>> --- a/fs/nfs/nfs42.h
>> +++ b/fs/nfs/nfs42.h
>> @@ -11,6 +11,7 @@
>>   */
>>  #define PNFS_LAYOUTSTATS_MAXDEV (4)
>>
>> +#if defined(CONFIG_NFS_V4_2)
>>  /* nfs4.2proc.c */
>>  int nfs42_proc_allocate(struct file *, loff_t, loff_t);
>>  ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t, size_t);
>> @@ -19,5 +20,7 @@
>>  int nfs42_proc_layoutstats_generic(struct nfs_server *,
>>                                  struct nfs42_layoutstat_data *);
>>  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
>> -
>> +int nfs42_proc_offload_status(struct file *, nfs4_stateid *,
>> +                           struct nfs42_offload_status_res *);
>> +#endif /* CONFIG_NFS_V4_2) */
>>  #endif /* __LINUX_FS_NFS_NFS4_2_H */
>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>> index 6c2db51..5c42e71 100644
>> --- a/fs/nfs/nfs42proc.c
>> +++ b/fs/nfs/nfs42proc.c
>> @@ -263,6 +263,48 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
>>       return err;
>>  }
>>
>> +int _nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
>> +                             struct nfs42_offload_status_res *res)
>
> Does res have to be passed as a pointer here?  The struct is fairly small, so it couldn't it be allocated on the stack?

Yes I'm assuming whatever is calling nfs42_proc_offload_status() would
be the one providing storage for the result and wanting to see the
results there.

>
>> +{
>> +     struct nfs42_offload_status_args args;
>> +     struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
>> +     struct rpc_message msg = {
>> +             .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OFFLOAD_STATUS],
>> +             .rpc_resp = res,
>> +             .rpc_argp = &args,
>> +     };
>> +     int status;
>> +
>> +     args.osa_src_fh = NFS_FH(file_inode(dst));
>
> This could probably be set in the struct initializer, similar to how msg is initialized.

Got it.

>> +     memcpy(&args.osa_stateid, stateid, sizeof(args.osa_stateid));
>> +     status = nfs4_call_sync(dst_server->client, dst_server, &msg,
>> +                             &args.osa_seq_args, &res->osr_seq_res, 0);
>> +     if (status == -ENOTSUPP)
>> +             dst_server->caps &= ~NFS_CAP_OFFLOAD_STATUS;
>> +
>> +     return status;
>> +}
>> +
>> +int nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
>> +                             struct nfs42_offload_status_res *res)
>
> Same question about the nfs42_offload_status_res here.
>
> How have you been testing offload status?  As far as I can tell, nfs42_proc_offload_status() has no callers.  I guess I'm uncomfortable about adding something that never gets used.

I have tested offload status by instead of going to wait on the
completion of the cb_offload, it would send the offload status and
then go to sleep for a little bit. It would poll until it received all
the bytes or received the cb_offload.

I needed a way to test the OFFLOAD_STATUS for the server which is a
MUST for the asynchronous copy.

Functionality is contained in this patch so it could be just excluded
if desired.

> Anna
>
>> +{
>> +     struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
>> +     struct nfs4_exception exception = { };
>> +     int status;
>> +
>> +     if (!(dst_server->caps & NFS_CAP_OFFLOAD_STATUS))
>> +             return -EOPNOTSUPP;
>> +
>> +     do {
>> +             status = _nfs42_proc_offload_status(dst, stateid, res);
>> +             if (status == -ENOTSUPP)
>> +                     return -EOPNOTSUPP;
>> +             status = nfs4_handle_exception(dst_server, status, &exception);
>> +     } while (exception.retry);
>> +
>> +     return status;
>> +}
>> +
>>  static loff_t _nfs42_proc_llseek(struct file *filep,
>>               struct nfs_lock_context *lock, loff_t offset, int whence)
>>  {
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
