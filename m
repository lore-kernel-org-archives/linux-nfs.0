Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:46246 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbeCVPIh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2018 11:08:37 -0400
Received: by mail-ua0-f172.google.com with SMTP id d1so5754437ual.13
        for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2018 08:08:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180307210551.GC28844@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com> <20180220164229.65404-6-kolga@netapp.com>
 <20180307210551.GC28844@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 22 Mar 2018 11:08:35 -0400
Message-ID: <CAN-5tyHx9ML5dtmhWwEJ_g1Vt8Fs9tKBM=jY=OjCe8wVJw9X4w@mail.gmail.com>
Subject: Re: [PATCH v7 05/10] NFSD introduce asynch copy feature
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 7, 2018 at 4:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> It looks like "struct nfsd_copy" is being used in at least three
> different ways: to hold the xdr arguments and reply, to hold the state
> needed while doing a copy, and to hold the callback arguments.  I wonder
> if the code would be clearer if those were three different data
> structures.

I'm having trouble with this one. Because things are done in 3
different running contexts and we need to pass information between
them then having a single data structure make more sense to me.
Furthermore, because there is also synchronous and asynchronous copies
then things like state and xdr needs to be accessed by the original
thread for the synchronous case.

nfsd4_copy structure needs to the passed into xdr decode/encode. But
for instance, offsets, count, synchronous need to be also a part of
the "copy_state" structure. xdr encode can be done from either the
main thread or the callback thread. to pass into the callback thread,
it first needs to be copied to the copy thread. only a single data
structure can be passed as arguments into the thread start function.

I have detailed each of the fields of where they are used (the intent
is to specify the need to access from multiple places). I have located
3 fields that I think don't need to be dup_copy_fields().  But I
haven't tested it yet.

struct nfsd4_copy {
       /* request */
        stateid_t       cp_src_stateid;  xdr args field needed by the
main copy (i should skip copying it in dup_copy_fields)
        stateid_t       cp_dst_stateid; xdr args field needed by the
main copy (i should skip copying it in the dup_copy_fileds)
        u64             cp_src_pos; xdr args field needed by the main
copy and then copy thread
        u64             cp_dst_pos; xdr args field needed by the main
copy and then copy thread
        u64             cp_count; xdr field needed by the main copy
and then copy thread

        /* both */
        bool            cp_synchronous; xdr args/res field need by the
main copy and then copy thread

        /* response */
        struct nfsd42_write_res cp_res; xdr res field needed by the
main copy and copy thread and callback thread

        /* for cb_offload */
        struct nfsd4_callback cp_cb; needed by the callback but has to
be setup by the structure not on the stack
        __be32                        nfserr; copy state info needed
by the main thread, copy thread, and callback thread
        struct knfsd_fh               fh; copy state available in the
main thread then copied to the copy thread and needed by the callback
thread

        struct nfs4_client      *cp_clp; copy state info needed by the
main thread, copy thread, and callback thread

        struct file             *file_src; copy state info set by the
main thread, needed by the copy thread
        struct file             *file_dst; copy state info set by the
main thread, needed by the copy thread
        struct net              *net; copy state info available/set in
the main thread, needed by the main thread and the copy thread
        struct nfs4_stid        *stid; copy state info available/set
in the main thread, needed by the main thread. (i should skip copying
it in the dup_copy_fields. Now I don't recall how "inter" copy uses
this.)
        struct nfs4_cp_state    *cps; copy state info set in the main
thread, needed by the callback so copied thru the copy thread

        struct list_head        copies; copy state information, needed
by the main thread and other parallel operations
        struct task_struct      *copy_task; copy state information/
        refcount_t              refcount; copy state information
needed by the main thread, needed by the callback so copied thru the
copy thread
        bool                    stopped; copy state information needed
by the copy thread, used by parallel threads (offload_cancel, close).

I also want to say that the data structure (will be) is used by the
"inter/intra" copy so some fields are there before they make more
sense in the "inter" case. Like the nfs4_cp_state is used for the
inter but the generated stateid is saved in that data structure
because it's share by what's COPY_NOTIFY will use to store it's copy
stateids it gives out and what COPY uses.

>
>> +static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
>> +{
>> +     memcpy(&dst->cp_src_stateid, &src->cp_src_stateid, sizeof(stateid_t));
>> +     memcpy(&dst->cp_dst_stateid, &src->cp_dst_stateid, sizeof(stateid_t));
>> +     dst->cp_src_pos = src->cp_src_pos;
>> +     dst->cp_dst_pos = src->cp_dst_pos;
>> +     dst->cp_count = src->cp_count;
>> +     dst->cp_consecutive = src->cp_consecutive;
>> +     dst->cp_synchronous = src->cp_synchronous;
>> +     memcpy(&dst->cp_res, &src->cp_res, sizeof(src->cp_res));
>> +     /* skipping nfsd4_callback */
>> +     memcpy(&dst->fh, &src->fh, sizeof(src->fh));
>> +     dst->net = src->net;
>> +     dst->cp_clp = src->cp_clp;
>> +     atomic_inc(&dst->cp_clp->cl_refcount);
>> +     dst->fh_dst = get_file(src->fh_dst);
>> +     dst->fh_src = get_file(src->fh_src);
>
> Just another minor gripe, but: could we name those fd_* or file_* or
> something instead of fh?  I tend to assume "fh" means "nfs filehandle".
>
>> +}
>> +
>> +static void cleanup_async_copy(struct nfsd4_copy *copy, bool remove)
>> +{
>> +     fput(copy->fh_dst);
>> +     fput(copy->fh_src);
>> +     if (remove) {
>> +             spin_lock(&copy->cp_clp->async_lock);
>> +             list_del(&copy->copies);
>> +             spin_unlock(&copy->cp_clp->async_lock);
>> +     }
>
> I don't understand yet why you need these two cases.  Anyway, I'd rather
> you did this in the caller.  So the caller can do either:
>
>         spin_lock()
>         list_del()
>         spin_unlock()
>         cleanup_async_copy()
>
> or just
>
>         cleanup_async_copy()
>
> Or define another helper for the first case if you're really doing it a
> lot.  Just don't make me have to remember what that second argument
> means each time I see it used.
>
>> +     atomic_dec(&copy->cp_clp->cl_refcount);
>> +     kfree(copy);
>> +}
> ...
>> +     copy->cp_clp = cstate->clp;
>> +     memcpy(&copy->fh, &cstate->current_fh.fh_handle,
>> +             sizeof(struct knfsd_fh));
>> +     copy->net = SVC_NET(rqstp);
>> +     /* for now disable asynchronous copy feature */
>> +     copy->cp_synchronous = 1;
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
>> +             async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
>> +                             async_copy, "%s", "copy thread");
>> +             if (IS_ERR(async_copy->copy_task)) {
>> +                     status = PTR_ERR(async_copy->copy_task);
>
> status should be an nfs error.
>
> --b.
>
>> +                     goto out_err;
>> +             }
>> +             spin_lock(&async_copy->cp_clp->async_lock);
>> +             list_add(&async_copy->copies,
>> +                             &async_copy->cp_clp->async_copies);
>> +             spin_unlock(&async_copy->cp_clp->async_lock);
>> +             wake_up_process(async_copy->copy_task);
>> +     } else {
>> +             status = nfsd4_do_copy(copy, 1);
>>       }
>> -
>> -     fput(src);
>> -     fput(dst);
>>  out:
>>       return status;
>> +out_err:
>> +     cleanup_async_copy(async_copy, false);
>> +     goto out;
>>  }
>>
>>  static __be32
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
