Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:55696 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbbI2WCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2015 18:02:48 -0400
Date: Tue, 29 Sep 2015 15:02:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: mhocko@kernel.org
Cc: <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>,
        "Theodore Ts'o" <tytso@mit.edu>, Ming Lei <ming.lei@canonical.com>,
        Andreas Dilger <andreas.dilger@intel.com>,
        Oleg Drokin <oleg.drokin@intel.com>, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org,
        xfs@oss.sgi.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, fs: Obey gfp_mapping for add_to_page_cache
Message-Id: <20150929150246.286cc6013bce3eec170376aa@linux-foundation.org>
In-Reply-To: <1443193461-31402-1-git-send-email-mhocko@kernel.org>
References: <1443193461-31402-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 25 Sep 2015 17:04:21 +0200 mhocko@kernel.org wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> 6afdb859b710 ("mm: do not ignore mapping_gfp_mask in page cache
> allocation paths) has caught some users of hardcoded GFP_KERNEL
> used in the page cache allocation paths. This, however, wasn't complete
> and there were others which went unnoticed.
> 
> Dave Chinner has reported the following deadlock for xfs on loop device:
> : With the recent merge of the loop device changes, I'm now seeing
> : XFS deadlock on my single CPU, 1GB RAM VM running xfs/073.
> :
> : The deadlocked is as follows:
> :
> : kloopd1: loop_queue_read_work
> :       xfs_file_iter_read
> :       lock XFS inode XFS_IOLOCK_SHARED (on image file)
> :       page cache read (GFP_KERNEL)
> :       radix tree alloc
> :       memory reclaim
> :       reclaim XFS inodes
> :       log force to unpin inodes
> :       <wait for log IO completion>
> :
> : xfs-cil/loop1: <does log force IO work>
> :       xlog_cil_push
> :       xlog_write
> :       <loop issuing log writes>
> :               xlog_state_get_iclog_space()
> :               <blocks due to all log buffers under write io>
> :               <waits for IO completion>
> :
> : kloopd1: loop_queue_write_work
> :       xfs_file_write_iter
> :       lock XFS inode XFS_IOLOCK_EXCL (on image file)
> :       <wait for inode to be unlocked>
> :
> : i.e. the kloopd, with it's split read and write work queues, has
> : introduced a dependency through memory reclaim. i.e. that writes
> : need to be able to progress for reads make progress.
> :
> : The problem, fundamentally, is that mpage_readpages() does a
> : GFP_KERNEL allocation, rather than paying attention to the inode's
> : mapping gfp mask, which is set to GFP_NOFS.
> :
> : The didn't used to happen, because the loop device used to issue
> : reads through the splice path and that does:
> :
> :       error = add_to_page_cache_lru(page, mapping, index,
> :                       GFP_KERNEL & mapping_gfp_mask(mapping));
> 
> This has changed by aa4d86163e4 (block: loop: switch to VFS ITER_BVEC).

xfs-on-loop deadlocks since April would appear to warrant a -stable
backport, yes?

> this is a rebase on top of the current mmotm
> (2015-09-22-15-28)

So I've redone the patch against current mainline.
