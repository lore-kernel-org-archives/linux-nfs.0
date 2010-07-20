From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 18/24] Removed warnings from gssd_proc.c
Date: Tue, 20 Jul 2010 19:37:31 -0400
Message-ID: <1279669057-17509-19-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60372 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761898Ab0GUAm7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:59 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNZ-0004K5-1j
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:41 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd_proc.c: In function 'create_auth_rpc_client':
gssd_proc.c:939: warning: comparison between signed and unsigned integer expressions
gssd_proc.c:939: warning: comparison between signed and unsigned integer expressions
gssd_proc.c: In function 'handle_krb5_upcall':
gssd_proc.c:1164: warning: comparison between signed and unsigned integer expressions
gssd_proc.c: In function 'handle_spkm3_upcall':
gssd_proc.c:1178: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd_proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 3902b95..c301d46 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -936,7 +936,7 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	if (sec.cred != GSS_C_NO_CREDENTIAL)
 		gss_release_cred(&min_stat, &sec.cred);
 	/* Restore euid to original value */
-	if ((save_uid != -1) && (setfsuid(save_uid) != uid)) {
+	if (((int)save_uid != -1) && (setfsuid(save_uid) != (int)uid)) {
 		printerr(0, "WARNING: Failed to restore fsuid"
 			    " to uid %d from %d\n", save_uid, uid);
 	}
@@ -1161,7 +1161,7 @@ handle_krb5_upcall(struct clnt_info *clp)
 {
 	uid_t			uid;
 
-	if (read(clp->krb5_fd, &uid, sizeof(uid)) < sizeof(uid)) {
+	if (read(clp->krb5_fd, &uid, sizeof(uid)) < (ssize_t)sizeof(uid)) {
 		printerr(0, "WARNING: failed reading uid from krb5 "
 			    "upcall pipe: %s\n", strerror(errno));
 		return;
@@ -1175,7 +1175,7 @@ handle_spkm3_upcall(struct clnt_info *clp)
 {
 	uid_t			uid;
 
-	if (read(clp->spkm3_fd, &uid, sizeof(uid)) < sizeof(uid)) {
+	if (read(clp->spkm3_fd, &uid, sizeof(uid)) < (ssize_t)sizeof(uid)) {
 		printerr(0, "WARNING: failed reading uid from spkm3 "
 			 "upcall pipe: %s\n", strerror(errno));
 		return;
-- 
1.7.0.1

