Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45972 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952Ab0JMSSU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 14:18:20 -0400
Subject: Re: whither NFS umount?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <4CB5EF15.5030003@RedHat.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>
	 <1286903046.24878.13.camel@heimdal.trondhjem.org>
	 <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>
	 <20101012151826.76b75f52@corrin.poochiereds.net>
	 <1286912649.1956.19.camel@heimdal.trondhjem.org>
	 <4CB5EF15.5030003@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Oct 2010 14:18:18 -0400
Message-ID: <1286993898.3015.123.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-10-13 at 13:40 -0400, Steve Dickson wrote:
> Sorry for joining late... 
> 
> On 10/12/2010 03:44 PM, Trond Myklebust wrote:
> > On Tue, 2010-10-12 at 15:18 -0400, Jeff Layton wrote:
> > 
> >> I think the part that causes problems is having userspace do this. In
> >> theory, if the kernel were in charge of sending the UMNT, then it's not
> >> really a problem since it knows when to do it. If we have code that
> >> sends a UMNT already, why not do a best-effort UMNT call from the
> >> kernel when we tear down the sb?
> > 
> > Purely for the pleasure of allowing the server to maintain inaccurate
> > statistics about who is currently mounting what? I think not...
> > 
> > You can get far more accurate results by replacing the MNT/UMNT state
> > counter with a purely server-based scheme to track who accessed one or
> > more files on each exported partition in the past 5 minutes or so. That
> > would even work with NFSv4...
> > 
> >> Either way, eliminating umount.nfs would be nice...
> > 
> > Agreed.
> I having a hard time understanding this logic... 
> 
> Why do we think we (the Linux community) can simply 
> throw way an established part of the protocol just because 
> we deem it advisory... Now maybe in our implementation UMNT its
> advisory and it might even be advisory in the spec, but how do we 
> know with  other NFS implementation is not advisory, its actually needed.
> We don't known and we can't known....

Yes we do know!

Anything that relies on a _stateful_ protocol that doesn't have a way to
deal with the fact that clients may go away and never return is
inherently broken. That lesson is exactly why we moved to making state
subject to a lease in NFSv4.

Furthermore, it is not as if we have more than a semi-working
implementation of this now: we don't implement UMNTALL on client reboot
(I doubt that even Solaris bothers doing that) and we don't get UMNT
right if the same filesystem is mounted twice on the same client.

IOW: if there are servers that really do require UMNT to work, then they
will already be learning the errors of their assumptions with today's
client.

> Now when our implementation becomes an NFSv4 only implementation, 
> I say fine; Eliminate all the protocols that go along
> with both v2 and v3. But until then lets just have leave
> the legacy protocols along and move forward in more meaningful 
> efforts... 

For the reasons state above, I see no need to put UMNT support in the
kernel, nor do I want yet another upcall mechanism in order to make
UMNTALL work.
For the same reasons, I don't care if people keep it or throw it out
from the userland utilities.

Trond
