Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33107 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbcEKKV0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2016 06:21:26 -0400
Received: by mail-qk0-f193.google.com with SMTP id q184so2745376qkf.0
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2016 03:21:26 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/9] pnfs: record sequence in pnfs_layout_segment when it's created
Date: Wed, 11 May 2016 06:21:07 -0400
Message-Id: <1462962074-6989-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
References: <1462962074-6989-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In later patches, we're going to teach the client to be more selective
about how it returns layouts. This means keeping a record of what the
stateid's seqid was at the time that the server handed out a layout
segment.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 1 +
 fs/nfs/pnfs.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5b404d926e08..18b6f950e300 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1697,6 +1697,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
+	lseg->pls_seq = be32_to_cpu(res->stateid.seqid);
 
 	spin_lock(&ino->i_lock);
 	if (pnfs_layoutgets_blocked(lo)) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7222d3a35439..361fa5494aa5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,6 +64,7 @@ struct pnfs_layout_segment {
 	struct list_head pls_lc_list;
 	struct pnfs_layout_range pls_range;
 	atomic_t pls_refcount;
+	u32 pls_seq;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
 	struct work_struct pls_work;
-- 
2.5.5

