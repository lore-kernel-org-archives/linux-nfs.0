Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:36733 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbbFBK7K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jun 2015 06:59:10 -0400
Received: by qgf2 with SMTP id 2so57180925qgf.3
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jun 2015 03:59:10 -0700 (PDT)
Message-ID: <556D8C75.4050409@gmail.com>
Date: Tue, 02 Jun 2015 18:59:01 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, kinglongmee@gmail.com,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 2/2] nfs: Initialize cb_sequenceres information before validate_seqid()
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For a cb_layoutrecall replay, nfsd got CB_SEQUENCE status of zero,
but all informations of cb_sequenceres are zero too !!!

validate_seqid() return NFS4ERR_RETRY_UNCACHED_REP for a replay,
and skip the initlize cb_sequenceres.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_proc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 7e9653a..17a5c57 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -445,6 +445,13 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		goto out;
 	}
 
+	memcpy(&res->csr_sessionid, &args->csa_sessionid,
+	       sizeof(res->csr_sessionid));
+	res->csr_sequenceid = args->csa_sequenceid;
+	res->csr_slotid = args->csa_slotid;
+	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+
 	status = validate_seqid(tbl, args);
 	spin_unlock(&tbl->slot_tbl_lock);
 	if (status)
@@ -462,13 +469,6 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		goto out;
 	}
 
-	memcpy(&res->csr_sessionid, &args->csa_sessionid,
-	       sizeof(res->csr_sessionid));
-	res->csr_sequenceid = args->csa_sequenceid;
-	res->csr_slotid = args->csa_slotid;
-	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
-	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
-
 	/*
 	 * RFC5661 20.9.3
 	 * If CB_SEQUENCE returns an error, then the state of the slot
-- 
2.4.2

