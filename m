Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:39286 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750947AbeECQvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 May 2018 12:51:47 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2118A407574E
        for <linux-nfs@vger.kernel.org>; Thu,  3 May 2018 16:51:47 +0000 (UTC)
Message-ID: <1525366305.7550.25.camel@redhat.com>
Subject: [PATCH v2 7/7] nfs-utils: use nfsconftool cli to test library
 function
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <SteveD@RedHat.com>
Date: Thu, 03 May 2018 17:51:45 +0100
In-Reply-To: <1525365943.7550.18.camel@redhat.com>
References: <1525365943.7550.18.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uses the nfsconftool cli to test that the configuration
library functions are operating as expected

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 tests/Makefile.am            |  3 ++-
 tests/nfsconf/01-errors.conf | 20 ++++++++++++++++++++
 tests/nfsconf/01-errors.exp  | 14 ++++++++++++++
 tests/nfsconf/02-valid.conf  | 25 +++++++++++++++++++++++++
 tests/nfsconf/02-valid.exp   | 26 ++++++++++++++++++++++++++
 tests/nfsconf/02-valid.sub   |  7 +++++++
 tests/t0002-nfsconf.sh       | 38 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 132 insertions(+), 1 deletion(-)
 create mode 100644 tests/nfsconf/01-errors.conf
 create mode 100644 tests/nfsconf/01-errors.exp
 create mode 100644 tests/nfsconf/02-valid.conf
 create mode 100644 tests/nfsconf/02-valid.exp
 create mode 100644 tests/nfsconf/02-valid.sub
 create mode 100755 tests/t0002-nfsconf.sh

diff --git a/tests/Makefile.am b/tests/Makefile.am
index 1f96264..60691cc 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -10,5 +10,6 @@ SUBDIRS = nsm_client
 
 MAINTAINERCLEANFILES = Makefile.in
 
-TESTS = t0001-statd-basic-mon-unmon.sh
+TESTS = t0001-statd-basic-mon-unmon.sh \
+	t0002-nfsconf.sh
 EXTRA_DIST = test-lib.sh $(TESTS)
diff --git a/tests/nfsconf/01-errors.conf b/tests/nfsconf/01-errors.conf
new file mode 100644
index 0000000..ca64d2c
--- /dev/null
+++ b/tests/nfsconf/01-errors.conf
@@ -0,0 +1,20 @@
+# file of deliberate errors
+[default]
+
+
+[ one
+
+[ two " foo ]
+aa = foo
+
+[ three 
+val = none
+
+[four]
+one
+ = two
+three =
+four = foo = bar
+five = " nothing
+six = normal
+
diff --git a/tests/nfsconf/01-errors.exp b/tests/nfsconf/01-errors.exp
new file mode 100644
index 0000000..2bf1b8c
--- /dev/null
+++ b/tests/nfsconf/01-errors.exp
@@ -0,0 +1,14 @@
+nfsconf: config error at 01-errors.conf:5: non-matched ']', ignoring until next section
+nfsconf: config error at 01-errors.conf:7: non-matched '"', ignoring until next section
+nfsconf: config error at 01-errors.conf:10: non-matched ']', ignoring until next section
+nfsconf: config error at 01-errors.conf:11: ignoring line not in a section
+nfsconf: config error at 01-errors.conf:14: line not empty and not an assignment
+nfsconf: config error at 01-errors.conf:15: missing tag in assignment
+nfsconf: config error at 01-errors.conf:16: missing value in assignment
+nfsconf: config error at 01-errors.conf:18: unmatched quotes
+[four]
+ four = foo = bar
+ six = normal
+
+[two]
+ aa = foo
diff --git a/tests/nfsconf/02-valid.conf b/tests/nfsconf/02-valid.conf
new file mode 100644
index 0000000..ca8ccab
--- /dev/null
+++ b/tests/nfsconf/02-valid.conf
@@ -0,0 +1,25 @@
+[environment]
+one = 1
+two = 2
+three = 3
+
+[section_one]
+one = 11
+two = 22
+three = $three
+ four   =   "six  "
+ five six = seven eight
+
+[section_two "two"]
+one = Un
+two = Dau
+include = "02-valid.sub"
+
+[section_two "one"]
+one = Un
+two = Deux
+
+[section_two "two"]
+four = Pedwar
+   five   =    " Pump "
+
diff --git a/tests/nfsconf/02-valid.exp b/tests/nfsconf/02-valid.exp
new file mode 100644
index 0000000..379d7a4
--- /dev/null
+++ b/tests/nfsconf/02-valid.exp
@@ -0,0 +1,26 @@
+[environment]
+ one = 1
+ three = 3
+ two = 2
+
+[extra_section]
+ bar = baz
+ foo = bar
+
+[section_one]
+ five six = seven eight
+ four = "six  "
+ one = 11
+ three = $three
+ two = 22
+
+[section_two "one"]
+ one = Un
+ two = Deux
+
+[section_two "two"]
+ five = " Pump "
+ four = Pedwar
+ one = Un
+ three = Tri
+ two = Dau
diff --git a/tests/nfsconf/02-valid.sub b/tests/nfsconf/02-valid.sub
new file mode 100644
index 0000000..ab7beda
--- /dev/null
+++ b/tests/nfsconf/02-valid.sub
@@ -0,0 +1,7 @@
+# Included configs don't need a section, it is inherited
+three=Tri
+
+# But if they do, that works also
+[extra_section]
+foo = bar
+bar = baz
diff --git a/tests/t0002-nfsconf.sh b/tests/t0002-nfsconf.sh
new file mode 100755
index 0000000..511d248
--- /dev/null
+++ b/tests/t0002-nfsconf.sh
@@ -0,0 +1,38 @@
+#!/bin/bash
+
+TESTFILES=nfsconf
+DUMPER=`realpath ../tools/nfsconf/nfsconftool`
+
+BASEDIR=`dirname "$0"`
+pushd $BASEDIR/$TESTFILES
+
+rm -f *.out
+
+TCOUNT=0
+TPASS=0
+
+for i in *.conf
+do
+TNAME=`basename "$i" .conf`
+
+echo "Running test $TNAME"
+TCOUNT=$((TCOUNT + 1))
+
+if ! $DUMPER --file "$i" --dump - > "$TNAME.out" 2>&1
+then
+echo "Error running test $TNAME"
+elif ! diff -u "$TNAME.exp" "$TNAME.out"
+then
+echo "FAIL differences detected in test $TNAME"
+else
+echo "PASS $TNAME"
+TPASS=$((TPASS + 1))
+fi
+
+done
+
+echo "nfsconf tests complete. $TPASS of $TCOUNT tests passed"
+
+if [ $TPASS -lt $TCOUNT ]; then
+exit 1
+fi
-- 
1.8.3.1




