Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:64939 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757691Ab2JKPLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:11:36 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3136165iea.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:11:36 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] mountd: Add exportent_release()
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:11:34 -0400
Message-ID: <20121011151134.4665.44892.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split out the logic that releases dynamically allocated data in an
exportent.  The junction resolution code will invoke this to clean
up the junction exportent once it has been dumped to the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c    |   19 ++++++++++++-------
 support/include/exportfs.h |    1 +
 2 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 4fda30a..17ceca9 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -31,16 +31,21 @@ static nfs_export *
 		export_allowed_internal(const struct addrinfo *ai,
 				const char *path);
 
+void
+exportent_release(struct exportent *eep)
+{
+	xfree(eep->e_squids);
+	xfree(eep->e_sqgids);
+	free(eep->e_mountpoint);
+	free(eep->e_fslocdata);
+	free(eep->e_uuid);
+	xfree(eep->e_hostname);
+}
+
 static void
 export_free(nfs_export *exp)
 {
-	xfree(exp->m_export.e_squids);
-	xfree(exp->m_export.e_sqgids);
-	free(exp->m_export.e_mountpoint);
-	free(exp->m_export.e_fslocdata);
-	free(exp->m_export.e_uuid);
-
-	xfree(exp->m_export.e_hostname);
+	exportent_release(&exp->m_export);
 	xfree(exp);
 }
 
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 99916e5..5960feb 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -141,6 +141,7 @@ nfs_export *			export_find(const struct addrinfo *ai,
 nfs_export *			export_allowed(const struct addrinfo *ai,
 						const char *path);
 nfs_export *			export_create(struct exportent *, int canonical);
+void				exportent_release(struct exportent *);
 void				export_freeall(void);
 int				export_export(nfs_export *);
 int				export_unexport(nfs_export *);

