Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45986 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751976AbdKFPPc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 10:15:32 -0500
Date: Mon, 6 Nov 2017 10:15:31 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "aweits@rit.edu" <aweits@rit.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: deal with revoked delegations appropriately
Message-ID: <20171106151531.GB599@fieldses.org>
References: <20171103180631.76071-1-aweits@rit.edu>
 <1509734212.21477.16.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1509734212.21477.16.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 03, 2017 at 06:36:55PM +0000, Trond Myklebust wrote:
> Thanks for the quick turnaround!
> 
> On Fri, 2017-11-03 at 14:06 -0400, Andrew Elble wrote:
> > If a delegation has been revoked by the server, operations using that
> > delegation should error out with NFS4ERR_DELEG_REVOKED in the >4.1
> > case, and NFS4ERR_BAD_STATEID otherwise.
> > 
> > Signed-off-by: Andrew Elble <aweits@rit.edu>
> 
> Reviewed-by: Trond Myklebust <trond.myklebust@primarydata.com>

I wonder if there's a way to simplify the resulting logic in
nfsd4_lookup_stateid--I guess I don't see anything.

Could we get some context here in the changelog, though?  What actual
problem was this causing?

--b.

> 
> > ---
> >  v2: deconflicting with Trond's OPEN/CLOSE locking work
> >  v3: don't return NFS4_OK on DELEGRETURN with revoked delegation
> >  
> >  fs/nfsd/nfs4state.c | 25 ++++++++++++++++++++++++-
> >  1 file changed, 24 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 0c04f81aa63b..d386d569edbc 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3966,7 +3966,8 @@ static struct nfs4_delegation
> > *find_deleg_stateid(struct nfs4_client *cl, statei
> >  {
> >  	struct nfs4_stid *ret;
> >  
> > -	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
> > +	ret = find_stateid_by_type(cl, s,
> > +				NFS4_DELEG_STID|NFS4_REVOKED_DELEG_S
> > TID);
> >  	if (!ret)
> >  		return NULL;
> >  	return delegstateid(ret);
> > @@ -3989,6 +3990,12 @@ static bool nfsd4_is_deleg_cur(struct
> > nfsd4_open *open)
> >  	deleg = find_deleg_stateid(cl, &open->op_delegate_stateid);
> >  	if (deleg == NULL)
> >  		goto out;
> > +	if (deleg->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID) {
> > +		nfs4_put_stid(&deleg->dl_stid);
> > +		if (cl->cl_minorversion)
> > +			status = nfserr_deleg_revoked;
> > +		goto out;
> > +	}
> >  	flags = share_access_to_flags(open->op_share_access);
> >  	status = nfs4_check_delegmode(deleg, flags);
> >  	if (status) {
> > @@ -4858,6 +4865,16 @@ static __be32 nfsd4_validate_stateid(struct
> > nfs4_client *cl, stateid_t *stateid)
> >  		     struct nfs4_stid **s, struct nfsd_net *nn)
> >  {
> >  	__be32 status;
> > +	bool return_revoked = false;
> > +
> > +	/*
> > +	 *  only return revoked delegations if explicitly asked.
> > +	 *  otherwise we report revoked or bad_stateid status.
> > +	 */
> > +	if (typemask & NFS4_REVOKED_DELEG_STID)
> > +		return_revoked = true;
> > +	else if (typemask & NFS4_DELEG_STID)
> > +		typemask |= NFS4_REVOKED_DELEG_STID;
> >  
> >  	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
> >  		return nfserr_bad_stateid;
> > @@ -4872,6 +4889,12 @@ static __be32 nfsd4_validate_stateid(struct
> > nfs4_client *cl, stateid_t *stateid)
> >  	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
> >  	if (!*s)
> >  		return nfserr_bad_stateid;
> > +	if (((*s)->sc_type == NFS4_REVOKED_DELEG_STID) &&
> > !return_revoked) {
> > +		nfs4_put_stid(*s);
> > +		if (cstate->minorversion)
> > +			return nfserr_deleg_revoked;
> > +		return nfserr_bad_stateid;
> > +	}
> >  	return nfs_ok;
> >  }
> >  
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
