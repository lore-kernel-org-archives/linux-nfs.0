Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41614 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbaGGSXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 14:23:41 -0400
Date: Mon, 7 Jul 2014 14:23:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140707182339.GD8630@fieldses.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-16-git-send-email-jlayton@primarydata.com>
 <20140703203259.GF24322@fieldses.org>
 <20140703213526.GG24322@fieldses.org>
 <20140703183115.397af08e@tlielax.poochiereds.net>
 <20140704081449.276d756d@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140704081449.276d756d@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 04, 2014 at 08:14:49AM -0400, Jeff Layton wrote:
> On Thu, 3 Jul 2014 18:31:15 -0400
> Jeff Layton <jeff.layton@primarydata.com> wrote:
> 
> > On Thu, 3 Jul 2014 17:35:26 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Jul 03, 2014 at 04:32:59PM -0400, J. Bruce Fields wrote:
> > > > On Mon, Jun 30, 2014 at 11:48:44AM -0400, Jeff Layton wrote:
> > > > > We want to use the nfsd4_compound_state to cache the nfs4_client in
> > > > > order to optimise away extra lookups of the clid.
> > > > > 
> > > > > In the v4.0 case, we use this to ensure that we only have to look up the
> > > > > client at most once per compound for each call into lookup_clientid. For
> > > > > v4.1+ we set the pointer in the cstate during SEQUENCE processing so we
> > > > > should never need to do a search for it.
> > > > 
> > > > The connectathon locking test is failing for me in the nfsv4/krb5i case
> > > > as of this commit.
> > > > 
> > > > Which makes no sense to me whatsoever, so it's entirely possible this is
> > > > some unrelated problem on my side.  I'll let you know when I've figured
> > > > out anything more.
> > > 
> > > It's intermittent.
> > > 
> > > I've reproduced it on the previous commit so I know at least that this
> > > one isn't at fault.
> > > 
> > > I doubt it's really dependent on krb5i, at most that's probably just
> > > making it more likely to reproduce.
> > > 
> > > --b.
> > 
> > Bruce,
> > 
> > Does this patch help? I suspect this is where the bug crept in, but I'm
> > unclear on why it would be intermittent...
> > 
> > FWIW, this all gets cleaned up in a later patch that changes how the
> > refcounting on lock and openowners works.
> > 
> 
> I was finally able to reproduce this after a running the cthon lock
> tests in a loop, with krb5i. With the patch that I sent earlier, I was
> able to run 100 iterations of it without a failure, so I think that was
> the bug.

Thanks!  That seems to be holding up for me too.

I'll continue slowly applying your patches to for-3.17.

--b.
