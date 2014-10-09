Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:31553 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbaJIS1t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2014 14:27:49 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>, <hch@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <smfrench@gmail.com>, <lczerner@redhat.com>
Subject: [PATCH] common: Re-enable testing over NFS
Date: Thu, 9 Oct 2014 14:27:45 -0400
Message-ID: <1412879265-32385-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

83ef157 (common: Check fs consistency on TEST_DEV only when needed) has
_require_test unconditionally return _notrun when testing on an NFS
filesystem, essentially disabling NFS.  This patch changes the code to
validate $TEST_DEV and only call _notrun if validation fails.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 common/rc | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/common/rc b/common/rc
index 34d7c19..868007f 100644
--- a/common/rc
+++ b/common/rc
@@ -1086,8 +1086,14 @@ _require_test()
 {
     case "$FSTYP" in
 	nfs*)
-                 _notrun "requires a test device"
-		 ;;
+		echo $TEST_DEV | grep -q ":/" > /dev/null 2>&1
+		if [ -z "$TEST_DEV" -o "$?" != "0" ]; then
+			_notrun "this test requires a valid \$TEST_DIR"
+		fi
+		if [ ! -d "$TEST_DIR" ]; then
+			_notrun "this test requires a valid \$TEST_DIR"
+		fi
+		;;
 	cifs)
 		echo $TEST_DEV | grep -q "//" > /dev/null 2>&1
 		if [ -z "$TEST_DEV" -o "$?" != "0" ]; then
-- 
2.1.2

