Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759973Ab2EKOCs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 May 2012 10:02:48 -0400
Date: Fri, 11 May 2012 10:02:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] NFSd laundromat containerization
Message-ID: <20120511100238.1c3f2bd4@tlielax.poochiereds.net>
In-Reply-To: <20120511135306.GA12795@fieldses.org>
References: <4FAD1934.8070908@parallels.com>
	<20120511135306.GA12795@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 May 2012 09:53:07 -0400
"bfields@fieldses.org" <bfields@fieldses.org> wrote:

> On Fri, May 11, 2012 at 05:50:44PM +0400, Stanislav Kinsbursky wrote:
> > Hello.
> > I'm currently looking on NFSd laundromat work, and it looks like
> > have to be performed per networks namespace context.
> > It's easy to make corresponding delayed work per network namespace
> > and thus gain per-net data pointer in laundromat function.
> > But here a problem appears: network namespace is required to skip
> > clients from other network namespaces while iterating over global
> > lists (client_lru and friends).
> > I see two possible solutions:
> > 1) Make these list per network namespace context. In this case
> > network namespace will not be required - per-net data will be
> > enough.
> > 2) Put network namespace link on per-net data (this one is easier, but uglier).
> 
> I'd rather there be as few shared data structures between network
> namespaces as possible--I think that will simplify things.
> 
> So, of those two choices, #1.
> 

Agreed, that's sort of how I envisioned things going. In general,
you'll want to move things that were one global structures to struct
nfsd_net, and fix up the code to manage that on a per-ns basis.

The catch here is that the laundromat is somewhat intertwined with the
grace period, and you need to consider how to handle the grace period
between different namespaces. Do we keep a single grace period
per-machine as we have today? Or do we move to a per-ns grace period
that is started whenever someone starts up knfsd within the container?

-- 
Jeff Layton <jlayton@redhat.com>
