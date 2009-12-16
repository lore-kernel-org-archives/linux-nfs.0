From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] nfs-utils: add initial tests for statd that run via "make check"
Date: Wed, 16 Dec 2009 14:40:40 -0500
Message-ID: <1260992440-8234-3-git-send-email-jlayton@redhat.com>
References: <1260992440-8234-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964962AbZLPTkp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2009 14:40:45 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBGJeio2006582
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2009 14:40:44 -0500
In-Reply-To: <1260992440-8234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Leverage the support that automake already has for running tests via
make check. Add a simple test that just checks that the statd mon and
unmon calls actually work.

Adding more tests should be a simple matter of adding new scripts
exit 0 on success and non-zero on fail, and adding those to the
Makefile.am.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 tests/Makefile.am                    |    2 +
 tests/t0001-statd-basic-mon-unmon.sh |   55 ++++++++++++++++++++++++++++++++++
 tests/test-lib.sh                    |   41 +++++++++++++++++++++++++
 3 files changed, 98 insertions(+), 0 deletions(-)
 create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
 create mode 100755 tests/test-lib.sh

diff --git a/tests/Makefile.am b/tests/Makefile.am
index 997ac51..634fb7b 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -3,3 +3,5 @@
 SUBDIRS = statdtest
 
 MAINTAINERCLEANFILES = Makefile.in
+
+TESTS = t0001-statd-basic-mon-unmon.sh
diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001-statd-basic-mon-unmon.sh
new file mode 100755
index 0000000..d5dffc5
--- /dev/null
+++ b/tests/t0001-statd-basic-mon-unmon.sh
@@ -0,0 +1,55 @@
+#!/bin/bash
+#
+# statd_basic_mon_unmon -- test basic mon/unmon functionality with statd
+#
+# Copyright (C) 2009  Red Hat, Jeff Layton <jlayton@redhat.com>
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License
+# as published by the Free Software Foundation; either version 2
+# of the License, or (at your option) any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation, Inc.,
+# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+#
+
+. ./test-lib.sh
+
+start_statd
+if [ $? -ne 0 ]; then
+	echo "FAIL: problem starting statd"
+	exit 1
+fi
+
+COOKIE=`echo $$ | md5sum | cut -d' ' -f1`
+MON_NAME=`hostname`
+
+statdtest mon $MON_NAME $COOKIE
+if [ $? -ne 0 ]; then
+	echo "FAIL: mon failed"
+	kill_statd
+	exit 1
+fi
+
+grep -q $COOKIE /var/lib/nfs/statd/sm/$MON_NAME 
+if [ $? -ne 0 ]; then
+	echo "FAIL: $COOKIE not present in monitor file"
+	kill_statd
+	exit 1
+fi
+
+statdtest unmon $MON_NAME
+if [ $? -ne 0 ]; then
+	echo "FAIL: unmon failed"
+	kill_statd
+	exit 1
+fi
+
+kill_statd
+
diff --git a/tests/test-lib.sh b/tests/test-lib.sh
new file mode 100755
index 0000000..053e46d
--- /dev/null
+++ b/tests/test-lib.sh
@@ -0,0 +1,41 @@
+#!/bin/bash
+#
+# test-lib.sh -- library of functions for nfs-utils tests
+#
+# Copyright (C) 2009  Red Hat, Jeff Layton <jlayton@redhat.com>
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License
+# as published by the Free Software Foundation; either version 2
+# of the License, or (at your option) any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation, Inc.,
+# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+#
+
+export PATH=$PATH:$srcdir/statdtest
+
+lockd_registered() {
+	rpcinfo -p | grep -q nlockmgr
+	return $?
+}
+
+start_statd() {
+	rpcinfo -u 127.0.0.1 status 1 &> /dev/null
+	if [ $? -eq 0 ]; then
+		echo "***ERROR***: statd is already running and should "
+		echo "             be down when starting this test"
+		return 1
+	fi
+	$srcdir/../utils/statd/statd --no-notify
+}
+
+kill_statd() {
+	kill `cat /var/run/rpc.statd.pid`
+}
-- 
1.6.5.2

