Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:50901 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932687AbcHaMjQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 08:39:16 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1: work around -Wmaybe-uninitialized warning
Date: Wed, 31 Aug 2016 14:39:01 +0200
Message-Id: <20160831123911.3467676-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A bugfix introduced a harmless gcc warning in nfs4_slot_seqid_in_use:

fs/nfs/nfs4session.c:203:54: error: 'cur_seq' may be used uninitialized in this function [-Werror=maybe-uninitialized]

gcc is not smart enough to conclude that the IS_ERR/PTR_ERR pair
results in a nonzero return value here. Using PTR_ERR_OR_ZERO()
instead makes this clear to the compiler.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e09c978aae5b ("NFSv4.1: Fix Oopsable condition in server callback races")
---
 fs/nfs/nfs4session.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

The patch that caused this just came in for v4.8-rc5. As the warning
is now disabled by default and this is harmless, this can probably
get queued for v4.9 instead.

I mentioned earlier that I got the new warning for net-next, but
failed to notice that it had come from mainline instead.

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index b62973045a3e..150c5a1879bf 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -178,12 +178,14 @@ static int nfs4_slot_get_seqid(struct nfs4_slot_table  *tbl, u32 slotid,
 	__must_hold(&tbl->slot_tbl_lock)
 {
 	struct nfs4_slot *slot;
+	int ret;
 
 	slot = nfs4_lookup_slot(tbl, slotid);
-	if (IS_ERR(slot))
-		return PTR_ERR(slot);
-	*seq_nr = slot->seq_nr;
-	return 0;
+	ret = PTR_ERR_OR_ZERO(slot);
+	if (!ret)
+		*seq_nr = slot->seq_nr;
+
+	return ret;
 }
 
 /*
-- 
2.9.0

