Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:58971 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933451Ab1ERSeh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 14:34:37 -0400
Subject: [PATCH v2] nfs-utils: getexportent interprets -test-client- as
	default options
To: steved@redhat.com
From: Ben Myers <bpm@sgi.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Date: Wed, 18 May 2011 06:55:37 -0500
Message-ID: <20110518115537.8725.44754.stgit@nfs3>
In-Reply-To: <4DD14CE9.1070301@RedHat.com>
References: <4DD14CE9.1070301@RedHat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With commit 1374c3861abdc66f3a1410e26cc85f86760b51dd Neil added a
-test-client- export to test the exportability of filesystems when exportfs
is run.  When using the old cache controls (i.e. /proc/fs/nfsd is not
mounted) exportfs will read /proc/fs/nfs/exports to process existing
exports and find these test client entries.  The dash at the beginning of
-test-client- will be cause getexportent to look for default options in the
rest of the string, which test-client- will not match:

exportfs: /proc/fs/nfs/exports:1: unknown keyword "test-client-(rw"

This patch resolves that problem (as Steve suggested) by not processing any
default options if we are reading the list of existing exports from the
kernel.  Default options are converted to individual exports by exportfs so
the kernel won't have any regardless.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 support/nfs/exports.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 6acb2b6..c250383 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -142,9 +142,14 @@ getexportent(int fromkernel, int fromexports)
 		return NULL;
 	}
 	first = 0;
-		
-	/* Check for default options */
-	if (exp[0] == '-') {
+
+	/*
+	 * Check for default options.  The kernel will never have default
+	 * options in /proc/fs/nfs/exports, however due to the initial '-' in
+	 * the -test-client- string from the test export we have to check that
+	 * we're not reading from the kernel.
+	 */
+	if (exp[0] == '-' && !fromkernel) {
 		if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
 			return NULL;
 		

