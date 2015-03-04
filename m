Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:43416 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbbCDWqZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2015 17:46:25 -0500
Date: Thu, 5 Mar 2015 09:45:57 +1100
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150304224557.GY4251@dastard>
References: <20150303221033.GB19439@fieldses.org>
 <20150303224456.GV4251@dastard>
 <20150304020826.GD19439@fieldses.org>
 <20150304155421.GE1627@fieldses.org>
 <20150304220900.GX18360@dastard>
 <20150304222709.GI1627@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150304222709.GI1627@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2015 at 05:27:09PM -0500, J. Bruce Fields wrote:
> On Thu, Mar 05, 2015 at 09:09:00AM +1100, Dave Chinner wrote:
> > On Wed, Mar 04, 2015 at 10:54:21AM -0500, J. Bruce Fields wrote:
> > > On Tue, Mar 03, 2015 at 09:08:26PM -0500, J. Bruce Fields wrote:
> > > > On Wed, Mar 04, 2015 at 09:44:56AM +1100, Dave Chinner wrote:
> > > > > On Tue, Mar 03, 2015 at 05:10:33PM -0500, J. Bruce Fields wrote:
> > > > > > I'm getting mysterious crashes on a server exporting an xfs filesystem.
> > > > > > 
> > > > > > Strangely, I've reproduced this on
> > > > > > 
> > > > > > 	93aaa830fc17 "Merge tag 'xfs-pnfs-for-linus-3.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/dgc/linux-xfs
> > > > > > 
> > > > > > but haven't yet managed to reproduce on either of its parents
> > > > > > (24a52e412ef2 or 781355c6e5ae).  That might just be chance, I'll try
> > > > > > again.
> > > > > 
> > > > > I think you'll find that the bug is only triggered after that XFS
> > > > > merge because it's what enabled block layout support in the server,
> > > > > i.e.  nfsd4_setup_layout_type() is now setting the export type to
> > > > > LAYOUT_BLOCK_VOLUME because XFS has added the necessary functions to
> > > > > it's export ops.
> > > > 
> > > > Doh--after all the discussion I didn't actually pay attention to what
> > > > happened in the end.  OK, I see, you're right, it's all more-or-less
> > > > dead code till that merge.
> > > > 
> > > > Christoph's code was passing all my tests before that, so maybe we
> > > > broke something in the merge process.
> > > > 
> > > > Alternatively, it could be because I've added more tests--I'll rerun my
> > > > current tests on his original branch....
> > > 
> > > The below is on Christoph's pnfsd-for-3.20-4 (at cd4b02e).  Doesn't look
> > > very informative.  I'm running xfstests over NFSv4.1 with client and
> > > server running the same kernel, the filesystem in question is xfs, but
> > > isn't otherwise available to the client (so the client shouldn't be
> > > doing pnfs).
> > > 
> > > --b.
> > > 
> > > BUG: unable to handle kernel paging request at 00000000757d4900
> > > IP: [<ffffffff810b59af>] cpuacct_charge+0x5f/0xa0
> > > PGD 0 
> > > Thread overran stack, or stack corrupted
> > 
> > Hmmmm. That is not at all informative, especially as it's only
> > dumped the interrupt stack and not the stack or the task that it
> > has detected as overrun or corrupted.
> > 
> > Can you turn on all the stack overrun debug options? Maybe even
> > turn on the stack tracer to get an idea of whether we are recursing
> > deeply somewhere we shouldn't be?
> 
> Digging around under "Kernel hacking".... I already have
> DEBUG_STACK_USAGE, DEBUG_STACKOVERFLOW, and STACK_TRACER, and I can try
> turning on the latter.  (Will I be able to get information out of it
> before the panic?)

just keep taking samples of the worst case stack usage as the test
runs. If there's anything unusual before the failure then it will
show up, otherwise I'm not sure how to track this down...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
