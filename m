Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19426 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932900Ab1CWN2G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:06 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 07/12] NFSv4.1: alloc and free commit_buckets
Date: Wed, 23 Mar 2011 09:27:50 -0400
Message-Id: <1300886875-5016-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Create a preallocated list header to hold nfs_pages for each
non-MDS COMMIT destination.  Note this is not necessarily each DS,
but is basically each <DS, fh> pair.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   22 ++++++++++++++++++++++
 fs/nfs/nfs4filelayout.h |    2 ++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9401afd..03ff80c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -503,6 +503,7 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
 
 	dprintk("--> %s\n", __func__);
 	nfs4_fl_put_deviceid(fl->dsaddr);
+	kfree(fl->commit_buckets);
 	_filelayout_free_lseg(fl);
 }
 
@@ -524,6 +525,27 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
 		_filelayout_free_lseg(fl);
 		return NULL;
 	}
+
+	/* This assumes there is only one IOMODE_RW lseg.  What
+	 * we really want to do is have a layout_hdr level
+	 * dictionary of <multipath_list4, fh> keys, each
+	 * associated with a struct list_head, populated by calls
+	 * to filelayout_write_pagelist().
+	 * */
+	if ((!fl->commit_through_mds) && (lgr->range.iomode == IOMODE_RW)) {
+		int i;
+		int size = (fl->stripe_type == STRIPE_SPARSE) ?
+			fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
+
+		fl->commit_buckets = kcalloc(size, sizeof(struct list_head), GFP_KERNEL);
+		if (!fl->commit_buckets) {
+			filelayout_free_lseg(&fl->generic_hdr);
+			return NULL;
+		}
+		fl->number_of_buckets = size;
+		for (i = 0; i < size; i++)
+			INIT_LIST_HEAD(&fl->commit_buckets[i]);
+	}
 	return &fl->generic_hdr;
 }
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index ee0c907..085a354 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -79,6 +79,8 @@ struct nfs4_filelayout_segment {
 	struct nfs4_file_layout_dsaddr *dsaddr; /* Point to GETDEVINFO data */
 	unsigned int num_fh;
 	struct nfs_fh **fh_array;
+	struct list_head *commit_buckets; /* Sort commits to ds */
+	int number_of_buckets;
 };
 
 static inline struct nfs4_filelayout_segment *
-- 
1.7.2.1

