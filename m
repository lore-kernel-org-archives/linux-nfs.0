Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143AbaJ1NQz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2014 09:16:55 -0400
From: Eryu Guan <eguan@redhat.com>
To: fstests@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Eryu Guan <eguan@redhat.com>
Subject: [PATCH 2/4] common: add _require_block_device() helper
Date: Tue, 28 Oct 2014 21:16:09 +0800
Message-Id: <1414502171-10319-3-git-send-email-eguan@redhat.com>
In-Reply-To: <1414502171-10319-1-git-send-email-eguan@redhat.com>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add _require_block_device() helper and use it in _require_dm_flakey()
and generic/076.

_require_dm_flakey() assumes $SCRATCH_DEV is a block device, now it can
also be a NFS export.

generic/076 does "cat $SCRATCH_DEV" which will fail when testing on NFS.

Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 common/rc         | 15 +++++++++++++++
 tests/generic/076 |  1 +
 2 files changed, 16 insertions(+)

diff --git a/common/rc b/common/rc
index 8738da7..42f00cb 100644
--- a/common/rc
+++ b/common/rc
@@ -1237,10 +1237,25 @@ _require_command()
     [ -n "$1" -a -x "$1" ] || _notrun "$_cmd utility required, skipped this test"
 }
 
+# this test requires the device to be valid block device
+# $1 - device
+_require_block_device()
+{
+	if [ -z "$1" ]; then
+		echo "Usage: _require_block_device <dev>" 1>&2
+		exit 1
+	fi
+	if [ "`_is_block_dev $SCRATCH_DEV`" == "" ]; then
+		_notrun "require $1 to be valid block disk"
+	fi
+}
+
 # this test requires the device mapper flakey target
 #
 _require_dm_flakey()
 {
+    # require SCRATCH_DEV to be a valid block device
+    _require_block_device $SCRATCH_DEV
     _require_command $DMSETUP_PROG
 
     modprobe dm-flakey >/dev/null 2>&1
diff --git a/tests/generic/076 b/tests/generic/076
index 02af762..aa0aae0 100755
--- a/tests/generic/076
+++ b/tests/generic/076
@@ -56,6 +56,7 @@ _supported_fs generic
 _supported_os IRIX Linux
 
 _require_scratch
+_require_block_device $SCRATCH_DEV
 
 echo "*** init fs"
 
-- 
1.8.3.1

