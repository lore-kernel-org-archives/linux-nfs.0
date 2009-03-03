From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Tue, 3 Mar 2009 12:30:55 -0500
Message-ID: <20090303173055.GH22184@fieldses.org>
References: <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com> <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com> <1222445161.10150.4.camel@localhost> <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com> <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809282121t6953e068n62870810f1d0874@mail.gmail.com> <b66ddc900809282153yb873d8ayf82f2a61eca9cc18@mail.gmail.com> <20080929172630.GB23212@fieldses.org> <49AD00A1.3050606@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>,
	howard chen <howachen@gmail.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53933 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398AbZCCRbE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 12:31:04 -0500
In-Reply-To: <49AD00A1.3050606@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2009 at 12:04:17PM +0200, Benny Halevy wrote:
> On Sep. 29, 2008, 20:26 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > (Maybe you built a new kernel with nfsd built-in instead of built as a
> > module?)
> > 
> > But I thought nfs-utils was supposed to fall back on old behavior when
> > the nfsd filesystem wasn't found.
> 
> Doesn't seem so.

Right.  The old behavior depends on mountd telling the server about each
client as it mounts, and that isn't adequate in some cases: for example,
since nfsv4 clients never talk directly to mountd at all (they first
call nfsd directly), they need to be able to call up to mountd to ask
about each client as it arrives, and the old interface doesn't provide
a mechanism to do that.

But in this case I don't see any reason the old interface shouldn't be
good enough.

> Steve: any chance this bug is fixed anywhere?

It shouldn't be hard to fix.

If someone has the time to work on it but doesn't know the code, just
testing with varied versions of nfs-utils and the kernel would help
determine whether the problem is in mountd or in the kernel, and when it
was introduced.

--b.
