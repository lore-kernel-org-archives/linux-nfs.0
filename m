Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644Ab2DJS2N convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2012 14:28:13 -0400
Date: Tue, 10 Apr 2012 14:28:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120410142853.7e749ba2@corrin.poochiereds.net>
In-Reply-To: <4F84537A.40100@parallels.com>
References: <4F82F16C.7030303@parallels.com>
	<20120409112739.6a823d6f@corrin.poochiereds.net>
	<4F830999.5000504@parallels.com>
	<20120409161114.GB6482@fieldses.org>
	<1333988226.2688.76.camel@lade.trondhjem.org>
	<20120409162107.GC6482@fieldses.org>
	<1333989216.2688.87.camel@lade.trondhjem.org>
	<4F8314CF.70302@parallels.com>
	<20120409181138.GA9581@fieldses.org>
	<4F8411CC.2070105@parallels.com>
	<20120410133913.GF18465@fieldses.org>
	<4F84537A.40100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Apr 2012 19:36:26 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 10.04.2012 17:39, bfields@fieldses.org пишет:
> > On Tue, Apr 10, 2012 at 02:56:12PM +0400, Stanislav Kinsbursky wrote:
> >> 09.04.2012 22:11, bfields@fieldses.org пишет:
> >>> Since NFSv4 doesn't have a separate MOUNT protocol, clients need to be
> >>> able to do readdir's and lookups to get to exported filesystems.  We
> >>> support this in the Linux server by exporting all the filesystems from
> >>> "/" on down that must be traversed to reach a given filesystem.  These
> >>> exports are very restricted (e.g. only parents of exports are visible).
> >>>
> >>
> >> Ok, thanks for explanation.
> >> So, this pseudoroot looks like a part of NFS server internal
> >> implementation, but not a part of a standard. That's good.
> >>
> >>>> Why does it prevents implementing of check for "superblock-network
> >>>> namespace" pair on NFS server start and forbid (?) it in case of
> >>>> this pair is shared already in other namespace? I.e. maybe this
> >>>> pseudoroot can be an exclusion from this rule?
> >>>
> >>> That might work.  It's read-only and consists only of directories, so
> >>> the grace period doesn't affect it.
> >>>
> >>
> >> I've just realized, that this per-sb grace period won't work.
> >> I.e., it's a valid situation, when two or more containers located on
> >> the same filesystem, but shares different parts of it. And there is
> >> not conflict here at all.
> >
> > Well, there may be some conflict in that a file could be hardlinked into
> > both subtrees, and that file could be locked from users of either
> > export.
> >
> 
> Is this case handled if both links or visible in the same export?
> But anyway, this is not that bad. I.e it doesn't make things unpredictable.
> Probably, there are some more issues like this one (bind-mounting, for example).
> But I think, that it's root responsibility to handle such problems.
> 

Well, it's a problem and one that you'll probably have to address to
some degree. In truth, the fact that you're exporting different
subtrees in different containers is immaterial since they're both on
the same fs and filehandles don't carry any info about the path in and
of themselves...

Suppose for instance that we have a hardlinked file that's available
from two different exports in two different containers. The grace
period ends in container #1, so that nfsd starts servicing normal lock
requests. An application takes a lock on that hardlinked file. In the
meantime, a client of container #2 attempts to reclaim the lock that he
previously held on that same inode and gets denied.

That's just one example. The scarier case is that the client of
container #1 takes the lock, alters the file and then drops it again
with the client of container #2 none the wiser. Now the file got
altered while client #2 thought he held a lock on it. That won't be fun
to track down...

This sort of thing is one of the reasons I've been saying that the
grace period is really a property of the underlying filesystem and not
of nfsd itself. Of course, we do have to come up with a way to handle
the grace period that doesn't involve altering every exportable fs.

-- 
Jeff Layton <jlayton@redhat.com>
