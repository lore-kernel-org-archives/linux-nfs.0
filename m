Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38892 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbaEGUVF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 16:21:05 -0400
Date: Wed, 7 May 2014 16:21:04 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 50/70] NFSd: Use the session->se_client  in
 lookup_clientid()
Message-ID: <20140507202104.GC9710@fieldses.org>
References: <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <20140507201854.GB9710@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140507201854.GB9710@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 07, 2014 at 04:18:54PM -0400, Bruce Fields wrote:
> On Fri, Apr 18, 2014 at 02:44:44PM -0400, Trond Myklebust wrote:
> > In NFSv4.x with x>0, we want to use the session's pointer to the
> > nfs4_client in order to optimise away the extra lookup of the clid.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 25 +++++++++++++++----------
> >  1 file changed, 15 insertions(+), 10 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 888acf114e40..6e2d348d3367 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3571,13 +3571,19 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
> >  		put_generic_stateid(open->op_stp);
> >  }
> >  
> > -static __be32 lookup_clientid(clientid_t *clid, bool session, struct nfsd_net *nn, struct nfs4_client **clp)
> > +static __be32 lookup_clientid(clientid_t *clid, struct nfsd4_session *session, struct nfsd_net *nn, struct nfs4_client **clp)
> >  {
> >  	struct nfs4_client *found;
> >  
> > -	if (STALE_CLIENTID(clid, nn))
> > -		return nfserr_stale_clientid;
> > -	found = find_confirmed_client(clid, session, nn);
> > +	if (session != NULL) {
> > +		found = session->se_client;
> > +		if (!same_clid(&found->cl_clientid, clid))
> > +			return nfserr_stale_clientid;
> 
> Is that the right error?  After your
> a8a7c6776f8d74780348bef639581421d85a4376 "nfsd: Don't return
> NFS4ERR_STALE_STATEID for NFSv4.1+", nfsd4_lookup_stateid will just
> immediately map this to BAD_STATEID.  (And the other callers aren't
> relevant in the minorversion > 0 case.)

(OK, never mind, I guess STALE must be the right error for the callers
added in later patches.)

--b.
