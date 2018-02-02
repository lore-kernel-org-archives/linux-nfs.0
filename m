Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:34425 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752597AbeBBUpa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Feb 2018 15:45:30 -0500
Received: by mail-ua0-f193.google.com with SMTP id g5so3244664uac.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Feb 2018 12:45:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180126215942.GC7770@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com> <20171024174752.74910-8-kolga@netapp.com>
 <20180126215942.GC7770@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 2 Feb 2018 15:45:28 -0500
Message-ID: <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 26, 2018 at 4:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Oct 24, 2017 at 01:47:49PM -0400, Olga Kornievskaia wrote:
>> Generate a new stateid to be used for reply to the asynchronous
>> COPY (this would also be used later by COPY_NOTIFY as well).
>> Associate the stateid with the parent OPEN/LOCK/DELEG stateid
>> that can be freed during the free of the parent stateid. However,
>> right now deciding to bind the lifetime to when the vfs copy
>> is done. This way don't need to keep the nfsd_net structure for
>> the callback. The drawback is that time copy state information
>> is available for query by OFFLOAD_STATUS is slightly less.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfsd/netns.h     |  8 +++++++
>>  fs/nfsd/nfs4proc.c  | 32 +++++++++++++++++++-------
>>  fs/nfsd/nfs4state.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfsctl.c    |  1 +
>>  fs/nfsd/state.h     | 14 ++++++++++++
>>  fs/nfsd/xdr4.h      |  2 ++
>>  6 files changed, 115 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>> index 3714231..2c88a95 100644
>> --- a/fs/nfsd/netns.h
>> +++ b/fs/nfsd/netns.h
>> @@ -119,6 +119,14 @@ struct nfsd_net {
>>       u32 clverifier_counter;
>>
>>       struct svc_serv *nfsd_serv;
>> +
>> +     /*
>> +      * clientid and stateid data for construction of net unique COPY
>> +      * stateids.
>> +      */
>> +     u32             s2s_cp_cl_id;
>> +     struct idr      s2s_cp_stateids;
>> +     spinlock_t      s2s_cp_lock;
>>  };
>>
>>  /* Simple check to find out if a given net was properly initialized */
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index a020533..6876080 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1039,7 +1039,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>>  static __be32
>>  nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>                 stateid_t *src_stateid, struct file **src,
>> -               stateid_t *dst_stateid, struct file **dst)
>> +               stateid_t *dst_stateid, struct file **dst,
>> +               struct nfs4_stid **stid)
>>  {
>>       __be32 status;
>>
>> @@ -1053,7 +1054,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>>
>>       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
>>                                           dst_stateid, WR_STATE, dst, NULL,
>> -                                         NULL);
>> +                                         stid);
>>       if (status) {
>>               dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
>>               goto out_put_src;
>> @@ -1084,7 +1085,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>>       __be32 status;
>>
>>       status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
>> -                                &clone->cl_dst_stateid, &dst);
>> +                                &clone->cl_dst_stateid, &dst, NULL);
>>       if (status)
>>               goto out;
>>
>> @@ -1117,8 +1118,6 @@ static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
>>
>>  static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
>>  {
>> -     memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
>> -             sizeof(copy->cp_dst_stateid));
>>       copy->cp_res.wr_stable_how = NFS_UNSTABLE;
>>       copy->cp_consecutive = 1;
>>       copy->cp_synchronous = sync;
>> @@ -1180,10 +1179,15 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
>>       atomic_inc(&dst->cp_clp->cl_refcount);
>>       dst->fh_dst = get_file(src->fh_dst);
>>       dst->fh_src = get_file(src->fh_src);
>> +     dst->stid = src->stid;
>> +     dst->cps = src->cps;
>>  }
>>
>>  static void cleanup_async_copy(struct nfsd4_copy *copy)
>>  {
>> +     list_del(&copy->cps->cp_list);
>> +     nfs4_free_cp_state(copy->cps);
>> +     nfs4_put_stid(copy->stid);
>>       fput(copy->fh_dst);
>>       fput(copy->fh_src);
>>       spin_lock(&copy->cp_clp->async_lock);
>> @@ -1225,7 +1229,7 @@ static int nfsd4_do_async_copy(void *data)
>>
>>       status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
>>                                  &copy->fh_src, &copy->cp_dst_stateid,
>> -                                &copy->fh_dst);
>> +                                &copy->fh_dst, &copy->stid);
>>       if (status)
>>               goto out;
>>
>> @@ -1234,15 +1238,27 @@ static int nfsd4_do_async_copy(void *data)
>>               sizeof(struct knfsd_fh));
>>       copy->net = SVC_NET(rqstp);
>>       if (!copy->cp_synchronous) {
>> +             struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
>> +
>>               status = nfsd4_init_copy_res(copy, 0);
>>               async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>>               if (!async_copy) {
>>                       status = nfserrno(-ENOMEM);
>>                       goto out;
>>               }
>> +             copy->cps = nfs4_alloc_init_cp_state(nn, copy->stid);
>> +             if (!copy->cps) {
>> +                     status = nfserrno(-ENOMEM);
>> +                     kfree(async_copy);
>> +                     goto out;
>> +             }
>> +             /* take a reference on the parent stateid so it's not
>> +              * not freed by the copy compound
>> +              */
>> +             atomic_inc(&copy->stid->sc_count);
>> +             memcpy(&copy->cp_res.cb_stateid, &copy->cps->cp_stateid,
>> +                     sizeof(copy->cps->cp_stateid));
>>               dup_copy_fields(copy, async_copy);
>> -             memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
>> -                     sizeof(copy->cp_dst_stateid));
>>               spin_lock(&async_copy->cp_clp->async_lock);
>>               list_add(&async_copy->copies,
>>                               &async_copy->cp_clp->async_copies);
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index af40762..f9151f2 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -658,6 +658,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
>>       /* Will be incremented before return to client: */
>>       atomic_set(&stid->sc_count, 1);
>>       spin_lock_init(&stid->sc_lock);
>> +     INIT_LIST_HEAD(&stid->sc_cp_list);
>>
>>       /*
>>        * It shouldn't be a problem to reuse an opaque stateid value.
>> @@ -674,6 +675,66 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
>>       return NULL;
>>  }
>>
>> +/*
>> + * Create a unique stateid_t to represent each COPY. Hang the copy
>> + * stateids off the OPEN/LOCK/DELEG stateid from the client open
>> + * the source file.
>> + */
>> +struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
>> +                                            struct nfs4_stid *p_stid)
>> +{
>> +     struct nfs4_cp_state *cps;
>> +     int new_id;
>> +
>> +     cps = kzalloc(sizeof(struct nfs4_cp_state), GFP_KERNEL);
>> +     if (!cps)
>> +             return NULL;
>> +     idr_preload(GFP_KERNEL);
>> +     spin_lock(&nn->s2s_cp_lock);
>> +     new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, cps, 0, 0, GFP_NOWAIT);
>> +     spin_unlock(&nn->s2s_cp_lock);
>> +     idr_preload_end();
>> +     if (new_id < 0)
>> +             goto out_free;
>> +     cps->cp_stateid.si_opaque.so_id = new_id;
>> +     cps->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
>> +     cps->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
>> +     cps->cp_p_stid = p_stid;
>> +     INIT_LIST_HEAD(&cps->cp_list);
>> +     list_add(&cps->cp_list, &p_stid->sc_cp_list);
>> +
>> +     return cps;
>> +out_free:
>> +     kfree(cps);
>> +     return NULL;
>> +}
>> +
>> +void nfs4_free_cp_state(struct nfs4_cp_state *cps)
>> +{
>> +     struct nfsd_net *nn;
>> +
>> +     nn = net_generic(cps->cp_p_stid->sc_client->net, nfsd_net_id);
>> +     spin_lock(&nn->s2s_cp_lock);
>> +     idr_remove(&nn->s2s_cp_stateids, cps->cp_stateid.si_opaque.so_id);
>> +     spin_unlock(&nn->s2s_cp_lock);
>> +
>> +     kfree(cps);
>> +}
>> +
>> +static void nfs4_free_cp_statelist(struct nfs4_stid *stid)
>> +{
>> +     struct nfs4_cp_state *cps;
>> +
>> +     might_sleep();
>> +
>> +     while (!list_empty(&stid->sc_cp_list)) {
>> +             cps = list_first_entry(&stid->sc_cp_list, struct nfs4_cp_state,
>> +                                    cp_list);
>> +             list_del(&cps->cp_list);
>> +             nfs4_free_cp_state(cps);
>> +     }
>> +}
>> +
>>  static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
>>  {
>>       struct nfs4_stid *stid;
>> @@ -819,6 +880,9 @@ static void block_delegations(struct knfsd_fh *fh)
>>       }
>>       idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
>>       spin_unlock(&clp->cl_lock);
>> +
>> +     nfs4_free_cp_statelist(s);
>
> Is this really safe if there are still ongoing copies?

You are right. It is not.

> I think the copies take a reference count on the parent stateid, so I
> think we should never actually get here: perhaps this could just be a
> WARN_ON(!list_empty(&s->s_cp_list)).  Though nfsd4_copy puts things on
> this list before bumping the sc_count, so there may be a race there.
>
> What is supposed to happen, by the way, if a close arrives for a stateid
> with a copy in progress?  Do we cancel the copy before returning from
> the close, or do we fail the close?  (Same question for unlock and
> delegation return, I guess.)

Good questions. I think a normal client shouldn't send CLOSE/UNLOCK
while there is an on-going copy. I could see how a DELEGRETURN could
be coming in the middle of the copy (because the client received a
CB_RECALL).

For an easy solution my proposal is to do the following. Upon
receiving close, unlock, delegreturn, if the copy list is non-empty,
then we send an ERR_DELAY back until the copy is done.

Another proposal is to kill the copy thread but that seems too drastic
(specially in the case of a delegreturn). Right now when the copy
thread is killed, it does not send a reply back to the client (as it
assumes the client sent the OFFLOAD_CANCEL and doesn't need a reply).
I could change that to send a reply back. In case the copy used a
delegation stateid, then the next copy would choose a different
stateid. This could be done for the delegation stateid and ERR_DELAY
for the close/unlock.

Is either one acceptable and if so which one sounds better to you?


>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
