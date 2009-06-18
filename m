From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 21:06:23 -0400
Message-ID: <20090617210623.4c7860fb@tlielax.poochiereds.net>
References: <76bd70e30906171223r1f286d0eg1e64510f106d3027@mail.gmail.com>
	<20090617165522.73606206@tlielax.poochiereds.net>
	<76bd70e30906171432m29b3f179y6d0f2111e205114c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60583 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbZFRBGX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 21:06:23 -0400
In-Reply-To: <76bd70e30906171432m29b3f179y6d0f2111e205114c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jun 2009 14:32:16 -0700
Chuck Lever <chucklever@gmail.com> wrote:

> On Wed, Jun 17, 2009 at 1:55 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> >
> > Site local addresses are considered deprecated but AFAIK, they are
> > indistinguishable from "normal" IPv6 addresses.
> 
> 
> My impression was site-local addresses may also use a scope ID.
> 

I don't think so. Site local addresses are considered routable and
should be unique within a "site". I think the intent with them was to
provide an address space analogous to RFC 1918 addresses.

There should be no need for a scopeid with them since it's not likely
that 2 interfaces would have the same subnet ID (doing so would be
silly given the large address space) and site-local addresses are not
autoconfigured like link-local ones.

In any case, site-local is deprecated and is supposedly being replaced
by ULA's which are also routable within cooperating sites:

http://en.wikipedia.org/wiki/Unique_local_address

AFAICT, ULA's also have no need for a scope id.

> 
> > They just have a
> > designated prefix which should really only have meaning to routers. I
> > don't think that we have to do anything special in order to support
> > them.
> >
> > We really can't reasonably support link-local addresses with this. To
> > use a link-local address you need to know the scopeid. That value only
> > has meaning within a single host. The client has no way to know what
> > scopeid to send to the server, so it can't send that information along
> > in the callback address.
> 
> 
> Right.  The callback presentation address string passed via SETCLIENTID is
> an RPC universal address, which doesn't have the ability to represent a
> scope ID.  However, there are ways around this limitation.  An incoming
> site- or link-local universal address in an RPCB_GETADDR inherits the scope
> ID from the address used to send the RPCB_GETADDR request, for example.
> 

Yes, that's the only real way to do that. At the end of the day (at
least on linux and windows), scopeid == interface number. A machine
will have no idea what the interface number will be in another machine.
Therefore that info can only reasonably be filled out by the host that
intends to connect to the remote link-local address.

What we should probably do here for the server is to make sure that
when a SETCLIENTID call comes in, that we can get the number of the
interface that received the call and then stuff that info into the
scopeid if the clientaddr has a link-local prefix.

> 
> > knfsd *might* be able to look for link-local prefixes and determine the
> > scopeid if it knows what interface the connection came in on. I'm not
> > clear if that information bubbles up from the RPC layer however.
> >
> > I don't think there's anything in this work that prevents us from
> > adding link local support later, but it'll probably take some research
> > and work to determine how to make it happen.
> >
> > There are client-side implications here too. We'll have to consider how
> > to generate callback addresses when the server's address is a
> > link-local address (mostly, make sure you use the link-local callback
> > address for the correct interface).
> 
> 
> See mount.nfs.  It strips the scope ID off of link-local clientaddr=, and
> assumes the server will know how to glue an appropriate scope ID back in.
>  (Or, it _should_ do that... it probably does something that only
> approximates this now).
> 
> 

That's probably the right thing to do.

The only real trick for mount.nfs is to make sure that when the
server's address is a link-local addr, that it autogenerates the
clientaddr= with the link-local address of the interface that matches
the provided scopeid.

PS: I think you can post to linux-nfs@vger.kernel.org from
non-subscribed addresses.

-- 
Jeff Layton <jlayton@redhat.com>
