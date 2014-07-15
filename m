Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313AbaGOPJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:47 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/15] libtirpc_debug: Converted the rest of the #ifdef DEBUGs
Date: Tue, 15 Jul 2014 11:09:25 -0400
Message-Id: <1405436974-4161-7-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the rest of the fprintf(stderr) surrounded
by #ifdef DEBUGS with the LIBTIRPC_DEBUG() macro

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c     | 18 ++++++------------
 src/getpublickey.c | 13 ++++++-------
 src/netnamer.c     | 20 ++++++++------------
 src/svc_auth_gss.c |  2 --
 4 files changed, 20 insertions(+), 33 deletions(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index 76bab66..e636e7e 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -49,6 +49,8 @@
 #include <netinet/in.h>
 #include <gssapi/gssapi.h>
 
+#include "debug.h"
+
 static void	authgss_nextverf(AUTH *);
 static bool_t	authgss_marshal(AUTH *, XDR *);
 static bool_t	authgss_refresh(AUTH *, void *);
@@ -164,9 +166,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 		free(auth);
 		return (NULL);
 	}
-#ifdef DEBUG
-	fprintf(stderr, "authgss_create: name is %p\n", name);
-#endif
+	LIBTIRPC_DEBUG(2, ("authgss_create: name is %p\n", name));
 	if (name != GSS_C_NO_NAME) {
 		if (gss_duplicate_name(&min_stat, name, &gd->name)
 						!= GSS_S_COMPLETE) {
@@ -179,9 +179,7 @@ authgss_create(CLIENT *clnt, gss_name_t name, struct rpc_gss_sec *sec)
 	else
 		gd->name = name;
 
-#ifdef DEBUG
-	fprintf(stderr, "authgss_create: gd->name is %p\n", gd->name);
-#endif
+	LIBTIRPC_DEBUG(2, ("authgss_create: gd->name is %p\n", gd->name));
 	gd->clnt = clnt;
 	gd->ctx = GSS_C_NO_CONTEXT;
 	gd->sec = *sec;
@@ -234,9 +232,7 @@ authgss_create_default(CLIENT *clnt, char *service, struct rpc_gss_sec *sec)
 	auth = authgss_create(clnt, name, sec);
 
 	if (name != GSS_C_NO_NAME) {
-#ifdef DEBUG
-	fprintf(stderr, "authgss_create_default: freeing name %p\n", name);
-#endif
+		LIBTIRPC_DEBUG(1, ("authgss_create_default: freeing name %p\n", name));
  		gss_release_name(&min_stat, &name);
 	}
 
@@ -627,9 +623,7 @@ authgss_destroy(AUTH *auth)
 
 	authgss_destroy_context(auth);
 
-#ifdef DEBUG
-	fprintf(stderr, "authgss_destroy: freeing name %p\n", gd->name);
-#endif
+	LIBTIRPC_DEBUG(2, ("authgss_destroy: freeing name %p\n", gd->name));
 	if (gd->name != GSS_C_NO_NAME)
 		gss_release_name(&min_stat, &gd->name);
 
diff --git a/src/getpublickey.c b/src/getpublickey.c
index 332c725..85935d8 100644
--- a/src/getpublickey.c
+++ b/src/getpublickey.c
@@ -46,6 +46,8 @@
 #include <string.h>
 #include <stdlib.h>
 
+#include "debug.h"
+
 #define PKFILE "/etc/publickey"
 
 /*
@@ -120,9 +122,8 @@ getpublicandprivatekey(key, ret)
 			lookup = NULL;
 			err = yp_match(domain, PKMAP, key, strlen(key), &lookup, &len);
 			if (err) {
-#ifdef DEBUG
-				fprintf(stderr, "match failed error %d\n", err);
-#endif
+				LIBTIRPC_DEBUG(1, 
+					("getpublicandprivatekey: match failed error %d\n", err));
 				continue;
 			}
 			lookup[len] = 0;
@@ -131,10 +132,8 @@ getpublicandprivatekey(key, ret)
 			free(lookup);
 			return (2);
 #else /* YP */
-#ifdef DEBUG
-			fprintf(stderr,
-"Bad record in %s '+' -- NIS not supported in this library copy\n", PKFILE);
-#endif /* DEBUG */
+			LIBTIRPC_DEBUG(1, 
+("Bad record in %s '+' -- NIS not supported in this library copy\n", PKFILE));
 			continue;
 #endif /* YP */
 		} else {
diff --git a/src/netnamer.c b/src/netnamer.c
index 9b3b7dc..7da2f0d 100644
--- a/src/netnamer.c
+++ b/src/netnamer.c
@@ -47,6 +47,8 @@
 #include <stdlib.h>
 #include <unistd.h>
 
+#include "debug.h"
+
 static char    *OPSYS = "unix";
 static char    *NETID = "netid.byname";
 static char    *NETIDFILE = "/etc/netid";
@@ -159,10 +161,8 @@ _getgroups(uname, groups)
 		for (i = 0; grp->gr_mem[i]; i++)
 			if (!strcmp(grp->gr_mem[i], uname)) {
 				if (ngroups == NGROUPS) {
-#ifdef DEBUG
-					fprintf(stderr,
-				"initgroups: %s is in too many groups\n", uname);
-#endif
+					LIBTIRPC_DEBUG(1,
+				("_getgroups: %s is in too many groups\n", uname));
 					goto toomany;
 				}
 				/* filter out duplicate group entries */
@@ -279,9 +279,7 @@ getnetid(key, ret)
 			err = yp_match(domain, NETID, key,
 				strlen(key), &lookup, &len);
 			if (err) {
-#ifdef DEBUG
-				fprintf(stderr, "match failed error %d\n", err);
-#endif
+				LIBTIRPC_DEBUG(1, ("getnetid: match failed error %d\n", err));
 				continue;
 			}
 			lookup[len] = 0;
@@ -291,11 +289,9 @@ getnetid(key, ret)
 				fclose(fd);
 			return (2);
 #else	/* YP */
-#ifdef DEBUG
-			fprintf(stderr,
-"Bad record in %s '+' -- NIS not supported in this library copy\n",
-				NETIDFILE);
-#endif
+			LIBTIRPC_DEBUG(1,
+("Bad record in %s '+' -- NIS not supported in this library copy\n",
+				NETIDFILE));
 			continue;
 #endif	/* YP */
 		} else {
diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
index a032dd6..155c8de 100644
--- a/src/svc_auth_gss.c
+++ b/src/svc_auth_gss.c
@@ -248,7 +248,6 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
 				maj_stat, min_stat);
 			return (FALSE);
 		}
-#ifdef DEBUG
 #ifdef HAVE_KRB5
 		{
 			gss_buffer_desc mechname;
@@ -269,7 +268,6 @@ svcauth_gss_accept_sec_context(struct svc_req *rqst,
 			      gd->cname.length, (char *)gd->cname.value,
 			      gd->sec.qop, gd->sec.svc);
 #endif
-#endif /* DEBUG */
 		seq = htonl(gr->gr_win);
 		seqbuf.value = &seq;
 		seqbuf.length = sizeof(seq);
-- 
1.9.3

