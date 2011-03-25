Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:47791 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753072Ab1CYXEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 19:04:53 -0400
Date: Sat, 26 Mar 2011 10:04:50 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: NFS page states & writeback
Message-ID: <20110325230450.GR26611@dastard>
References: <20110325012803.GA25052@quack.suse.cz>
 <20110325044754.GK26611@dastard>
 <20110325222458.GB26932@quack.suse.cz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110325222458.GB26932@quack.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 25, 2011 at 11:24:58PM +0100, Jan Kara wrote:
> So I think we could stop doing writeback when we have done the transition
> of pages from Dirty to Writeback state. We should only make sure someone
> kicks the background writeback again when there are enough unstable pages
> to be worth a commit. This tends to happen from balance_dirty_pages() or
> in the worst case when flusher thread awakes to check for old inodes to
> flush. But we can also kick the flusher thread from NFS when we transition
> enough pages which would seem rather robust to me. I'll try to write a
> patch in this direction.

I think making the background writeback commits triggered by NFS
write completion is a good way to proceed. A write request
completion gives us a guaranteed context to determine if we need to
issue a commit or not and should mostly avoid the need for polling
or some external event to trigger a threshold check.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
