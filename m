From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] text-based mount command: use po_get_numeric() for
	handling retry=
Date: Thu, 11 Dec 2008 13:33:53 -0500
Message-ID: <20081211183353.6882.67562.stgit@ingres.1015granger.net>
References: <20081211182820.6882.20716.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:45211 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755765AbYLKSeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 13:34:21 -0500
In-Reply-To: <20081211182820.6882.20716.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the logic in nfs_parse_retry_option() with a call to the new
po_get_numeric() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 09fca86..43791e6 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -99,19 +99,21 @@ struct nfsmount_info {
 static time_t nfs_parse_retry_option(struct mount_options *options,
 				     unsigned int timeout_minutes)
 {
-	char *retry_option, *endptr;
+	long tmp;
 
-	retry_option = po_get(options, "retry");
-	if (retry_option) {
-		long tmp;
-
-		errno = 0;
-		tmp = strtol(retry_option, &endptr, 10);
-		if (errno == 0 && endptr != retry_option && tmp >= 0)
+	switch (po_get_numeric(options, "retry", &tmp)) {
+	case PO_NOT_FOUND:
+		break;
+	case PO_FOUND:
+		if (tmp >= 0) {
 			timeout_minutes = tmp;
-		else if (verbose)
+			break;
+		}
+	case PO_BAD_VALUE:
+		if (verbose)
 			nfs_error(_("%s: invalid retry timeout was specified; "
 					"using default timeout"), progname);
+		break;
 	}
 
 	return time(NULL) + (time_t)(timeout_minutes * 60);

