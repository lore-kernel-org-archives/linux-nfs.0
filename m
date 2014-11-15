Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:11319 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752162AbaKOBYk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 20:24:40 -0500
Date: Sat, 15 Nov 2014 12:24:35 +1100
From: Dave Chinner <david@fromorbit.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141115012435.GG23575@dastard>
References: <20141111162704.GA12103@lst.de>
 <20141111222710.GY23575@dastard>
 <20141112102440.GA31344@lst.de>
 <CAHQdGtRi-20XRthpU7vrkAE+=3d9HG6g8i6REGYn+uo0xkbmRw@mail.gmail.com>
 <20141113002846.GC23575@dastard>
 <CAHQdGtRvaOTT7375p0eDjPPm+uFc19AJkf-NWDAKq-=goqZSpA@mail.gmail.com>
 <20141113235400.GM28565@dastard>
 <CAHQdGtTzs+K1dUo=9W9sp45-qGxFp5pDwXJgdHY=6UV+Myr68Q@mail.gmail.com>
 <20141114043505.GA29950@dastard>
 <CAHQdGtR6hQ=B9SvD+52jS7gdAGLw4-y4SSX829eEH5q0ONXp1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtR6hQ=B9SvD+52jS7gdAGLw4-y4SSX829eEH5q0ONXp1w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 14, 2014 at 09:22:14AM -0500, Trond Myklebust wrote:
> On Thu, Nov 13, 2014 at 11:35 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Thu, Nov 13, 2014 at 07:43:33PM -0500, Trond Myklebust wrote:
> >> On Thu, Nov 13, 2014 at 6:54 PM, Dave Chinner <david@fromorbit.com> wrote:
> >> > On Thu, Nov 13, 2014 at 08:02:43AM -0500, Trond Myklebust wrote:
> >> >> On Wed, Nov 12, 2014 at 7:28 PM, Dave Chinner <david@fromorbit.com> wrote:
> >> >> > On Wed, Nov 12, 2014 at 09:26:16AM -0500, Trond Myklebust wrote:
> >> >> >> On Wed, Nov 12, 2014 at 5:24 AM, Christoph Hellwig <hch@lst.de> wrote:
> >> >> >> > On Wed, Nov 12, 2014 at 09:27:10AM +1100, Dave Chinner wrote:
> >> >> >> >> To clarify what Christoph wrote, XFS updates i_version is updated
> >> >> >> >> once per transaction that modifies the inode. So if a VFS level
> >> >> >> >> operation results in multiple transactions then each transaction
> >> >> >> >> will but the version.
> >> >> >> >>
> >> >> >> >> It was implemented that way because nobody could tell me what the
> >> >> >> >> actual granularity requirement for change detection was.  Hence what
> >> >> >> >> I implemented was "be able to detect any persistent change that is
> >> >> >> >> made" to cover all bases.
> >> >
> >> > FWIW, ext4 takes the same approach.  See Ted's post today:
> >> >
> >> > http://www.spinics.net/lists/linux-ext4/msg46194.html
> >> >
> >> > "The inode_inc_iversion() in mark4_ext4_iloc_dirty() is probably not
> >> > necessary, since we already should be incrementing i_version whenever
> >> > ctime and mtime gets updated.  The inode_inc_iversion() there is more
> >> > of a "belt and suspenders" safety thing, on the theory that the extra
> >> > bump in i_version won't hurt anything."
> >> >
> >>
> >> It will hurt if it causes all the NFS clients to blow their caches
> >> unnecessarily.
> >
> > Not my problem. We've just implemented what we were asked to
> > implement.
> >
> >> Who asked for this?
> >
> > The only discussion where actual specifications were enumerated was
> > during a thread about using i_version in the integrity measurement
> > code (IMA subsystem). The NFSv4 requirements for the change counter
> > were expressed here:
> >
> > https://lkml.org/lkml/2012/1/5/408
> >
> > Don't blame us for implementing the vague "changes every time"
> > requirements in a way that results in no chance of a persistent
> > change to either data or metadata being missed by the filesystem.
> 
> I'm not blaming anyone. I'm stating that I'm not aware of anybody who
> needs to trace fiemap changes via the change attribute, and so I'm
> asking where that requirement came from?

It was seriously being considered - it appeared as a potential in
NFSv4 draft specs for handling sparse file reads. Indeed, this draft
directly mentions reading block maps from XFS and using it on the
client side:

http://tools.ietf.org/html/draft-hildebrand-nfsv4-read-sparse-00

"XFS supports the XFS_IOC_GETBMAP extended attribute, which returns
the allocation information for a file. Clients can then use this
information to only read allocated data blocks"

Now, I know that was from 2010, and the eventual 2014 NFSv4.2 RFC
doesn't have this in it, but go back 3-4 years ago when we were
trying to work out to how make an on-disk version counter work
sanely for all the different things we'd been hearing about were
going to be necessary for NFSv4....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
