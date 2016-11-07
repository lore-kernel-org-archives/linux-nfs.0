Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from resqmta-po-07v.sys.comcast.net ([96.114.154.166]:41026 "EHLO
        resqmta-po-07v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932347AbcKGRsW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2016 12:48:22 -0500
From: Shuah Khan <shuahkh@osg.samsung.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] fs/nfs: Fix used uninitialized warn in nfs4_slot_seqid_in_use()
Date: Mon,  7 Nov 2016 10:48:16 -0700
Message-Id: <20161107174816.22587-1-shuahkh@osg.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the following warn:

fs/nfs/nfs4session.c: In function ‘nfs4_slot_seqid_in_use’:
fs/nfs/nfs4session.c:203:54: warning: ‘cur_seq’ may be used uninitialized in this function [-Wmaybe-uninitialized]
  if (nfs4_slot_get_seqid(tbl, slotid, &cur_seq) == 0 &&
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~
      cur_seq == seq_nr && test_bit(slotid, tbl->used_slots))
      ~~~~~~~~~~~~~~~~~

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---

 fs/nfs/nfs4session.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index b629730..68e700e 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -196,7 +196,7 @@ static int nfs4_slot_get_seqid(struct nfs4_slot_table  *tbl, u32 slotid,
 static bool nfs4_slot_seqid_in_use(struct nfs4_slot_table *tbl,
 		u32 slotid, u32 seq_nr)
 {
-	u32 cur_seq;
+	u32 cur_seq = 0;
 	bool ret = false;
 
 	spin_lock(&tbl->slot_tbl_lock);
-- 
2.9.3

