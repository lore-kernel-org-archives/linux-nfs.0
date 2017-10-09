Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45854 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754473AbdJIP6G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Oct 2017 11:58:06 -0400
Date: Mon, 9 Oct 2017 11:58:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 08/10] NFSD handle OFFLOAD_CANCEL op
Message-ID: <20171009155804.GA1586@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-9-kolga@netapp.com>
 <20170928183846.GG10182@parsley.fieldses.org>
 <CAN-5tyFfTZ=CFsyM8CWWXkGt8jvLBV+qH60Yd-X4p5ohK5pK=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFfTZ=CFsyM8CWWXkGt8jvLBV+qH60Yd-X4p5ohK5pK=g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 09, 2017 at 10:53:13AM -0400, Olga Kornievskaia wrote:
> On Thu, Sep 28, 2017 at 2:38 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Sep 28, 2017 at 01:29:43PM -0400, Olga Kornievskaia wrote:
> >> Upon receiving OFFLOAD_CANCEL search the list of copy stateids,
> >> if found mark it cancelled. If copy has more interations to
> >> call vfs_copy_file_range, it'll stop it. Server won't be sending
> >> CB_OFFLOAD to the client since it received a cancel.
> >>
> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >> ---
> >>  fs/nfsd/nfs4proc.c  | 26 ++++++++++++++++++++++++--
> >>  fs/nfsd/nfs4state.c | 16 ++++++++++++++++
> >>  fs/nfsd/state.h     |  4 ++++
> >>  3 files changed, 44 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 3cddebb..f4f3d93 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -1139,6 +1139,7 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
> >>       size_t bytes_to_copy;
> >>       u64 src_pos = copy->cp_src_pos;
> >>       u64 dst_pos = copy->cp_dst_pos;
> >> +     bool cancelled = false;
> >>
> >>       do {
> >>               bytes_to_copy = min_t(u64, bytes_total, MAX_RW_COUNT);
> >> @@ -1150,7 +1151,12 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
> >>               copy->cp_res.wr_bytes_written += bytes_copied;
> >>               src_pos += bytes_copied;
> >>               dst_pos += bytes_copied;
> >> -     } while (bytes_total > 0 && !copy->cp_synchronous);
> >> +             if (!copy->cp_synchronous) {
> >> +                     spin_lock(&copy->cps->cp_lock);
> >> +                     cancelled = copy->cps->cp_cancelled;
> >> +                     spin_unlock(&copy->cps->cp_lock);
> >> +             }
> >> +     } while (bytes_total > 0 && !copy->cp_synchronous && !cancelled);
> >>       return bytes_copied;
> >
> > I'd rather we sent a signal, and then we won't need this
> > logic--vfs_copy_range() will just return EINTR or something.
> 
> Hi Bruce,
> 
> Now that I've implemented using the kthread instead of the workqueue,
> I don't see that it can provide any better  guarantee than the work
> queue. vfs_copy_range() is not interrupted in the middle and returning
> the EINTR. The function that runs the kthread, it has to at some point
> call signalled()/kthread_should_stop() function to see if it was
> signaled and use it to 'stop working instead of continuing on'.
> 
> If I were to remove the loop and check (if signaled() ||
> kthread_should_stop()) before and after calling the
> vfs_copy_file_range(), the copy will either not start if the
> OFFLOAD_CANCEL was received before copy started or the whole copy
> would happen.
> 
> Even with the loop, I'd be checking after every call for
> vfs_copy_file_range() just like it was in the current version with the
> workqueue.
> 
> Please advise if you still want the kthread-based implementation or
> keep the workqueue.

That's interesting.

To me that sounds like a bug somewhere under vfs_copy_file_range().
splice_direct_to_actor() can do long-running copies, so it should be
interruptible, shouldn't it?

--b.

> 
> > That will help us get rid of the 4MB-at-a-time loop.  And will mean we
> > don't need to wait for the next 4MB copy to finish before stopping the
> > loop.  Normally I wouldn't expect that to take too long, but it might.
> > And a situation where a cancel is sent is a situation where we're
> > probably more likely to have some problem slowing down the copy.
> >
> > Also: don't we want OFFLOAD_CANCEL to wait until the cancel has actually
> > taken effect before returning?
> >
> > I can't see any language in the spec to that affect, but it would seem
> > surprising to me if I got back a succesful response to OFFLOAD_CANCEL
> > and then noticed that the target file was still changing.
> >
> > --b.
> >
> >>  }
> >>
> >> @@ -1198,6 +1204,10 @@ static void nfsd4_do_async_copy(struct work_struct *work)
> >>       struct nfsd4_copy *cb_copy;
> >>
> >>       copy->nfserr = nfsd4_do_copy(copy, 0);
> >> +
> >> +     if (copy->cps->cp_cancelled)
> >> +             goto out;
> >> +
> >>       cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> >>       if (!cb_copy)
> >>               goto out;
> >> @@ -1269,7 +1279,19 @@ static void nfsd4_do_async_copy(struct work_struct *work)
> >>                    struct nfsd4_compound_state *cstate,
> >>                    union nfsd4_op_u *u)
> >>  {
> >> -     return 0;
> >> +     struct nfsd4_offload_status *os = &u->offload_status;
> >> +     struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> >> +     __be32 status;
> >> +     struct nfs4_cp_state *state = NULL;
> >> +
> >> +     status = find_cp_state(nn, &os->stateid, &state);
> >> +     if (state) {
> >> +             spin_lock(&state->cp_lock);
> >> +             state->cp_cancelled = true;
> >> +             spin_unlock(&state->cp_lock);
> >> +     }
> >> +
> >> +     return status;
> >>  }
> >>
> >>  static __be32
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index be59baf..97ab3f8 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -752,6 +752,22 @@ static void nfs4_free_deleg(struct nfs4_stid *stid)
> >>       atomic_long_dec(&num_delegations);
> >>  }
> >>
> >> +__be32 find_cp_state(struct nfsd_net *nn, stateid_t *st,
> >> +                         struct nfs4_cp_state **cps)
> >> +{
> >> +     struct nfs4_cp_state *state = NULL;
> >> +
> >> +     if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
> >> +             return nfserr_bad_stateid;
> >> +     spin_lock(&nn->s2s_cp_lock);
> >> +     state = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
> >> +     spin_unlock(&nn->s2s_cp_lock);
> >> +     if (!state)
> >> +             return nfserr_bad_stateid;
> >> +     *cps = state;
> >> +     return 0;
> >> +}
> >> +
> >>  /*
> >>   * When we recall a delegation, we should be careful not to hand it
> >>   * out again straight away.
> >> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> >> index 8724955..7a070d5 100644
> >> --- a/fs/nfsd/state.h
> >> +++ b/fs/nfsd/state.h
> >> @@ -111,6 +111,8 @@ struct nfs4_cp_state {
> >>       stateid_t               cp_stateid;
> >>       struct list_head        cp_list;        /* per parent nfs4_stid */
> >>       struct nfs4_stid        *cp_p_stid;     /* pointer to parent */
> >> +     bool                    cp_cancelled;   /* copy cancelled */
> >> +     spinlock_t              cp_lock;
> >>  };
> >>
> >>  /*
> >> @@ -647,6 +649,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
> >>  extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
> >>  extern int nfsd4_create_copy_queue(void);
> >>  extern void nfsd4_destroy_copy_queue(void);
> >> +extern __be32 find_cp_state(struct nfsd_net *nn, stateid_t *st,
> >> +                     struct nfs4_cp_state **cps);
> >>
> >>  struct nfs4_file *find_file(struct knfsd_fh *fh);
> >>  void put_nfs4_file(struct nfs4_file *fi);
> >> --
> >> 1.8.3.1
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
