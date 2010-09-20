Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:34373 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab0ITQdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:33:18 -0400
Received: by mail-gw0-f46.google.com with SMTP id 17so1357564gwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:33:17 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] mountd: Use MNT status values instead of NFSERR
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:33:14 -0400
Message-ID: <20100920163314.3170.47126.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up:  The MNT protocol has its own enum type defining error
status values.  While the values can be the same as the NFSERR enum
type on some systems, it's not guaranteed to be true everywhere.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 1a14a85..d309950 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -474,27 +474,27 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 	/* Now authenticate the intruder... */
 	exp = auth_authenticate("mount", sap, p);
 	if (exp == NULL) {
-		*error = NFSERR_ACCES;
+		*error = MNT3ERR_ACCES;
 		return NULL;
 	}
 	if (stat(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
 				p, strerror(errno));
 		if (errno == ENOENT)
-			*error = NFSERR_NOENT;
+			*error = MNT3ERR_NOENT;
 		else
-			*error = NFSERR_ACCES;
+			*error = MNT3ERR_ACCES;
 		return NULL;
 	}
 	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
 		xlog(L_WARNING, "%s is not a directory or regular file", p);
-		*error = NFSERR_NOTDIR;
+		*error = MNT3ERR_NOTDIR;
 		return NULL;
 	}
 	if (stat(exp->m_export.e_path, &estb) < 0) {
 		xlog(L_WARNING, "can't stat export point %s: %s",
 		     p, strerror(errno));
-		*error = NFSERR_NOENT;
+		*error = MNT3ERR_NOENT;
 		return NULL;
 	}
 	if (estb.st_dev != stb.st_dev
@@ -502,7 +502,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 			   || !(exp->m_export.e_flags & NFSEXP_CROSSMOUNT))) {
 		xlog(L_WARNING, "request to export directory %s below nearest filesystem %s",
 		     p, exp->m_export.e_path);
-		*error = NFSERR_ACCES;
+		*error = MNT3ERR_ACCES;
 		return NULL;
 	}
 	if (exp->m_export.e_mountpoint &&
@@ -511,7 +511,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 				  exp->m_export.e_path)) {
 		xlog(L_WARNING, "request to export an unmounted filesystem: %s",
 		     p);
-		*error = NFSERR_NOENT;
+		*error = MNT3ERR_NOENT;
 		return NULL;
 	}
 
@@ -522,12 +522,12 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 		 */
 
 		if (cache_export(exp, p)) {
-			*error = NFSERR_ACCES;
+			*error = MNT3ERR_ACCES;
 			return NULL;
 		}
 		fh = cache_get_filehandle(exp, v3?64:32, p);
 		if (fh == NULL) {
-			*error = NFSERR_ACCES;
+			*error = MNT3ERR_ACCES;
 			return NULL;
 		}
 	} else {
@@ -557,11 +557,11 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 
 		if (fh == NULL) {
 			xlog(L_WARNING, "getfh failed: %s", strerror(errno));
-			*error = NFSERR_ACCES;
+			*error = MNT3ERR_ACCES;
 			return NULL;
 		}
 	}
-	*error = NFS_OK;
+	*error = MNT_OK;
 	mountlist_add(host_ntop(sap, buf, sizeof(buf)), p);
 	if (expret)
 		*expret = exp;

