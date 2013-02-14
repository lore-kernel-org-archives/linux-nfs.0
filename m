Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:39139 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750990Ab3BNGKG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2013 01:10:06 -0500
Date: Thu, 14 Feb 2013 17:10:02 +1100
From: Dave Chinner <david@fromorbit.com>
To: "Theodore Ts'o" <tytso@mit.edu>
Cc: Anand Avati <anand.avati@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>, sandeen@redhat.com,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130214061002.GM26694@dastard>
References: <20130212202841.GC10267@fieldses.org>
 <20130213040003.GB2614@thunk.org>
 <20130213133131.GE14195@fieldses.org>
 <20130213151455.GB17431@thunk.org>
 <20130213151953.GJ14195@fieldses.org>
 <20130213153654.GC17431@thunk.org>
 <20130213162059.GL14195@fieldses.org>
 <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130213222052.GD5938@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2013 at 05:20:52PM -0500, Theodore Ts'o wrote:
> Telldir() and seekdir() are basically implementation horrors for any
> file system that is using anything other than a simple array of
> directory entries ala the V7 Unix file system or the BSD FFS.  For any
> file system which is using a more advanced data structure, like
> b-trees hash trees, etc, there **can't** possibly be a "offset" into a
> readdir stream. 

I'll just point you to this:

http://marc.info/?l=linux-ext4&m=136081996316453&w=2

so you can see that XFS implements what you say can't possibly be
done. ;)

FWIW, that post only talked about the data segment. I didn't mention
that XFS has 2 other segments in the directory file (both beyond
EOF) for the directory data indexes. One contains the name-hash btree
index used for name based lookups and the other contains a freespace
index for tracking free space in the data segment.

IOWs persistent, deterministic, low cost telldir/seekdir behaviour
was a problem solved in the 1990s. :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
