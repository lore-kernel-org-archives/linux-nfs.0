Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:52383 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751738AbdKAMJV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Nov 2017 08:09:21 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] 4.1 server tests: make DELEG8 also check that an operation using a revoked stateid returns revoked status
Date: Wed,  1 Nov 2017 08:08:55 -0400
Message-Id: <20171101120855.65421-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 nfs4.1/server41tests/st_delegation.py | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index a5066926a89d..c5959f6cda84 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -186,6 +186,8 @@ def testDelegRevocation(t, env):
         # depend on the above compound waiting no longer than the
         # server's lease period:
         res = sess1.compound([])
+    res = sess1.compound([op.putfh(fh), op.read(delegstateid, 0, 1000)])
+    check(res, NFS4ERR_DELEG_REVOKED, "Read with a revoked delegation")
     slot, seq_op = sess1._prepare_compound({})
     res = sess1.c.compound([seq_op])
     flags = res.resarray[0].sr_status_flags;
-- 
2.10.1

