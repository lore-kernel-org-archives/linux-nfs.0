Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35486 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754663AbaEHP2y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 11:28:54 -0400
Date: Thu, 8 May 2014 11:28:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: clean up fh_auth usage
Message-ID: <20140508152852.GB20976@fieldses.org>
References: <1399463384-4324-1-git-send-email-hch@lst.de>
 <20140507160118.GD4240@fieldses.org>
 <20140508062723.GA9437@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140508062723.GA9437@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 08, 2014 at 08:27:23AM +0200, Christoph Hellwig wrote:
> On Wed, May 07, 2014 at 12:01:18PM -0400, J. Bruce Fields wrote:
> > On Wed, May 07, 2014 at 01:49:44PM +0200, Christoph Hellwig wrote:
> > > Use fh_fsid when reffering to the fsid part of the filehandle.  The
> > > variable length auth field envisioned in nfsfh wasn't ever implemented.
> > > Also clean up some lose ends around this and document the file handle
> > > format better.
> > 
> > Thanks.
> > 
> > > Btw, why do we even export nfsfh.h to userspace?  The file handle very
> > > much is kernel private, and nothing in nfs-utils include the header
> > > either.
> > 
> > Something like wireshark might use that information?  But anyway that
> > doesn't mean it makes much sense to export.  I'm fine with moving that
> > header.
> 
> Let's just put this version in for now,

OK, doing that.

> I'll do some research if the uapi <linux/nfsd/*.h> headers are used
> anywhere at all, if not I'll send a series to kill them all.

Thanks!

--b.
