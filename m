Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49028 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbbAIOq7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 09:46:59 -0500
Date: Fri, 9 Jan 2015 06:46:58 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [PATCH v2 02/10] locks: have locks_release_file use
 flock_lock_file to release generic flock locks
Message-ID: <20150109144658.GA12860@infradead.org>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
 <1420742065-28423-3-git-send-email-jlayton@primarydata.com>
 <20150109142723.GA30294@infradead.org>
 <20150109064257.02f28d85@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150109064257.02f28d85@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 06:42:57AM -0800, Jeff Layton wrote:
> > I'd suggest keeping an open coded loop in locks_remove_flock, which
> > should both be more efficient and easier to review.
> > 
> 
> I don't know. On the one hand, I rather like keeping all of the lock
> removal logic in a single spot. On the other hand, we do take and drop
> the i_lock/flc_lock more than once with this scheme if there are both
> flock locks and leases present at the time of the close. Open coding
> the loops would allow us to do that just once.
> 
> I'll ponder it a bit more for the next iteration...

FYI, I like the split into locks_remove_flock, it's just that
flock_lock_file is giant mess.  If it helps you feel free to keep
it as-is for now and just document what you did in the changelog in
detail.
