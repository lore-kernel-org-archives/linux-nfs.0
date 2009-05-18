From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 07/31] nfsd41: replay solo and embedded create
	session
Date: Mon, 18 May 2009 10:23:24 -0400
Message-ID: <20090518142323.GB1978@fieldses.org>
References: <1240938005-23778-1-git-send-email-andros@netapp.com> <1240938005-23778-2-git-send-email-andros@netapp.com> <1240938005-23778-3-git-send-email-andros@netapp.com> <1240938005-23778-4-git-send-email-andros@netapp.com> <1240938005-23778-5-git-send-email-andros@netapp.com> <1240938005-23778-6-git-send-email-andros@netapp.com> <1240938005-23778-7-git-send-email-andros@netapp.com> <20090515230821.GH26389@fieldses.org> <89c397150905180702x6cecb802md9fed2f7f81e9aa1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33178 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbZEROXY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 May 2009 10:23:24 -0400
In-Reply-To: <89c397150905180702x6cecb802md9fed2f7f81e9aa1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 18, 2009 at 10:02:25AM -0400, William A. (Andy) Adamson wrote:
> On Fri, May 15, 2009 at 7:08 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Apr 28, 2009 at 12:59:41PM -0400, andros@netapp.com wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> CREATE_SESSION can be preceeded by a SEQUENCE operation (an embedded
> >> CREATE_SESSION) and the create session single slot cache must be maintained.
> >> Always replay a create session from nfsd4_replay_create_session(). Leave
> >> nfsd4_store_cache_entry() for session (sequence operation) replays.
> >>
> >> Set cstate->status to a new internal error, nfserr_replay_clientid_cache, and
> >> change the logic in nfsd4_proc_compound so that CREATE_SESSION replays replace
> >> encode_operation.
> >> The new internal error is needed to differentiate between an embedded
> >> CREATE_SESSION replay and a SEQUENCE replay.
> >
> > And making the clientid_cache cache just the unencoded
> > nfsd4_create_session would avoid the need for this special case, since
> > it would look to nfsd4_proc_compound() like any other create_session.
> 
> I believe we will still need the new internal case.
> When the sequence operation replay case gets hit in
> nfsd4_proc_compound, the entire reply has been constructed from the
> cache, so the sequence operation replay exits nfsd4_proc_compound
> processing.
> 
> In the create session replay case, only the create session operation
> will be reconstructed from the cache, and it might be an embedded
> create session (part of another sessions sequence compound) and so the
> rest of the operations in that compound would need to be processed.
> So, the create session replay does not exit nfsd4_proc_compound
> processing.

Right--and in that respect it's just like any other (non-replay) case.

So you'd still need the sequence case, but you wouldn't need the
replay_clientid_cache case, which would be encoded normally--the only
"replay" would be done inside create_session's proc function, which
would restore the saved values to the struct nfsd4_create_session.

Where possible, I'm happier keeping special cases inside the individual
op functions rather than in nfsd_proc_compound.

--b.

> 
> -->Andy
> >
> > --b.
> >
> >>
> >> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> ---
> >>  fs/nfsd/nfs4proc.c        |    9 +++++++--
> >>  fs/nfsd/nfs4state.c       |    5 +++++
> >>  fs/nfsd/nfs4xdr.c         |   17 +++++++++++++++++
> >>  include/linux/nfsd/nfsd.h |    2 ++
> >>  include/linux/nfsd/xdr4.h |    2 ++
> >>  5 files changed, 33 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index b2883e9..32d5866 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -996,7 +996,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> >>                       BUG_ON(op->status == nfs_ok);
> >>
> >>  encode_op:
> >> -             /* Only from SEQUENCE or CREATE_SESSION */
> >> +             /* Only from SEQUENCE */
> >>               if (resp->cstate.status == nfserr_replay_cache) {
> >>                       dprintk("%s NFS4.1 replay from cache\n", __func__);
> >>                       if (nfsd4_not_cached(resp))
> >> @@ -1005,7 +1005,12 @@ encode_op:
> >>                               status = op->status;
> >>                       goto out;
> >>               }
> >> -             if (op->status == nfserr_replay_me) {
> >> +             /* Only from CREATE_SESSION */
> >> +             if (resp->cstate.status == nfserr_replay_clientid_cache) {
> >> +                     dprintk("%s NFS4.1 replay from clientid cache\n",
> >> +                             __func__);
> >> +                     status = op->status;
> >> +             } else if (op->status == nfserr_replay_me) {
> >>                       op->replay = &cstate->replay_owner->so_replay;
> >>                       nfsd4_encode_replay(resp, op);
> >>                       status = op->status = op->replay->rp_status;
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index de7cc51..e216169 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -1350,6 +1350,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >>                    struct nfsd4_create_session *cr_ses)
> >>  {
> >>       u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
> >> +     struct nfsd4_compoundres *resp = rqstp->rq_resp;
> >>       struct nfs4_client *conf, *unconf;
> >>       struct nfsd4_clid_slot *slot = NULL;
> >>       int status = 0;
> >> @@ -1364,6 +1365,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >>               if (status == nfserr_replay_cache) {
> >>                       dprintk("Got a create_session replay! seqid= %d\n",
> >>                               slot->sl_seqid);
> >> +                     cstate->status = nfserr_replay_clientid_cache;
> >> +                     /* Return the cached reply status */
> >> +                     status = nfsd4_replay_create_session(resp, slot);
> >> +                     goto out;
> >>               } else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
> >>                       status = nfserr_seq_misordered;
> >>                       dprintk("Sequence misordered!\n");
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index 1dfec1d..238612e 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -3064,6 +3064,23 @@ nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
> >>       slot->sl_datalen = (char *)resp->p - (char *)p;
> >>  }
> >>
> >> +__be32
> >> +nfsd4_replay_create_session(struct nfsd4_compoundres *resp,
> >> +                         struct nfsd4_clid_slot *slot)
> >> +{
> >> +     __be32 *p;
> >> +
> >> +     RESERVE_SPACE(8);
> >> +     WRITE32(OP_CREATE_SESSION);
> >> +     *p++ = slot->sl_status; /* already in network byte order */
> >> +     ADJUST_ARGS();
> >> +
> >> +     memcpy(resp->p, slot->sl_data, slot->sl_datalen);
> >> +     p += XDR_QUADLEN(slot->sl_datalen);
> >> +     ADJUST_ARGS();
> >> +     return slot->sl_status;
> >> +}
> >> +
> >>  static __be32
> >>  nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
> >>                            struct nfsd4_destroy_session *destroy_session)
> >> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
> >> index 2b49d67..9cd6399 100644
> >> --- a/include/linux/nfsd/nfsd.h
> >> +++ b/include/linux/nfsd/nfsd.h
> >> @@ -301,6 +301,8 @@ void              nfsd_lockd_shutdown(void);
> >>  #define      nfserr_replay_me        cpu_to_be32(11001)
> >>  /* nfs41 replay detected */
> >>  #define      nfserr_replay_cache     cpu_to_be32(11002)
> >> +/* nfs41 clientid cache replay detected */
> >> +#define      nfserr_replay_clientid_cache    cpu_to_be32(11003)
> >>
> >>  /* Check for dir entries '.' and '..' */
> >>  #define isdotent(n, l)       (l < 3 && n[0] == '.' && (l == 1 || n[1] == '.'))
> >> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> >> index 21e0b73..ac00985 100644
> >> --- a/include/linux/nfsd/xdr4.h
> >> +++ b/include/linux/nfsd/xdr4.h
> >> @@ -519,6 +519,8 @@ extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
> >>               struct nfsd4_sequence *seq);
> >>  extern void nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
> >>               struct nfsd4_clid_slot *slot, int nfserr);
> >> +extern __be32 nfsd4_replay_create_session(struct nfsd4_compoundres *resp,
> >> +             struct nfsd4_clid_slot *slot);
> >>  extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
> >>               struct nfsd4_compound_state *,
> >>  struct nfsd4_exchange_id *);
> >> --
> >> 1.5.4.3
> >>
> > _______________________________________________
> > pNFS mailing list
> > pNFS@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> >
