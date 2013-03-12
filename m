Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34703 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514Ab3CLUhu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2013 16:37:50 -0400
Received: by mail-ie0-f171.google.com with SMTP id 10so417840ied.2
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2013 13:37:50 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 08/10] gssd: Clean up gssd_setup_krb5_user_gss_ccache()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@redhat.com>
Date: Tue, 12 Mar 2013 16:37:48 -0400
Message-ID: <20130312203747.2478.64215.stgit@seurat.1015granger.net>
In-Reply-To: <20130312203105.2478.88903.stgit@seurat.1015granger.net>
References: <20130312203105.2478.88903.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove a contradictory portion of the block comment documenting
gssd_find_existing_krb5_ccache().  This should have been removed by
commit 289ad31e, which reversed the meaning of the function's return
values.

Note that, in user space, typically errno's are positive.  But here
we follow the kernel convention of using negative values to return
error codes.  Make the documenting comments explicit about the sign
of an error return -- it will never be positive in the case of an
error.

And a nit: At the last return statement in
gssd_setup_krb5_user_gss_ccache(), "err" always contains zero, as
far as I can tell.  Make it explicit (to human readers) that when
execution reaches this point, gssd_setup_krb5_user_gss_ccache() is
going to return "success."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>
---

 utils/gssd/krb5_util.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index aeb8f70..940f7cd 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -169,13 +169,13 @@ select_krb5_ccache(const struct dirent *d)
 
 /*
  * Look in directory "dirname" for files that look like they
- * are Kerberos Credential Cache files for a given UID.  Return
- * non-zero and the dirent pointer for the entry most likely to be
- * what we want. Otherwise, return zero and no dirent pointer.
- * The caller is responsible for freeing the dirent if one is returned.
+ * are Kerberos Credential Cache files for a given UID.
  *
- * Returns 0 if a valid-looking entry was found and a non-zero error
- * code otherwise.
+ * Returns 0 if a valid-looking entry is found.  "*cctype" is
+ * set to the name of the cache type.  A pointer to the dirent
+ * is planted in "*d".  Caller must free "*d" with free(3).
+ *
+ * Otherwise, a negative errno is returned.
  */
 static int
 gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
@@ -1037,7 +1037,7 @@ err_cache:
  * given only a UID.  We really need more information, but we
  * do the best we can.
  *
- * Returns 0 if a ccache was found, and a non-zero error code otherwise.
+ * Returns 0 if a ccache was found, or a negative errno otherwise.
  */
 int
 gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
@@ -1082,7 +1082,7 @@ gssd_setup_krb5_user_gss_ccache(uid_t uid, char *servername, char *dirpattern)
 	printerr(2, "using %s as credentials cache for client with "
 		    "uid %u for server %s\n", buf, uid, servername);
 	gssd_set_krb5_ccache_name(buf);
-	return err;
+	return 0;
 }
 
 /*

