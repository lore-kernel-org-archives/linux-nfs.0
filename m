From: Theodore Tso <tytso-DPNOqEs/LNQ@public.gmane.org>
Subject: Re: [PATCH] nfs2/3 ESTALE bug (libblkid uses stale cache/uuid
	values)
Date: Mon, 19 May 2008 15:03:56 -0400
Message-ID: <20080519190356.GH15035@mit.edu>
References: <200805172204.m4HM424o003970@agora.fsl.cs.sunysb.edu> <20080519160408.GG7622@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Kevin Coffman <kwc@umich.edu>, nfs@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, Himanshu Kanda <hkanda-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:37118 "EHLO
	biscayne-one-station.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430AbYESTEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 15:04:53 -0400
In-Reply-To: <20080519160408.GG7622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 19, 2008 at 12:04:08PM -0400, J. Bruce Fields wrote:
> > 3. blkid_verify can verify that a device is valid.  To do so, it open(2)'s
> >    the device, reads some filesystem-specific info from it (e.g., the ext2
> >    superblock header, which includes the uuid), and caches all that
> >    filesystem-specific information for later reuse.  Of course, reading the
> >    f/s superblock each time is expensive,
> 
> How expensive is it actually?

The problem is if you have a *very* large number of disk drives, and
you sequence through them doing a mount -a, it because an order
n-squared operation.  The goal here was to avoid doing that check.

> >    Therefore, the above "if" wants to ensure that a device won't be
> >    re-probed unless enough time had passed since the last time it was
> >    probed: BLKID_PROBE_INTERVAL is 200 seconds.  That check alone is wrong.
> >    A device could have changed numerous times within 200 seconds, and the
> >    result is that libblkid happily returns the old dev structure, with the
> >    old UUID, *until* 200 seconds have passed.  We verified it by sticking
> >    printf's in nfs-utils and libblkid, and also using tcpdumps b/t an nfs
> >    client and server.

In practice it's rare for a system administrator to rerun mkfs
multiple times in the space of 200 seconds.  (Especially since mkfs
for ext3 normally takes quite a bit of time to run on large disks,
although I'll grant that's a bug that we'll fixing for ext4.  :-) In
general, though, it's rare for system administrator to be constantly
recreating filesystems on their devices.  It's happening in your test
scenario, but in real life, it's rare that an administrator will be
constantly reformatting a drive, especially if it's being exported by
NFS.

> I should know this, but I don't: when exactly do the ctime, mtime, and
> atime of a block device get updated?

They won't get change if they are being modified via a mounted
filesystem, but if they are modified from an outside program (such as
mkfs) the mtime will get changed.

> >    (BTW, I think that the check for "diff > 0" is redundant in the above
> >    "if" b/c if "now > dev->bid_time" is true, then "diff > 0" is also true.)
> 
> I don't understand that check either.

Yeah, it's not needed.

> > The following patch (against e2fsprogs v1.40.8-215-g9817a2b) fixes
> > the bug.  It's a small patch, but perhaps not the cleanest one: it
> > has to goto the middle of another if statement; a better patch
> > would perhaps consolidate the stat() and fstat() calls into one,
> > and rewrite the code so the second 'if' doesn't need the fstat().
> > We've tested this patch with our script and we cannot reproduce
> > the ESTALE bug even after thousands of iterations.

Thanks for the patch.  I'll clean it up and include in e2fsprogs, but
I don't consider this a high priority fix to get out to everyone,
since it's really not something that I expect will be hit in real
life, except in test scenarios like the one run into by Erez and his
team.

						- Ted
