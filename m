From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] libexport.a: Add documenting comments
Date: Mon, 21 Jun 2010 12:55:08 -0400
Message-ID: <20100621165508.4771.73939.stgit@ellison.1015granger.net>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757972Ab0FUQzL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:55:11 -0400
Received: by mail-iw0-f174.google.com with SMTP id 36so1063318iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:55:11 -0700 (PDT)
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  Add a few additional documenting comments for globally
visible functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   25 ++++++++++++++++++++++---
 support/export/export.c |   23 +++++++++++++++++------
 2 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 9a0fc9d..dc01067 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -134,9 +134,13 @@ client_add(nfs_client *clp)
 	*cpp = clp;
 }
 
-/* if canonical is set, then we *know* this is already a canonical name
- * so hostname lookup is avoided.
- * This is used when reading /proc/fs/nfs/exports
+/**
+ * client_lookup - look for @hname in our list of cached nfs_clients
+ * @hname: '\0'-terminated ASCII string containing hostname to look for
+ * @canonical: if set, @hname is known to be canonical DNS name
+ *
+ * Returns pointer to a matching or freshly created nfs_client.  NULL
+ * is returned if some problem occurs.
  */
 nfs_client *
 client_lookup(char *hname, int canonical)
@@ -215,6 +219,10 @@ client_dup(const nfs_client *clp, const struct addrinfo *ai)
 	return new;
 }
 
+/**
+ * client_release - drop a reference to an nfs_client record
+ *
+ */
 void
 client_release(nfs_client *clp)
 {
@@ -223,6 +231,10 @@ client_release(nfs_client *clp)
 	clp->m_count--;
 }
 
+/**
+ * client_freeall - deallocate all nfs_client records
+ *
+ */
 void
 client_freeall(void)
 {
@@ -558,6 +570,13 @@ client_check(const nfs_client *clp, const struct addrinfo *ai)
 	return 0;
 }
 
+/**
+ * client_gettype - determine type of nfs_client given an identifier
+ * @ident: '\0'-terminated ASCII string containing a client identifier
+ *
+ * Returns the type of nfs_client record that would be used for
+ * this client.
+ */
 int
 client_gettype(char *ident)
 {
diff --git a/support/export/export.c b/support/export/export.c
index eca833c..f528603 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -81,8 +81,13 @@ export_read(char *fname)
 	endexportent();
 }
 
-/*
- * Create an in-core export struct from an export entry.
+/**
+ * export_create - create an in-core nfs_export record from an export entry
+ * @xep: export entry to lookup
+ * @canonical: if set, e_hostname is known to be canonical DNS name
+ *
+ * Returns a freshly instantiated export record, or NULL if
+ * a problem occurred.
  */
 nfs_export *
 export_create(struct exportent *xep, int canonical)
@@ -260,11 +265,17 @@ export_allowed(const struct addrinfo *ai, const char *path)
 	return NULL;
 }
 
-/*
- * Search hash table for export entry. 
- */  
+/**
+ * export_lookup - search hash table for export entry
+ * @hname: '\0'-terminated ASCII string containing client hostname to look for
+ * @path: '\0'-terminated ASCII string containing export path to look for
+ * @canonical: if set, @hname is known to be canonical DNS name
+ *
+ * Returns a pointer to nfs_export record matching @hname and @path,
+ * or NULL if the export was not found.
+ */
 nfs_export *
-export_lookup(char *hname, char *path, int canonical) 
+export_lookup(char *hname, char *path, int canonical)
 {
 	nfs_client *clp;
 	nfs_export *exp;

