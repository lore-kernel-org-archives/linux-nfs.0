From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [RFC 04/11] nfsd: mark client for renew
Date: Thu, 17 Dec 2009 15:19:14 -0500
Message-ID: <20091217201914.GB20185@fieldses.org>
References: <4B291B4C.3060603@panasas.com> <1260985272-21481-1-git-send-email-bhalevy@panasas.com> <20091216204839.GA28822@fieldses.org> <20091216205301.GB28822@fieldses.org> <4B295775.1000301@panasas.com> <20091216220600.GG28822@fieldses.org> <4B295DED.4080609@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbZLQUTI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 15:19:08 -0500
In-Reply-To: <4B295DED.4080609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 17, 2009 at 12:23:41AM +0200, Benny Halevy wrote:
> On Dec. 17, 2009, 0:06 +0200, "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > On Wed, Dec 16, 2009 at 11:56:05PM +0200, Benny Halevy wrote:
> >> On Dec. 16, 2009, 22:53 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> >>> On Wed, Dec 16, 2009 at 03:48:39PM -0500,  J. Bruce Fields wrote:
> >>>> On Wed, Dec 16, 2009 at 07:41:12PM +0200, Benny Halevy wrote:
> >>>>>  static inline void
> >>>>> +mark_client_for_renew(struct nfsd4_compound_state *cstate,
> >>>>> +		      struct nfs4_client *clp)
> >>>>> +{
> >>>>> +	int old_state = atomic_cmpxchg(&clp->cl_state, CL_STATE_NORMAL,
> >>>>> +				       CL_STATE_RENEW);
> >>>>> +
> >>>>> +	if (old_state != CL_STATE_EXPIRED) {
> >>>>> +		cstate->renew_client = clp;
> >>>>> +		get_nfs4_client(clp);
> >>>> If cstate->renew_client is already set, then we may leak a reference
> >>>> count here, right?
> >>>>
> >>>> Also: at least in the v4 case, I don't think there's anything preventing
> >>>> cstate->renew_client being already set to a different client.  (With
> >>>> sessions hopefully that's not possible.)
> >>>>
> >> Yeah.  That's a valid point.  So if it is already set then
> >> if it is the same client we can do nothing, else we can renew
> >> the previous one here put it and replace cstate->renew_client.
> > 
> > I'm not sure if that can only happen if someone's intentionally messing
> > with us, or if maybe there's a legitimate case where it can happen
> > (maybe when a new client is created by some op in the compound?) But,
> > yes, that sounds like a safe way to handle it.
> > 
> 
> Can the client send a compound with multiple I/Os for different
> stateids (and even filehandles) that lead back to different clientids?

I don't know of anything in rfc 3530 that forbids it, but I doubt it
would be useful to any legitimate client.

--b.
