Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57738 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933657AbcKWWUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Nov 2016 17:20:55 -0500
Date: Wed, 23 Nov 2016 17:20:54 -0500
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH xfstests] dirstress: Allow ESTALE as well as ENOENT
Message-ID: <20161123222054.GA7900@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the NFS case an attempt to chdir out of a removed directory could result
in ESTALE, and that should not cause the test to fail.

This was causing intermittent failures on generic/011 on NFS.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 src/dirstress.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Sorry, who do xfstests patches go to?--b.

diff --git a/src/dirstress.c b/src/dirstress.c
index f8f7355..33a166c 100644
--- a/src/dirstress.c
+++ b/src/dirstress.c
@@ -203,8 +203,10 @@ dirstress(
         if (verbose) fprintf(stderr,"** [%d] chdir ..\n", pid);
 	error = chdir("..");
 	if (error) {
-		/* If this is multithreaded, then expecting a ENOENT here is fine */
-		if (nprocs_per_dir > 1 && errno == ENOENT) {
+		/* If this is multithreaded, then expecting a ENOENT here is fine,
+		 * and ESTALE is normal in the NFS case. */
+		if (nprocs_per_dir > 1 &&
+				(errno == ENOENT || errno = ESTALE)) {
 			return 0;
 		}
 
@@ -224,8 +226,10 @@ dirstress(
         if (verbose) fprintf(stderr,"** [%d] chdir ..\n", pid);
 	error = chdir("..");
 	if (error) {
-		/* If this is multithreaded, then expecting a ENOENT here is fine */
-		if (nprocs_per_dir > 1 && errno == ENOENT) {
+		/* If this is multithreaded, then expecting a ENOENT here is fine,
+		 * and ESTALE is normal in the NFS case. */
+		if (nprocs_per_dir > 1 &&
+				(errno == ENOENT || errno = ESTALE)) {
 			return 0;
 		}
 
-- 
2.9.3

