Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47504 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751067AbdGMGau (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 02:30:50 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>
Date: Thu, 13 Jul 2017 16:30:05 +1000
Subject: [PATCH 4/4] mount: Fix problems with parsing minorversion=
Cc: linux-nfs@vger.kernel.org
Message-ID: <149992740578.9181.10837920531865843446.stgit@noble>
In-Reply-To: <149992731965.9181.6611555845253022123.stgit@noble>
References: <149992731965.9181.6611555845253022123.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1/ minorversion=0 is not recognized, as errors from
   strtol() are not correctly detected.
2/ when there is an error in the minorversion= value,
   no message is presented.
3/ Current code recognizes "minorversion" and sets V_SPECIFIC,
   but then because *cptr == '\0', the v_mode is reset to V_GENERAL.
   This results in minorversion negotiation, which is not wanted.

This patch addresses all of these.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/network.c |   22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d673391b5fff..11ee818f9705 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -100,7 +100,6 @@ static const char *nfs_version_opttbl[] = {
 	"v4",
 	"vers",
 	"nfsvers",
-	"minorversion",
 	NULL,
 };
 
@@ -1291,17 +1290,19 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
 	if (!version_val)
 		goto ret_error;
 
-	if (!(version->major = strtol(version_val, &cptr, 10)))
+	version->major = strtol(version_val, &cptr, 10);
+	if (cptr == version_val || (*cptr && *cptr != '.'))
 		goto ret_error;
-
-	if (strcmp(nfs_version_opttbl[i], "minorversion") == 0) {
+	if (version->major == 4 && *cptr != '.' &&
+	    (version_val = po_get(options, "minorversion")) != NULL) {
+		version->minor = strtol(version_val, &cptr, 10);
+		i = -1;
+		if (*cptr)
+			goto ret_error;
 		version->v_mode = V_SPECIFIC;
-		version->minor = version->major;
-		version->major = 4;
 	} else if (version->major < 4)
 		version->v_mode = V_SPECIFIC;
-
-	if (*cptr == '.') {
+	else if (*cptr == '.') {
 		version_val = ++cptr;
 		if (!(version->minor = strtol(version_val, &cptr, 10)) && cptr == version_val)
 			goto ret_error;
@@ -1315,7 +1316,10 @@ nfs_nfs_version(char *type, struct mount_options *options, struct nfs_version *v
 	return 1;
 
 ret_error:
-	if (i <= 2 ) {
+	if (i < 0) {
+		nfs_error(_("%s: parsing error on 'minorversion=' option"),
+			progname);
+	} else if (i <= 2 ) {
 		nfs_error(_("%s: parsing error on 'v' option"),
 			progname);
 	} else if (i == 3 ) {


