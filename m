Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f45.google.com ([209.85.160.45]:53270 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932300Ab3LXC65 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Dec 2013 21:58:57 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so5951216pbb.18
        for <linux-nfs@vger.kernel.org>; Mon, 23 Dec 2013 18:58:56 -0800 (PST)
Message-ID: <52B8F86A.1040509@gmail.com>
Date: Tue, 24 Dec 2013 10:58:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4.1: check whether old session is discard for EID5f
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/server41tests/st_exchange_id.py | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
index c31af95..d2c0c97 100644
--- a/nfs4.1/server41tests/st_exchange_id.py
+++ b/nfs4.1/server41tests/st_exchange_id.py
@@ -244,7 +244,12 @@ def testNoUpdate101(t, env):
     # Old session state should not be discarded until confirm:
     res = sess1.compound([])
     check(res)
-    # FIXME - more checks here
+
+    # Old session state should be discarded after confirm:
+    sess2 = c2.create_session()
+    check(res)
+    res = sess1.compound([])
+    check(res, NFS4ERR_BADSESSION)
 
 def testNoUpdate101b(t, env):
     """
-- 
1.8.4.2
