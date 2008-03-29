From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] mount.nfs: allow backgrounded nfs4 mounts to work with binary mount opts
Date: Sat, 29 Mar 2008 16:30:07 -0400
Message-ID: <1206822608-20154-3-git-send-email-jlayton@redhat.com>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com>
 <1206822608-20154-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333AbYC2UaN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Mar 2008 16:30:13 -0400
In-Reply-To: <1206822608-20154-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The bg option is essentially ignored with nfs4 currently. nfs4mount()
will never exit with EX_BG, so the mount will never be backgrounded.
Fix it so that when bg is specified that we error out with EX_BG as
soon as possible after the first failed mount attempt.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/nfs4mount.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index af70551..2b0fe2e 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -188,10 +188,9 @@ int nfs4mount(const char *spec, const char *node, int flags,
 	int bg, soft, intr;
 	int nocto, noac, unshared;
 	int retry;
-	int retval;
+	int retval = EX_FAIL;
 	time_t timeout, t;
 
-	retval = EX_FAIL;
 	if (strlen(spec) >= sizeof(hostdir)) {
 		nfs_error(_("%s: excessively long host:dir argument\n"),
 				progname);
@@ -443,6 +442,13 @@ int nfs4mount(const char *spec, const char *node, int flags,
 			rpc_mount_errors(hostname, 0, bg);
 			goto fail;
 		}
+
+		if (bg && !running_bg) {
+			if (retry > 0)
+				retval = EX_BG;
+			goto fail;
+		}
+
 		t = time(NULL);
 		if (t >= timeout) {
 			rpc_mount_errors(hostname, 0, bg);
-- 
1.5.3.6

