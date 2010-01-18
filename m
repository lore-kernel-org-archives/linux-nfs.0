Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450Ab0ARWrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 17:47:33 -0500
Date: Mon, 18 Jan 2010 17:47:22 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com, steved@redhat.com
Subject: Re: should mount.nfs prefer IPv4 addresses (was: enabling IPv6)
Message-ID: <20100118174722.036f7530@tlielax.poochiereds.net>
In-Reply-To: <1263849838.4127.84.camel@localhost>
References: <20100118144746.1e05865e@tlielax.poochiereds.net>
	<20100118152047.70f9ab80@tlielax.poochiereds.net>
	<1263846450.4127.71.camel@localhost>
	<20100118154643.05faa05a@tlielax.poochiereds.net>
	<1263849838.4127.84.camel@localhost>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 18 Jan 2010 16:23:58 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Mon, 2010-01-18 at 15:46 -0500, Jeff Layton wrote: 
> > On Mon, 18 Jan 2010 15:27:30 -0500
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > On Mon, 2010-01-18 at 15:20 -0500, Jeff Layton wrote: 
> > > > On Mon, 18 Jan 2010 14:47:46 -0500
> > > > Jeff Layton <jlayton@redhat.com> wrote:
> > > > 
> > > > > With the commit of the statd patches over the weekend, we're now
> > > > > positioned to be able to ship IPv6-enabled nfs-utils in distros. There
> > > > > is a potential snag though...
> > > > > 
> > > > > Consider this situation:
> > > > > 
> > > > > Admin has a Linux server set up. Server has both IPv4 and IPv6 addrs.
> > > > > Both addresses are in DNS.
> > > > > 
> > > > > Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
> > > > > fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
> > > > > addr and the mount fails (or hangs for a long time and then fails, if
> > > > > it's using NFSv4)...
> > > > > 
> > > > > While I don't really like it, I think we may need to consider making
> > > > > mount.nfs prefer IPv4 addrs when it can resolve a hostname to both v4
> > > > > and v6. Otherwise, we run the risk of breaking an awful lot of working
> > > > > setups...
> > > > > 
> > > > 
> > > > Apologies for the self reply and non-descript initial title.
> > > > 
> > > > For discussion purposes, here's a patch to do what I'm thinking of. It
> > > > seems to work and do the right thing. You can still force a mount over
> > > > ipv6 by using the right proto/mountproto options.
> > > 
> > > How do other applications deal with this problem? Surely, not every
> > > application out there is having to filter away IPv6 addresses?
> > > 
> > > I thought that glibc was by default set up to prefer IPv4 addresses, and
> > > allows you to further configure that using /etc/gai.conf. Why is this
> > > failing?
> > > 
> > > Cheers
> > >   Trond
> > > 
> > 
> > At least on my test box (which has no gai.conf set up), IPv6 addrs seem
> > to come first in the list returned by getaddrinfo, and I think that's
> > how it'll turn out for most people. There's a bit of discussion on this
> > in Ulrich's writeup here:
> > 
> > http://people.redhat.com/drepper/linux-rfc3484.html
> > 
> > (see "The BIG Problem")
> > 
> > Though that's sort of orthogonal to the issue. I'm not worried about
> > unreachable IPv6 addresses. The problem is that there is a large
> > installed base of servers that do not support serving NFS over IPv6.
> > Many of those may have IPv6 connectivity set up for other reasons. We
> > don't want clients to start failing to mount them when they get an
> > ipv6-enabled nfs-utils.
> 
> We already have set AI_ADDRCONFIG, so unreachable addresses should not
> be the problem here.
> 
> We do have a 'family' parameter to allow the caller to specify what kind
> of address to request. So my first point would be that your sorting only
> makes sense if the requested family is AF_UNSPEC.
> 

True. In the event that it's AF_INET, the sorting will stop at the first
entry. In the event it's AF_INET6, it'll walk the whole list and end up
using the first entry. We could optimize the sorting out in the non
AF_UNSPEC case. I don't think it creates a lot of overhead though.

> Secondly, in the future, I can quite see that some servers may start to
> prefer IPv6. They may even decide to turn off or to block the NFS IPv4
> port. What happens then if the mount program is enforcing a preference
> for IPv4?
> 

That's a good point. I tend to think that problem will be less
widespread than this issue, but it's something to consider. Those
people can use proto=tcp6 or equivalent to force IPv6. I think it's
reasonable to impose the use of an extra mount option for people in the
situation you describe. They will be changing their configuration in
such a way that they should expect to have to deal with it.

My main interest here is to avoid a bunch of angry admins who had a
setup that worked before, upgraded nfs-utils to one that supports IPv6
and then ended up with a broken environment. That situation is a bit
different in that those people aren't expecting to be surprised. If we
can achieve that in another way, I'm definitely open to suggestions.

-- 
Jeff Layton <jlayton@redhat.com>
