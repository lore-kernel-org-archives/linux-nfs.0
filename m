From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] libexport.a: Add export_free()
Date: Thu, 15 Apr 2010 11:25:15 -0400
Message-ID: <20100415152514.4716.41039.stgit@localhost.localdomain>
References: <20100415152401.4716.83632.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:33051 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0DOPZS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2010 11:25:18 -0400
Received: by mail-qy0-f189.google.com with SMTP id 27so1787265qyk.23
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2010 08:25:18 -0700 (PDT)
In-Reply-To: <20100415152401.4716.83632.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Introduce a helper to free an nfs_export record.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 42e78f6..ddc8a84 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -28,6 +28,18 @@ static int	export_check(nfs_export *, struct hostent *, char *);
 static nfs_export *
 		export_allowed_internal(struct hostent *hp, char *path);
 
+static void
+export_free(nfs_export *exp)
+{
+	xfree(exp->m_export.e_squids);
+	xfree(exp->m_export.e_sqgids);
+	free(exp->m_export.e_mountpoint);
+	free(exp->m_export.e_fslocdata);
+
+	xfree(exp->m_export.e_hostname);
+	xfree(exp);
+}
+
 static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
 {
 	if (exp->m_export.e_flags != eep->e_flags) {
@@ -260,6 +272,10 @@ export_check(nfs_export *exp, struct hostent *hp, char *path)
 	return client_check(exp->m_client, hp);
 }
 
+/**
+ * export_freeall - deallocate all nfs_export records
+ *
+ */
 void
 export_freeall(void)
 {
@@ -270,16 +286,7 @@ export_freeall(void)
 		for (exp = exportlist[i].p_head; exp; exp = nxt) {
 			nxt = exp->m_next;
 			client_release(exp->m_client);
-			if (exp->m_export.e_squids)
-				xfree(exp->m_export.e_squids);
-			if (exp->m_export.e_sqgids)
-				xfree(exp->m_export.e_sqgids);
-			if (exp->m_export.e_mountpoint)
-				free(exp->m_export.e_mountpoint);
-			if (exp->m_export.e_fslocdata)
-				free(exp->m_export.e_fslocdata);
-			xfree(exp->m_export.e_hostname);
-			xfree(exp);
+			export_free(exp);
 		}
 		for (j = 0; j < HASH_TABLE_SIZE; j++) {
 			exportlist[i].entries[j].p_first = NULL;

