Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:55599 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756009AbaGCTHe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 15:07:34 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so552175qab.34
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 12:07:33 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 3 Jul 2014 15:07:32 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140703150732.59cea6f9@tlielax.poochiereds.net>
In-Reply-To: <20140703161140.GA2645@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-16-git-send-email-jlayton@primarydata.com>
	<20140703151819.GC24322@fieldses.org>
	<20140703112050.61c1561d@tlielax.poochiereds.net>
	<20140703153208.GD24322@fieldses.org>
	<20140703161140.GA2645@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Jul 2014 09:11:40 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jul 03, 2014 at 11:32:08AM -0400, J. Bruce Fields wrote:
> > > > > +	struct nfs4_client *found;
> > > > > +
> > > > > +	if (cstate->clp) {
> > > > > +		found = cstate->clp;
> > > > > +		if (!same_clid(&found->cl_clientid, clid))
> > > > > +			return nfserr_stale_clientid;
> > > > 
> > > > That's new behavior, isn't it?
> > > > 
> > > 
> > > Yeah, I suppose it is, but it's hard to understand a valid use-case for
> > > sending multiple ops in a compound with different clientids. Certainly
> > > no well-behaved client would do that, would it? (Hmm, that might be an
> > > interesting pynfs test, come to think of it).
> > 
> > We could ask for a clarification in 3530bis if there's not already
> > something there that clearly forbids this, but I'm not sure if it's even
> > worth it.
> 
> Or just handle it and be done with me.  After all we'd just need to put
> the existing client, and store the new one in the cstate.
> 

Meh, ok... I suppose there's no harm in doing that and since that's the
behavior that was there before, we should probably go with it for the
v4.0 case. I'll have the next iteration do that instead.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
