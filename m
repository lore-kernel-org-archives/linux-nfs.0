Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18221 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012Ab1I2S7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 14:59:43 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 2/3] NFSD: Added fault injection script
Date: Thu, 29 Sep 2011 14:59:24 -0400
Message-Id: <1317322765-19094-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1317322765-19094-1-git-send-email-bjschuma@netapp.com>
References: <1317322765-19094-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

This script provides a convenient way to use the NFSD fault injection
framework.  Fault injection writes to dmesg using the KERN_INFO flag, so
this script will compare the before and after output of `dmesg` to show
the user what happened

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 tools/nfs/inject_fault |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)
 create mode 100644 tools/nfs/inject_fault

diff --git a/tools/nfs/inject_fault b/tools/nfs/inject_fault
new file mode 100644
index 0000000..4869bdd
--- /dev/null
+++ b/tools/nfs/inject_fault
@@ -0,0 +1,45 @@
+#!/bin/bash
+
+# Check that debugfs has been mounted
+DEBUGFS=`cat /proc/mounts | grep debugfs`
+if [ "$DEBUGFS" == "" ]; then
+	echo "debugfs does not appear to be mounted!"
+	echo "Please mount debugfs and try again"
+	exit 1
+fi
+
+# Check that the fault injection directory exists
+DEBUGDIR=`echo $DEBUGFS | awk '{print $2}'`/nfsd
+if [ ! -d "$DEBUGDIR" ]; then
+	echo "$DEBUGDIR does not exist"
+	echo "Check that your .config selects CONFIG_NFSD_FAULT_INJECTION"
+	exit 1
+fi
+
+function help()
+{
+	echo "Usage $0 injection_type [count]"
+	echo ""
+	echo "Injection types are:"
+	ls $DEBUGDIR
+	exit 1
+}
+
+if [ $# == 0 ]; then
+	help
+elif [ ! -f $DEBUGDIR/$1 ]; then
+	help
+elif [ $# != 2 ]; then
+	COUNT=0
+else
+	COUNT=$2
+fi
+
+BEFORE=`mktemp`
+AFTER=`mktemp`
+dmesg > $BEFORE
+echo $COUNT > $DEBUGDIR/$1
+dmesg > $AFTER
+# Capture lines that only exist in the $AFTER file
+diff $BEFORE $AFTER | grep ">"
+rm -f $BEFORE $AFTER
-- 
1.7.6.4

