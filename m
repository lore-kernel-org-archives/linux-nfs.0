From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] libexport.a: Make export_add() static
Date: Mon, 21 Jun 2010 12:54:58 -0400
Message-ID: <20100621165458.4771.40212.stgit@ellison.1015granger.net>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757972Ab0FUQzB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:55:01 -0400
Received: by mail-iw0-f174.google.com with SMTP id 36so1063318iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:55:01 -0700 (PDT)
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: export_add() is not called from outside of export.c, so make
it a static helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c    |    6 ++----
 support/include/exportfs.h |    1 -
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 1800efd..eca833c 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -24,6 +24,7 @@ static int export_hash(char *);
 
 static void	export_init(nfs_export *exp, nfs_client *clp,
 					struct exportent *nep);
+static void	export_add(nfs_export *exp);
 static int	export_check(const nfs_export *exp, const struct addrinfo *ai,
 				const char *path);
 static nfs_export *
@@ -151,10 +152,7 @@ export_dup(nfs_export *exp, const struct addrinfo *ai)
 	return new;
 }
 
-/*
- * Add export entry to hash table
- */
-void 
+static void
 export_add(nfs_export *exp)
 {
 	exp_hash_table *p_tbl;
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 8e54833..3cf1ee8 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -129,7 +129,6 @@ int 				client_member(const char *client,
 						const char *name);
 
 void				export_read(char *fname);
-void			export_add(nfs_export *);
 void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);
 nfs_export *			export_find(const struct addrinfo *ai,

