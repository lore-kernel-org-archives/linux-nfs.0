Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031079Ab2CITtv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:49:51 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29Jnpra029975
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:49:51 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 2/7] Kill SPKM3: Remove spkm3 support from gssd
Date: Fri,  9 Mar 2012 14:49:41 -0500
Message-Id: <1331322586-4631-3-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/gss_oids.c       |    3 -
 utils/gssd/gss_oids.h       |    1 -
 utils/gssd/gssd.h           |    5 +--
 utils/gssd/gssd_main_loop.c |   11 -----
 utils/gssd/gssd_proc.c      |  106 +-----------------------------------------
 5 files changed, 4 insertions(+), 122 deletions(-)

diff --git a/utils/gssd/gss_oids.c b/utils/gssd/gss_oids.c
index a59c4a6428859ea0229252b063e0bc14164df63d..4362de26fbdcf7d23288da1b712fbd1ab0b4607b 100644
--- a/utils/gssd/gss_oids.c
+++ b/utils/gssd/gss_oids.c
@@ -38,6 +38,3 @@
 /* from kerberos source, gssapi_krb5.c */
 gss_OID_desc krb5oid =
    {9, "\052\206\110\206\367\022\001\002\002"};
-
-gss_OID_desc spkm3oid =
-   {7, "\053\006\001\005\005\001\003"};
diff --git a/utils/gssd/gss_oids.h b/utils/gssd/gss_oids.h
index 8b0a35219430ffa7711bbbdbc7ff3c37ff4ff9a0..fde8532ab3b480e5c43cf5a91abc9265b96d80aa 100644
--- a/utils/gssd/gss_oids.h
+++ b/utils/gssd/gss_oids.h
@@ -34,7 +34,6 @@
 #include <sys/types.h>
 
 extern gss_OID_desc krb5oid;
-extern gss_OID_desc spkm3oid;
 
 #ifndef g_OID_equal
 #define g_OID_equal(o1,o2) \
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index b1b57938c3490802ea659a5e54ca72218a806222..40f824cd19c2056f160c44764acb039a40df8f92 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -55,7 +55,7 @@
 /*
  * The gss mechanisms that we can handle
  */
-enum {AUTHTYPE_KRB5, AUTHTYPE_SPKM3, AUTHTYPE_LIPKEY};
+enum {AUTHTYPE_KRB5, AUTHTYPE_LIPKEY};
 
 
 
@@ -80,8 +80,6 @@ struct clnt_info {
 	char			*protocol;
 	int			krb5_fd;
 	int			krb5_poll_index;
-	int			spkm3_fd;
-	int			spkm3_poll_index;
 	int                     gssd_fd;
 	int                     gssd_poll_index;
 	struct sockaddr_storage addr;
@@ -98,7 +96,6 @@ struct topdirs_info {
 void init_client_list(void);
 int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
-void handle_spkm3_upcall(struct clnt_info *clp);
 void handle_gssd_upcall(struct clnt_info *clp);
 void gssd_run(void);
 
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index b06c223294f2f0aadc928ba8d73d6b711e164ba0..cec09ea5b218fa6d586f5d5798e0280d4dde4125 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -98,17 +98,6 @@ scan_poll_results(int ret)
 			if (!ret)
 				break;
 		}
-		i = clp->spkm3_poll_index;
-		if (i >= 0 && pollarray[i].revents) {
-			if (pollarray[i].revents & POLLHUP)
-				dir_changed = 1;
-			if (pollarray[i].revents & POLLIN)
-				handle_spkm3_upcall(clp);
-			pollarray[clp->spkm3_poll_index].revents = 0;
-			ret--;
-			if (!ret)
-				break;
-		}
 	}
 };
 
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 41328c9b18483e8f7f5d9a2edc8eb9bce9465e30..a51dbaeba3d06e8414356573418bf02b36a15d6c 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -299,15 +299,11 @@ destroy_client(struct clnt_info *clp)
 	if (clp->krb5_poll_index != -1)
 		memset(&pollarray[clp->krb5_poll_index], 0,
 					sizeof(struct pollfd));
-	if (clp->spkm3_poll_index != -1)
-		memset(&pollarray[clp->spkm3_poll_index], 0,
-					sizeof(struct pollfd));
 	if (clp->gssd_poll_index != -1)
 		memset(&pollarray[clp->gssd_poll_index], 0,
 					sizeof(struct pollfd));
 	if (clp->dir_fd != -1) close(clp->dir_fd);
 	if (clp->krb5_fd != -1) close(clp->krb5_fd);
-	if (clp->spkm3_fd != -1) close(clp->spkm3_fd);
 	if (clp->gssd_fd != -1) close(clp->gssd_fd);
 	free(clp->dirname);
 	free(clp->servicename);
@@ -327,10 +323,8 @@ insert_new_clnt(void)
 		goto out;
 	}
 	clp->krb5_poll_index = -1;
-	clp->spkm3_poll_index = -1;
 	clp->gssd_poll_index = -1;
 	clp->krb5_fd = -1;
-	clp->spkm3_fd = -1;
 	clp->gssd_fd = -1;
 	clp->dir_fd = -1;
 
@@ -355,30 +349,22 @@ process_clnt_dir_files(struct clnt_info * clp)
 			snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
 			clp->krb5_fd = open(name, O_RDWR);
 		}
-		if (clp->spkm3_fd == -1) {
-			snprintf(name, sizeof(name), "%s/spkm3", clp->dirname);
-			clp->spkm3_fd = open(name, O_RDWR);
-		}
 
 		/* If we opened a gss-specific pipe, let's try opening
 		 * the new upcall pipe again. If we succeed, close
 		 * gss-specific pipe(s).
 		 */
-		if (clp->krb5_fd != -1 || clp->spkm3_fd != -1) {
+		if (clp->krb5_fd != -1) {
 			clp->gssd_fd = open(gname, O_RDWR);
 			if (clp->gssd_fd != -1) {
 				if (clp->krb5_fd != -1)
 					close(clp->krb5_fd);
 				clp->krb5_fd = -1;
-				if (clp->spkm3_fd != -1)
-					close(clp->spkm3_fd);
-				clp->spkm3_fd = -1;
 			}
 		}
 	}
 
-	if ((clp->krb5_fd == -1) && (clp->spkm3_fd == -1) &&
-			(clp->gssd_fd == -1))
+	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
 		return -1;
 	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
 			clp->dirname);
@@ -431,15 +417,6 @@ insert_clnt_poll(struct clnt_info *clp)
 		pollarray[clp->krb5_poll_index].events |= POLLIN;
 	}
 
-	if ((clp->spkm3_fd != -1) && (clp->spkm3_poll_index == -1)) {
-		if (get_poll_index(&clp->spkm3_poll_index)) {
-			printerr(0, "ERROR: Too many spkm3 clients\n");
-			return -1;
-		}
-		pollarray[clp->spkm3_poll_index].fd = clp->spkm3_fd;
-		pollarray[clp->spkm3_poll_index].events |= POLLIN;
-	}
-
 	return 0;
 }
 
@@ -839,13 +816,6 @@ int create_auth_rpc_client(struct clnt_info *clp,
 		sec.mech = (gss_OID)&krb5oid;
 		sec.req_flags = GSS_C_MUTUAL_FLAG;
 	}
-	else if (authtype == AUTHTYPE_SPKM3) {
-		sec.mech = (gss_OID)&spkm3oid;
-		/* XXX sec.req_flags = GSS_C_ANON_FLAG;
-		 * Need a way to switch....
-		 */
-		sec.req_flags = GSS_C_MUTUAL_FLAG;
-	}
 	else {
 		printerr(0, "ERROR: Invalid authentication type (%d) "
 			"in create_auth_rpc_client\n", authtype);
@@ -919,9 +889,8 @@ int create_auth_rpc_client(struct clnt_info *clp,
 	auth = authgss_create_default(rpc_clnt, clp->servicename, &sec);
 	if (!auth) {
 		/* Our caller should print appropriate message */
-		printerr(2, "WARNING: Failed to create %s context for "
+		printerr(2, "WARNING: Failed to create krb5 context for "
 			    "user with uid %d for server %s\n",
-			(authtype == AUTHTYPE_KRB5 ? "krb5":"spkm3"),
 			 uid, clp->servername);
 		goto out_fail;
 	}
@@ -1103,59 +1072,6 @@ out_return_error:
 	goto out;
 }
 
-/*
- * this code uses the userland rpcsec gss library to create an spkm3
- * context on behalf of the kernel
- */
-static void
-process_spkm3_upcall(struct clnt_info *clp, uid_t uid, int fd)
-{
-	CLIENT			*rpc_clnt = NULL;
-	AUTH			*auth = NULL;
-	struct authgss_private_data pd;
-	gss_buffer_desc		token;
-
-	printerr(2, "handling spkm3 upcall (%s)\n", clp->dirname);
-
-	token.length = 0;
-	token.value = NULL;
-
-	if (create_auth_rpc_client(clp, &rpc_clnt, &auth, uid, AUTHTYPE_SPKM3)) {
-		printerr(0, "WARNING: Failed to create spkm3 context for "
-			    "user with uid %d\n", uid);
-		goto out_return_error;
-	}
-
-	if (!authgss_get_private_data(auth, &pd)) {
-		printerr(0, "WARNING: Failed to obtain authentication "
-			    "data for user with uid %d for server %s\n",
-			 uid, clp->servername);
-		goto out_return_error;
-	}
-
-	if (serialize_context_for_kernel(pd.pd_ctx, &token, &spkm3oid, NULL)) {
-		printerr(0, "WARNING: Failed to serialize spkm3 context for "
-			    "user with uid %d for server\n",
-			 uid, clp->servername);
-		goto out_return_error;
-	}
-
-	do_downcall(fd, uid, &pd, &token);
-
-out:
-	if (token.value)
-		free(token.value);
-	if (auth)
-		AUTH_DESTROY(auth);
-	if (rpc_clnt)
-		clnt_destroy(rpc_clnt);
-	return;
-
-out_return_error:
-	do_error_downcall(fd, uid, -1);
-	goto out;
-}
-
 void
 handle_krb5_upcall(struct clnt_info *clp)
 {
@@ -1171,20 +1087,6 @@ handle_krb5_upcall(struct clnt_info *clp)
 }
 
 void
-handle_spkm3_upcall(struct clnt_info *clp)
-{
-	uid_t			uid;
-
-	if (read(clp->spkm3_fd, &uid, sizeof(uid)) < (ssize_t)sizeof(uid)) {
-		printerr(0, "WARNING: failed reading uid from spkm3 "
-			 "upcall pipe: %s\n", strerror(errno));
-		return;
-	}
-
-	return process_spkm3_upcall(clp, uid, clp->spkm3_fd);
-}
-
-void
 handle_gssd_upcall(struct clnt_info *clp)
 {
 	uid_t			uid;
@@ -1292,8 +1194,6 @@ handle_gssd_upcall(struct clnt_info *clp)
 
 	if (strcmp(mech, "krb5") == 0)
 		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
-	else if (strcmp(mech, "spkm3") == 0)
-		process_spkm3_upcall(clp, uid, clp->gssd_fd);
 	else
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "received unknown gss mech '%s'\n", mech);
-- 
1.7.7.6

