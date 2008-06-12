From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/37] NFS: do_setlk(): don't flush caches when we have a
	delegation
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.18972.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61969 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763AbYFLTeC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:02 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJY0lR003043
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:34:01 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7ac89a8..0213c21 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -602,7 +602,8 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 	 * This makes locking act as a cache coherency point.
 	 */
 	nfs_sync_mapping(filp->f_mapping);
-	nfs_zap_caches(inode);
+	if (!nfs_have_delegation(inode, FMODE_READ))
+		nfs_zap_caches(inode);
 out:
 	return status;
 }

