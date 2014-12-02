Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbaLBEce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Dec 2014 23:32:34 -0500
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Anna.Schumaker@netapp.com,
        Eryu Guan <eguan@redhat.com>
Subject: [PATCH] common: recognise NFS export over IPv6 in _require_scratch_nocheck()
Date: Tue,  2 Dec 2014 12:31:53 +0800
Message-Id: <1417494713-25937-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit

73dfa4a common: Fixes for testing NFS over IPv6

adds NFS over IPv6 support, and commit

76c5f3c common: re-enable tests that require scratch dev on NFS

enables NFS tests on scratch device.

Now do the same updates to _require_scratch_nocheck() to enable NFS over
IPv6 support on scratch device.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/common/rc b/common/rc
index d5e3aff..525d9d4 100644
--- a/common/rc
+++ b/common/rc
@@ -1078,10 +1078,12 @@ _require_scratch_nocheck()
     esac
 
     # mounted?
-    if _mount | grep -q $SCRATCH_DEV
+    # Note that we use -F here so grep doesn't try to interpret an NFS over
+    # IPv6 server as a regular expression.
+    if _mount | grep -F -q $SCRATCH_DEV
     then
         # if it's mounted, make sure its on $SCRATCH_MNT
-        if ! _mount | grep $SCRATCH_DEV | grep -q $SCRATCH_MNT
+        if ! _mount | grep -F $SCRATCH_DEV | grep -q $SCRATCH_MNT
         then
             echo "\$SCRATCH_DEV is mounted but not on \$SCRATCH_MNT - aborting"
             exit 1
-- 
1.9.3

