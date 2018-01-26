Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:41791 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbeAZPRR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jan 2018 10:17:17 -0500
Received: by mail-ua0-f194.google.com with SMTP id f5so483391ual.8
        for <linux-nfs@vger.kernel.org>; Fri, 26 Jan 2018 07:17:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180125220440.GA21492@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <20171024174752.74910-6-kolga@netapp.com>
 <20180125220440.GA21492@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 26 Jan 2018 10:17:15 -0500
Message-ID: <CAN-5tyGAso7uABtezqCB7J54Vun8iNwO4LUx3N8z7J6a1Rb=uA@mail.gmail.com>
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 25, 2018 at 5:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Nit: this could use a better subject line.

Will change it.

> On Tue, Oct 24, 2017 at 01:47:47PM -0400, Olga Kornievskaia wrote:
> ...
>> +     if (!copy->cp_synchronous) {
>> +             status = nfsd4_init_copy_res(copy, 0);
>> +             async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>> +             if (!async_copy) {
>> +                     status = nfserrno(-ENOMEM);
>> +                     goto out;
>> +             }
>> +             dup_copy_fields(copy, async_copy);
>> +             memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
>> +                     sizeof(copy->cp_dst_stateid));
>> +             spin_lock(&async_copy->cp_clp->async_lock);
>> +             list_add(&async_copy->copies,
>> +                             &async_copy->cp_clp->async_copies);
>> +             spin_unlock(&async_copy->cp_clp->async_lock);
>
> At this point other threads could in theory look up this async_copy, but
> its copy_task field is not yet initialized.  I don't *think* that's a
> problem for nfsd4_shutdown_copy, because I don't think the server could
> be processing rpc's for this client any more at that point.  But I think
> a malicious client might be able to trigger a NULL dereference in
> nfsd4_offload_cancel.
>
> Is there any reason not to assign copy_task before adding it to this
> list?

Good idea. I'll move the addition to after the copy_task assignment.

>
> --b.
>
>> +             async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
>> +                             async_copy, "%s", "copy thread");
>> +             if (IS_ERR(async_copy->copy_task)) {
>> +                     status = PTR_ERR(async_copy->copy_task);
>> +                     goto out_err_dec;
>> +             }
>> +             wake_up_process(async_copy->copy_task);
>> +     } else {
>> +             status = nfsd4_do_copy(copy, 1);
>>       }
>> -
>> -     fput(src);
>> -     fput(dst);
>>  out:
>>       return status;
>> +out_err_dec:
>> +     cleanup_async_copy(async_copy);
>> +     goto out;
>>  }
>>
>>  static __be32
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 0c04f81..d7767a1 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1774,6 +1774,8 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>>  #ifdef CONFIG_NFSD_PNFS
>>       INIT_LIST_HEAD(&clp->cl_lo_states);
>>  #endif
>> +     INIT_LIST_HEAD(&clp->async_copies);
>> +     spin_lock_init(&clp->async_lock);
>>       spin_lock_init(&clp->cl_lock);
>>       rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
>>       return clp;
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index f8b0210..9189062 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -352,6 +352,8 @@ struct nfs4_client {
>>       struct rpc_wait_queue   cl_cb_waitq;    /* backchannel callers may */
>>                                               /* wait here for slots */
>>       struct net              *net;
>> +     struct list_head        async_copies;   /* list of async copies */
>> +     spinlock_t              async_lock;     /* lock for async copies */
>>  };
>>
>>  /* struct nfs4_client_reset
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 9b0c099..0a19954 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -529,6 +529,15 @@ struct nfsd4_copy {
>>       struct nfsd4_callback   cp_cb;
>>       __be32                  nfserr;
>>       struct knfsd_fh         fh;
>> +
>> +     struct nfs4_client      *cp_clp;
>> +
>> +     struct file             *fh_src;
>> +     struct file             *fh_dst;
>> +     struct net              *net;
>> +
>> +     struct list_head        copies;
>> +     struct task_struct      *copy_task;
>>  };
>>
>>  struct nfsd4_seek {
>> --
>> 1.8.3.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
