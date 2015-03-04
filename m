Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:57819 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755130AbbCDCI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 21:08:29 -0500
Date: Tue, 3 Mar 2015 21:08:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150304020826.GD19439@fieldses.org>
References: <20150303221033.GB19439@fieldses.org>
 <20150303224456.GV4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150303224456.GV4251@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2015 at 09:44:56AM +1100, Dave Chinner wrote:
> On Tue, Mar 03, 2015 at 05:10:33PM -0500, J. Bruce Fields wrote:
> > I'm getting mysterious crashes on a server exporting an xfs filesystem.
> > 
> > Strangely, I've reproduced this on
> > 
> > 	93aaa830fc17 "Merge tag 'xfs-pnfs-for-linus-3.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/dgc/linux-xfs
> > 
> > but haven't yet managed to reproduce on either of its parents
> > (24a52e412ef2 or 781355c6e5ae).  That might just be chance, I'll try
> > again.
> 
> I think you'll find that the bug is only triggered after that XFS
> merge because it's what enabled block layout support in the server,
> i.e.  nfsd4_setup_layout_type() is now setting the export type to
> LAYOUT_BLOCK_VOLUME because XFS has added the necessary functions to
> it's export ops.

Doh--after all the discussion I didn't actually pay attention to what
happened in the end.  OK, I see, you're right, it's all more-or-less
dead code till that merge.

Christoph's code was passing all my tests before that, so maybe we
broke something in the merge process.

Alternatively, it could be because I've added more tests--I'll rerun my
current tests on his original branch....

> > I can also try a serial console or something, but for now I'm not
> > getting a lot of information about the crashes.
> 
> Really need a stack trace - even a photo of the screen with the
> stack trace on it will do for starters. ;)

Yeah, I'll let you know when I have something.

By the way, Christoph, an unrelated question: how are the devices found,
and what are the chances of a client writing to the wrong block device?

(E.g., if they're addressed based on a uuid that doesn't change on
cloning the block device, and if the client had access to another device
with an identical copy of the filesystem, could it end up writing to
that instead?)

--b.
