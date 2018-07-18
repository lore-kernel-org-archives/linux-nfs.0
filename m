Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59984 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730213AbeGRMsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Jul 2018 08:48:46 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 23DFB308330B
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jul 2018 12:11:09 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-174.phx2.redhat.com [10.3.117.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D087C5D9C6
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jul 2018 12:11:08 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.gssd: truncates 32-bit UIDs/GIDs to 16 bits architectures.
Date: Wed, 18 Jul 2018 08:11:07 -0400
Message-Id: <20180718121107.16838-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

utils/gssd_proc.c uses SYS_setresuid and SYS_setresgid in
change_identity when it should use SYS_setresuid32 and
SYS_setresgid32 instead. This causes it to truncate
UIDs/GIDs > 65536.

Fixes: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1779962
Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1595927

Tested-by: James Ettle <theholyettlz@googlemail.com>
Tested-by: Sree <Sree@gmail.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 8767e26..7a57c4e 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -434,6 +434,7 @@ static int
 change_identity(uid_t uid)
 {
 	struct passwd	*pw;
+	int res;
 
 	/* drop list of supplimentary groups first */
 	if (syscall(SYS_setgroups, 0, 0) != 0) {
@@ -459,14 +460,23 @@ change_identity(uid_t uid)
 	 * send a signal to all other threads to synchronize the uid in all
 	 * other threads. To bypass this, we have to call syscall() directly.
 	 */
-	if (syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid) != 0) {
+#ifdef __NR_setresuid32
+	res = syscall(SYS_setresgid32, pw->pw_gid, pw->pw_gid, pw->pw_gid);
+#else 
+	res = syscall(SYS_setresgid, pw->pw_gid, pw->pw_gid, pw->pw_gid);
+#endif
+	if (res != 0) {
 		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
 		return errno;
 	}
 
-	if (syscall(SYS_setresuid, uid, uid, uid) != 0) {
-		printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
-				uid);
+#ifdef __NR_setresuid32
+	res = syscall(SYS_setresuid32, uid, uid, uid);
+#else 
+	res = syscall(SYS_setresuid, uid, uid, uid);
+#endif
+	if (res != 0) {
+		printerr(0, "WARNING: Failed to setuid for user with uid %u\n", uid);
 		return errno;
 	}
 
-- 
2.17.1

