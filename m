Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:59193 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbbAGKa3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 05:30:29 -0500
Date: Wed, 7 Jan 2015 11:30:26 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 02/18] fs: add FL_LAYOUT lease type
Message-ID: <20150107103026.GB28783@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-3-git-send-email-hch@lst.de> <20150106104652.49078615@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150106104652.49078615@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 10:46:52AM -0800, Jeff Layton wrote:
> So with the current code, layouts are always whole-file?

layouts aren't whole-file, but layout recalls are.

> Tracking layouts as a lease-like object seems reasonable, but I'm not
> 100% thrilled with overloading all of the lease code with this. Perhaps
> it should be its own sort of object with a separate API to manage them?
> That would also make it easier to support layouts that are not for the
> entire file.
> 
> To that end, it might be nice to hold off on taking this until we
> deprecate the i_flock list as we can then give layouts their own
> list_head in the file_lock_context. It would also make it easier to use
> a new sort of object to represent layouts.
> 
> I just cleaned up that patchset last week, and will re-post it soon
> once I give it a bit of testing this week.

I'm happy to add support to your reworked locks/leases/etc handling
for this.  As for which one gets merged first I'd say which one
is in a mergeable shape earlier.  If you're confident to get your
rework in ASAP I'm happy to rebase it on top, otherwise doing it
the other way around sounds easier.
