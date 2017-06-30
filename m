Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55032 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751659AbdF3NWK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:22:10 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 12/12] tests: add "vsock:" exports(5) test case
Date: Fri, 30 Jun 2017 14:21:20 +0100
Message-Id: <20170630132120.31578-13-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This simple test case checks that the new syntax works for AF_VSOCK.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 tests/Makefile.am          |  3 ++-
 tests/t0002-vsock-basic.sh | 53 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 1 deletion(-)
 create mode 100755 tests/t0002-vsock-basic.sh

diff --git a/tests/Makefile.am b/tests/Makefile.am
index 1f96264..c4e2792 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -10,5 +10,6 @@ SUBDIRS = nsm_client
 
 MAINTAINERCLEANFILES = Makefile.in
 
-TESTS = t0001-statd-basic-mon-unmon.sh
+TESTS = t0001-statd-basic-mon-unmon.sh \
+	t0002-vsock-basic.sh
 EXTRA_DIST = test-lib.sh $(TESTS)
diff --git a/tests/t0002-vsock-basic.sh b/tests/t0002-vsock-basic.sh
new file mode 100755
index 0000000..21a3884
--- /dev/null
+++ b/tests/t0002-vsock-basic.sh
@@ -0,0 +1,53 @@
+#!/bin/bash
+#
+# t0002-vsock-basic.sh -- test basic NFSv4 over AF_VSOCK functionality
+#
+# Copyright (C) 2017  Red Hat, Stefan Hajnoczi <stefanha@redhat.com>
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
+# 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
+#
+
+. ./test-lib.sh
+
+check_root
+
+test_exportfs() {
+	client_addr="$1"
+	export_spec="$client_addr:$(realpath .)"
+
+	echo "TEST: $client_addr"
+
+	"$srcdir/../utils/exportfs/exportfs" "$export_spec"
+	if [ $? -ne 0 ]; then
+		echo "FAIL: exportfs failed"
+		exit 1
+	fi
+
+	expected_etab="$(realpath .)	$client_addr("
+	grep --fixed-strings -q "$expected_etab" /var/lib/nfs/etab
+	if [ $? -ne 0 ]; then
+		echo "FAIL: etab doesn't contain entry"
+		exit 1
+	fi
+
+	"$srcdir/../utils/exportfs/exportfs" -u "$export_spec"
+	if [ $? -ne 0 ]; then
+		echo "FAIL: exportfs -u failed"
+		exit 1
+	fi
+}
+
+test_exportfs "vsock:3"
+test_exportfs "vsock:*"
-- 
2.9.4

