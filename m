Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59040 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750781AbdCIUwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 15:52:31 -0500
Date: Thu, 9 Mar 2017 15:51:52 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/2] Fix up nfsd to enable NFSv4.x without NFSv4.0
Message-ID: <20170309205152.GG3929@fieldses.org>
References: <20170222233533.23845-1-trond.myklebust@primarydata.com>
 <87y3wxrcha.fsf@notabene.neil.brown.name>
 <1487811610.4863.10.camel@primarydata.com>
 <20170227230357.GA11912@fieldses.org>
 <87k287nv6r.fsf@notabene.neil.brown.name>
 <1488653739.34957.1.camel@primarydata.com>
 <87o9xfjain.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87o9xfjain.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for not paying close attention here.  Catching up:

On Mon, Mar 06, 2017 at 03:26:40PM +1100, NeilBrown wrote:
> On Sat, Mar 04 2017, Trond Myklebust wrote:
> 
> > The main issue that worried me was one of predictability. What is
> > supposed to happen when you type "echo +4"? One thing that I considered
> > to be a regression, was that previously, I could expect that "echo +4"
> > would at the very least turn on NFSv4 minor version 0, but with the
> > change to semantics, it would only do so if nobody had typed "echo
> > -4.0".
> 
> I don't think I would consider this as a regression. Prior to
> 
> Commit: e35659f1b03c ("NFSD: correctly range-check v4.x minor version when setting versions.")
> 
> "echo -4.0" would result in an error.  After that patch it will result in
> behaviour that you think is inconsistent.  While that might be a poor
> design choice, I don't think it is a regression because it is not
> (holistically) something that worked before and now works differently.
>
> I agree that "echo +4" should do something sensible and predictable.  I
> would like to suggest that it should enable all "supported" NFSv4.x minor
> versions.  That is consistent with how rpc.nfsd uses it, and makes sense
> to me. "echo -4" should disable all minor versions.
> 
> >
> > An analogy would be putting 2 light switches in front of a light bulb,
> > so that unless both switches are on, the bulb will not turn on.
> > Actually, it is worse than that, because none of the bulbs turn on
> > until you start up knfsd (so you can argue that there is a third switch
> > in front of the other two).
> > Why do we need this many levels of switches in a kernel interface? You
> > should be able to achieve the same functionality by just turning on and
> > off the individual minor versions. The right place for designing more
> > complex interfaces would be userspace, and is exactly what the rpc.nfsd
> > utility should be taking care of.
> 
> The "no regressions" rule can often lead to clunky interfaces.  It
> certainly isn't ideal, but sometimes we need to live with it.
> The right place to hide that clunkiness is in rpc.nfsd :-)

That sounds right to me.

> > Finally, there is the issue that the interface allowed situations where
> > knfsd was advertising support for NFSv4 via rpcbind, but there were no
> > minor versions enabled, and so you'd just get a confusing series of
> > NFS4ERR_MINOR_VERSION_MISMATCH replies when attempting to mount. Why
> > even advertise support in that case?
> 
> I agree with this.
> If all minor versions are disabled, the major version should be disabled
> as well.  If any minor versions are enabled, the major version must be
> enabled too.

So, if you have a patch that keeps the agreed-on change while reverting
to a (clunkier, but more backwards-compatible) interface, and if you can
do it while we're still early in 4.11, then I'd take that.

--b.
