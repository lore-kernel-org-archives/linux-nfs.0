Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47792 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753177AbeCVPRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Mar 2018 11:17:45 -0400
Date: Thu, 22 Mar 2018 11:17:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 07/10] NFSD create new stateid for async copy
Message-ID: <20180322151745.GL4288@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-8-kolga@netapp.com>
 <20180308163121.GE10782@fieldses.org>
 <CAN-5tyH08LBhkY24yC24cCb16kJ5C8zN7Dp3cqawVStiJr6u5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyH08LBhkY24yC24cCb16kJ5C8zN7Dp3cqawVStiJr6u5w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 22, 2018 at 11:12:23AM -0400, Olga Kornievskaia wrote:
> On Thu, Mar 8, 2018 at 11:31 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Feb 20, 2018 at 11:42:26AM -0500, Olga Kornievskaia wrote:
> >> Generate a new stateid to be used for reply to the asynchronous
> >> COPY (this would also be used later by COPY_NOTIFY as well).
> >> Associate the stateid with the parent OPEN/LOCK/DELEG stateid
> >> that can be freed during the free of the parent stateid. However,
> >> right now deciding to bind the lifetime to when the vfs copy
> >> is done. This way don't need to keep the nfsd_net structure for
> >> the callback. The drawback is that time copy state information
> >> is available for query by OFFLOAD_STATUS is slightly less.
> >
> > I don't understand yet the purpose of the parent stateid.
> >
> > I understand that it's part of the COPY arguments and that we need to
> > check it when we first process the COPY.  But what's it used for after
> > that?  Why do we need to keep it around?
> 
> Parent stateid tie is needed for when the "CLOSE" is received. CLOSE
> only has the parent state. We have a global list of async copies and
> then each copy has a pointer to parent to provide the match.

Why do you need it on CLOSE?  Is it that CLOSE is supposed to find any
related copies and shut them down or return an error?  (I thought we
decided that we could leave that to the client--but maybe I've lost
track of that discussion.)

--b.

> 
> >
> > --b.
> >
> >>
> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >> ---
> >>  fs/nfsd/netns.h     |  8 +++++++
> >>  fs/nfsd/nfs4proc.c  | 34 ++++++++++++++++++--------
> >>  fs/nfsd/nfs4state.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>  fs/nfsd/nfsctl.c    |  1 +
> >>  fs/nfsd/state.h     | 14 +++++++++++
> >>  fs/nfsd/xdr4.h      |  2 ++
> >>  6 files changed, 118 insertions(+), 10 deletions(-)
> >>
> >> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> >> index 36358d4..e83cf6e 100644
> >> --- a/fs/nfsd/netns.h
> >> +++ b/fs/nfsd/netns.h
> >> @@ -122,6 +122,14 @@ struct nfsd_net {
> >>
> >>       wait_queue_head_t ntf_wq;
> >>       atomic_t ntf_refcnt;
> >> +
> >> +     /*
> >> +      * clientid and stateid data for construction of net unique COPY
> >> +      * stateids.
> >> +      */
> >> +     u32             s2s_cp_cl_id;
> >> +     struct idr      s2s_cp_stateids;
> >> +     spinlock_t      s2s_cp_lock;
> >>  };
> >>
> >>  /* Simple check to find out if a given net was properly initialized */
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index aafd5a58..eb9f528 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -1030,7 +1030,8 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >>  static __be32
> >>  nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>                 stateid_t *src_stateid, struct file **src,
> >> -               stateid_t *dst_stateid, struct file **dst)
> >> +               stateid_t *dst_stateid, struct file **dst,
> >> +               struct nfs4_stid **stid)
> >>  {
> >>       __be32 status;
> >>
> >> @@ -1044,7 +1045,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >>
> >>       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> >>                                           dst_stateid, WR_STATE, dst, NULL,
> >> -                                         NULL);
> >> +                                         stid);
> >>       if (status) {
> >>               dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
> >>               goto out_put_src;
> >> @@ -1075,7 +1076,7 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >>       __be32 status;
> >>
> >>       status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
> >> -                                &clone->cl_dst_stateid, &dst);
> >> +                                &clone->cl_dst_stateid, &dst, NULL);
> >>       if (status)
> >>               goto out;
> >>
> >> @@ -1108,8 +1109,6 @@ static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
> >>
> >>  static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
> >>  {
> >> -     memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> >> -             sizeof(copy->cp_dst_stateid));
> >>       copy->cp_res.wr_stable_how = NFS_UNSTABLE;
> >>       copy->cp_consecutive = 1;
> >>       copy->cp_synchronous = sync;
> >> @@ -1171,10 +1170,15 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
> >>       atomic_inc(&dst->cp_clp->cl_refcount);
> >>       dst->fh_dst = get_file(src->fh_dst);
> >>       dst->fh_src = get_file(src->fh_src);
> >> +     dst->stid = src->stid;
> >> +     dst->cps = src->cps;
> >>  }
> >>
> >>  static void cleanup_async_copy(struct nfsd4_copy *copy, bool remove)
> >>  {
> >> +     list_del(&copy->cps->cp_list);
> >> +     nfs4_free_cp_state(copy->cps);
> >> +     nfs4_put_stid(copy->stid);
> >>       fput(copy->fh_dst);
> >>       fput(copy->fh_src);
> >>       if (remove) {
> >> @@ -1218,7 +1222,7 @@ static int nfsd4_do_async_copy(void *data)
> >>
> >>       status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
> >>                                  &copy->fh_src, &copy->cp_dst_stateid,
> >> -                                &copy->fh_dst);
> >> +                                &copy->fh_dst, &copy->stid);
> >>       if (status)
> >>               goto out;
> >>
> >> @@ -1226,18 +1230,28 @@ static int nfsd4_do_async_copy(void *data)
> >>       memcpy(&copy->fh, &cstate->current_fh.fh_handle,
> >>               sizeof(struct knfsd_fh));
> >>       copy->net = SVC_NET(rqstp);
> >> -     /* for now disable asynchronous copy feature */
> >> -     copy->cp_synchronous = 1;
> >>       if (!copy->cp_synchronous) {
> >> +             struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> >> +
> >>               status = nfsd4_init_copy_res(copy, 0);
> >>               async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> >>               if (!async_copy) {
> >>                       status = nfserrno(-ENOMEM);
> >>                       goto out;
> >>               }
> >> +             copy->cps = nfs4_alloc_init_cp_state(nn, copy->stid);
> >> +             if (!copy->cps) {
> >> +                     status = nfserrno(-ENOMEM);
> >> +                     kfree(async_copy);
> >> +                     goto out;
> >> +             }
> >> +             /* take a reference on the parent stateid so it's not
> >> +              * not freed by the copy compound
> >> +              */
> >> +             refcount_inc(&copy->stid->sc_count);
> >> +             memcpy(&copy->cp_res.cb_stateid, &copy->cps->cp_stateid,
> >> +                     sizeof(copy->cps->cp_stateid));
> >>               dup_copy_fields(copy, async_copy);
> >> -             memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> >> -                     sizeof(copy->cp_dst_stateid));
> >>               async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
> >>                               async_copy, "%s", "copy thread");
> >>               if (IS_ERR(async_copy->copy_task)) {
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index e05832b..bd76bd1 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -667,6 +667,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
> >>       /* Will be incremented before return to client: */
> >>       refcount_set(&stid->sc_count, 1);
> >>       spin_lock_init(&stid->sc_lock);
> >> +     INIT_LIST_HEAD(&stid->sc_cp_list);
> >>
> >>       /*
> >>        * It shouldn't be a problem to reuse an opaque stateid value.
> >> @@ -683,6 +684,69 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
> >>       return NULL;
> >>  }
> >>
> >> +/*
> >> + * Create a unique stateid_t to represent each COPY. Hang the copy
> >> + * stateids off the OPEN/LOCK/DELEG stateid from the client open
> >> + * the source file.
> >> + */
> >> +struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
> >> +                                            struct nfs4_stid *p_stid)
> >> +{
> >> +     struct nfs4_cp_state *cps;
> >> +     int new_id;
> >> +
> >> +     cps = kzalloc(sizeof(struct nfs4_cp_state), GFP_KERNEL);
> >> +     if (!cps)
> >> +             return NULL;
> >> +     idr_preload(GFP_KERNEL);
> >> +     spin_lock(&nn->s2s_cp_lock);
> >> +     new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, cps, 0, 0, GFP_NOWAIT);
> >> +     spin_unlock(&nn->s2s_cp_lock);
> >> +     idr_preload_end();
> >> +     if (new_id < 0)
> >> +             goto out_free;
> >> +     cps->cp_stateid.si_opaque.so_id = new_id;
> >> +     cps->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
> >> +     cps->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
> >> +     cps->cp_p_stid = p_stid;
> >> +     spin_lock(&p_stid->sc_lock);
> >> +     list_add(&cps->cp_list, &p_stid->sc_cp_list);
> >> +     spin_unlock(&p_stid->sc_lock);
> >> +
> >> +     return cps;
> >> +out_free:
> >> +     kfree(cps);
> >> +     return NULL;
> >> +}
> >> +
> >> +void nfs4_free_cp_state(struct nfs4_cp_state *cps)
> >> +{
> >> +     struct nfsd_net *nn;
> >> +
> >> +     nn = net_generic(cps->cp_p_stid->sc_client->net, nfsd_net_id);
> >> +     spin_lock(&nn->s2s_cp_lock);
> >> +     idr_remove(&nn->s2s_cp_stateids, cps->cp_stateid.si_opaque.so_id);
> >> +     spin_unlock(&nn->s2s_cp_lock);
> >> +
> >> +     kfree(cps);
> >> +}
> >> +
> >> +static void nfs4_free_cp_statelist(struct nfs4_stid *stid)
> >> +{
> >> +     struct nfs4_cp_state *cps;
> >> +
> >> +     might_sleep();
> >> +
> >> +     spin_lock(&stid->sc_lock);
> >> +     while (!list_empty(&stid->sc_cp_list)) {
> >> +             cps = list_first_entry(&stid->sc_cp_list, struct nfs4_cp_state,
> >> +                                    cp_list);
> >> +             list_del(&cps->cp_list);
> >> +             nfs4_free_cp_state(cps);
> >> +     }
> >> +     spin_unlock(&stid->sc_lock);
> >> +}
> >> +
> >>  static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
> >>  {
> >>       struct nfs4_stid *stid;
> >> @@ -828,6 +892,9 @@ static void block_delegations(struct knfsd_fh *fh)
> >>       }
> >>       idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
> >>       spin_unlock(&clp->cl_lock);
> >> +
> >> +     nfs4_free_cp_statelist(s);
> >> +
> >>       s->sc_free(s);
> >>       if (fp)
> >>               put_nfs4_file(fp);
> >> @@ -7115,6 +7182,8 @@ static int nfs4_state_create_net(struct net *net)
> >>       INIT_LIST_HEAD(&nn->close_lru);
> >>       INIT_LIST_HEAD(&nn->del_recall_lru);
> >>       spin_lock_init(&nn->client_lock);
> >> +     spin_lock_init(&nn->s2s_cp_lock);
> >> +     idr_init(&nn->s2s_cp_stateids);
> >>
> >>       spin_lock_init(&nn->blocked_locks_lock);
> >>       INIT_LIST_HEAD(&nn->blocked_locks_lru);
> >> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> >> index d107b44..63edf68 100644
> >> --- a/fs/nfsd/nfsctl.c
> >> +++ b/fs/nfsd/nfsctl.c
> >> @@ -1241,6 +1241,7 @@ static __net_init int nfsd_init_net(struct net *net)
> >>       nn->nfsd4_grace = 90;
> >>       nn->clverifier_counter = prandom_u32();
> >>       nn->clientid_counter = prandom_u32();
> >> +     nn->s2s_cp_cl_id = nn->clientid_counter++;
> >>
> >>       atomic_set(&nn->ntf_refcnt, 0);
> >>       init_waitqueue_head(&nn->ntf_wq);
> >> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> >> index 9b7d7a0..49709d1 100644
> >> --- a/fs/nfsd/state.h
> >> +++ b/fs/nfsd/state.h
> >> @@ -94,6 +94,7 @@ struct nfs4_stid {
> >>  #define NFS4_REVOKED_DELEG_STID 16
> >>  #define NFS4_CLOSED_DELEG_STID 32
> >>  #define NFS4_LAYOUT_STID 64
> >> +     struct list_head        sc_cp_list;
> >>       unsigned char           sc_type;
> >>       stateid_t               sc_stateid;
> >>       spinlock_t              sc_lock;
> >> @@ -103,6 +104,17 @@ struct nfs4_stid {
> >>  };
> >>
> >>  /*
> >> + * Keep a list of stateids issued by the COPY, associate it with the
> >> + * parent OPEN/LOCK/DELEG stateid. Used for lookup by
> >> + * OFFLOAD_CANCEL and OFFLOAD_STATUS (as well as COPY_NOTIFY)
> >> + */
> >> +struct nfs4_cp_state {
> >> +     stateid_t               cp_stateid;
> >> +     struct list_head        cp_list;        /* per parent nfs4_stid */
> >> +     struct nfs4_stid        *cp_p_stid;     /* pointer to parent */
> >> +};
> >> +
> >> +/*
> >>   * Represents a delegation stateid. The nfs4_client holds references to these
> >>   * and they are put when it is being destroyed or when the delegation is
> >>   * returned by the client:
> >> @@ -612,6 +624,8 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
> >>                    struct nfs4_stid **s, struct nfsd_net *nn);
> >>  struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
> >>                                 void (*sc_free)(struct nfs4_stid *));
> >> +struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn, struct nfs4_stid *p_stid);
> >> +void nfs4_free_cp_state(struct nfs4_cp_state *cps);
> >>  void nfs4_unhash_stid(struct nfs4_stid *s);
> >>  void nfs4_put_stid(struct nfs4_stid *s);
> >>  void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
> >> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> >> index 3b6b655..5d493b9 100644
> >> --- a/fs/nfsd/xdr4.h
> >> +++ b/fs/nfsd/xdr4.h
> >> @@ -535,6 +535,8 @@ struct nfsd4_copy {
> >>       struct file             *fh_src;
> >>       struct file             *fh_dst;
> >>       struct net              *net;
> >> +     struct nfs4_stid        *stid;
> >> +     struct nfs4_cp_state    *cps;
> >>
> >>       struct list_head        copies;
> >>       struct task_struct      *copy_task;
> >> --
> >> 1.8.3.1
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
