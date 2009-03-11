From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 07/14] nfsd4: separate delegreturn case from
	preprocess_stateid_op
Date: Wed, 11 Mar 2009 15:51:29 -0400
Message-ID: <20090311195129.GJ13540@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org> <1236731222-3294-2-git-send-email-bfields@fieldses.org> <1236731222-3294-3-git-send-email-bfields@fieldses.org> <1236731222-3294-4-git-send-email-bfields@fieldses.org> <1236731222-3294-5-git-send-email-bfields@fieldses.org> <1236731222-3294-6-git-send-email-bfields@fieldses.org> <1236731222-3294-7-git-send-email-bfields@fieldses.org> <1236731222-3294-8-git-send-email-bfields@fieldses.org> <49B7182E.6080103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54511 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbZCKTva (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 15:51:30 -0400
In-Reply-To: <49B7182E.6080103@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 11, 2009 at 09:47:26AM +0800, Yang Hongyang wrote:
> J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > Delegreturn is enough a special case for preprocess_stateid_op to
> > warrant just open-coding it in delegreturn.
> > 
> > There should be no change in behavior here; we're just reshuffling code.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/nfsd/nfs4state.c        |   40 ++++++++++++++++++++++++++++------------
> >  include/linux/nfsd/state.h |    1 -
> >  2 files changed, 28 insertions(+), 13 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index d555585..de1d68a 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -2000,10 +2000,7 @@ out:
> >  static inline __be32
> >  check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
> >  {
> > -	/* Trying to call delegreturn with a special stateid? Yuch: */
> > -	if (!(flags & (RD_STATE | WR_STATE)))
> > -		return nfserr_bad_stateid;
> > -	else if (ONE_STATEID(stateid) && (flags & RD_STATE))
> > +	if (ONE_STATEID(stateid) && (flags & RD_STATE))
> >  		return nfs_ok;
> >  	else if (locks_in_grace()) {
> >  		/* Answer in remaining cases depends on existance of
> > @@ -2024,8 +2021,7 @@ check_special_stateids(svc_fh *current_fh, stateid_t *stateid, int flags)
> >  static inline int
> >  io_during_grace_disallowed(struct inode *inode, int flags)
> >  {
> > -	return locks_in_grace() && (flags & (RD_STATE | WR_STATE))
> > -		&& mandatory_lock(inode);
> > +	return locks_in_grace() && mandatory_lock(inode);
> >  }
> >  
> >  static int check_stateid_generation(stateid_t *in, stateid_t *ref)
> > @@ -2089,8 +2085,6 @@ nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int fl
> >  		if (status)
> >  			goto out;
> >  		renew_client(dp->dl_client);
> > -		if (flags & DELEG_RET)
> > -			unhash_delegation(dp);
> >  		if (filpp)
> >  			*filpp = dp->dl_vfs_file;
> >  	} else { /* open or lock stateid */
> > @@ -2408,16 +2402,38 @@ __be32
> >  nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  		  struct nfsd4_delegreturn *dr)
> >  {
> > +	struct nfs4_delegation *dp;
> > +	stateid_t *stateid = &dr->dr_stateid;
> > +	struct inode *inode;
> >  	__be32 status;
> >  
> >  	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
> 
> adjust style:
>           status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)
>           if (status)

Agreed, I just didn't want to touch that for now.

At some point a separate patch that addressed all cases of that problem
in nfs4state.c might not be a bad idea.

--b.

> 
> > -		goto out;
> > +		return status;
> > +	inode = cstate->current_fh.fh_dentry->d_inode;
> >  
> >  	nfs4_lock_state();
> > -	status = nfs4_preprocess_stateid_op(&cstate->current_fh,
> > -					    &dr->dr_stateid, DELEG_RET, NULL);
> > -	nfs4_unlock_state();
> > +	status = nfserr_bad_stateid;
> > +	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
> > +		goto out;
> > +	status = nfserr_stale_stateid;
> > +	if (STALE_STATEID(stateid)) 
> > +		goto out;
> > +	status = nfs_ok;
> > +	if (is_delegation_stateid(stateid))
> > +		goto out;
> > +	status = nfserr_bad_stateid;
> > +	dp = find_delegation_stateid(inode, stateid);
> > +	if (!dp)
> > +		goto out;
> > +	status = check_stateid_generation(stateid, &dp->dl_stateid);
> > +	if (status)
> > +		goto out;
> > +	renew_client(dp->dl_client);
> > +
> > +	unhash_delegation(dp);
> >  out:
> > +	nfs4_unlock_state();
> > +
> >  	return status;
> >  }
> >  
> > diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> > index 1130d53..c9311a1 100644
> > --- a/include/linux/nfsd/state.h
> > +++ b/include/linux/nfsd/state.h
> > @@ -263,7 +263,6 @@ struct nfs4_stateid {
> >  #define RD_STATE	        0x00000010
> >  #define WR_STATE	        0x00000020
> >  #define CLOSE_STATE             0x00000040
> > -#define DELEG_RET               0x00000080
> >  
> >  #define seqid_mutating_err(err)                       \
> >  	(((err) != nfserr_stale_clientid) &&    \
> 
> 
> -- 
> Regards
> Yang Hongyang
