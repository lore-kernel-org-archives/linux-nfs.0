Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:52306 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964923AbcJQWHy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2016 18:07:54 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 06/28] NFSv4.1: work around -Wmaybe-uninitialized warning
Date: Tue, 18 Oct 2016 00:05:35 +0200
Message-Id: <20161017220557.1688282-6-arnd@arndb.de>
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A bugfix introduced a harmless gcc warning in nfs4_slot_seqid_in_use
if we enable -Wmaybe-uninitialized again:

fs/nfs/nfs4session.c:203:54: error: 'cur_seq' may be used uninitialized in this function [-Werror=maybe-uninitialized]

gcc is not smart enough to conclude that the IS_ERR/PTR_ERR pair
results in a nonzero return value here. Using PTR_ERR_OR_ZERO()
instead makes this clear to the compiler.

The warning originally did not appear in v4.8 as it was globally
disabled, but the bugfix that introduced the warning got backported
to stable kernels which again enable it, and this is now the only
warning in the v4.7 builds.

Fixes: e09c978aae5b ("NFSv4.1: Fix Oopsable condition in server callback races")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
---
First submitted on Aug 31, but ended up not getting applied then
as the warning was disabled in v4.8-rc

 fs/nfs/nfs4session.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index b629730..150c5a1 100644
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

