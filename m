Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18377 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752046AbcK2XWZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 18:22:25 -0500
Date: Tue, 29 Nov 2016 15:21:46 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/4] Add copy_file_range() tests
Message-ID: <20161129232146.GA25841@birch.djwong.org>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
 <20161026082638.GA19419@infradead.org>
 <20161125080509.GA6082@infradead.org>
 <20161129204722.GA9331@fieldses.org>
 <ce1c4ee0-eaa9-1011-857a-c4930bb12115@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ce1c4ee0-eaa9-1011-857a-c4930bb12115@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 29, 2016 at 03:59:29PM -0500, Anna Schumaker wrote:

> Sorry for the delay!  I've been busy looking at other things and
> forgot to update the copy_file_range() stuff :(

While you're at it, please make a test to check the return value for
invalid inputs.  I'd prefer we avoid repeating what happened with the
vfs dedupe ioctl.

--D

> 
> On 11/29/2016 03:47 PM, J. Bruce Fields wrote:
> > On Fri, Nov 25, 2016 at 12:05:10AM -0800, Christoph Hellwig wrote:
> >> On Wed, Oct 26, 2016 at 01:26:38AM -0700, Christoph Hellwig wrote:
> >>> On Wed, Sep 07, 2016 at 03:56:15PM -0400, Anna Schumaker wrote:
> >>>> These tests exercise the copy_file_range() system call, and check copying
> >>>> data to both a new file and overwriting data inside an existing file.  I use
> >>>> the xfs_io "copy_range" command for the actual copies, so running these
> >>>> tests requires an up-to-date version of xfsprogs.
> >>>
> >>> Hi Anna,
> >>>
> >>> what's the status of these tests?  Did you get a chance to look
> >>> into xfs_io copyfile support?
> 
> xfs_io has support for copying now, so I'll make sure that the tests
> use that correctly.  I promise to send out an update this week, once I
> check that everything still works!
> 
> Thanks for the reminders,
> Anna
> 
> >>
> >> Another month, another ping - it would be really sad to not have any
> >> real testing for copy_file_range.
> > 
> > Agreed, Anna, are you still planning on doing this?
> > 
> > --b.
> > 
> >> I've been holding a pending change
> >> for it back for month now because I want to verify it more than cursory,
> >> but I guess I'll just have to send it anyway.
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
