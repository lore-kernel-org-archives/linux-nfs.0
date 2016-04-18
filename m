Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44136 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509AbcDRS0f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2016 14:26:35 -0400
Date: Mon, 18 Apr 2016 14:26:33 -0400
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: AUTH_NONE at top of SECINFO_NONAME reply.
Message-ID: <20160418182633.GA3193@fieldses.org>
References: <87k2k1jd8d.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87k2k1jd8d.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 14, 2016 at 09:33:22AM +1000, NeilBrown wrote:
>  I have an NFSv4.1 server (Netapp, don't know about version numbers)
>  which responds to
>     PUT_ROOTFH
>     SECINFO_NONAME
> 
> with:
> 
> flavor: AUTH_NULL (0)
> flavor: RPCSEC_GSS (6)
>     service: rpcsec_gss_svc_integrity (2)
> flavor: RPCSEC_GSS (6)
>     service: rpcsec_gss_svc_none (1)
> flavor: AUTH_UNIX (1)
> 
> This causes the Linux client to use AUTH_NULL, which doesn't end well
>    Opcode: ACCESS (3), [Access Denied: RD LU MD XT DL]
> 
> I suspect this is a server bug, because the first flavor is meant to be
> the most preferred.  However I wonder if there might be something else
> going on.
> 
> 1/ I note that for NFSv3 AUTH_NULL means something a bit different
>   in this context:
> 
> 	 * AUTH_NULL has a special meaning when it's in the server list - it
> 	 * means that the server will ignore the rpc creds, so any flavor
> 	 * can be used.
> 
>   Is there any chance that servers might reasonably expect that
>   behavior for NFSv4.1 as well??

I'll admit it seems a trap for the unwary implementor, but I think this
case is really clear:

	http://tools.ietf.org/html/rfc5661#section-18.29.3

	The result will contain an array that represents the security
	mechanisms available, with an order corresponding to the
	server's preferences, the most preferred being first in the
	array.  The client is free to pick whatever security mechanism
	it both desires and supports, or to pick in the server's
	preference order the first one it supports.

So we should be leaning on the server vendor to fix and/or explain
what's going on there.

> 2/ In the pseudo-root filesystem it might make sense to use AUTH_NULL,
>   providing something else is used when crossing in to another
>   filesystem.

One thing that bugs me about that is that the client could have been fed
forged replies while using AUTH_NULL, and after switching to, say,
krb5i, it may still be depending on those results (e.g., the lookups
that got you to that mountpoint), unless it's careful to recheck some
things.

There are probably assumptions under which that could still be useful,
but it starts to feel a bit delicate.  Anyway, that's a bit of a derail:

>   Should the client send a new SECINFO when that happens (it may not
>   help in this case, I don't know) or is that really only needed when
>   NFS4ERR_WRONGSEC is returned?
>   It seems a bit asymmetric that SECINFO is use pro-actively at the start
>   of a session, but then only re-actively after that.

Maybe.  I would have guessed that / is the point where you're most
likely to guess the security flavor wrong.  I'm not sure it really
matters which way you do it, though.  It's just one round trip plus or
minus on each mountpoint.

--b.
