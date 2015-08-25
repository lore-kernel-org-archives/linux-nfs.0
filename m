Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37222 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223AbbHYXxt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 19:53:49 -0400
Received: by igui7 with SMTP id i7so24097965igu.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 16:53:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4.1/pnfs Improve the packing of struct pnfs_layout_hdr
Date: Tue, 25 Aug 2015 19:53:43 -0400
Message-Id: <1440546826-51922-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate a couple of holes in the structure, and move the 2 atomics
into the same cacheline.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d3979dd1037a..4df87ef3dccc 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -183,15 +183,15 @@ struct pnfs_layoutdriver_type {
 
 struct pnfs_layout_hdr {
 	atomic_t		plh_refcount;
+	atomic_t		plh_outstanding; /* number of RPCs out */
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_bulk_destroy;
 	struct list_head	plh_segs;      /* layout segments list */
-	nfs4_stateid		plh_stateid;
-	atomic_t		plh_outstanding; /* number of RPCs out */
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
-	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_retry_timestamp;
 	unsigned long		plh_flags;
+	nfs4_stateid		plh_stateid;
+	u32			plh_barrier; /* ignore lower seqids */
 	enum pnfs_iomode	plh_return_iomode;
 	loff_t			plh_lwb; /* last write byte for layoutcommit */
 	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
-- 
2.4.3

