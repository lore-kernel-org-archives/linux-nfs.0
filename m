Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39281 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754367Ab2EKPJj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 May 2012 11:09:39 -0400
Date: Fri, 11 May 2012 11:09:38 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] NFSd laundromat containerization
Message-ID: <20120511150938.GA13613@fieldses.org>
References: <4FAD1934.8070908@parallels.com>
 <20120511135306.GA12795@fieldses.org>
 <20120511100238.1c3f2bd4@tlielax.poochiereds.net>
 <4FAD1F03.8060909@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FAD1F03.8060909@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2012 at 06:15:31PM +0400, Stanislav Kinsbursky wrote:
> On 11.05.2012 18:02, Jeff Layton wrote:
> >On Fri, 11 May 2012 09:53:07 -0400
> >"bfields@fieldses.org"<bfields@fieldses.org>  wrote:
> >
> >>On Fri, May 11, 2012 at 05:50:44PM +0400, Stanislav Kinsbursky wrote:
> >>>Hello.
> >>>I'm currently looking on NFSd laundromat work, and it looks like
> >>>have to be performed per networks namespace context.
> >>>It's easy to make corresponding delayed work per network namespace
> >>>and thus gain per-net data pointer in laundromat function.
> >>>But here a problem appears: network namespace is required to skip
> >>>clients from other network namespaces while iterating over global
> >>>lists (client_lru and friends).
> >>>I see two possible solutions:
> >>>1) Make these list per network namespace context. In this case
> >>>network namespace will not be required - per-net data will be
> >>>enough.
> >>>2) Put network namespace link on per-net data (this one is easier, but uglier).
> >>
> >>I'd rather there be as few shared data structures between network
> >>namespaces as possible--I think that will simplify things.
> >>
> >>So, of those two choices, #1.
> >>
> >
> >Agreed, that's sort of how I envisioned things going. In general,
> >you'll want to move things that were one global structures to struct
> >nfsd_net, and fix up the code to manage that on a per-ns basis.
> >
> 
> Ok. I'll do it in first way.
> Anyway, this patch set with laundromat will depends on grace period
> containerization.
> 
> >The catch here is that the laundromat is somewhat intertwined with the
> >grace period, and you need to consider how to handle the grace period
> >between different namespaces. Do we keep a single grace period
> >per-machine as we have today? Or do we move to a per-ns grace period
> >that is started whenever someone starts up knfsd within the container?
> >
> 
> Second one. You can have a look at "Lockd: grace period
> containerization" patch set I've sent last week.

I think that makes the most sense.  It allows people to shoot themselves
in the foot in the case they're exporting the same content from two
different containers.  We'll need to figure out some way to help them.

But one of the common use cases seems to be exporting a set of
filesystems where one filesystem is exported by only one server at a
time, but people want to be able to move that one filesystem export from
one server to another, and this solves that problem.

For the first pass at this let's keep the servers as separate as
possible.

--b.
