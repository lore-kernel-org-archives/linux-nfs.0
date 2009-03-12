From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/14] nfsd4: fail when delegreturn gets a
	non-delegation stateid
Date: Wed, 11 Mar 2009 20:03:11 -0400
Message-ID: <20090312000311.GA21854@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org> <1236731222-3294-2-git-send-email-bfields@fieldses.org> <1236731222-3294-3-git-send-email-bfields@fieldses.org> <1236731222-3294-4-git-send-email-bfields@fieldses.org> <1236731222-3294-5-git-send-email-bfields@fieldses.org> <1236731222-3294-6-git-send-email-bfields@fieldses.org> <1236731222-3294-7-git-send-email-bfields@fieldses.org> <1236731222-3294-8-git-send-email-bfields@fieldses.org> <1236731222-3294-9-git-send-email-bfields@fieldses.org> <49B80320.6080507@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60864 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbZCLADR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 20:03:17 -0400
In-Reply-To: <49B80320.6080507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 11, 2009 at 08:29:52PM +0200, Benny Halevy wrote:
> On Mar. 11, 2009, 2:26 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > Previous cleanup reveals an obvious (though harmless) bug: when
> > delegreturn gets a stateid that isn't for a delegation, it should return
> > an error rather than doing nothing.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/nfsd/nfs4state.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index de1d68a..4a92d1e 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -2418,7 +2418,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >  	status = nfserr_stale_stateid;
> >  	if (STALE_STATEID(stateid)) 
> >  		goto out;
> > -	status = nfs_ok;
> > +	status = nfserr_bad_stateid;
> >  	if (is_delegation_stateid(stateid))
> >  		goto out;
> >  	status = nfserr_bad_stateid;
> 
> This assignment is redundant now, isn't it?

Yep, thanks.--b.
