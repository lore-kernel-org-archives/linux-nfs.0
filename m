Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63634 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab0HaTLc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 15:11:32 -0400
Received: by iwn5 with SMTP id 5so6057237iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 Aug 2010 12:11:32 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] mount.nfs: Refactor mount version and protocol
	autonegotiation
To: neilb@suse.de
Cc: linux-nfs@vger.kernel.org
Date: Tue, 31 Aug 2010 15:11:28 -0400
Message-ID: <20100831191128.10685.64224.stgit@matisse.1015granger.net>
In-Reply-To: <20100831191006.10685.66951.stgit@matisse.1015granger.net>
References: <20100831191006.10685.66951.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The logic that manages negotiating NFS version and protocol settings
is getting more complex over time, so let's split this out of
nfs_try_mount().

This should make Bruce a little happier, as it eliminates the silent
switch case fall through in nfs_try_mount().  And it should help Neil
fix some bugs he's found in this logic.

We can reduce indenting and use a more clear switch over the errno's
as well.  Adding more comments can only help.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   59 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0241400..94e75be 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -747,6 +747,49 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 }
 
 /*
+ * Handle NFS version and transport protocol autonegotiation.
+ *
+ * When no version or protocol is specified on the command line,
+ * mount.nfs negotiates with the server to determine appropriate
+ * settings.
+ *
+ * Employ a set of wonky heuristics to work around missing server 
+ * features and work in the face of not-yet-ready servers.
+ */
+static int nfs_autonegotiate(struct nfsmount_info *mi)
+{
+	int result;
+
+	/*
+	 * Before 2.6.31, the kernel NFS client didn't support
+	 * "-t nfs vers=4" mounts, so we can't include NFSv4
+	 * when autonegotiating.
+	 */
+	if (linux_version_code() <= MAKE_VERSION(2, 6, 31))
+		goto fall_back;
+
+	errno = 0;
+	result = nfs_try_mount_v4(mi);
+	switch (errno) {
+	case EPROTONOSUPPORT:
+		goto fall_back;
+	case ENOENT:
+		/* Legacy Linux servers don't export an NFSv4
+		 * pseudoroot. */
+		goto fall_back;
+	case EPERM:
+		/* Linux servers prior to 2.6.25 may return
+		 * EPERM when NFSv4 is not supported. */
+		goto fall_back;
+	default:
+		return result;
+	}
+
+fall_back:
+	return nfs_try_mount_v3v2(mi);
+}
+
+/*
  * This is a single pass through the fg/bg loop.
  *
  * Returns TRUE if successful, otherwise FALSE.
@@ -758,20 +801,8 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 
 	switch (mi->version) {
 	case 0:
-		if (linux_version_code() > MAKE_VERSION(2, 6, 31)) {
-			errno = 0;
-			result = nfs_try_mount_v4(mi);
-			if (errno != EPROTONOSUPPORT) {
-				/* 
-				 * To deal with legacy Linux servers that don't
-				 * automatically export a pseudo root, retry
-				 * ENOENT errors using version 3. And for
-				 * Linux servers prior to 2.6.25, retry EPERM
-				 */
-				if (errno != ENOENT && errno != EPERM)
-					break;
-			}
-		}
+		result = nfs_autonegotiate(mi);
+		break;
 	case 2:
 	case 3:
 		result = nfs_try_mount_v3v2(mi);

