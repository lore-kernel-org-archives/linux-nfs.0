Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54322 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756402Ab3DZPnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Apr 2013 11:43:52 -0400
Date: Fri, 26 Apr 2013 11:43:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/5] SUNRPC: allow disabling idle timeout
Message-ID: <20130426154348.GD17268@fieldses.org>
References: <1366054508-27604-1-git-send-email-bfields@redhat.com>
 <1366054508-27604-3-git-send-email-bfields@redhat.com>
 <20130418170020.GA31075@fieldses.org>
 <1366304823.58246.22.camel@leira.trondhjem.org>
 <20130418171424.GA30837@pad.fieldses.org>
 <F9B356AC-18C0-4BF1-8FBF-1F719801F72F@oracle.com>
 <20130424150037.GA20275@fieldses.org>
 <1366815805.3812.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1366815805.3812.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 03:03:23PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-04-24 at 11:00 -0400, J. Bruce Fields wrote:
> > On Thu, Apr 18, 2013 at 10:25:49AM -0700, Chuck Lever wrote:
> > > 
> > > On Apr 18, 2013, at 10:14 AM, "J. Bruce Fields" <bfields@redhat.com> wrote:
> > > 
> > > > On Thu, Apr 18, 2013 at 05:07:03PM +0000, Myklebust, Trond wrote:
> > > >> On Thu, 2013-04-18 at 13:00 -0400, J. Bruce Fields wrote:
> > > >>> On Mon, Apr 15, 2013 at 03:35:04PM -0400, J. Bruce Fields wrote:
> > > >>>> From: "J. Bruce Fields" <bfields@redhat.com>
> > > >>>> 
> > > >>>> In the gss-proxy case we don't want to have to reconnect at random--we
> > > >>>> want to connect only on gss-proxy startup when we can steal gss-proxy's
> > > >>>> context to do the connect in the right namespace.
> > > >>>> 
> > > >>>> So, provide a flag that allows the rpc_create caller to turn off the
> > > >>>> idle timeout.
> > > >>> 
> > > >>> Chuck, the basic ideas was your suggestion, does the executation look OK
> > > >>> here?  I had to copy the rpc_create flags down to the xprt_create, I
> > > >>> don't know if that's reasonable.
> > > >> 
> > > >> This patch will conflict with commit
> > > >> b7993cebb841b0da7a33e9d5ce301a9fd3209165 (SUNRPC: Allow rpc_create() to
> > > >> request that TCP slots be unlimited) that was posted on this list
> > > >> earlier this week.
> > > > 
> > > > Oh, sorry, I missed that.
> > > > 
> > > > Presumably then I should just work on top of that and do the same
> > > > thing--define a pair of flags
> > > > {RP_CLNT_CREATE|XPRT_CREATE}_NO_IDLE_TIMEOUT and translate between the
> > > > two in rpc_create.
> > > 
> > > Agree.
> > 
> > The result (untested) looks like this.
> > 
> > If this is OK--Trond, do you mind if I merge this commit (or
> > nfs-for-next) into my tree, and then the rest of the gss-proxy patches
> > on top?
> > 
> > Or is the nfs-for-next branch still potentially subject to rewriting?
> 
> nfs-for-next is stable, so it should be safe to pull into your nfsd
> tree.

OK, done locally, pushing out that and the gss-proxy work soon pending
some testing.

This just means I'll want to wait till after your branch is pulled for
the next merge window before sending my pull-request, to avoid creating
confusion about who did what.

Therefore, please delay your request as long as you like, as that will
give me an excuse for my own procrastination.  Thanks!

--b.
