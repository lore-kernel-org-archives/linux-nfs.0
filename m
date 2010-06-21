From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] libexport.a: Make export_read() return void
Date: Mon, 21 Jun 2010 12:54:48 -0400
Message-ID: <20100621165448.4771.59142.stgit@ellison.1015granger.net>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:46880 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757972Ab0FUQyx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:54:53 -0400
Received: by gwaa12 with SMTP id a12so392938gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:54:51 -0700 (PDT)
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: export_read()'s return value is always zero, and its only
caller never checks it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/export.c    |    8 ++++++--
 support/include/exportfs.h |    2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 919a244..1800efd 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -58,7 +58,12 @@ static void warn_duplicated_exports(nfs_export *exp, struct exportent *eep)
 	}
 }
 
-int
+/**
+ * export_read - read entries from /etc/exports
+ * @fname: name of file to read from
+ *
+ */
+void
 export_read(char *fname)
 {
 	struct exportent	*eep;
@@ -73,7 +78,6 @@ export_read(char *fname)
 			warn_duplicated_exports(exp, eep);
 	}
 	endexportent();
-	return 0;
 }
 
 /*
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 0da8566..8e54833 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -128,7 +128,7 @@ struct addrinfo *		client_resolve(const struct sockaddr *sap);
 int 				client_member(const char *client,
 						const char *name);
 
-int				export_read(char *fname);
+void				export_read(char *fname);
 void			export_add(nfs_export *);
 void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);

