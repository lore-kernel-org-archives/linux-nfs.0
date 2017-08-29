Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39374 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751440AbdH2VtJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Aug 2017 17:49:09 -0400
Date: Tue, 29 Aug 2017 17:49:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 3/3] nfsd: clients don't need to break their own
 delegations
Message-ID: <20170829214907.GJ8822@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-4-git-send-email-bfields@redhat.com>
 <87bmn0ia6i.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bmn0ia6i.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now we get to harder questions....

On Mon, Aug 28, 2017 at 02:32:53PM +1000, NeilBrown wrote:
> On Fri, Aug 25 2017, J. Bruce Fields wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> >
> > We currently revoke read delegations on any write open or any operation
> > that modifies file data or metadata (including rename, link, and
> > unlink).  But if the delegation in question is the only read delegation
> > and is held by the client performing the operation, that's not really
> > necessary.
> >
> > It's not always possible to prevent this in the NFSv4.0 case, because
> > there's not always a way to determine which client an NFSv4.0 delegation
> > came from.  (In theory we could try to guess this from the transport
> > layer, e.g., by assuming all traffic on a given TCP connection comes
> > from the same client.  But that's not really correct.)
> >
> > In the NFSv4.1 case the session layer always tells us the client.
> >
> > This patch should remove such self-conflicts in all cases where we can
> > reliably determine the client from the compound.
> 
> I don't see any mention of the new DELEG_NO_WAIT, either here or where
> the value is defined.  That means I have to figure it out for myself?

That's a fair complaint.

> When I saw this, I thought: "Shouldn't 'who' be 'fl_owner_t' rather that
> 'void*'".
> Then I saw
> 
> /* legacy typedef, should eventually be removed */
> typedef void *fl_owner_t;
> 
> 
> Maybe you could do the world a favor and remove fl_owner_t in a
> preliminary patch :-)

I remember trying that before and getting frustrated for some reason.
OK, I'll take another look.

> And it is kind-a weird that the "who" you pass to break_lease() is
> different from the owner passed to vfs_setlease().
> 
> >  
> >  	/* typically we will check that ctx is non-NULL before calling */
> >  	ctx = smp_load_acquire(&inode->i_flctx);
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 0c04f81aa63b..fb15efcc4e08 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3825,6 +3825,45 @@ nfsd_break_deleg_cb(struct file_lock *fl)
> >  	return ret;
> >  }
> >  
> > +static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
> > +{
> > +	struct nfsd4_compoundres *resp;
> > +
> > +	/*
> > +	 * In case it's possible we could be called from NLM or ACL
> > +	 * code?:
> > +	 */
> > +	if (rqst->rq_prog != NFS_PROGRAM)
> > +		return NULL;
> > +	if (rqst->rq_vers != 4)
> > +		return NULL;
> > +	resp = rqst->rq_resp;
> > +	return resp->cstate.clp;
> > +}
> > +
> > +static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
> > +{
> > +	struct svc_rqst *rqst = who;
> > +	struct nfs4_client *cl;
> > +	struct nfs4_delegation *dl;
> > +	struct nfs4_file *fi = (struct nfs4_file *)fl->fl_owner;
> > +	bool ret = true;
> > +
> > +	cl = nfsd4_client_from_rqst(rqst);
> > +	if (!cl)
> > +		return false;
> > +
> > +	spin_lock(&fi->fi_lock);
> > +	list_for_each_entry(dl, &fi->fi_delegations, dl_perfile) {
> > +		if (dl->dl_stid.sc_client != cl) {
> > +			ret = false;
> > +			break;
> > +		}
> > +	}
> > +	spin_unlock(&fi->fi_lock);
> > +	return ret;
> > +}
> 
> You haven't provided any documentation telling me what the
> "lm_breaker_owns_lease" callback is meant to do.
> So I look at this one piece of sample code -- it seems to compute:
>   not (an other client owns lease)
> rather than
>   (this client owns lease)
> which is what I would have expected.
> 
> Given that any_leases_conflict() already loops over all leases, does
> nfsd_breaker_owns_lease() need to loop as well?
> Or does nfsd only take a single lease to cover all the delegations to
> all the clients?
> ... hmmm, yes that does seem to be how nfsd works.
> 
> Would this all turn out to be easier if nfsd took a separate lease for
> each client?  What would be the cost of that?

I'll have to remind myself.

I think it might have been forced by the decision to consolidate NFSv4
opens in a similar way.

Both decisions I regret since they've been a source of overly
complicated code that's had lots of bugs.  But I may just be forgetting
the drawbacks of the alternative.

Anyway, I'll review that code.  But I think the answer will be that we
need to live with it for now.

But, yes, this needs some comments and better variable names at a
minimum.

--b.
