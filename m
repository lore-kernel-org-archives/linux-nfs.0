Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754108Ab3AXO6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jan 2013 09:58:20 -0500
Date: Thu, 24 Jan 2013 09:58:18 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/7] nfsd4: rewrite xdr encoding of attributes
Message-ID: <20130124145818.GA16603@pad.fieldses.org>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
 <1358981738-5649-6-git-send-email-bfields@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9183350A5@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9183350A5@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2013 at 05:22:43AM +0000, Myklebust, Trond wrote:
> On Wed, 2013-01-23 at 17:55 -0500, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Write xdr encoding primitives that can handle crossing page boundaries,
> > and use them in nfsd4_encode_fattr.
> > 
> > The main practical advantage for now is that we can return arbitrarily
> > large ACLs (well, up to our maximum rpc size).  However, compounds with
> > other operations following such a getattr may fail.
> > 
> > Eventually we plan to use the same xdr code through v4 at least.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4proc.c |   6 +-
> >  fs/nfsd/nfs4xdr.c  | 705 +++++++++++++++++++++++++++++++++++------------------
> >  fs/nfsd/xdr4.h     |  18 +-
> >  3 files changed, 483 insertions(+), 246 deletions(-)
> > 
> 
> Why do these belong in the NFS server layer, and not the SUNRPC layer?
> 
> Also, why are you inventing an entirely new server-specific structure
> instead of just reusing the existing struct xdr_stream?  The xdr_stream
> already has support for bounce buffers to deal with crossing page
> boundaries (although I've only implemented the decode side of the
> equation so far)...

I thought a little about using a bounce buffer.  What do you see as the
advantage?

A couple issues I ran into: I want to be able to encode fields out of
order, and to measure the offset between two points in the buffer.

For example, we encode attributes by encoding a dummy length field at
the beginning, encoding the attributes, then calculating the length of
the encoded data and going back to reencode the length field; roughly:

	nfsd4_encode_fattr:

		... encode bitmap

		attrlenp = p;

		... encode attributes

		attrlen = (char *)p - (char *)attrlenp - 4;
		*attrlenp = htonl(attrlen);

Replacing p by a (__be32 *, page **) pair allows me to do basically the
same thing:

		attrlenp = p;
		...
		attrlen = svcxdr_byte_offset(&attrlenp, &xdr->ptr) - 4;
		write32(&attrlenp, attrlen);

The "pointers" have all the information I need to calculate the length,
and I don't have to worry about how many pages the attributes spanned or
whether attrlenp itself spans a page boundary.  (OK, actually it won't
because it's 4 bytes.  But we do the same thing elsewhere, e.g. when
encoding readdir cookies.)

Using a bounce buffer also sets an arbitrary limits on how much space I
can reserve at once.  Maybe that's not a problem in practice.

--b.
