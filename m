Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48153 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab1ECDsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 23:48:43 -0400
Date: Mon, 2 May 2011 23:48:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>, iisaman@umich.edu
Subject: Re: [PATCH] nfsd41: compare request's opcnt with session's maxops
 at nfsd4_sequence
Message-ID: <20110503034841.GA16120@fieldses.org>
References: <4DB76CE6.9080404@cn.fujitsu.com>
 <20110427024126.GB26541@fieldses.org>
 <4DB7AE19.3080308@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DB7AE19.3080308@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 27, 2011 at 01:48:09PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > On Wed, Apr 27, 2011 at 09:09:58AM +0800, Mi Jinlong wrote:
> >> Make sure nfs server can distinguish request contains more ops
> >> than channel allowed.
> > 
> > Yes, sequence looks like a reasonable op to catch this error.  The spec
> > doesn't care as far as I can tell (and it's a buggy-client case, so why
> > should it), and we already check that any compound not starting with a
> > sequence has only one op.
> > 
> >> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >> ---
> >>  fs/nfsd/nfs4state.c |    5 +++++
> >>  1 files changed, 5 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index fbde6f7..4f9fc68 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -1749,6 +1749,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >>  	if (!session)
> >>  		goto out;
> >>  
> >> +	status = nfserr_too_many_ops;
> >> +	if (((struct nfsd4_compoundargs *)rqstp->rq_argp)->opcnt >
> > 
> > Kind of a cumbersome construction, though.
> > 
> > Eh, maybe overkill, but how about this?:
> 
>   That's great!

But note we're making a bunch of the pynfs tests fail now, since they
aren't careful about how many ops they use in a compound.  For example,
LKPP1d fails for me now.  Note it might not fail for you if you put the
pynfs test directory right at the root of the export tree?

I don't think pynfs hsould be using absolute paths for everything.  And
it should probably be doing single-component lookups in a loop instead
of depending on being able to do the whole lookup in one compound,
unless it's willing to adapt the compounds to take into account
maxops--which sounds to me like more trouble than it's worth.

The server could probably also raise its limit, though.

--b.

> 
> -- 
> ----
> thanks
> Mi Jinlong
> 
> > 
> > --b.
> > 
> > commit d5eee1629fb9d3a55e5793d156026248c14cb46c
> > Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
> > Date:   Wed Apr 27 09:09:58 2011 +0800
> > 
> >     nfsd41: compare request's opcnt with session's maxops at nfsd4_sequence
> >     
> >     Make sure nfs server errors out if request contains more ops
> >     than channel allows.
> >     
> >     Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> >     [bfields@redhat.com: use helper function]
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index fbde6f7..487ba47 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1721,6 +1721,13 @@ static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_sessi
> >  	return;
> >  }
> >  
> > +static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_session *session)
> > +{
> > +	struct nfsd4_compoundargs *args = rqstp->rq_argp;
> > +
> > +	return args->opcnt > session->se_fchannel.maxops;
> > +}
> > +
> >  __be32
> >  nfsd4_sequence(struct svc_rqst *rqstp,
> >  	       struct nfsd4_compound_state *cstate,
> > @@ -1749,6 +1756,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
> >  	if (!session)
> >  		goto out;
> >  
> > +	status = nfserr_too_many_ops;
> > +	if (nfsd4_session_too_many_ops(rqstp, session))
> > +		goto out;
> > +
> >  	status = nfserr_badslot;
> >  	if (seq->slotid >= session->se_fchannel.maxreqs)
> >  		goto out;
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> 
