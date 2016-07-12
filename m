Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36212 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933089AbcGLMk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2016 08:40:56 -0400
Date: Tue, 12 Jul 2016 08:40:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/3][resend] pnfs/nfsd: have client and server support
 multiple layout types
Message-ID: <20160712124055.GA449@fieldses.org>
References: <1468180560-13004-1-git-send-email-jlayton@redhat.com>
 <20160711180429.GE18083@fieldses.org>
 <1468269178.2577.24.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1468269178.2577.24.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 11, 2016 at 04:32:58PM -0400, Jeff Layton wrote:
> On Mon, 2016-07-11 at 14:04 -0400, J. Bruce Fields wrote:
> > On Sun, Jul 10, 2016 at 03:55:57PM -0400, Jeff Layton wrote:
> > > From: Jeff Layton <jlayton@poochiereds.net>
> > > 
> > > v3:
> > > - use sort() from lib/sort.c to sort the list
> > > 
> > > v2:
> > > - rework Tigran's patch to preserve existing selection behaviour
> > > - simplify layout driver selection by sorting the list
> > > 
> > > This is v3 of the patchset. The main change is that this patch doesn't
> > > use a hand-rolled bubble sort, but rather the heapsort library in
> > > lib/sort.c. This is mostly for conciseness since the array sizes are
> > > generally so small that it shouldn't make any perf difference.
> > > 
> > > Note that this does mean that we need to keep track on the number of
> > > elements in the array that the server sends, so there are a few
> > > ancillary changes to deal with that as well.
> > > 
> > > Only lightly tested by mounting a server that sends both flexfiles and
> > > block layouts. The client successfully selected the block layout in most
> > > cases, but if I blacklist blocklayoutdriver then it selects flexfiles
> > > instead.
> > > 
> > > I'm sending these together, but I'd expect Bruce to pick up the nfsd
> > > patches and Trond or Anna to pick up the client-side ones.
> > 
> > Patches still look fine to me.  Feel free to add a Reviewed-by: J. Bruce
> > Fields <bfields@redhat.com> for the client-side patches.  I'll take the
> > server-side patch for 4.8 assuming no objections to this approach from
> > the client side.
> > 
> > --b.
> > 
> 
> Sorry, I think you added a Reviewed-by tag on the earlier set, and I
> forgot to add it. I'll put it in now. BTW, these patches are in the
> nfsd-4.8 branch of my tree if that makes it easier to pick them:
> 
>     https://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfsd-4.8
> 
> I still haven't heard from Trond or Anna on the latest iteration of the
> series. I think I've addressed Trond's concerns with the earlier set
> though.
> 
> The only part that I'm not sure of with the server-side patch is that
> it orders the list by numerical layouttype value. In principle, it
> shouldn't matter since the client should pick the best one for its
> needs, but older clients will just look at the first one on the list.
> 
> In the case where you have both SCSI and FlexFile layouts, older
> clients will pick flexfiles over scsi. That may not be what we want.
> Should we take more care to order the list by some measure of
> "usefulness"?

That would be OK with me, but I don't think it's worth a lot of effort
at this point.  Very few will want the current server flexfiles
implementation, and they can live with just the compile-time option.

Longer term this doesn't seem like something we can decide
algorithmically.  The suggestion I've heard is to extend the export
syntax to allow "pnfs=scsi,flex" or whatever, and take the ordering as
the user's priority.

I agree that we want this sorted out eventually, and certainly before
flexfiles becomes useful in production.

--b.
