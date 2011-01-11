Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786Ab1AKPJY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 10:09:24 -0500
Date: Tue, 11 Jan 2011 10:09:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Takuma Umeya <tumeya@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs4: set source address when callback is generated
Message-ID: <20110111150919.GB15603@fieldses.org>
References: <20101215050901.GB13532@redhat.com>
 <20101216034945.GH9646@fieldses.org>
 <A4BB9763-B67F-4559-B3FF-F7BC2DBD3B3A@oracle.com>
 <20110105005835.GA14744@fieldses.org>
 <F369CCC7-285D-4F4D-80D4-EEAC273E561C@oracle.com>
 <20110105171111.GC13000@fieldses.org>
 <3443745A-607D-4FD8-BA93-622669A09EAF@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3443745A-607D-4FD8-BA93-622669A09EAF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 12:18:37PM -0500, Chuck Lever wrote:
> 
> On Jan 5, 2011, at 12:11 PM, J. Bruce Fields wrote:
> 
> > On Wed, Jan 05, 2011 at 12:06:04PM -0500, Chuck Lever wrote:
> >> 
> >> On Jan 4, 2011, at 7:58 PM, J. Bruce Fields wrote:
> >> 
> >>> On Thu, Dec 16, 2010 at 10:54:00AM -0500, Chuck Lever wrote:
> >>>> I don't recall creating svc_addr_u, but I'll take a stab at a
> >>>> guess.
> >>>> 
> >>>> It looks like someone thought that we should retain the idea of
> >>>> storing just the address part of the socket address, and not the
> >>>> other stuff (like the family and port, since this code doesn't
> >>>> appear to need that additional information).  It greatly reduces
> >>>> the size of the field.  A full sockaddr_storage is more than 128
> >>>> bytes, since it has to be able to store an AF_UNIX pathname.
> >>>> 
> >>>> Doing this, there is a lot less data to keep around, but an IPv6
> >>>> socket address has other items outside of in6_addr that can be
> >>>> used to form a full address.  We decided at some point we could
> >>>> copy this information from the other address storage field in the
> >>>> rqstp.
> >>>> 
> >>>> But the result of this space savings means we must construct a
> >>>> full socket address when needed, using logic such as the above.
> >>> 
> >>> Seems to me we should either just waste the extra 100 bytes or
> >>> define something that would be useful elsewhere as well....
> >> 
> >> In nfs-utils, we define:
> >> 
> >> 	union nfs_sockaddr { struct sockaddr_in	s4; struct sockaddr_in6
> >> 	s6; struct sockaddr		sa; };
> >> 
> >> A variable of this type is large enough to hold a full IPv6
> >> sockaddr, but is significantly smaller than a sockaddr_storage.
> >> 
> >> The addition of the "struct sockaddr" element is to enable access
> >> to such variables via a "struct sockaddr *" without type punning.
> >> This seems to be preferred by gcc over type casting in order to
> >> handle optimizations involving address aliasing.  It also allows
> >> more precise type checking.
> > 
> > Sounds reasonable to me.
> > 
> >> 
> >> A full conversion to use such a construct in kernel RPC and NFS
> >> components is, I fear, too late for 2.6.38, but might be considered
> >> for a future release if there is consensus on this approach.
> > 
> > OK; I suppose for now I'll apply my revision of Takuma Umeya's patch
> > below (if I didn't screw it up).
> 
> My thinking cap is still on vacation.  I don't see anything
> immediately wrong with this as a temporary fix.  Has anyone tested
> this with a multi-homed IPv6 server?  How about link-local IPv6
> addresses?

I believe the original patch was tested with a multi-homed server, but
probably just IPv4.  It would be useful to retest to make sure I didn't
introduce a typo on cleanup (my version is pushed to
git://linux-nfs.org/~bfields/linux.git for-2.6.38 now).  And, yes, the
IPv6 cases would be good to test as well.

--b.
