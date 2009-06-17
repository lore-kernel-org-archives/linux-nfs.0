From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 07/44] nfsd41: create_session check replay first
Date: Tue, 16 Jun 2009 21:25:14 -0400
Message-ID: <20090617012514.GE8980@fieldses.org>
References: <1245115172-7030-1-git-send-email-bhalevy@panasas.com> <20090616204734.GE3045@fieldses.org> <89c397150906161815v6136e000t338f4fce10ceff23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39730 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbZFQBZL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 21:25:11 -0400
In-Reply-To: <89c397150906161815v6136e000t338f4fce10ceff23-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 09:15:32PM -0400, William A. (Andy) Adamson wrote:
> On Tue, Jun 16, 2009 at 4:47 PM, J. Bruce Fields<bfields@fieldses.org> wrote:
> > On Tue, Jun 16, 2009 at 04:19:32AM +0300, Benny Halevy wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> Replay processing needs to preceed other error processing.
> >
> > Why?
> >
> 
> Section 18.36.4. (CREATE_SESSION implementation section) states the
> ordering of clientid confirmation processing as
> 1) client id record lookup
> 2) sequence id processing
> 3) client id confirmation
> 
> rpc cred processing is done in #3.

I don't see any reason we can't check the cred earlier--let's just leave
this as is and drop this patch.

--b.

> 
> ->Andy
> 
> > --b.
> >
> >>
> >> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> >> ---
> >>  fs/nfsd/nfs4state.c |   12 ++++++------
> >>  1 files changed, 6 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index bfc808b..5aef525 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -1378,12 +1378,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >>               }
> >>               conf->cl_slot.sl_seqid++;
> >>       } else if (unconf) {
> >> -             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> >> -                 (ip_addr != unconf->cl_addr)) {
> >> -                     status = nfserr_clid_inuse;
> >> -                     goto out_cache;
> >> -             }
> >> -
> >>               slot = &unconf->cl_slot;
> >>               status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
> >>               if (status) {
> >> @@ -1392,6 +1386,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
> >>                       goto out;
> >>               }
> >>
> >> +             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
> >> +                 (ip_addr != unconf->cl_addr)) {
> >> +                     status = nfserr_clid_inuse;
> >> +                     goto out_cache;
> >> +             }
> >> +
> >>               slot->sl_seqid++; /* from 0 to 1 */
> >>               move_to_confirmed(unconf);
> >>
> >> --
> >> 1.6.3
> >>
> > _______________________________________________
> > pNFS mailing list
> > pNFS@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> >
