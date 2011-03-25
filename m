Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37372 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203Ab1CYHCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2011 03:02:45 -0400
Date: Fri, 25 Mar 2011 15:00:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Dave Chinner <david@fromorbit.com>
Subject: Re: NFS page states & writeback
Message-ID: <20110325070054.GA5970@localhost>
References: <20110325012803.GA25052@quack.suse.cz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110325012803.GA25052@quack.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jan,

On Fri, Mar 25, 2011 at 09:28:03AM +0800, Jan Kara wrote:
>   Hi,
> 
>   while working on changes to balance_dirty_pages() I was investigating why
> NFS writeback is *so* bumpy when I do not call writeback_inodes_wb() from
> balance_dirty_pages(). Take a single dd writing to NFS. What I can
> see is that we quickly accumulate dirty pages upto limit - ~700 MB on that
> machine. So flusher thread starts working and in an instant all these ~700
> MB transition from Dirty state to Writeback state. Then, as server acks

That can be fixed by the following patch:

        [PATCH 09/27] nfs: writeback pages wait queue
        https://lkml.org/lkml/2011/3/3/79

> writes, Writeback pages slowly change to Unstable pages (at 100 MB/s rate
> let's say) and then at one moment (commit to server happens) all pages
> transition from Unstable to Clean state - the cycle begins from the start.
> 
> The reason for this behavior seems to be a flaw in the logic in
> over_bground_thresh() which checks:
> global_page_state(NR_FILE_DIRTY) +
>       global_page_state(NR_UNSTABLE_NFS) > background_thresh
> So at the moment all pages are turned Writeback, flusher thread goes to
> sleep and doesn't do any background writeback, until we have accumulated
> enough Stable pages to get over background_thresh. But NFS needs to have
> ->write_inode() called so that it can sent commit requests to the server.
> So effectively we end up sending commit only when background_thresh Unstable
> pages have accumulated which creates the bumpyness. Previously this wasn't
> a problem because balance_dirty_pages() ended up calling ->write_inode()
> often enough for NFS to send commit requests reasonably often.
> 
> Now I wouldn't write so long email about this if I knew how to cleanly fix
> the check ;-). One way to "fix" the check would be to add there Writeback
> pages:
> NR_FILE_DIRTY + NR_WRITEBACK + NR_UNSTABLE_NFS > background_thresh
> 
> This would work in the sense that it would keep flusher thread working but
> a) for normal filesystems it would be working even if there's potentially
> nothing to do (or it is not necessary to do anything)
> b) NFS is picky when it sends commit requests (inode has to have more
> Stable pages than Writeback pages if I'm reading the code in
> nfs_commit_unstable_pages() right) so flusher thread may be working but
> nothing really happens until enough stable pages accumulate.
> 
> A check which kind of works but looks a bit hacky and is not perfect when
> there are multiple files is:
> NR_FILE_DIRTY + NR_UNSTABLE_NFS > background_thresh ||
> NR_UNSTABLE_NFS > NR_WRITEBACK (to match what NFS does)

There is another patch in the series "[PATCH 12/27] nfs: lower
writeback threshold proportionally to dirty threshold" that tries to
limit the NFS write queue size. For the system default 10%/20%
background/dirty ratios, it has the nice effect of keeping

        nr_writeback < 5%

So when the system is dirty exceeded, the background flusher won't
quit because

        nr_dirty + nr_unstable > 10%

Thanks,
Fengguang
