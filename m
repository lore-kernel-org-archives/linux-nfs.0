Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16944 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875Ab2KZURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:14 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qAQKHDi4001692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 15:17:13 -0500
Received: from smallhat.bos.devel.redhat.com (vpn-9-97.rdu.redhat.com [10.11.9.97])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id qAQKHBB3026413
	for <linux-nfs@vger.kernel.org>; Mon, 26 Nov 2012 15:17:13 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] mountd: Return ENOENT when an export does not exist.
Date: Mon, 26 Nov 2012 15:17:09 -0500
Message-Id: <1353961029-6317-3-git-send-email-steved@redhat.com>
In-Reply-To: <1353961029-6317-1-git-send-email-steved@redhat.com>
References: <1353961029-6317-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an export does not exist, ENOENT should be
returned instead of EACCES

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/auth.c   | 11 ++++++++++-
 utils/mountd/mountd.c |  5 ++++-
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 508040a..c81c3a8 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -232,7 +232,7 @@ auth_authenticate(const char *what, const struct sockaddr *caller,
 	char		*p = NULL;
 	char		buf[INET6_ADDRSTRLEN];
 	struct addrinfo *ai = NULL;
-	enum auth_error	error = bad_path;
+	enum auth_error	error = bad_path, first_error = success;
 
 	if (path[0] != '/') {
 		xlog(L_WARNING, "Bad path in %s request from %s: \"%s\"",
@@ -258,7 +258,15 @@ auth_authenticate(const char *what, const struct sockaddr *caller,
 		p = strrchr(epath, '/');
 		if (p == epath) p++;
 		*p = '\0';
+		/* 
+		 * Recored the first error, ignoring the error when "/" 
+		 * is tried and fails
+		 */
+		if (first_error == success)
+			first_error = error;
 	}
+	if (first_error != success)
+		error = first_error;
 
 	switch (error) {
 	case bad_path:
@@ -277,6 +285,7 @@ auth_authenticate(const char *what, const struct sockaddr *caller,
 		break;
 
 	case not_exported:
+		errno = ENOENT;
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): not exported",
 		     what, ai->ai_canonname, path, epath);
 		break;
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 993b6e6..efd4b49 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -472,7 +472,10 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 	/* Now authenticate the intruder... */
 	exp = auth_authenticate("mount", sap, p);
 	if (exp == NULL) {
-		*error = MNT3ERR_ACCES;
+		if (errno == ENOENT)
+			*error = MNT3ERR_NOENT;
+		else
+			*error = MNT3ERR_ACCES;
 		return NULL;
 	}
 	if (stat(p, &stb) < 0) {
-- 
1.7.11.7

