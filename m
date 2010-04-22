From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Thu, 22 Apr 2010 11:03:13 -0400
Message-ID: <20100422150313.GB5926@fieldses.org>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu> <20100422144831.GA5926@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50486 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755657Ab0DVPDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 11:03:14 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1O4xvt-0001gm-S1
	for linux-nfs@vger.kernel.org; Thu, 22 Apr 2010 11:03:13 -0400
In-Reply-To: <20100422144831.GA5926@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 10:48:31AM -0400, J. Bruce Fields wrote:
> On Thu, Apr 22, 2010 at 10:32:23AM -0400, J. Bruce Fields wrote:
> > Enforce the rules about compound op ordering.
> > 
> > Motivated by implementing RECLAIM_COMPLETE, for which the client is
> > implicit in the current session, so it is important to ensure a
> > succesful SEQUENCE proceeds the RECLAIM_COMPLETE.
> 
> The other problem here is that while we have a reference count on the
> session itself preventing it from going away till the compound is done,
> I don't see what prevents the associated clientid from going away.

That session reference counting also doesn't make sense to me: we should
never allow a client to disappear while a session is in use.

> > +static bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
> > +{
> > +	struct nfsd4_compoundres *resp = rqstp->rq_resp;
> > +	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
> > +
> > +	return argp->opcnt == resp->opcnt;
> > +}
> > +
> >  __be32
> >  nfsd4_destroy_session(struct svc_rqst *r,
> >  		      struct nfsd4_compound_state *cstate,
> > @@ -1380,6 +1388,11 @@ nfsd4_destroy_session(struct svc_rqst *r,
> >  	 * - Do we need to clear any callback info from previous session?
> >  	 */
> >  

Also to do in destroy_session, from
http://tools.ietf.org/search/rfc5661#section-13.9 "DESTROY_SESSION MUST
be invoked on a connection that is associated with the session being
destroyed."  We should probably be enforcing that here.  I'm not sure
what error to return.

--b.

> > +	if (!memcmp(&sessionid->sessionid, &cstate->session->se_sessionid,
> > +					sizeof(struct nfs4_sessionid))) {
> > +		if (!nfsd4_last_compound_op(r))
> > +			return nfserr_not_only_op;
> > +	}
> >  	dump_sessionid(__func__, &sessionid->sessionid);
> >  	spin_lock(&sessionid_lock);
> >  	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
> > -- 
> > 1.6.3.3
> > 
