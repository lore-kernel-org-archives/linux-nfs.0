Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45976 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab2BOVfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 16:35:01 -0500
Received: by mail-yx0-f174.google.com with SMTP id m8so959437yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 13:35:01 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/13] NFS: Fix comparison signage warnings with slot ID
 computations
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 16:35:00 -0500
Message-ID: <20120215213500.3254.16678.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To make nfs4proc.c compile cleanly, address the following compiler
warnings:

fs/nfs/nfs4proc.c: In function ‘nfs4_free_slot’:
fs/nfs/nfs4proc.c:371:2: warning: comparison between signed and
		unsigned integer expressions [-Wsign-compare]
fs/nfs/nfs4proc.c: In function ‘nfs4_reset_slot_table’:
fs/nfs/nfs4proc.c:5000:15: warning: comparison between signed and
		unsigned integer expressions [-Wsign-compare]
fs/nfs/nfs4proc.c: In function ‘nfs4_init_slot_table’:
fs/nfs/nfs4proc.c:5064:2: warning: comparison between signed and
		unsigned integer expressions [-Wsign-compare]

Why is max_reqs always u32, but nfs4_slot_table.max_slots a signed
integer?

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d9f4d78..5ff9c5a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -368,7 +368,7 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
 	int free_slotid = free_slot - tbl->slots;
 	int slotid = free_slotid;
 
-	BUG_ON(slotid < 0 || slotid >= NFS4_MAX_SLOT_TABLE);
+	BUG_ON(slotid < 0 || slotid >= (int)NFS4_MAX_SLOT_TABLE);
 	/* clear used bit in bitmap */
 	__clear_bit(slotid, tbl->used_slots);
 
@@ -4997,7 +4997,7 @@ static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
 		max_reqs, tbl->max_slots);
 
 	/* Does the newly negotiated max_reqs match the existing slot table? */
-	if (max_reqs != tbl->max_slots) {
+	if (max_reqs != (u32)tbl->max_slots) {
 		ret = -ENOMEM;
 		new = kmalloc(max_reqs * sizeof(struct nfs4_slot),
 			      GFP_NOFS);
@@ -5056,7 +5056,7 @@ static void nfs4_destroy_slot_tables(struct nfs4_session *session)
  * Initialize slot table
  */
 static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
-		int max_slots, int ivalue)
+		u32 max_slots, int ivalue)
 {
 	struct nfs4_slot *slot;
 	int ret = -ENOMEM;

