Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40105 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753722Ab0IMRVM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:21:12 -0400
Received: by mail-gx0-f174.google.com with SMTP id 23so2101445gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:21:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/12] mountd: add IPv6 support in auth_authenticate()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:21:08 -0400
Message-ID: <20100913172108.19017.20534.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make the entire auth_authenticate() code path address-family agnostic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/auth.c   |   52 +++++++++++++++++++++++++------------------------
 utils/mountd/mountd.c |   14 +++++++------
 utils/mountd/mountd.h |    5 +++--
 utils/mountd/rmtab.c  |    3 ++-
 4 files changed, 39 insertions(+), 35 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 04487e5..ccc849a 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -15,6 +15,8 @@
 #include <arpa/inet.h>
 #include <errno.h>
 #include <unistd.h>
+
+#include "sockaddr.h"
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -111,13 +113,14 @@ auth_reload()
 }
 
 static char *
-get_client_hostname(struct sockaddr_in *caller, struct addrinfo *ai,
+get_client_hostname(const struct sockaddr *caller, struct addrinfo *ai,
 		enum auth_error *error)
 {
+	char buf[INET6_ADDRSTRLEN];
 	char *n;
 
 	if (use_ipaddr)
-		return strdup(inet_ntoa(caller->sin_addr));
+		return strdup(host_ntop(caller, buf, sizeof(buf)));
 	n = client_compose(ai);
 	*error = unknown_host;
 	if (!n)
@@ -130,8 +133,8 @@ get_client_hostname(struct sockaddr_in *caller, struct addrinfo *ai,
 
 /* return static nfs_export with details filled in */
 static nfs_export *
-auth_authenticate_newcache(struct sockaddr_in *caller,
-			   char *path, struct addrinfo *ai,
+auth_authenticate_newcache(const struct sockaddr *caller,
+			   const char *path, struct addrinfo *ai,
 			   enum auth_error *error)
 {
 	nfs_export *exp;
@@ -144,7 +147,7 @@ auth_authenticate_newcache(struct sockaddr_in *caller,
 		return NULL;
 
 	my_client.m_naddr = 1;
-	set_addrlist_in(&my_client, 0, caller);
+	set_addrlist(&my_client, 0, caller);
 	my_exp.m_client = &my_client;
 
 	exp = NULL;
@@ -168,9 +171,8 @@ auth_authenticate_newcache(struct sockaddr_in *caller,
 }
 
 static nfs_export *
-auth_authenticate_internal(struct sockaddr_in *caller,
-			   char *path, struct addrinfo *ai,
-			   enum auth_error *error)
+auth_authenticate_internal(const struct sockaddr *caller, const char *path,
+		struct addrinfo *ai, enum auth_error *error)
 {
 	nfs_export *exp;
 
@@ -190,7 +192,7 @@ auth_authenticate_internal(struct sockaddr_in *caller,
 		return NULL;
 	}
 	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
-		     ntohs(caller->sin_port) >= IPPORT_RESERVED) {
+		     nfs_get_port(caller) >= IPPORT_RESERVED) {
 		*error = illegal_port;
 		return NULL;
 	}
@@ -200,18 +202,19 @@ auth_authenticate_internal(struct sockaddr_in *caller,
 }
 
 nfs_export *
-auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
+auth_authenticate(const char *what, const struct sockaddr *caller,
+		const char *path)
 {
 	nfs_export	*exp = NULL;
 	char		epath[MAXPATHLEN+1];
 	char		*p = NULL;
+	char		buf[INET6_ADDRSTRLEN];
 	struct addrinfo *ai = NULL;
-	struct in_addr	addr = caller->sin_addr;
 	enum auth_error	error = bad_path;
 
-	if (path [0] != '/') {
-		xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
-		     what, inet_ntoa(addr), path);
+	if (path[0] != '/') {
+		xlog(L_WARNING, "Bad path in %s request from %s: \"%s\"",
+			     what, host_ntop(caller, buf, sizeof(buf)), path);
 		return exp;
 	}
 
@@ -219,14 +222,13 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 	epath[sizeof (epath) - 1] = '\0';
 	auth_fixpath(epath); /* strip duplicate '/' etc */
 
-	ai = client_resolve((struct sockaddr *)caller);
+	ai = client_resolve(caller);
 	if (ai == NULL)
 		return exp;
 
 	/* Try the longest matching exported pathname. */
 	while (1) {
-		exp = auth_authenticate_internal(caller, epath,
-						 ai, &error);
+		exp = auth_authenticate_internal(caller, epath, ai, &error);
 		if (exp || (error != not_exported && error != no_entry))
 			break;
 		/* We have to treat the root, "/", specially. */
@@ -239,12 +241,12 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 	switch (error) {
 	case bad_path:
 		xlog(L_WARNING, "bad path in %s request from %s: \"%s\"",
-		     what, inet_ntoa(addr), path);
+		     what, host_ntop(caller, buf, sizeof(buf)), path);
 		break;
 
 	case unknown_host:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): unmatched host",
-		     what, inet_ntoa(addr), path, epath);
+		     what, host_ntop(caller, buf, sizeof(buf)), path, epath);
 		break;
 
 	case no_entry:
@@ -258,17 +260,17 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 		break;
 
 	case illegal_port:
-		xlog(L_WARNING, "refused %s request from %s for %s (%s): illegal port %d",
-		     what, ai->ai_canonname, path, epath, ntohs(caller->sin_port));
+		xlog(L_WARNING, "refused %s request from %s for %s (%s): illegal port %u",
+		     what, ai->ai_canonname, path, epath, nfs_get_port(caller));
 		break;
 
 	case success:
-		xlog(L_NOTICE, "authenticated %s request from %s:%d for %s (%s)",
-		     what, ai->ai_canonname, ntohs(caller->sin_port), path, epath);
+		xlog(L_NOTICE, "authenticated %s request from %s:%u for %s (%s)",
+		     what, ai->ai_canonname, nfs_get_port(caller), path, epath);
 		break;
 	default:
-		xlog(L_NOTICE, "%s request from %s:%d for %s (%s) gave %d",
-		     what, ai->ai_canonname, ntohs(caller->sin_port),
+		xlog(L_NOTICE, "%s request from %s:%u for %s (%s) gave %d",
+		     what, ai->ai_canonname, nfs_get_port(caller),
 			path, epath, error);
 	}
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 78f26c2..c8ea3f7 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -237,9 +237,9 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *UNUSED(resp))
 		p = rpath;
 	}
 
-	if (!(exp = auth_authenticate("unmount", sin, p))) {
+	exp = auth_authenticate("unmount", (struct sockaddr *)sin, p);
+	if (exp == NULL)
 		return 1;
-	}
 
 	mountlist_del(inet_ntoa(sin->sin_addr), p);
 	return 1;
@@ -313,10 +313,10 @@ mount_pathconf_2_svc(struct svc_req *rqstp, dirpath *path, ppathcnf *res)
 	}
 
 	/* Now authenticate the intruder... */
-	exp = auth_authenticate("pathconf", sin, p);
-	if (!exp) {
+	exp = auth_authenticate("pathconf", (struct sockaddr *)sin, p);
+	if (exp == NULL)
 		return 1;
-	} else if (stat(p, &stb) < 0) {
+	else if (stat(p, &stb) < 0) {
 		xlog(L_WARNING, "can't stat exported dir %s: %s",
 				p, strerror(errno));
 		return 1;
@@ -415,8 +415,8 @@ get_rootfh(struct svc_req *rqstp, dirpath *path, nfs_export **expret,
 	}
 
 	/* Now authenticate the intruder... */
-	exp = auth_authenticate("mount", sin, p);
-	if (!exp) {
+	exp = auth_authenticate("mount", (struct sockaddr *)sin, p);
+	if (exp == NULL) {
 		*error = NFSERR_ACCES;
 		return NULL;
 	}
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index 31bacb5..96e9bf1 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -41,8 +41,9 @@ bool_t		mount_mnt_3_svc(struct svc_req *, dirpath *, mountres3 *);
 void		mount_dispatch(struct svc_req *, SVCXPRT *);
 void		auth_init(char *export_file);
 unsigned int	auth_reload(void);
-nfs_export *	auth_authenticate(char *what, struct sockaddr_in *sin,
-					char *path);
+nfs_export *	auth_authenticate(const char *what,
+					const struct sockaddr *caller,
+					const char *path);
 void		auth_export(nfs_export *exp);
 
 void		mountlist_add(char *host, const char *path);
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index ba0fcf6..d23712b 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -157,7 +157,8 @@ mountlist_del_all(struct sockaddr_in *sin)
 
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
 		if (strcmp(rep->r_client, hostname) == 0 &&
-		    (exp = auth_authenticate("umountall", sin, rep->r_path)))
+		    (exp = auth_authenticate("umountall",
+				(struct sockaddr *)sin, rep->r_path)))
 			continue;
 		fputrmtabent(fp, rep, NULL);
 	}

