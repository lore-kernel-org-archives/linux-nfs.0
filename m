Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38197 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab3J0TPN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Oct 2013 15:15:13 -0400
Date: Sun, 27 Oct 2013 15:15:12 -0400
To: Christoph Anton Mitterer <calestyo@scientia.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: XATTRs in NFS?
Message-ID: <20131027191512.GA31322@fieldses.org>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
 <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
 <1382635350.6907.83.camel@heisenberg.scientia.net>
 <20131025140846.GB20497@fieldses.org>
 <1382807547.29041.12.camel@heisenberg.scientia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382807547.29041.12.camel@heisenberg.scientia.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please don't trim the cc list.

On Sat, Oct 26, 2013 at 07:12:27PM +0200, Christoph Anton Mitterer wrote:
> On Fri, 2013-10-25 at 10:08 -0400, J. Bruce Fields wrote:
> > Can you give any more details about your use case?  (E.g. is there an
> > article describing this system somewhere?)
> Okay let me try to explain the motivation more elaborately.
> 
> The general idea is getting data integrity, i.e. being able to see
> whether some files are in a valid state.
> 
> This is similar to what e.g. btrfs/zfs provide at (IIRC block/extent
> level) with checksuming.
> But a) btrfs is not yet fully production ready (IMHO) and zfs in Linux
> has it's (license) issues and more important b) the checksuming there
> happens always and automatically as soon as some valid filesystem
> operations occur on the files.
> 
> So what you basically notice are errors on the physical medium (or at
> least on block layers below the filesystem).
> 
> 
> You won't notice many other cases of file "corruptions":
> 
> - when you have programs which do subtly manipulate the files and you
> don't notice,...e.g. some image organisation programs store their
> meta-data crap in the Exif/XMP fields, even when you don't actively tell
> them to do so (and sometimes even when the files are read-only)
> 
> - when there are e.g. kernel bugs (in some other places of the kernel)
> and you copy the files around. Some years ago I found a bug (not the
> solution) where single bit errors happened more or less randomly every
> 40-100 GB of writing data. In the end it was found to be a IOMMU related
> bug and a single one liner of flushing some buffers cleared the problem.
> Since such errors would happen already at earlier stages, when writing
> such files btrfs/zfs would simply write the checksums of the corrupted
> data.

Was this problem actually caught using checksums stored in xattrs, or
did the problem predate your use of xattrs?

> So the idea of my integrity data is, that I really manually say "now the
> data is in the state where I consider it to be consistent and I want to
> have checksums stored and attached to the files, for exactly that
> state", e.g. after I have read out some images from the SD card (perhaps
> even twice with the cache cleared and the results diffed) and placed in
> my archive.
> Afterwards I can regularly verify the whole archive and if at some stage
> corruptions as the above would have happened, I can simply take the
> respective files from backups.

How long have you been using this for?  How many problems has it caught?
How often do you checksum or verify files, and how expensive is that?

--b.

> 
> 
> Obviously that cannot be stored *in* the files,... and a database
> solution fails since, it wouldn't track the changes when I move files
> around within the archive.
> 
> 
> So IMHO the best solution were XATTRs, which do work fine for that
> purpose... just the problem that I can't have it via NFS ;)
> 
> 
> Cheers,
> Chris.


