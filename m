Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:44818 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbaEHG10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2014 02:27:26 -0400
Date: Thu, 8 May 2014 08:27:23 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: clean up fh_auth usage
Message-ID: <20140508062723.GA9437@lst.de>
References: <1399463384-4324-1-git-send-email-hch@lst.de> <20140507160118.GD4240@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140507160118.GD4240@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 07, 2014 at 12:01:18PM -0400, J. Bruce Fields wrote:
> On Wed, May 07, 2014 at 01:49:44PM +0200, Christoph Hellwig wrote:
> > Use fh_fsid when reffering to the fsid part of the filehandle.  The
> > variable length auth field envisioned in nfsfh wasn't ever implemented.
> > Also clean up some lose ends around this and document the file handle
> > format better.
> 
> Thanks.
> 
> > Btw, why do we even export nfsfh.h to userspace?  The file handle very
> > much is kernel private, and nothing in nfs-utils include the header
> > either.
> 
> Something like wireshark might use that information?  But anyway that
> doesn't mean it makes much sense to export.  I'm fine with moving that
> header.

Let's just put this version in for now, I'll do some research if the
uapi <linux/nfsd/*.h> headers are used anywhere at all, if not I'll
send a series to kill them all.

