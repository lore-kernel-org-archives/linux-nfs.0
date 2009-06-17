From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 16:55:22 -0400
Message-ID: <20090617165522.73606206@tlielax.poochiereds.net>
References: <76bd70e30906171223r1f286d0eg1e64510f106d3027@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37736 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbZFQUzX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 16:55:23 -0400
In-Reply-To: <76bd70e30906171223r1f286d0eg1e64510f106d3027-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jun 2009 12:23:00 -0700
Chuck Lever <chucklever@gmail.com> wrote:

> Still no outgoing e-mail here.  Feel free to copy your reply to
> linux-nfs@vger.kernel.org (as chucklever@gmail.com is not subscribed
> to that list).
> 
> My two major comments are:
> 
> 1.  The CONFIG_IPV6 stuff in 4/4 is pretty messy.  Are you sure you
> need every one of those switches?  And, can you combine some of this
> into helper functions whose definition changes depending on how the
> kernel is built?
> 

Agreed, I'll see what I can do to clean it up.

I could probably eliminate some of the switches. Combining that into
helper functions will lead to a lot of "code sprawl" though (a lot of
little tiny functions).

> 2.  Does this implementation support link-local and site-local
> addresses?  Perhaps that's not important for your initial submission,
> but we should try to ensure that nothing in this design excludes
> support for the local address types.
> 

Site local addresses are considered deprecated but AFAIK, they are
indistinguishable from "normal" IPv6 addresses. They just have a
designated prefix which should really only have meaning to routers. I
don't think that we have to do anything special in order to support
them.

We really can't reasonably support link-local addresses with this. To
use a link-local address you need to know the scopeid. That value only
has meaning within a single host. The client has no way to know what
scopeid to send to the server, so it can't send that information along
in the callback address.

knfsd *might* be able to look for link-local prefixes and determine the
scopeid if it knows what interface the connection came in on. I'm not
clear if that information bubbles up from the RPC layer however.

I don't think there's anything in this work that prevents us from
adding link local support later, but it'll probably take some research
and work to determine how to make it happen.

There are client-side implications here too. We'll have to consider how
to generate callback addresses when the server's address is a
link-local address (mostly, make sure you use the link-local callback
address for the correct interface).

-- 
Jeff Layton <jlayton@redhat.com>
