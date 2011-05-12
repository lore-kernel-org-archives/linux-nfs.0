Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:54911 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757579Ab1ELTwd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 May 2011 15:52:33 -0400
Subject: [PATCH] nfs-utils: getexportent interprets -test-client- as default
	options
To: steved@redhat.com
From: Ben Myers <bpm@sgi.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Date: Thu, 12 May 2011 08:18:10 -0500
Message-ID: <20110512131810.25028.50931.stgit@nfs3>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With commit 1374c3861abdc66f3a1410e26cc85f86760b51dd Neil added a -test-client-
export to test the exportability of filesystems when exportfs is run.  When
using the old cache controls (i.e. /proc/fs/nfsd is not mounted) exportfs will
read /proc/fs/nfs/exports and find these test client entries.  The dash at the
beginning of -test-client- will be cause getexportent to look for default
options in the rest of the string, which test-client- will not match:

exportfs: /proc/fs/nfs/exports:1: unknown keyword "test-client-(rw"

This patch resolves the problem by testing for -test-client- string in the
check for default arguments.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 support/nfs/exports.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 6acb2b6..7e29155 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -142,9 +142,12 @@ getexportent(int fromkernel, int fromexports)
 		return NULL;
 	}
 	first = 0;
-		
-	/* Check for default options */
-	if (exp[0] == '-') {
+
+	/*
+	 * Check for default options.  The test client string does not indicate
+	 * default arguments.
+	 */
+	if (exp[0] == '-' && strncmp(exp, "-test-client-", 13) != 0) {
 		if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
 			return NULL;
 		

