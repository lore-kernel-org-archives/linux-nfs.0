Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:33488 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbbAIOnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 09:43:06 -0500
Received: by mail-qc0-f176.google.com with SMTP id i17so9174342qcy.7
        for <linux-nfs@vger.kernel.org>; Fri, 09 Jan 2015 06:43:04 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 9 Jan 2015 06:42:57 -0800
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH v2 02/10] locks: have locks_release_file use
 flock_lock_file to release generic flock locks
Message-ID: <20150109064257.02f28d85@synchrony.poochiereds.net>
In-Reply-To: <20150109142723.GA30294@infradead.org>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
	<1420742065-28423-3-git-send-email-jlayton@primarydata.com>
	<20150109142723.GA30294@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Jan 2015 06:27:23 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jan 08, 2015 at 10:34:17AM -0800, Jeff Layton wrote:
> > ...instead of open-coding it and removing flock locks directly. This
> > simplifies some coming interim changes in the following patches when
> > we have different file_lock types protected by different spinlocks.
> 
> It took me quite a while to figure out what's going on here, as this
> adds a call to flock_lock_file, but it still keeps the old open coded
> loop around, just with a slightly different WARN_ON.
> 

Right. Eventually that open-coded loop (and the WARN_ON) goes away once
leases get moved into i_flctx in a later patch.

FWIW, there is some messiness involved in this patchset in the interim
stages due to the need to keep things bisectable. Once all of the
patches are applied, the result looks a lot cleaner.

> I'd suggest keeping an open coded loop in locks_remove_flock, which
> should both be more efficient and easier to review.
> 

I don't know. On the one hand, I rather like keeping all of the lock
removal logic in a single spot. On the other hand, we do take and drop
the i_lock/flc_lock more than once with this scheme if there are both
flock locks and leases present at the time of the close. Open coding
the loops would allow us to do that just once.

I'll ponder it a bit more for the next iteration...

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
