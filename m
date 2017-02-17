Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33080 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934074AbdBQQoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 11:44:17 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/3] getacl fixes
Date: Fri, 17 Feb 2017 11:44:11 -0500
Message-Id: <1487349854-9732-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The getacl code is allocating enough space to handle the ACL data but
not to handle the bitmask, which can lead to spurious ERANGE errors when
the end of the ACL gets close to a page boundary.

Dros addressed this by letting the rpc layer allocate pages as necessary
on demand, as the NFSv3 ACL code does.

On its own that didn't do the job either, because we don't handle the
case where xdr_shrink_bufhead needs to move data around in the xdr buf.
And xdr_shrink_bufhead was getting called every time due to an incorrect
estimate in an xdr_inline_pages call.

So, I fixed that estimate.  That still leaves the chance of a bug in the
rare case xdr_shrink_bufhead is called.

We could fix up the handling of the xdr_shrink_bufhead case, but I don't
see the point of shifting this data around in the first place.  We're
not doing anything like zero-copy here, we're just going to copy the
data out into the buffer we were passed.  The NFSv3 ACL code doesn't
bother with this.

It's simpler just to pass down the buffer to the xdr layer and let it
copy the ACL out.

The result looks a lot simpler and more obviously correct than this code
has been, though I'm not particularly happy with the sequence of patches
that gets us there; it would be better to squash together Dros's and my
patch and then split out the result some more sensible way.

Sorry for the delay getting back to this.  Older discussions:

	https://marc.info/?t=138452791200001&r=1&w=2
	http://marc.info/?t=138506891000003&r=1&w=2

J. Bruce Fields (2):
  nfsd4: fix getacl head length estimation
  nfsd4: simplify getacl decoding

Weston Andros Adamson (1):
  NFSv4: fix getacl ERANGE for some ACL buffer sizes

 fs/nfs/nfs4proc.c       | 116 +++++++++++++++++++++++-------------------------
 fs/nfs/nfs4xdr.c        |  29 +++---------
 include/linux/nfs_xdr.h |   4 +-
 3 files changed, 64 insertions(+), 85 deletions(-)

-- 
2.9.3

