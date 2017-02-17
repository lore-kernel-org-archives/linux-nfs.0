Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932467AbdBQUwr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 15:52:47 -0500
Date: Fri, 17 Feb 2017 15:52:45 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Dros Adamson <dros@primarydata.com>
Subject: Re: [PATCH 0/3] getacl fixes
Message-ID: <20170217205245.GA18901@parsley.fieldses.org>
References: <1487349854-9732-1-git-send-email-bfields@redhat.com>
 <EA115AB5-7508-45F7-9CFC-3388A55F36BD@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <EA115AB5-7508-45F7-9CFC-3388A55F36BD@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 17, 2017 at 03:36:38PM -0500, Chuck Lever wrote:
> 
> > On Feb 17, 2017, at 11:44 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > The getacl code is allocating enough space to handle the ACL data but
> > not to handle the bitmask, which can lead to spurious ERANGE errors when
> > the end of the ACL gets close to a page boundary.
> > 
> > Dros addressed this by letting the rpc layer allocate pages as necessary
> > on demand, as the NFSv3 ACL code does.
> > 
> > On its own that didn't do the job either, because we don't handle the
> > case where xdr_shrink_bufhead needs to move data around in the xdr buf.
> > And xdr_shrink_bufhead was getting called every time due to an incorrect
> > estimate in an xdr_inline_pages call.
> > 
> > So, I fixed that estimate.  That still leaves the chance of a bug in the
> > rare case xdr_shrink_bufhead is called.
> > 
> > We could fix up the handling of the xdr_shrink_bufhead case, but I don't
> > see the point of shifting this data around in the first place.  We're
> > not doing anything like zero-copy here, we're just going to copy the
> > data out into the buffer we were passed.  The NFSv3 ACL code doesn't
> > bother with this.
> > 
> > It's simpler just to pass down the buffer to the xdr layer and let it
> > copy the ACL out.
> 
> I haven't looked closely at these yet, but I have some general
> thoughts (worth approximately 2 cents).
> 
> NFS/RDMA clients have to pre-allocate and register a receive buffer
> for requests with large replies. The client's RPC layer can't allocate
> more memory if the reply overruns the existing buffer.
> 
> (Note that the server doesn't have the same problem: the client
> sends an RPC-over-RDMA message telling the server exactly how large
> the RPC Call message is, and the server prepares RDMA Read operations
> to pull it over.)
> 
> ACLs are particularly troublesome because there doesn't seem to be
> a way for a client to ask a server "how big is this ACL?" before it
> actually asks for the ACL. And at least for NFSACL there does
> not seem to be a protocol-defined size limit for these objects.

I think in practice the OS/filesystem limits end up being the limiting
factor.  V4.0 might be the more annoying case, partly thanks to all
those string names.

> If the server can't fit an ACL into the client-provided reply buffer,
> that causes a transport level error. The blast radius of this failure
> includes any RPC that happens to be running on that connection, which
> will have to be retransmitted.
> 
> If the client has sent a COMPOUND with a non-idempotent request in
> the same COMPOUND with a GETATTR requesting the ACL, there could
> be a problem if the server can't return the RPC because the client's
> receive buffer is too small. The solution there is to always send
> such operations in separate COMPOUNDs.
> 
> So I prefer in general that the NFS client (above RPC) provide as
> large a buffer as practical for NFSACL GETACL and NFSv4 GETATTR
> requesting an ACL. IIUC that is the direction your patches are
> going.

No, the net effect is to make the v4 code like the v3 code and allocate
pages for the reply only on demand.  (I understand the confusion,
there's multiple buffers involved here, and my description could
probably be better.)

Ugh.

Does the RDMA protocol give us any other mechanism we can use for the
case of ACL replies?

It probably wouldn't be so terrible to preallocate the maximum number of
pages possible if that's really the only option.  May as well get rid of
the allocations in xdr_partial_copy_from_skb if we do that, as I don't
think there are other users?

--b.

> 
> We likely have a similar conundrum with security labels.
> 
> 
> > The result looks a lot simpler and more obviously correct than this code
> > has been, though I'm not particularly happy with the sequence of patches
> > that gets us there; it would be better to squash together Dros's and my
> > patch and then split out the result some more sensible way.
> > 
> > Sorry for the delay getting back to this.  Older discussions:
> > 
> > 	https://marc.info/?t=138452791200001&r=1&w=2
> > 	http://marc.info/?t=138506891000003&r=1&w=2
> > 
> > J. Bruce Fields (2):
> >  nfsd4: fix getacl head length estimation
> >  nfsd4: simplify getacl decoding
> > 
> > Weston Andros Adamson (1):
> >  NFSv4: fix getacl ERANGE for some ACL buffer sizes
> > 
> > fs/nfs/nfs4proc.c       | 116 +++++++++++++++++++++++-------------------------
> > fs/nfs/nfs4xdr.c        |  29 +++---------
> > include/linux/nfs_xdr.h |   4 +-
> > 3 files changed, 64 insertions(+), 85 deletions(-)
> > 
> > -- 
> > 2.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
