Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:36459 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbcGKUdE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 16:33:04 -0400
Received: by mail-qk0-f170.google.com with SMTP id 82so103224031qko.3
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 13:33:02 -0700 (PDT)
Message-ID: <1468269178.2577.24.camel@redhat.com>
Subject: Re: [PATCH v3 0/3][resend] pnfs/nfsd: have client and server
 support multiple layout types
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Date: Mon, 11 Jul 2016 16:32:58 -0400
In-Reply-To: <20160711180429.GE18083@fieldses.org>
References: <1468180560-13004-1-git-send-email-jlayton@redhat.com>
	 <20160711180429.GE18083@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-07-11 at 14:04 -0400, J. Bruce Fields wrote:
> On Sun, Jul 10, 2016 at 03:55:57PM -0400, Jeff Layton wrote:
> > From: Jeff Layton <jlayton@poochiereds.net>
> > 
> > v3:
> > - use sort() from lib/sort.c to sort the list
> > 
> > v2:
> > - rework Tigran's patch to preserve existing selection behaviour
> > - simplify layout driver selection by sorting the list
> > 
> > This is v3 of the patchset. The main change is that this patch doesn't
> > use a hand-rolled bubble sort, but rather the heapsort library in
> > lib/sort.c. This is mostly for conciseness since the array sizes are
> > generally so small that it shouldn't make any perf difference.
> > 
> > Note that this does mean that we need to keep track on the number of
> > elements in the array that the server sends, so there are a few
> > ancillary changes to deal with that as well.
> > 
> > Only lightly tested by mounting a server that sends both flexfiles and
> > block layouts. The client successfully selected the block layout in most
> > cases, but if I blacklist blocklayoutdriver then it selects flexfiles
> > instead.
> > 
> > I'm sending these together, but I'd expect Bruce to pick up the nfsd
> > patches and Trond or Anna to pick up the client-side ones.
> 
> Patches still look fine to me.  Feel free to add a Reviewed-by: J. Bruce
> Fields <bfields@redhat.com> for the client-side patches.  I'll take the
> server-side patch for 4.8 assuming no objections to this approach from
> the client side.
> 
> --b.
> 

Sorry, I think you added a Reviewed-by tag on the earlier set, and I
forgot to add it. I'll put it in now. BTW, these patches are in the
nfsd-4.8 branch of my tree if that makes it easier to pick them:

    https://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfsd-4.8

I still haven't heard from Trond or Anna on the latest iteration of the
series. I think I've addressed Trond's concerns with the earlier set
though.

The only part that I'm not sure of with the server-side patch is that
it orders the list by numerical layouttype value. In principle, it
shouldn't matter since the client should pick the best one for its
needs, but older clients will just look at the first one on the list.

In the case where you have both SCSI and FlexFile layouts, older
clients will pick flexfiles over scsi. That may not be what we want.
Should we take more care to order the list by some measure of
"usefulness"?

> > 
> > The nfsd patch is based on top of Tom's nfsd flexfile layout patches.
> > 
> > Jeff Layton (3):
> >   nfsd: allow nfsd to advertise multiple layout types
> >   pnfs: track multiple layout types in fsinfo structure
> >   pnfs: add a new mechanism to select a layout driver according to an
> >     ordered list
> > 
> >  fs/nfs/client.c         |  3 ++-
> >  fs/nfs/nfs4proc.c       |  3 ++-
> >  fs/nfs/nfs4xdr.c        | 40 +++++++++++++++--------------
> >  fs/nfs/pnfs.c           | 67 ++++++++++++++++++++++++++++++++++++++++---------
> >  fs/nfs/pnfs.h           |  5 ++--
> >  fs/nfsd/export.c        |  4 +--
> >  fs/nfsd/export.h        |  2 +-
> >  fs/nfsd/nfs4layouts.c   |  6 ++---
> >  fs/nfsd/nfs4proc.c      |  4 +--
> >  fs/nfsd/nfs4xdr.c       | 30 +++++++++++-----------
> >  include/linux/nfs_xdr.h |  8 +++++-
> >  11 files changed, 112 insertions(+), 60 deletions(-)
> > 
> > -- 
> > 2.5.5
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

Jeff Layton <jlayton@redhat.com>
