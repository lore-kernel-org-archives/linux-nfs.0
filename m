Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:56394 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbcDZNeZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Apr 2016 09:34:25 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 2/3] gssd: using syscalls directly to change thread's identity
Date: Tue, 26 Apr 2016 09:34:14 -0400
Message-ID: <1461677655-68294-3-git-send-email-kolga@netapp.com>
In-Reply-To: <1461677655-68294-1-git-send-email-kolga@netapp.com>
References: <1461677655-68294-1-git-send-email-kolga@netapp.com>
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
 utils/gssd/gssd_proc.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index e2e95dc..39c4b17 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -69,6 +69,7 @@
 #include <netdb.h>
 #include <sys/types.h>
 #include <sys/wait.h>
+#include <syscall.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -436,7 +437,7 @@ change_identity(uid_t uid)
 	struct passwd	*pw;
 
 	/* drop list of supplimentary groups first */
-	if (setgroups(0, NULL) != 0) {
+	if (syscall(SYS_setgroups, 0, 0) != 0) {
 		printerr(0, "WARNING: unable to drop supplimentary groups!");
 		return errno;
 	}
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
+	if (syscall(SYS_setresgid, pw->pw_gid, -1, -1) != 0) {
 		printerr(0, "WARNING: failed to set gid to %u!\n", pw->pw_gid);
 		return errno;
 	}
@@ -466,7 +472,7 @@ change_identity(uid_t uid)
 	 * Switch UIDs, but leave saved-set-uid alone to prevent ptrace() by
 	 * other processes running with this uid.
 	 */
-	if (setresuid(uid, uid, -1) != 0) {
+	if (syscall(SYS_setresuid, uid, -1, -1) != 0) {
 		printerr(0, "WARNING: Failed to setuid for user with uid %u\n",
 				uid);
 		return errno;
-- 
1.8.3.1

