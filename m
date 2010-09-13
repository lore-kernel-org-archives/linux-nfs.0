Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62750 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab0IMRVW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:21:22 -0400
Received: by pzk34 with SMTP id 34so2221811pzk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:21:21 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/12] mountd: Support IPv6 in mountd's svc routines
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:21:18 -0400
Message-ID: <20100913172118.19017.73274.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Replace IPv4-specific code with use of our generic hostname helpers
in the routines that handle incoming MNT RPC requests.

These functions will support IPv6 without additional changes, once
IPv6 is enabled in the generic hostname helpers.

As part of this update, I've modified all of mountd's _svc routines
to use a debug message format that is consistent with statd.  It may
be overkill for some of these; if so we can pull them out later.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |   79 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 59 insertions(+), 20 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index c8ea3f7..19dc4ee 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -192,18 +192,28 @@ sig_hup (int sig)
 }
 
 bool_t
-mount_null_1_svc(struct svc_req *UNUSED(rqstp), void *UNUSED(argp), 
+mount_null_1_svc(struct svc_req *rqstp, void *UNUSED(argp), 
 	void *UNUSED(resp))
 {
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char buf[INET6_ADDRSTRLEN];
+
+	xlog(D_CALL, "Received NULL request from %s",
+		host_ntop(sap, buf, sizeof(buf)));
+
 	return 1;
 }
 
 bool_t
 mount_mnt_1_svc(struct svc_req *rqstp, dirpath *path, fhstatus *res)
 {
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char buf[INET6_ADDRSTRLEN];
 	struct nfs_fh_len *fh;
 
-	xlog(D_CALL, "MNT1(%s) called", *path);
+	xlog(D_CALL, "Received MNT1(%s) request from %s", *path,
+		host_ntop(sap, buf, sizeof(buf)));
+
 	fh = get_rootfh(rqstp, path, NULL, &res->fhs_status, 0);
 	if (fh)
 		memcpy(&res->fhstatus_u.fhs_fhandle, fh->fh_handle, 32);
@@ -213,9 +223,12 @@ mount_mnt_1_svc(struct svc_req *rqstp, dirpath *path, fhstatus *res)
 bool_t
 mount_dump_1_svc(struct svc_req *rqstp, void *UNUSED(argp), mountlist *res)
 {
-	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char buf[INET6_ADDRSTRLEN];
+
+	xlog(D_CALL, "Received DUMP request from %s",
+		host_ntop(sap, buf, sizeof(buf)));
 
-	xlog(D_CALL, "dump request from %s.", inet_ntoa(addr->sin_addr));
 	*res = mountlist_list();
 
 	return 1;
@@ -224,10 +237,11 @@ mount_dump_1_svc(struct svc_req *rqstp, void *UNUSED(argp), mountlist *res)
 bool_t
 mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *UNUSED(resp))
 {
-	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
 	nfs_export	*exp;
 	char		*p = *argp;
 	char		rpath[MAXPATHLEN+1];
+	char		buf[INET6_ADDRSTRLEN];
 
 	if (*p == '\0')
 		p = "/";
@@ -237,11 +251,14 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *UNUSED(resp))
 		p = rpath;
 	}
 
-	exp = auth_authenticate("unmount", (struct sockaddr *)sin, p);
+	xlog(D_CALL, "Received UMNT(%s) request from %s", p,
+		host_ntop(sap, buf, sizeof(buf)));
+
+	exp = auth_authenticate("unmount", sap, p);
 	if (exp == NULL)
 		return 1;
 
-	mountlist_del(inet_ntoa(sin->sin_addr), p);
+	mountlist_del(host_ntop(sap, buf, sizeof(buf)), p);
 	return 1;
 }
 
@@ -249,6 +266,12 @@ bool_t
 mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp), 
 	void *UNUSED(resp))
 {
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char		buf[INET6_ADDRSTRLEN];
+
+	xlog(D_CALL, "Received UMNTALL request from %s",
+		host_ntop(sap, buf, sizeof(buf)));
+
 	/* Reload /etc/xtab if necessary */
 	auth_reload();
 
@@ -259,9 +282,12 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp),
 bool_t
 mount_export_1_svc(struct svc_req *rqstp, void *UNUSED(argp), exports *resp)
 {
-	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char buf[INET6_ADDRSTRLEN];
+
+	xlog(D_CALL, "Received EXPORT request from %s.",
+		host_ntop(sap, buf, sizeof(buf)));
 
-	xlog(D_CALL, "export request from %s.", inet_ntoa(addr->sin_addr));
 	*resp = get_exportlist();
 		
 	return 1;
@@ -270,9 +296,12 @@ mount_export_1_svc(struct svc_req *rqstp, void *UNUSED(argp), exports *resp)
 bool_t
 mount_exportall_1_svc(struct svc_req *rqstp, void *UNUSED(argp), exports *resp)
 {
-	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char buf[INET6_ADDRSTRLEN];
+
+	xlog(D_CALL, "Received EXPORTALL request from %s.",
+		host_ntop(sap, buf, sizeof(buf)));
 
-	xlog(D_CALL, "exportall request from %s.", inet_ntoa(addr->sin_addr));
 	*resp = get_exportlist();
 
 	return 1;
@@ -292,11 +321,12 @@ mount_exportall_1_svc(struct svc_req *rqstp, void *UNUSED(argp), exports *resp)
 bool_t
 mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 {
-	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
 	struct stat	stb;
 	nfs_export	*exp;
 	char		rpath[MAXPATHLEN+1];
 	char		*p = *path;
+	char buf[INET6_ADDRSTRLEN];
 
 	memset(res, 0, sizeof(*res));
 
@@ -312,8 +342,11 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 		p = rpath;
 	}
 
+	xlog(D_CALL, "Received PATHCONF(%s) request from %s", p,
+		host_ntop(sap, buf, sizeof(buf)));
+
 	/* Now authenticate the intruder... */
-	exp = auth_authenticate("pathconf", (struct sockaddr *)sin, p);
+	exp = auth_authenticate("pathconf", sap, p);
 	if (exp == NULL)
 		return 1;
 	else if (stat(p, &stb) < 0) {
@@ -376,11 +409,15 @@ static void set_authflavors(struct mountres3_ok *ok, nfs_export *exp)
 bool_t
 mount_mnt_3_svc(struct svc_req *rqstp, dirpath *path, mountres3 *res)
 {
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
 	struct mountres3_ok *ok = &res->mountres3_u.mountinfo;
+	char buf[INET6_ADDRSTRLEN];
 	nfs_export *exp;
 	struct nfs_fh_len *fh;
 
-	xlog(D_CALL, "MNT3(%s) called", *path);
+	xlog(D_CALL, "Received MNT3(%s) request from %s", *path,
+		host_ntop(sap, buf, sizeof(buf)));
+
 	fh = get_rootfh(rqstp, path, &exp, &res->fhs_status, 1);
 	if (!fh)
 		return 1;
@@ -395,12 +432,13 @@ static struct nfs_fh_len *
 get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 		mountstat3 *error, int v3)
 {
-	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
 	struct stat	stb, estb;
 	nfs_export	*exp;
 	struct nfs_fh_len *fh;
 	char		rpath[MAXPATHLEN+1];
 	char		*p = *path;
+	char		buf[INET6_ADDRSTRLEN];
 
 	if (*p == '\0')
 		p = "/";
@@ -415,7 +453,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 	}
 
 	/* Now authenticate the intruder... */
-	exp = auth_authenticate("mount", (struct sockaddr *)sin, p);
+	exp = auth_authenticate("mount", sap, p);
 	if (exp == NULL) {
 		*error = NFSERR_ACCES;
 		return NULL;
@@ -484,13 +522,14 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 			xtab_append(exp);
 
 		if (v3)
-			fh = getfh_size(sin, p, 64);
+			fh = getfh_size((struct sockaddr_in *)sap, p, 64);
 		if (!v3 || (fh == NULL && errno == EINVAL)) {
 			/* We first try the new nfs syscall. */
-			fh = getfh(sin, p);
+			fh = getfh((struct sockaddr_in *)sap, p);
 			if (fh == NULL && errno == EINVAL)
 				/* Let's try the old one. */
-				fh = getfh_old(sin, stb.st_dev, stb.st_ino);
+				fh = getfh_old((struct sockaddr_in *)sap,
+						stb.st_dev, stb.st_ino);
 		}
 		if (fh == NULL && !did_export) {
 			exp->m_exported = 0;
@@ -504,7 +543,7 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 		}
 	}
 	*error = NFS_OK;
-	mountlist_add(inet_ntoa(sin->sin_addr), p);
+	mountlist_add(host_ntop(sap, buf, sizeof(buf)), p);
 	if (expret)
 		*expret = exp;
 	return fh;

