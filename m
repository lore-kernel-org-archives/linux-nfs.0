Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49614 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbaILRzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2014 13:55:44 -0400
Date: Fri, 12 Sep 2014 13:55:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv2/3 vs v4 error codes?
Message-ID: <20140912175543.GA32359@fieldses.org>
References: <20140910221650.GD29452@infradead.org>
 <20140911190345.GA20501@fieldses.org>
 <20140911200214.GA21392@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140911200214.GA21392@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 01:02:14PM -0700, Christoph Hellwig wrote:
> On Thu, Sep 11, 2014 at 03:03:45PM -0400, J. Bruce Fields wrote:
> > On Wed, Sep 10, 2014 at 03:16:50PM -0700, Christoph Hellwig wrote:
> > > As a followup to the fallocate discussion I checked what we map ENODEV
> > > to in nfsd.  Turns out we map it to NFSERR_NODEV, which doesn't exist
> > > in eiter NFSv4.0 nor NFSv4.1 despite the comment in
> > > include/uapi/linux/nfs.h claiming otherwise.
> > 
> > That's interesting.  Is there a reasonable alternative, or is this a
> > protocol bug?
> 
> I still haven't figured this out.  RFC1813 mentions NFS3ERR_NODEV, but
> doesn't actually reference it anywhere.
> 
> In general it seems to me like the use of ENODEV in fallocate is the
> bug, as we don't really return it from any other filesystem operation.
> 
> > > I also just ran into another issue where nfserrno translates a large
> > > lits of errors into NFSERR_JUKEBOX, but for v4 we'd really want
> > > NFSERR_DELAY instead for most of them.
> > 
> > The distinction is academic as they're both 10008.
> 
> Oh, right.  I missed to spot that.
> 
> > > Is it time for a version specific errno mapping?
> > 
> > I'm certainly not opposed if it turns out to be necessary.
> 
> A start might be to move nfserrno out of the NFSv2-specific nfsproc
> file..

The current location's a little confusing.   But I don't have strong
feelings about it.

--b.
