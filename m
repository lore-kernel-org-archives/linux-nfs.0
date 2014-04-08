Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757834AbaDHSwI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 14:52:08 -0400
Subject: Re: v4.0 CB_COMPOUND authentication failures
From: Simo Sorce <simo@redhat.com>
To: Dr Fields James Bruce <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
In-Reply-To: <20140408181158.GE9457@fieldses.org>
References: <20140408140333.GD3882@fieldses.org>
	 <6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com>
	 <20140408144652.GE3882@fieldses.org>
	 <ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com>
	 <20140408124428.5152ae8b@tlielax.poochiereds.net>
	 <1396978021.14203.163.camel@willson.li.ssimo.org>
	 <20140408133040.3c149238@tlielax.poochiereds.net>
	 <1396980075.14203.164.camel@willson.li.ssimo.org>
	 <20140408140447.51695274@tlielax.poochiereds.net>
	 <1396980494.14203.169.camel@willson.li.ssimo.org>
	 <20140408181158.GE9457@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Apr 2014 14:52:03 -0400
Message-ID: <1396983123.14203.183.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-04-08 at 14:11 -0400, Dr Fields James Bruce wrote:
> On Tue, Apr 08, 2014 at 02:08:14PM -0400, Simo Sorce wrote:
> > On Tue, 2014-04-08 at 14:04 -0400, Jeff Layton wrote:
> > > On Tue, 08 Apr 2014 14:01:15 -0400
> > > Simo Sorce <simo@redhat.com> wrote:
> > > 
> > > > On Tue, 2014-04-08 at 13:30 -0400, Jeff Layton wrote:
> > > > > On Tue, 08 Apr 2014 13:27:01 -0400
> > > > > Simo Sorce <simo@redhat.com> wrote:
> > > > > 
> > > > > > On Tue, 2014-04-08 at 12:44 -0400, Jeff Layton wrote:
> > > > > > > 
> > > > > > > I think that's what happens. We only fall back to using AUTH_SYS if
> > > > > > > nfs_create_rpc_client returns -EINVAL. In the event that the security
> > > > > > > negotiation fails, we should get back -EACCES and that should bubble
> > > > > > > back up to userland.
> > > > > > > 
> > > > > > > The real problem is that gssd (and also the krb5 libs themselves) will
> > > > > > > try to canonicalize the name. The resulting host portion of the SPN
> > > > > > > may bear no resemblance to the hostname in the device string. In fact,
> > > > > > > if you mount using an IP address then you're pretty much SOL.
> > > > > > 
> > > > > > If you mount by IP do you really care about krb5 ? Probably not, maybe
> > > > > > that's a clue we should not even try ...
> > > > > > 
> > > > > 
> > > > > It's certainly possible that someone passes in an IP address but then
> > > > > says "-o sec=krb5". It has worked in the past, so it's hard to know
> > > > > whether and how many people actually depend on it.
> > > > > 
> > > > > > > I haven't tried it yet, but it looks reasonably trivial to fix gssd
> > > > > > > not to bother with DNS at all and just rely on the hostname. That
> > > > > > > won't stop the krb5 libs from doing their canonicalization though. I'm
> > > > > > > not sure if there's some way to ask the krb5 libs to avoid doing that.
> > > > > > 
> > > > > > [libdefaults]
> > > > > > rdns = false
> > > > > > 
> > > > > > And I think we change the default to false in Fedora/RHEL lately ...
> > > > > > 
> > > > > > Simo.
> > > > > > 
> > > > > 
> > > > > That's a step in the right direction, but I think that the rdns just
> > > > > makes it skip the reverse lookup. AFAIK, the MIT libs will still do
> > > > > getaddrinfo and scrape out the ai_canonname and use that in preference
> > > > > to the hostname you pass in.
> > > > 
> > > > That should happen only if you are using a CNAME, not for an A name.
> > > > 
> > > > We can open bugs if this is not the case though.
> > > > 
> > > 
> > > That's still a problem for us then. The current code tries to compare
> > > the host portion of the device string to the SPN that we get in the
> > > callback request. If they don't match, it fails.
> > > 
> > > I think what we need to do is fix this the right way -- make rpc.gssd
> > > pass down the acceptor name with the downcall.
> > 
> > Why do you need the comparison at all, pardon my ignorance, I do not
> > know very well what its purpose is.
> 
> The NFS client wants to verify that a callback came from the server, so
> it needs to know who it originally authenticated to.

As Jeff said, the only good way at this point would be to have rpc.gssd
pass down the acceptor name after it is done with the gssapi calls.

Note that this may still fail, especially i clustered environments where
servers have multiple credentials they can answer with (due to
responding with multiple names). Unless the server is careful in always
using the principal the client got tickets for when it calls back.

Although the best solution is to quickly deprecate 4.0 callbacks and try
as hard as possible to move on. 4.0 callbacks are just broken.

> (Though honestly it's unlikely you can do much damage by spoofing
> callbacks.)

Better not finding out :)

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

