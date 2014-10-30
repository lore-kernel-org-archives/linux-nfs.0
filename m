Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:6752 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759446AbaJ3NHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2014 09:07:40 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>, <hch@infradead.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] common:  Fixes for testing NFS over IPv6
Date: Thu, 30 Oct 2014 09:07:36 -0400
Message-ID: <1414674456-9097-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing NFS over IPv6, the user will set a $TEST_DEV of the form
[fe80::42]:/export.  The use of square brackets surrounding the IPv6
address is an accepted convention, but grep and awk think that our IPv6
address is actually a regex and tries to evaluate it instead.  The
result is that xfstests reports our filesystem "is busy or already
mounted".

This patch fixes the IPv6 problem by telling awk and grep to treat
$TEST_DEV as a fixed string rather than a regex.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 common/rc | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/common/rc b/common/rc
index 747cf72..9f17564 100644
--- a/common/rc
+++ b/common/rc
@@ -809,14 +809,16 @@ _df_device()
 	exit 1
     fi
 
+    # Note that we use "==" here so awk doesn't try to interpret an NFS over
+    # IPv6 server as a regular expression.
     $DF_PROG 2>/dev/null | $AWK_PROG -v what=$1 '
-        match($1,what) && NF==1 {
+        ($1==what) && (NF==1) {
             v=$1
             getline
             print v, $0
             exit
         }
-        match($1,what) {
+        ($1==what) {
             print
             exit
         }
@@ -1132,10 +1134,12 @@ _require_test()
     esac
 
     # mounted?
-    if _mount | grep -q $TEST_DEV
+    # Note that we use -F here so grep doesn't try to interpret an NFS over
+    # IPv6 server as a regular expression.
+    if _mount | grep -F -q $TEST_DEV
     then
         # if it's mounted, make sure its on $TEST_DIR
-        if ! _mount | grep $TEST_DEV | grep -q $TEST_DIR
+        if ! _mount | grep -F $TEST_DEV | grep -q $TEST_DIR
         then
             echo "\$TEST_DEV is mounted but not on \$TEST_DIR - aborting"
             exit 1
-- 
2.1.3

