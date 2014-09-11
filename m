Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60782 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376AbaIKUCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 16:02:15 -0400
Date: Thu, 11 Sep 2014 13:02:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: NFSv2/3 vs v4 error codes?
Message-ID: <20140911200214.GA21392@infradead.org>
References: <20140910221650.GD29452@infradead.org>
 <20140911190345.GA20501@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140911190345.GA20501@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 03:03:45PM -0400, J. Bruce Fields wrote:
> On Wed, Sep 10, 2014 at 03:16:50PM -0700, Christoph Hellwig wrote:
> > As a followup to the fallocate discussion I checked what we map ENODEV
> > to in nfsd.  Turns out we map it to NFSERR_NODEV, which doesn't exist
> > in eiter NFSv4.0 nor NFSv4.1 despite the comment in
> > include/uapi/linux/nfs.h claiming otherwise.
> 
> That's interesting.  Is there a reasonable alternative, or is this a
> protocol bug?

I still haven't figured this out.  RFC1813 mentions NFS3ERR_NODEV, but
doesn't actually reference it anywhere.

In general it seems to me like the use of ENODEV in fallocate is the
bug, as we don't really return it from any other filesystem operation.

> > I also just ran into another issue where nfserrno translates a large
> > lits of errors into NFSERR_JUKEBOX, but for v4 we'd really want
> > NFSERR_DELAY instead for most of them.
> 
> The distinction is academic as they're both 10008.

Oh, right.  I missed to spot that.

> > Is it time for a version specific errno mapping?
> 
> I'm certainly not opposed if it turns out to be necessary.

A start might be to move nfserrno out of the NFSv2-specific nfsproc
file..
