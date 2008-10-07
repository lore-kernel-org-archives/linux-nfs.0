From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 29/30] NFS: Don't use range_cyclic for data integrity syncs
Date: Tue, 07 Oct 2008 18:19:54 -0400
Message-ID: <20081007221954.20945.51018.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756340AbYJGWcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:53 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0l025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:49 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is more efficient to write linearly starting from the beginning of the
file.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3229e21..9f98458 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1427,8 +1427,9 @@ static int nfs_write_mapping(struct address_space *mapping, int how)
 		.bdi = mapping->backing_dev_info,
 		.sync_mode = WB_SYNC_NONE,
 		.nr_to_write = LONG_MAX,
+		.range_start = 0,
+		.range_end = LLONG_MAX,
 		.for_writepages = 1,
-		.range_cyclic = 1,
 	};
 	int ret;
 

