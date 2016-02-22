Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:42685 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbcBVP3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 10:29:05 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] gssd: using syscalls directly to change thread's identity
Date: Mon, 22 Feb 2016 10:28:58 -0500
Message-ID: <1456154939-26926-3-git-send-email-kolga@netapp.com>
In-Reply-To: <1456154939-26926-1-git-send-email-kolga@netapp.com>
References: <1456154939-26926-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the threaded version we have to set uid,gid per thread instead
of per process. glibc setresuid() when called from a thread, it'll
send a signal to all other threads to synchronize the uid in all
other threads. To bypass this, we have to call syscall() directly.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Reviewed-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 616082e..fee72c6 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -69,6 +69,7 @@
 #include <netdb.h>
 #include <sys/types.h>
 #include <sys/wait.h>
+#include <syscall.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -457,7 +458,12 @@ change_identity(uid_t uid)
 	 * Switch the GIDs. Note that we leave the saved-set-gid alone in an
 	 * attempt to prevent attacks via ptrace()
 	 */
-	if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
+	/* For the threaded version we have to set uid,gid per thread instead
+	 * of per process. glibc setresuid() when called from a thread, it'll
+	 * send a signal to all other threads to synchronize the uid in all
+	 * other threads. To bypass this, we have to call syscall() directly.
+	 */
+	if (syscall(SYS_setresgid, pw->pw_gid) != 0) {
 		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
 		return errno;
 	}
@@ -466,7 +472,7 @@ change_identity(uid_t uid)
 	 * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
 	 * other processes running with this uid.
 	 */
-	if (setresuid(uid, uid, -1) != 0) {
+	if (syscall(SYS_setresuid, uid) != 0) {
 		printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
 				uid);
 		return errno;
-- 
1.8.3.1

