Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:49052 "EHLO
        elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753732AbeC1WgM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 18:36:12 -0400
Received: from [67.170.185.135] (helo=FRANKSTHINKPAD)
        by elasmtp-dupuy.atl.sa.earthlink.net with esmtpa (Exim 4)
        (envelope-from <ffilzlnx@mindspring.com>)
        id 1f1JYJ-0003dY-TW
        for linux-nfs@vger.kernel.org; Wed, 28 Mar 2018 18:28:20 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: <linux-nfs@vger.kernel.org>
Subject: [pynfs] [PATCH 1/3] Add required RECLAIM_COMPLETE ops for new clients in
Date: Wed, 28 Mar 2018 15:28:20 -0700
Message-ID: <00e001d3c6e4$13ed2c70$3bc78550$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
---
 nfs4.1/server41tests/st_destroy_session.py | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/nfs4.1/server41tests/st_destroy_session.py
b/nfs4.1/server41tests/st_destroy_session.py
index 435ef4b..c247434 100644
--- a/nfs4.1/server41tests/st_destroy_session.py
+++ b/nfs4.1/server41tests/st_destroy_session.py
@@ -51,6 +51,7 @@ def testDestroy2(t, env):
         return res
     c = env.c1.new_client(env.testname(t))
     sess1 = c.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
     res = c.c.compound([op.destroy_session(sess1.sessionid)])
     sess2 = c.create_session()
     res = create_file(sess2, env.testname(t),
@@ -63,6 +64,7 @@ def testDestroy2(t, env):
         fail("Could not get delegation")
     c2 = env.c1.new_client("%s_2" % env.testname(t))
     sess3 = c2.create_session()
+    sess3.compound([op.reclaim_complete(FALSE)])
     claim = open_claim4(CLAIM_NULL, env.testname(t))
     owner = open_owner4(0, "My Open Owner 2")
     how = openflag4(OPEN4_NOCREATE)
@@ -100,6 +102,7 @@ def testDestroy3(t, env):
         return res
     c = env.c1.new_client(env.testname(t))
     sess1 = c.create_session()
+    sess1.compound([op.reclaim_complete(FALSE)])
     res = create_file(sess1, env.testname(t),
                       access=OPEN4_SHARE_ACCESS_READ |
                       OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
@@ -112,6 +115,7 @@ def testDestroy3(t, env):
     recall.happened = False
     c2 = env.c1.new_client("%s_2" % env.testname(t))
     sess2 = c2.create_session()
+    sess2.compound([op.reclaim_complete(FALSE)])
     claim = open_claim4(CLAIM_NULL, env.testname(t))
     owner = open_owner4(0, "My Open Owner 2")
     how = openflag4(OPEN4_NOCREATE)
-- 
2.5.5




