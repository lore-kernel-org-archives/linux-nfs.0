Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44207 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbaGCPcJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jul 2014 11:32:09 -0400
Date: Thu, 3 Jul 2014 11:32:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140703153208.GD24322@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-16-git-send-email-jlayton@primarydata.com>
 <20140703151819.GC24322@fieldses.org>
 <20140703112050.61c1561d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140703112050.61c1561d@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 03, 2014 at 11:20:50AM -0400, Jeff Layton wrote:
> On Thu, 3 Jul 2014 11:18:19 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Jun 30, 2014 at 11:48:44AM -0400, Jeff Layton wrote:
> > > @@ -2997,6 +3009,38 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
> > >  	return nfserr_bad_seqid;
> > >  }
> > >  
> > > +static __be32 lookup_clientid(clientid_t *clid,
> > > +		struct nfsd4_compound_state *cstate,
> > > +		struct nfsd_net *nn)
> > > +{
> > > +	struct nfs4_client *found;
> > > +
> > > +	if (cstate->clp) {
> > > +		found = cstate->clp;
> > > +		if (!same_clid(&found->cl_clientid, clid))
> > > +			return nfserr_stale_clientid;
> > 
> > That's new behavior, isn't it?
> > 
> 
> Yeah, I suppose it is, but it's hard to understand a valid use-case for
> sending multiple ops in a compound with different clientids. Certainly
> no well-behaved client would do that, would it? (Hmm, that might be an
> interesting pynfs test, come to think of it).

We could ask for a clarification in 3530bis if there's not already
something there that clearly forbids this, but I'm not sure if it's even
worth it.

--b.
