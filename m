Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45293 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932885Ab2HHThE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 15:37:04 -0400
Date: Wed, 8 Aug 2012 15:36:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120808193659.GA942@fieldses.org>
References: <20120710215618.GC6038@fieldses.org>
 <1341958332.17428.12.camel@lade.trondhjem.org>
 <1341959112.17428.19.camel@lade.trondhjem.org>
 <20120710223818.GA6720@fieldses.org>
 <1341961118.17428.29.camel@lade.trondhjem.org>
 <20120711170331.GE11432@fieldses.org>
 <20120711172714.GA13610@fieldses.org>
 <1342028948.25375.45.camel@lade.trondhjem.org>
 <20120712221058.GC24162@fieldses.org>
 <20120713154302.GA32660@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120713154302.GA32660@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 13, 2012 at 11:43:02AM -0400, J. Bruce Fields wrote:
> On Thu, Jul 12, 2012 at 06:10:58PM -0400, J. Bruce Fields wrote:
> > On Wed, Jul 11, 2012 at 05:49:09PM +0000, Myklebust, Trond wrote:
> > > On Wed, 2012-07-11 at 13:27 -0400, J. Bruce Fields wrote:
> > > > So, if the issue is: you want to be able to choose, in individual
> > > > containers, which mechanism to use: whatever, we can probably make that
> > > > work.
> > > 
> > > Please do then.
> > > 
> > > > If you're instead saying: it's not acceptable to use the gssproxy
> > > > mechanism to authenticate v4.0 callbacks, the client must only ever use
> > > > the existing mechanism: then I'd rather drop this entirely.  I don't
> > > > want to merge an rpc server authentication upcall that's not acceptable
> > > > for one of the rpc servers.
> > > 
> > > If it goes in, I want it to be optional so that it doesn't break working
> > > setups. I also want upgrades/downgrades to be as painless as possible. 
> > > 
> > > See for instance the idmapper changes in 3.5 which are totally
> > > transparent to the user: if the admin sets up /etc/request-key.conf to
> > > use the new id_resolver, then that works, otherwise we just fall back to
> > > using the old rpc.idmapd method. There are no module parameters etc
> > > involved.
> > 
> > There's a module parameter here, but it's meant to be set by gssproxy to
> > indicate it's listening for the new upcall.  In theory that should make
> > the transition transparent.
> > 
> > However, if we need to make the choice per-namespace then we need to
> > find some other mechanism (assuming there's no way to make module
> > parameters per-namespace.)
> 
> So, perhaps something like: if the cache "channel" file for the
> namespace associated with the current request isn't opened, then try the
> new upcall.

Looking at that a little longer: the channel file could be temporarily
without any opens.  (For example, svcgssd could be restarted--not
normal, but it's always been possible before.)  We probably could
temporarily switch to the new upcall and then back without losing
anything, but it all sounds complicated.

The module parameter won't work any more, and obviously module init
isn't the right time to set everything up.

So my current thought is to give gssproxy some other way it can signal
its presence using a write to a special file.  (Maybe a new file under
nfsd/, or maybe a write of a special value to one of the existing cache
files.)

However, one hangup: figuring out how to switch on gssproxy
per-container isn't very interesting until gssproxy can actually work
per-container.  I'd *really* like to get the unix socket stuff worked
out first.

--b.
