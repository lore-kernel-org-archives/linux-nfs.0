Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:64345 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab3AXPGn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jan 2013 10:06:43 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/7] nfsd4: rewrite xdr encoding of attributes
Date: Thu, 24 Jan 2013 15:06:42 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918336AAD@sacexcmbx05-prd.hq.netapp.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
	 <1358981738-5649-6-git-send-email-bfields@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA9183350A5@sacexcmbx05-prd.hq.netapp.com>
	 <20130124145818.GA16603@pad.fieldses.org>
In-Reply-To: <20130124145818.GA16603@pad.fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-01-24 at 09:58 -0500, J. Bruce Fields wrote:
> On Thu, Jan 24, 2013 at 05:22:43AM +0000, Myklebust, Trond wrote:
> > On Wed, 2013-01-23 at 17:55 -0500, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > Write xdr encoding primitives that can handle crossing page boundaries,
> > > and use them in nfsd4_encode_fattr.
> > > 
> > > The main practical advantage for now is that we can return arbitrarily
> > > large ACLs (well, up to our maximum rpc size).  However, compounds with
> > > other operations following such a getattr may fail.
> > > 
> > > Eventually we plan to use the same xdr code through v4 at least.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/nfsd/nfs4proc.c |   6 +-
> > >  fs/nfsd/nfs4xdr.c  | 705 +++++++++++++++++++++++++++++++++++------------------
> > >  fs/nfsd/xdr4.h     |  18 +-
> > >  3 files changed, 483 insertions(+), 246 deletions(-)
> > > 
> > 
> > Why do these belong in the NFS server layer, and not the SUNRPC layer?
> > 
> > Also, why are you inventing an entirely new server-specific structure
> > instead of just reusing the existing struct xdr_stream?  The xdr_stream
> > already has support for bounce buffers to deal with crossing page
> > boundaries (although I've only implemented the decode side of the
> > equation so far)...
> 
> I thought a little about using a bounce buffer.  What do you see as the
> advantage?

It makes the XDR buffer appear locally linear, despite being globally
non-linear.

> A couple issues I ran into: I want to be able to encode fields out of
> order, and to measure the offset between two points in the buffer.

Already done. See the xdr_stream_pos().

> For example, we encode attributes by encoding a dummy length field at
> the beginning, encoding the attributes, then calculating the length of
> the encoded data and going back to reencode the length field; roughly:
> 
> 	nfsd4_encode_fattr:
> 
> 		... encode bitmap
> 
> 		attrlenp = p;
> 
> 		... encode attributes
> 
> 		attrlen = (char *)p - (char *)attrlenp - 4;
> 		*attrlenp = htonl(attrlen);
> 
> Replacing p by a (__be32 *, page **) pair allows me to do basically the
> same thing:
> 
> 		attrlenp = p;
> 		...
> 		attrlen = svcxdr_byte_offset(&attrlenp, &xdr->ptr) - 4;
> 		write32(&attrlenp, attrlen);
> 
> The "pointers" have all the information I need to calculate the length,
> and I don't have to worry about how many pages the attributes spanned or
> whether attrlenp itself spans a page boundary.  (OK, actually it won't
> because it's 4 bytes.  But we do the same thing elsewhere, e.g. when
> encoding readdir cookies.)

Yeah, but it is just as simple to track the cursor offset. I already did
that precisely to solve the above problem in NFSv4.

> Using a bounce buffer also sets an arbitrary limits on how much space I
> can reserve at once.  Maybe that's not a problem in practice.

The current decode implementation uses a single scratch page which can
be preallocated for use in situations where we don't want to sleep. I
can't think of any case (including readdir) where the record size is
going to be greater than 4k. Even pathnames are limited to < that.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
