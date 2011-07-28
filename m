Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755579Ab1G1UDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 16:03:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/6] Merge top-level READMEs
Date: Thu, 28 Jul 2011 16:03:03 -0400
Message-Id: <1311883384-20260-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 README     |   17 +++++++++++++----
 README-4.1 |    8 --------
 2 files changed, 13 insertions(+), 12 deletions(-)
 delete mode 100644 README-4.1

diff --git a/README b/README
index 4fc8ad3..e756871 100644
--- a/README
+++ b/README
@@ -1,4 +1,13 @@
-The 4.0 and 4.1 git trees have been merged, preparing for merging of
-the actual code bases.  As a first step, the original 4.0 code was
-just moved down into the nfs4.0 directory.  If yuo want to ignore the
-4.1 work, just cd down to nfs4.0 and work from there as before.
+This tree includes support for both 4.0 and 4.1 pynfs testing.  It is
+the merge of what were originally two independent projects--initially
+the 4.0 pynfs code was all moved into the nfs4.0 directory, but as time
+passes we expect to merge the two code bases.
+
+You can prepare both for use with a single
+	./setup.py build_ext --inplace
+which will create auto-generated files and compile any shared libraries
+in place.
+
+For more details about 4.0 and 4.1 testing, see nfs4.0/README and
+nfs4.1/README, respectively.  For information about automatic code
+generation from an XDR file, see xdr/README.
diff --git a/README-4.1 b/README-4.1
deleted file mode 100644
index fcfe9d9..0000000
--- a/README-4.1
+++ /dev/null
@@ -1,8 +0,0 @@
-For nfs4 testing, see the nfs4/README.
-For automatic code generation frmo an XDR file, see xdr/README.
-
-First, if you need gss (kerberos), cd to the gssapi directoy
-and run "python setup.py build_ext --inplace"
-
-To use, you will first need to run "python setup.py build" to generate
-python files from xdr.
-- 
1.7.4.1

