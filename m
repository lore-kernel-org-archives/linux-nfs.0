Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59347 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758446AbaGCQLn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 12:11:43 -0400
Date: Thu, 3 Jul 2014 09:11:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140703161140.GA2645@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-16-git-send-email-jlayton@primarydata.com>
 <20140703151819.GC24322@fieldses.org>
 <20140703112050.61c1561d@tlielax.poochiereds.net>
 <20140703153208.GD24322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140703153208.GD24322@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 03, 2014 at 11:32:08AM -0400, J. Bruce Fields wrote:
> > > > +	struct nfs4_client *found;
> > > > +
> > > > +	if (cstate->clp) {
> > > > +		found = cstate->clp;
> > > > +		if (!same_clid(&found->cl_clientid, clid))
> > > > +			return nfserr_stale_clientid;
> > > 
> > > That's new behavior, isn't it?
> > > 
> > 
> > Yeah, I suppose it is, but it's hard to understand a valid use-case for
> > sending multiple ops in a compound with different clientids. Certainly
> > no well-behaved client would do that, would it? (Hmm, that might be an
> > interesting pynfs test, come to think of it).
> 
> We could ask for a clarification in 3530bis if there's not already
> something there that clearly forbids this, but I'm not sure if it's even
> worth it.

Or just handle it and be done with me.  After all we'd just need to put
the existing client, and store the new one in the cstate.

