Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47142 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751463AbdIOUCX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 16:02:23 -0400
Date: Fri, 15 Sep 2017 16:02:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [RFC v3 27/42] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20170915200221.GA23720@parsley.fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-28-kolga@netapp.com>
 <20170908193836.GB18220@fieldses.org>
 <CAN-5tyE17rgXnkzZJM_TVih1cqC5CL4CSp6i5c7bNe+G2vX-Lg@mail.gmail.com>
 <20170915014722.GF7734@parsley.fieldses.org>
 <CAN-5tyHasLG79AQoduP=Bt=L9Tpwy4KVi39J+47nzH2jQnseUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyHasLG79AQoduP=Bt=L9Tpwy4KVi39J+47nzH2jQnseUw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 15, 2017 at 03:46:03PM -0400, Olga Kornievskaia wrote:
> On Thu, Sep 14, 2017 at 9:47 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Sep 14, 2017 at 02:44:32PM -0400, Olga Kornievskaia wrote:
> >> How about changing it to be more restrictive by checking within the
> >> while loop that
> >> if it's a PUTFH and it's followed by the SAVE_FH+PUTFH+COPY only
> >> then set the NO_VERIFY_FH.
> >
> > I agree that the only op that could reasonably follow the first PUTFH of
> > a foreign filehandle is a SAVEFH.  But once we've saved the foreign
> > filehandle, the client could in theory do all sorts of stuff, as you
> > say:
> >
> >> I guess we can allow some other operations between the 2nd PUTFH and
> >> COPY because the 2nd filehandle will be validated and must be valid to
> >> continue processing the compound.
> >
> > PUTHF+SAVEFH+PUTFH+GETATTR+COPY might be useful to get pre-copy
> > attributes of the target file, for example?
> >
> > I'd rather not restrict this if we don't need to.
> >
> > We could do something like:
> >
> >         - if this op is PUTFH
> >         - if the following is not SAVEFH, stop and verify the
> >           filehandle.
> >         - otherwise, skip to the next operation that uses a saved
> >           filehandle.  The possibilities are:
> >                 - RENAME, LINK, RESTOREFH, CLONE: stop and verify the
> >                   filehandle.
> >                 - COPY: if it's a local copy, stop and verify the
> >                   filehandle.  Otherwise, allow the PUTFH to succeed and
> >                   delay verification.
> 
> OK so I can peep into the upcoming copy and see if it's inter or intra and
> then based on that I can set NO_VERIFY_FH for processing the putfh.
> 
> >> Somewhere else you were talking about how a "foreign" file handle can
> >> mean something to the server. If that's the case and we do allow for
> >> operations between putfh, savefh, putfh then we'll get into trouble
> >> that I can't think we can get out of.
> >>
> >> If it's a inter copy and the source file handle means something to the
> >> server I can think of the following scenario: the state won't be
> >> flagged IS_STALE then the filehandle would go thru the checks you
> >> listed below and can (unintentionally) result in an error (eg.,
> >> err_moved?).
> >
> > I don't see any problem with just leaving those checks in.  If the
> > current filehandle is not validated, then there's already a
> > current_fh->fh_dentry check that skips the ABSENT_FH check, for example.
> >
> >> This should be changed to
> >> if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH) && op->opnum == OP_SAVEFH)
> >> then we need to skip the checks for savefh as it has no valid file handle.
> >>
> >> Does that address your concern?
> >
> > I think you only need to skip the nofilehandle check in this case, not
> > the other stuff.
> 
> As long as I can add that current_fh->fh_export is not null for the 2nd check
> otherwise it leads to an oops.

fh_export should be set whenever fh_dentry is.

> > I don't think the IS_STALE_FH flag is needed at all.
> 
> We still need it so that the savefh process can skip the check for the
> filehandle.
>
> Or I can use something like checking that fh_dentry and fh_export are both null
> and use that to mean I need to check the filehandle check in savefh.

Yes, or you can just check the fh_dentry.

> I think explicitly marking it makes the code either to understand instead of
> 'knowning/remembering' that lack of fh_dentry+fh_export means inter copy?

If it turns out we still need a flag I think I'd rather it be set on the
filehandle somehow rather than in the cstate.  It's the filehandle
that's unverified.

--b.

> 
> >> >>               if (!current_fh->fh_dentry) {
> >> >>                       if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
> >> >>                               op->status = nfserr_nofilehandle;
> >> >> @@ -1844,6 +1880,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
> >> >>
> >> >>               if (opdesc->op_get_currentstateid)
> >> >>                       opdesc->op_get_currentstateid(cstate, &op->u);
> >> >> +call_op:
> >> >>               op->status = opdesc->op_func(rqstp, cstate, &op->u);
> >> >>
> >> >>               /* Only from SEQUENCE */
> >> >> @@ -1862,6 +1899,14 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
> >> >>                       if (need_wrongsec_check(rqstp))
> >> >>                               op->status = check_nfsd_access(current_fh->fh_export, rqstp);
> >> >>               }
> >> >> +             /* Only from intra COPY */
> >> >> +             if (cstate->status == nfserr_copy_stalefh) {
> >> >> +                     dprintk("%s NFS4.2 intra COPY stale src filehandle\n",
> >> >> +                             __func__);
> >> >> +                     status = nfserr_stale;
> >> >> +                     nfsd4_adjust_encode(resp);
> >> >
> >> > Are you sure it's safe just to throw away any operations since that
> >> > stale PUTFH?  What if some of those operations had side effects?
> >>
> >> If COPY comes in PUTFH,SAVEFH, PUTFH,COPY compound then
> >> I think it's safe?
> >
> > The spec says "If a server supports the inter-server copy feature, a
> > PUTFH followed by a SAVEFH MUST NOT return NFS4ERR_STALE for either
> > operation.  These restrictions do not pose substantial difficulties for
> > servers.  CURRENT_FH and SAVED_FH may be validated in the context of the
> > operation referencing them and an NFS4ERR_STALE error returned for an
> > invalid filehandle at that point."
> >
> > So we're supposed to return NFS4ERR_STALE on the COPY, not the PUTFH.
> > So there's no need for this backtracking.
> 
> You are right.
