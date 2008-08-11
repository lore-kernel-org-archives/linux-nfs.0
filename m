From: Bruce Fields <bfields@citi.umich.edu>
Subject: [PATCH 3/3] Determine supported pseudoflavors from export
Date: Sun, 10 Aug 2008 22:47:10 -0400
Message-ID: <1218422830-5465-4-git-send-email-bfields@citi.umich.edu>
References: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu>
 <1218422830-5465-2-git-send-email-bfields@citi.umich.edu>
 <1218422830-5465-3-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732AbYHKCrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Aug 2008 22:47:12 -0400
In-Reply-To: <1218422830-5465-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Instead of using a static list of supported flavors, we should be taking
the list from the export.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/mountd/mountd.c |   55 +++++++++++++++++++++++++++++++++---------------
 1 files changed, 38 insertions(+), 17 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index d5b8c0d..6adb68f 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -26,6 +26,7 @@
 #include "misc.h"
 #include "mountd.h"
 #include "rpcmisc.h"
+#include "pseudoflavors.h"
 
 extern void	cache_open(void);
 extern struct nfs_fh_len *cache_get_filehandle(nfs_export *exp, int len, char *p);
@@ -35,7 +36,7 @@ extern void my_svc_run(void);
 
 static void		usage(const char *, int exitcode);
 static exports		get_exportlist(void);
-static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, mountstat3 *, int v3);
+static struct nfs_fh_len *get_rootfh(struct svc_req *, dirpath *, nfs_export **, mountstat3 *, int v3);
 
 int reverse_resolve = 0;
 int new_cache = 0;
@@ -192,7 +193,7 @@ mount_mnt_1_svc(struct svc_req *rqstp, dirpath *path, fhstatus *res)
 	struct nfs_fh_len *fh;
 
 	xlog(D_CALL, "MNT1(%s) called", *path);
-	fh = get_rootfh(rqstp, path, &res->fhs_status, 0);
+	fh = get_rootfh(rqstp, path, NULL, &res->fhs_status, 0);
 	if (fh)
 		memcpy(&res->fhstatus_u.fhs_fhandle, fh->fh_handle, 32);
 	return 1;
@@ -330,39 +331,57 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 }
 
 /*
+ * We should advertise the preferred flavours first. (See RFC 2623
+ * section 2.7.)  We leave that to the administrator, by advertising
+ * flavours in the order they were listed in /etc/exports.  AUTH_NULL is
+ * dropped from the list to avoid backward compatibility issue with
+ * older Linux clients, who inspect the list in reversed order.
+ *
+ * XXX: It might be more helpful to rearrange these so that flavors
+ * giving more access (as determined from readonly and id-squashing
+ * options) come first.  (If we decide to do that we should probably do
+ * that when reading the exports rather than here.)
+ */
+static void set_authflavors(struct mountres3_ok *ok, nfs_export *exp)
+{
+	struct sec_entry *s;
+	static int flavors[SECFLAVOR_COUNT];
+	int i = 0;
+
+	for (s = exp->m_export.e_secinfo; s->flav; s++) {
+		if (s->flav->fnum == AUTH_NULL)
+			continue;
+		flavors[i] = s->flav->fnum;
+		i++;
+	}
+	ok->auth_flavors.auth_flavors_val = flavors;
+	ok->auth_flavors.auth_flavors_len = i;
+}
+
+/*
  * NFSv3 MOUNT procedure
  */
 bool_t
 mount_mnt_3_svc(struct svc_req *rqstp, dirpath *path, mountres3 *res)
 {
-#define AUTH_GSS_KRB5 390003
-#define AUTH_GSS_KRB5I 390004
-#define AUTH_GSS_KRB5P 390005
-	static int	flavors[] = { AUTH_UNIX, AUTH_GSS_KRB5, AUTH_GSS_KRB5I, AUTH_GSS_KRB5P};
-	/*
-	 * We should advertise the preferred flavours first. (See RFC 2623
-	 * section 2.7.) AUTH_UNIX is arbitrarily ranked over the GSS's.
-	 * AUTH_NULL is dropped from the list to avoid backward compatibility
-	 * issue with older Linux clients, who inspect the list in reversed
-	 * order.
-	 */
 	struct mountres3_ok *ok = &res->mountres3_u.mountinfo;
+	nfs_export *exp;
 	struct nfs_fh_len *fh;
 
 	xlog(D_CALL, "MNT3(%s) called", *path);
-	fh = get_rootfh(rqstp, path, &res->fhs_status, 1);
+	fh = get_rootfh(rqstp, path, &exp, &res->fhs_status, 1);
 	if (!fh)
 		return 1;
 
 	ok->fhandle.fhandle3_len = fh->fh_size;
 	ok->fhandle.fhandle3_val = (char *)fh->fh_handle;
-	ok->auth_flavors.auth_flavors_len = sizeof(flavors)/sizeof(flavors[0]);
-	ok->auth_flavors.auth_flavors_val = flavors;
+	set_authflavors(ok, exp);
 	return 1;
 }
 
 static struct nfs_fh_len *
-get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
+get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
+		mountstat3 *error, int v3)
 {
 	struct sockaddr_in *sin =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
@@ -467,6 +486,8 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
 	}
 	*error = NFS_OK;
 	mountlist_add(inet_ntoa(sin->sin_addr), p);
+	if (expret)
+		*expret = exp;
 	return fh;
 }
 
-- 
1.5.5.rc1

