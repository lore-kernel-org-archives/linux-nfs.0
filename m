From: Harshula Jayasuriya <harshula@redhat.com>
Subject: [PATCH] nfs-utils: NFSv4: fix backgrounding
Date: Fri, 06 Nov 2009 02:31:28 +1100
Message-ID: <1257435088.2984.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754291AbZKEPbZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 10:31:25 -0500
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nA5FVURo026907
	for <linux-nfs@vger.kernel.org>; Thu, 5 Nov 2009 10:31:30 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

The nfsmount() function checks if !bg before running
switch(rpc_createerr.cf_stat). On the other hand, the nfs4mount()
function does not, and results in exiting the loop on the first
iteration even with the bg mount option.

NOTE: This and the previous patch ("nfs-utils: mount options can be lost
when using bg option") are relevant to non text-based mount options.

See https://bugzilla.redhat.com/show_bug.cgi?id=529370 for details.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
---
 utils/mount/nfs4mount.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index a2f318f..4a2fab7 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -217,8 +217,11 @@ int nfs4mount(const char *spec, const char *node, int flags,
 				progname);
 		goto fail;
 	}
-	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
-		 old_opts, *old_opts ? "," : "", s);
+	if (running_bg)
+		strncpy(new_opts, old_opts, sizeof(new_opts));
+	else
+		snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
+			 old_opts, *old_opts ? "," : "", s);
 	*extra_opts = xstrdup(new_opts);
 
 	/* Set default options.
@@ -434,15 +437,17 @@ int nfs4mount(const char *spec, const char *node, int flags,
 			break;
 		}
 
-		switch(rpc_createerr.cf_stat){
-		case RPC_TIMEDOUT:
-			break;
-		case RPC_SYSTEMERROR:
-			if (errno == ETIMEDOUT)
+		if (!bg) {
+			switch(rpc_createerr.cf_stat) {
+			case RPC_TIMEDOUT:
 				break;
-		default:
-			rpc_mount_errors(hostname, 0, bg);
-			goto fail;
+			case RPC_SYSTEMERROR:
+				if (errno == ETIMEDOUT)
+					break;
+			default:
+				rpc_mount_errors(hostname, 0, bg);
+				goto fail;
+			}
 		}
 
 		if (bg && !running_bg) {
--

cya,
#

