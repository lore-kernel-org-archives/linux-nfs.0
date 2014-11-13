Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:45098 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934400AbaKMXyQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 18:54:16 -0500
Date: Fri, 14 Nov 2014 10:54:00 +1100
From: Dave Chinner <david@fromorbit.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141113235400.GM28565@dastard>
References: <20141111162849.GA12527@lst.de>
 <20141111162704.GA12103@lst.de>
 <20141111222710.GY23575@dastard>
 <20141112102440.GA31344@lst.de>
 <CAHQdGtRi-20XRthpU7vrkAE+=3d9HG6g8i6REGYn+uo0xkbmRw@mail.gmail.com>
 <20141113002846.GC23575@dastard>
 <CAHQdGtRvaOTT7375p0eDjPPm+uFc19AJkf-NWDAKq-=goqZSpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRvaOTT7375p0eDjPPm+uFc19AJkf-NWDAKq-=goqZSpA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 08:02:43AM -0500, Trond Myklebust wrote:
> On Wed, Nov 12, 2014 at 7:28 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Wed, Nov 12, 2014 at 09:26:16AM -0500, Trond Myklebust wrote:
> >> On Wed, Nov 12, 2014 at 5:24 AM, Christoph Hellwig <hch@lst.de> wrote:
> >> > On Wed, Nov 12, 2014 at 09:27:10AM +1100, Dave Chinner wrote:
> >> >> To clarify what Christoph wrote, XFS updates i_version is updated
> >> >> once per transaction that modifies the inode. So if a VFS level
> >> >> operation results in multiple transactions then each transaction
> >> >> will but the version.
> >> >>
> >> >> It was implemented that way because nobody could tell me what the
> >> >> actual granularity requirement for change detection was.  Hence what
> >> >> I implemented was "be able to detect any persistent change that is
> >> >> made" to cover all bases.

FWIW, ext4 takes the same approach.  See Ted's post today:

http://www.spinics.net/lists/linux-ext4/msg46194.html

"The inode_inc_iversion() in mark4_ext4_iloc_dirty() is probably not
necessary, since we already should be incrementing i_version whenever
ctime and mtime gets updated.  The inode_inc_iversion() there is more
of a "belt and suspenders" safety thing, on the theory that the extra
bump in i_version won't hurt anything."

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
