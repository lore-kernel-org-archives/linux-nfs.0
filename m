Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:56074 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758007Ab3BOC1l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 21:27:41 -0500
Date: Fri, 15 Feb 2013 13:27:38 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Theodore Ts'o" <tytso@mit.edu>, Anand Avati <anand.avati@gmail.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130215022738.GD10731@dastard>
References: <20130213040003.GB2614@thunk.org>
 <20130213133131.GE14195@fieldses.org>
 <20130213151455.GB17431@thunk.org>
 <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
 <20130214061002.GM26694@dastard>
 <20130214220110.GE8343@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130214220110.GE8343@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 14, 2013 at 05:01:10PM -0500, J. Bruce Fields wrote:
> On Thu, Feb 14, 2013 at 05:10:02PM +1100, Dave Chinner wrote:
> > On Wed, Feb 13, 2013 at 05:20:52PM -0500, Theodore Ts'o wrote:
> > > Telldir() and seekdir() are basically implementation horrors for any
> > > file system that is using anything other than a simple array of
> > > directory entries ala the V7 Unix file system or the BSD FFS.  For any
> > > file system which is using a more advanced data structure, like
> > > b-trees hash trees, etc, there **can't** possibly be a "offset" into a
> > > readdir stream. 
> > 
> > I'll just point you to this:
> > 
> > http://marc.info/?l=linux-ext4&m=136081996316453&w=2
> > 
> > so you can see that XFS implements what you say can't possibly be
> > done. ;)
> > 
> > FWIW, that post only talked about the data segment. I didn't mention
> > that XFS has 2 other segments in the directory file (both beyond
> > EOF) for the directory data indexes. One contains the name-hash btree
> > index used for name based lookups and the other contains a freespace
> > index for tracking free space in the data segment.
> 
> OK, so in some sense that reduces the problem to that of implementing
> readdir cookies for directories that are stored in a simple linear
> array.

*nod*

> Which I should know how to do but I don't: I guess all you need is a
> provision for making holes on remove (so that you aren't required move
> existing entries, messing up offsets for concurrent readers)?

Exactly.

The data segment is a virtual mapping that is maintained by the
extent tree, so we can simply punch holes in it for directory blocks
that are empty and no longer referenced. i.e. the data segement
really is just a sparse file.

The result of doing block mapping this way is that the freespace
tracking segment actually only needs to track space in partially
used blocks. Hence we only need to allocate new blocks when the
freespace map empties, And we work out where to allocate the new
block in the virtual map by doing an extent tree lookup to find the
first hole....

> Purely out of curiosity: is there a more detailed writeup of XFS's
> directory format?  (Or a pointer to a piece of the code a person could
> understand without losing a month to it?)

Not really. There's documentation of the on-disk structures, but
it's a massive leap from there to understanding the structure and
how it all ties together.  I've been spending the past couple of
months deep in the depths of the XFS directory code so how it all
works is front-and-center in my brain right now...

That said, the thought had crossed my mind that there's a a couple
of LWN articles/conference talks I could put together as a brain
dump. ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
