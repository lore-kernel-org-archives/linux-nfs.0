Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237Ab0JNOAP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 10:00:15 -0400
Date: Thu, 14 Oct 2010 10:00:10 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
Message-ID: <20101014140009.GA24146@fieldses.org>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
 <1286903046.24878.13.camel@heimdal.trondhjem.org>
 <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
 <20101012151826.76b75f52@corrin.poochiereds.net>
 <1286912649.1956.19.camel@heimdal.trondhjem.org>
 <4CB5EF15.5030003@RedHat.com>
 <1286993898.3015.123.camel@heimdal.trondhjem.org>
 <4CB60869.4050004@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CB60869.4050004@RedHat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 13, 2010 at 03:28:41PM -0400, Steve Dickson wrote:
> 
> 
> On 10/13/2010 02:18 PM, Trond Myklebust wrote:
> > Yes we do know!
> > 
> > Anything that relies on a _stateful_ protocol that doesn't have a way to
> > deal with the fact that clients may go away and never return is
> > inherently broken. That lesson is exactly why we moved to making state
> > subject to a lease in NFSv4.

And yet, we try to make lockd work as well as we can.

(OK, it's a question of degree: nlm isn't as broken as UMNT.)

> > Furthermore, it is not as if we have more than a semi-working
> > implementation of this now: we don't implement UMNTALL on client reboot
> > (I doubt that even Solaris bothers doing that) and we don't get UMNT
> > right if the same filesystem is mounted twice on the same client.
> > 
> > IOW: if there are servers that really do require UMNT to work, then they
> > will already be learning the errors of their assumptions with today's
> > client.
> You reasoning is very solid... I agree, if servers, for some reason,
> are depended on this state they are broken. But *not* staying 
> compatible with broken server is not an option, at least from 
> where I view the world.. ;-)

I'm inclined to agree, but a) I haven't thought about it much, b)
posting a patch would be more effective than repeating the same point,
and c) we shouldn't take this as an excuse not to fix the server.

So, on the server side...  As Trond says, we'd like to know which
clients have been active recently.  (In the v4 case, the lease gives
that a precise meaning.  In the v2/v3 case, I suppose we just pick a
number to use as a timeout.  We could use the v4 lease time.)  It's only
the kernel that knows which clients have been active recently.  So we'd
need a way for the client to export that information to userspace.

Greg's per-client statistics might be a good starting point:

	http://thread.gmane.org/gmane.linux.nfs/25537/focus=25534

Though that's just per-ip address, which isn't ideal for v4.  (In the v4
case the client identifier/owner allows us to distinguish e.g. between
multiple clients on the same machine, or behind the same NAT.)  I think
that wouldn't be hard to fix.  (Maybe just add on some ascii-escaped
representation of the clientid to the end of the same line?)

--b.
