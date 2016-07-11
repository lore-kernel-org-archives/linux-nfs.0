Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35332 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbcGKSEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jul 2016 14:04:31 -0400
Date: Mon, 11 Jul 2016 14:04:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/3][resend] pnfs/nfsd: have client and server support
 multiple layout types
Message-ID: <20160711180429.GE18083@fieldses.org>
References: <1468180560-13004-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1468180560-13004-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 10, 2016 at 03:55:57PM -0400, Jeff Layton wrote:
> From: Jeff Layton <jlayton@poochiereds.net>
> 
> v3:
> - use sort() from lib/sort.c to sort the list
> 
> v2:
> - rework Tigran's patch to preserve existing selection behaviour
> - simplify layout driver selection by sorting the list
> 
> This is v3 of the patchset. The main change is that this patch doesn't
> use a hand-rolled bubble sort, but rather the heapsort library in
> lib/sort.c. This is mostly for conciseness since the array sizes are
> generally so small that it shouldn't make any perf difference.
> 
> Note that this does mean that we need to keep track on the number of
> elements in the array that the server sends, so there are a few
> ancillary changes to deal with that as well.
> 
> Only lightly tested by mounting a server that sends both flexfiles and
> block layouts. The client successfully selected the block layout in most
> cases, but if I blacklist blocklayoutdriver then it selects flexfiles
> instead.
> 
> I'm sending these together, but I'd expect Bruce to pick up the nfsd
> patches and Trond or Anna to pick up the client-side ones.

Patches still look fine to me.  Feel free to add a Reviewed-by: J. Bruce
Fields <bfields@redhat.com> for the client-side patches.  I'll take the
server-side patch for 4.8 assuming no objections to this approach from
the client side.

--b.

> 
> The nfsd patch is based on top of Tom's nfsd flexfile layout patches.
> 
> Jeff Layton (3):
>   nfsd: allow nfsd to advertise multiple layout types
>   pnfs: track multiple layout types in fsinfo structure
>   pnfs: add a new mechanism to select a layout driver according to an
>     ordered list
> 
>  fs/nfs/client.c         |  3 ++-
>  fs/nfs/nfs4proc.c       |  3 ++-
>  fs/nfs/nfs4xdr.c        | 40 +++++++++++++++--------------
>  fs/nfs/pnfs.c           | 67 ++++++++++++++++++++++++++++++++++++++++---------
>  fs/nfs/pnfs.h           |  5 ++--
>  fs/nfsd/export.c        |  4 +--
>  fs/nfsd/export.h        |  2 +-
>  fs/nfsd/nfs4layouts.c   |  6 ++---
>  fs/nfsd/nfs4proc.c      |  4 +--
>  fs/nfsd/nfs4xdr.c       | 30 +++++++++++-----------
>  include/linux/nfs_xdr.h |  8 +++++-
>  11 files changed, 112 insertions(+), 60 deletions(-)
> 
> -- 
> 2.5.5
