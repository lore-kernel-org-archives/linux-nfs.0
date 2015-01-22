Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:49631 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbbAVUTA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2015 15:19:00 -0500
Date: Thu, 22 Jan 2015 21:18:57 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 03/20] fs: add FL_LAYOUT lease type
Message-ID: <20150122201857.GA14577@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <1421925006-24231-4-git-send-email-hch@lst.de> <20150122201442.GJ898@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150122201442.GJ898@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 03:14:42PM -0500, J. Bruce Fields wrote:
> On Thu, Jan 22, 2015 at 12:09:49PM +0100, Christoph Hellwig wrote:
> > This (ab-)uses the file locking code to allow filesystems to recall
> > outstanding pNFS layouts on a file.  This new lease type is similar but
> > not quite the same as FL_DELEG.  A FL_LAYOUT lease can always be granted,
> > an a per-filesystem lock (XFS iolock for the initial implementation)
> > ensures not FL_LAYOUT leases granted when we would need to recall them.
> 
> So when there's a conflicting operation it's xfs's responsibility to
> call break_layout and wait for the recall?
> 
> (And what roughly is the set of conflicting operations?)

The last patch in the series has a comment explaining this.

There's two categories:

 a) operations that need to be protected to maintain filesystem integrity:
    truncate, hole punch, collapse range, a well as any new operation
    that can deallocate blocks.
 b) operations that write data locally, and we want to provide a best
    effort attempt at data cohrency between local use and pFNS clients.
    This covers writes in all variants, and should apply to shared mmap
    writes, but sleeping in the page fault handler is too hard to bother
    with for this sort of best effort coherency.
