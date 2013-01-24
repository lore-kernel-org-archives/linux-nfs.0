Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755539Ab3AXUpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jan 2013 15:45:33 -0500
Date: Thu, 24 Jan 2013 15:45:30 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/7] nfsd4: rewrite xdr encoding of attributes
Message-ID: <20130124204530.GD16603@pad.fieldses.org>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
 <1358981738-5649-6-git-send-email-bfields@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9183350A5@sacexcmbx05-prd.hq.netapp.com>
 <20130124145818.GA16603@pad.fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA918336AAD@sacexcmbx05-prd.hq.netapp.com>
 <20130124161418.GB16603@pad.fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9183374BF@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9183374BF@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2013 at 05:03:40PM +0000, Myklebust, Trond wrote:
> On Thu, 2013-01-24 at 11:14 -0500, J. Bruce Fields wrote:
> > On Thu, Jan 24, 2013 at 03:06:42PM +0000, Myklebust, Trond wrote:
> > > On Thu, 2013-01-24 at 09:58 -0500, J. Bruce Fields wrote:
> > > > On Thu, Jan 24, 2013 at 05:22:43AM +0000, Myklebust, Trond wrote:
> > > > > On Wed, 2013-01-23 at 17:55 -0500, J. Bruce Fields wrote:
> > > > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > > > 
> > > > > > Write xdr encoding primitives that can handle crossing page boundaries,
> > > > > > and use them in nfsd4_encode_fattr.
> > > > > > 
> > > > > > The main practical advantage for now is that we can return arbitrarily
> > > > > > large ACLs (well, up to our maximum rpc size).  However, compounds with
> > > > > > other operations following such a getattr may fail.
> > > > > > 
> > > > > > Eventually we plan to use the same xdr code through v4 at least.
> > > > > > 
> > > > > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > > > > ---
> > > > > >  fs/nfsd/nfs4proc.c |   6 +-
> > > > > >  fs/nfsd/nfs4xdr.c  | 705 +++++++++++++++++++++++++++++++++++------------------
> > > > > >  fs/nfsd/xdr4.h     |  18 +-
> > > > > >  3 files changed, 483 insertions(+), 246 deletions(-)
> > > > > > 
> > > > > 
> > > > > Why do these belong in the NFS server layer, and not the SUNRPC layer?
> > > > > 
> > > > > Also, why are you inventing an entirely new server-specific structure
> > > > > instead of just reusing the existing struct xdr_stream?  The xdr_stream
> > > > > already has support for bounce buffers to deal with crossing page
> > > > > boundaries (although I've only implemented the decode side of the
> > > > > equation so far)...
> > > > 
> > > > I thought a little about using a bounce buffer.  What do you see as the
> > > > advantage?
> > > 
> > > It makes the XDR buffer appear locally linear, despite being globally
> > > non-linear.
> > 
> > I still don't see why that's helpful.  As long as you know how to write
> > some data to the buffer, you don't need to know whether it's linear.
> 
> It's about avoiding having to make all your helper functions (i.e. the
> existing xdr_encode/decode_foo() in net/sunrpc/xdr.c) page aware.

Sure, but the helper functions are easy.  And there's much less code in
the encoders than in the callers, so I'd rather optimize for the
convenience of the latter:

	$ wc -l net/sunrpc/xdr.c 
	 1289 net/sunrpc/xdr.c
	$ wc -l fs/nfs*/*xdr.c
	  999 fs/nfs/callback_xdr.c
	 1117 fs/nfsd/nfs3xdr.c
	 3975 fs/nfsd/nfs4xdr.c
	  546 fs/nfsd/nfsxdr.c
	 1136 fs/nfs/nfs2xdr.c
	 2546 fs/nfs/nfs3xdr.c
	 7293 fs/nfs/nfs4xdr.c
	17612 total

> Also, it can be useful to be able to pass a portion of an XDR buffer
> as a direct argument to a VFS function (e.g. readdir()).

I don't see how we'd use it in readdir?

> So the way that the decode stuff works is through the
> xdr_inline_decode() function, which is passed a decode buffer size. If
> it sees that the buffer will fit inside the current page, then it
> returns a pointer to the page itself. If it sees that the buffer spans a
> page boundary, then it copies the data to the bounce buffer and passes a
> pointer to that. It means we don't need special versions of
> xdr_decode_string() etc that are page boundary aware.
> 
> As far as I can see, you basically want the same thing on the encode
> side. If you can encode data inline in the page, then have
> xdr_reserve_space() do that, but otherwise, have it return a scratch
> buffer and add an 'xdr_commit()' to take care of copying data from the
> scratch buffer across the page boundary. Saves a lot of trouble.

With more callers than callees, I'd take slightly more complicated
encoders in return for not having to add xdr_commit's all over.

> > So for the case of encoding fields out of order: you're proposing
> > remembering the offset of the earlier field, seeking back to that offset
> > somehow, then writing the data by hand (and handling the case where that
> > data right cross a boundary as a special case?).  Or is there something
> > simpler?
> 
> Are there any use-cases other than attribute array lengths?

The only other nested xdr I can think of is from pNFS.

Readdir cookies are also written out of order.  As are compound status
and compound opcnt.  (And tags, for some reason.  That's weird.)  That
might be all.

> We already
> have write_bytes_to_xdr_buf() that can write a memory buffer to any
> arbitrary offset in an xdr_buf. Maybe we could add a simplified version
> of that for 32-bit writes?

I guess so.

> An alternative, if you already have an estimate for the total buffer
> size, is to xdr_reserve_space() that buffer, and then add an
> xdr_adjust_space() in order to grow/shrink the buffer (copying it into a
> bounce buffer if the new size crosses a page boundary).

I don't want to try to reserve the whole attribute buffer.  (It could
include ACLs of arbitrary length.)

--b.
