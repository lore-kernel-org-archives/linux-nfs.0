Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43438 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752250Ab1BPGQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 01:16:09 -0500
Date: Wed, 16 Feb 2011 17:15:55 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Small O_SYNC writes are no longer NFS_DATA_SYNC
Message-ID: <20110216171555.6642c630@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Trond,
 I wonder if I might get your help/advice on an issue with NFS.

 It seems that NFS_DATA_SYNC is hardly used at all currently.  It is used for
 O_DIRECT writes and for writes 'for_reclaim', and for handling some error
 conditions, but that is about it.

 This appears to be a regression.

 Back in 2005, commit ab0a3dbedc5 in 2.6.13 says:

    [PATCH] NFS: Write optimization for short files and small O_SYNC writes.
    
     Use stable writes if we can see that we are only going to put a single
     write on the wire.

 which seems like a sensible optimisation, and we have a customer which
 values it.  Very roughly, they have an NFS server which optimises 'unstable'
 writes for throughput and 'stable' writes for latency - these seems like a
 reasonable approach.
 With a 2.6.16 kernel an application which generates many small sync writes
 gets adequate performance.  In 2.6.32 they see unstable writes followed by
 commits, which cannot be (or at least aren't) optimised as well.

 It seems this was changed by commit c63c7b0513953

    NFS: Fix a race when doing NFS write coalescing
    
 in 2.6.22.

 Is it possible/easy/desirable to get this behaviour back.  i.e. to use
 NFS_DATA_SYNC at least on sub-page writes triggered by a write to an
 O_SYNC file.

 My (possibly naive) attempt is as follows.  It appears to work as I expect
 (though it still uses SYNC for 1-page writes) but I'm not confident that it
 is "right".

Thanks,

NeilBrown

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 10d648e..392bfa8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -178,6 +178,9 @@ static int wb_priority(struct writeback_control *wbc)
 		return FLUSH_HIGHPRI | FLUSH_STABLE;
 	if (wbc->for_kupdate || wbc->for_background)
 		return FLUSH_LOWPRI;
+	if (wbc->sync_mode == WB_SYNC_ALL &&
+	    (wbc->range_end - wbc->range_start) < PAGE_SIZE)
+		return FLUSH_STABLE;
 	return 0;
 }
 
