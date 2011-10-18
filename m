Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga09.intel.com ([134.134.136.24]:29427 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab1JRIxz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Oct 2011 04:53:55 -0400
Date: Tue, 18 Oct 2011 16:53:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>,
        Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>,
        Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>,
        Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>,
        linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC][PATCH 2/2] nfs: scale writeback threshold proportional
 to dirty threshold
Message-ID: <20111018085351.GB27805@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
 <20111010131051.GA16847@localhost>
 <20111010131154.GB16847@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111010131154.GB16847@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An update from Feng:

Subject: nfs: fix a bug about adjusting nfs_congestion_kb
Date: Tue Oct 18 12:47:58 CST 2011

From: "Tang, Feng" <feng.tang@intel.com>

The VM dirty_thresh may be set to very small(even 0) by wired user, in
such case, nfs_congestion_kb may be adjusted to 0, will cause the normal
NFS write function get congested and deaklocked. So let's set the bottom
line of nfs_congestion_kb to 128kb.

Signed-off-by: Feng Tang <feng.tang@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next.orig/fs/nfs/write.c	2011-10-17 16:07:40.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-10-18 12:47:46.000000000 +0800
@@ -1814,6 +1814,7 @@ void nfs_update_congestion_thresh(void)
 	 */
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 	dirty_thresh <<= PAGE_SHIFT - 10;
+	dirty_thresh += 1024;
 
 	if (nfs_congestion_kb > dirty_thresh / 8)
 		nfs_congestion_kb = dirty_thresh / 8;
