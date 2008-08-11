From: Bruce Fields <bfields@citi.umich.edu>
Subject: [PATCH 2/3] Minor mountd.c cleanup
Date: Sun, 10 Aug 2008 22:47:09 -0400
Message-ID: <1218422830-5465-3-git-send-email-bfields@citi.umich.edu>
References: <1218422830-5465-1-git-send-email-bfields@citi.umich.edu>
 <1218422830-5465-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44692 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753760AbYHKCrN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Aug 2008 22:47:13 -0400
In-Reply-To: <1218422830-5465-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

I find it more readable to have the normal (non-error) case unindented,
and to keep conditionals relatively simple, as is the usual kernel
style.  Fix some inconsistent indentation while we're there.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/mountd/mountd.c |   87 +++++++++++++++++++++++++++---------------------
 1 files changed, 49 insertions(+), 38 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 0facf89..d5b8c0d 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -175,9 +175,9 @@ killer (int sig)
 static void
 sig_hup (int sig)
 {
-  /* don't exit on SIGHUP */
-  xlog (L_NOTICE, "Received SIGHUP... Ignoring.\n", sig);
-  return;
+	/* don't exit on SIGHUP */
+	xlog (L_NOTICE, "Received SIGHUP... Ignoring.\n", sig);
+	return;
 }
 
 bool_t
@@ -192,7 +192,8 @@ mount_mnt_1_svc(struct svc_req *rqstp, dirpath *path, fhstatus *res)
 	struct nfs_fh_len *fh;
 
 	xlog(D_CALL, "MNT1(%s) called", *path);
-	if ((fh = get_rootfh(rqstp, path, &res->fhs_status, 0)) != NULL)
+	fh = get_rootfh(rqstp, path, &res->fhs_status, 0);
+	if (fh)
 		memcpy(&res->fhstatus_u.fhs_fhandle, fh->fh_handle, 32);
 	return 1;
 }
@@ -304,7 +305,8 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 	}
 
 	/* Now authenticate the intruder... */
-	if (!(exp = auth_authenticate("pathconf", sin, p))) {
+	exp = auth_authenticate("pathconf", sin, p);
+	if (!exp) {
 		return 1;
 	} else if (stat(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
@@ -344,18 +346,18 @@ mount_mnt_3_svc(struct svc_req *rqstp, dirpath *path, mountres3 *res)
 	 * issue with older Linux clients, who inspect the list in reversed
 	 * order.
 	 */
+	struct mountres3_ok *ok = &res->mountres3_u.mountinfo;
 	struct nfs_fh_len *fh;
 
 	xlog(D_CALL, "MNT3(%s) called", *path);
-	if ((fh = get_rootfh(rqstp, path, &res->fhs_status, 1)) != NULL) {
-		struct mountres3_ok	*ok = &res->mountres3_u.mountinfo;
-
-		ok->fhandle.fhandle3_len = fh->fh_size;
-		ok->fhandle.fhandle3_val = (char *)fh->fh_handle;
-		ok->auth_flavors.auth_flavors_len
-			= sizeof(flavors)/sizeof(flavors[0]);
-		ok->auth_flavors.auth_flavors_val = flavors;
-	}
+	fh = get_rootfh(rqstp, path, &res->fhs_status, 1);
+	if (!fh)
+		return 1;
+
+	ok->fhandle.fhandle3_len = fh->fh_size;
+	ok->fhandle.fhandle3_val = (char *)fh->fh_handle;
+	ok->auth_flavors.auth_flavors_len = sizeof(flavors)/sizeof(flavors[0]);
+	ok->auth_flavors.auth_flavors_val = flavors;
 	return 1;
 }
 
@@ -366,6 +368,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
 	struct stat	stb, estb;
 	nfs_export	*exp;
+	struct nfs_fh_len *fh;
 	char		rpath[MAXPATHLEN+1];
 	char		*p = *path;
 
@@ -382,57 +385,65 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
 	}
 
 	/* Now authenticate the intruder... */
-	if (!(exp = auth_authenticate("mount", sin, p))) {
+	exp = auth_authenticate("mount", sin, p);
+	if (!exp) {
 		*error = NFSERR_ACCES;
-	} else if (stat(p, &stb) < 0) {
+		return NULL;
+	}
+	if (stat(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
 				p, strerror(errno));
 		if (errno == ENOENT)
 			*error = NFSERR_NOENT;
 		else
 			*error = NFSERR_ACCES;
-	} else if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
+		return NULL;
+	}
+	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
 		xlog(L_WARNING, "%s is not a directory or regular file", p);
 		*error = NFSERR_NOTDIR;
-	} else if (stat(exp->m_export.e_path, &estb) < 0) {
+		return NULL;
+	}
+	if (stat(exp->m_export.e_path, &estb) < 0) {
 		xlog(L_WARNING, "can't stat export point %s: %s",
 		     p, strerror(errno));
 		*error = NFSERR_NOENT;
-	} else if (estb.st_dev != stb.st_dev
-		   && (!new_cache || !(exp->m_export.e_flags & NFSEXP_CROSSMOUNT))
-		) {
+		return NULL;
+	}
+	if (estb.st_dev != stb.st_dev
+		   && (!new_cache
+			   || !(exp->m_export.e_flags & NFSEXP_CROSSMOUNT))) {
 		xlog(L_WARNING, "request to export directory %s below nearest filesystem %s",
 		     p, exp->m_export.e_path);
 		*error = NFSERR_ACCES;
-	} else if (exp->m_export.e_mountpoint &&
+		return NULL;
+	}
+	if (exp->m_export.e_mountpoint &&
 		   !is_mountpoint(exp->m_export.e_mountpoint[0]?
 				  exp->m_export.e_mountpoint:
 				  exp->m_export.e_path)) {
 		xlog(L_WARNING, "request to export an unmounted filesystem: %s",
 		     p);
 		*error = NFSERR_NOENT;
-	} else if (new_cache) {
+		return NULL;
+	}
+
+	if (new_cache) {
 		/* This will be a static private nfs_export with just one
 		 * address.  We feed it to kernel then extract the filehandle,
 		 * 
 		 */
-		struct nfs_fh_len  *fh;
 
 		if (cache_export(exp, p)) {
 			*error = NFSERR_ACCES;
 			return NULL;
 		}
 		fh = cache_get_filehandle(exp, v3?64:32, p);
-		if (fh == NULL) 
+		if (fh == NULL) {
 			*error = NFSERR_ACCES;
-		else {
-			*error = NFS_OK;
-			mountlist_add(inet_ntoa(sin->sin_addr), p);
+			return NULL;
 		}
-		return fh;
 	} else {
-		struct nfs_fh_len  *fh;
-
 		if (exp->m_exported<1)
 			export_export(exp);
 		if (!exp->m_xtabent)
@@ -448,15 +459,15 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, mountstat3 *error, int v3)
 				fh = getfh_old ((struct sockaddr *) sin,
 						stb.st_dev, stb.st_ino);
 		}
-		if (fh != NULL) {
-			mountlist_add(inet_ntoa(sin->sin_addr), p);
-			*error = NFS_OK;
-			return fh;
+		if (fh == NULL) {
+			xlog(L_WARNING, "getfh failed: %s", strerror(errno));
+			*error = NFSERR_ACCES;
+			return NULL;
 		}
-		xlog(L_WARNING, "getfh failed: %s", strerror(errno));
-		*error = NFSERR_ACCES;
 	}
-	return NULL;
+	*error = NFS_OK;
+	mountlist_add(inet_ntoa(sin->sin_addr), p);
+	return fh;
 }
 
 static exports
-- 
1.5.5.rc1

