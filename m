Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ip013087.uvm.edu ([132.198.13.87]:53802 "EHLO
	ip0af50343.int.uvm.edu" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1749667Ab1GMTJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2011 15:09:55 -0400
From: Benjamin Coddington <bcodding@uvm.edu>
Date: Wed, 13 Jul 2011 13:35:40 -0400
Subject: [PATCH] svcgssd: acquire creds for multiple server identities
To: linux-nfs@vger.kernel.org
Message-Id: <20110713174812.39F32635932B@planck.uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For clustered servers, svcgssd may need to establish
contexts under different network names.  Allow specification
of multiple service identities.  Try to establish a security context
with each identity in the order specified.
---
 utils/gssd/gss_util.c     |   93 +++++++++++++++++++++++++++++++++------------
 utils/gssd/gss_util.h     |   13 +++++-
 utils/gssd/svcgssd.c      |   43 ++++++++++++++++++---
 utils/gssd/svcgssd.man    |    2 +-
 utils/gssd/svcgssd_proc.c |   34 ++++++++++------
 5 files changed, 137 insertions(+), 48 deletions(-)

diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 190b497..c145e8e 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -93,7 +93,7 @@
 #endif
 
 /* Global gssd_credentials handle */
-gss_cred_id_t gssd_creds;
+struct gssd_cred *gssd_creds = NULL;
 
 gss_OID g_mechOid = GSS_C_NULL_OID;;
 
@@ -253,6 +253,9 @@ display_status_2(char *m, u_int32_t major, u_int32_t minor, const gss_OID mech)
 	if (major == GSS_S_CREDENTIALS_EXPIRED)
 		msg_verbosity = 1;
 
+	if (major == GSS_S_FAILURE)
+		msg_verbosity = 1;
+
 	printerr(msg_verbosity, "ERROR: GSS-API: error in %s(): %s (%s) - %s\n",
 		 m, gss_display_error(major), maj, min);
 
@@ -268,46 +271,86 @@ pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat, const gss_OID mech)
 	display_status_2(msg, maj_stat, min_stat, mech);
 }
 
+void
+gssd_cred_add(struct gssd_cred *newcred) {
+	struct gssd_cred *current = gssd_creds;
+
+	if (!gssd_creds) {
+		gssd_creds = newcred;
+		return;
+	}
+
+	while (current->next) {
+		current = current->next;
+	}
+	current->next = newcred;
+}
+
 int
-gssd_acquire_cred(char *server_name, const gss_OID oid)
+gssd_acquire_creds(char **server_names, const gss_OID oid)
 {
 	gss_buffer_desc name;
 	gss_name_t target_name;
 	u_int32_t maj_stat, min_stat;
 	u_int32_t ignore_maj_stat, ignore_min_stat;
 	gss_buffer_desc pbuf;
+	struct gssd_cred *newcred;
+	int i;
 
-	name.value = (void *)server_name;
-	name.length = strlen(server_name);
+	/* Allocate gssd_cred structure */
+	for (i = 0; server_names[i]; i++) {
 
-	maj_stat = gss_import_name(&min_stat, &name,
-			oid,
-			&target_name);
+		newcred = calloc(1, sizeof(struct gssd_cred));
+		if (!newcred) {
+			perror("calloc");
+			return (FALSE);
+		}
 
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_import_name", maj_stat, min_stat, g_mechOid);
-		return (FALSE);
-	}
+		name.value = (void *)server_names[i];
+		name.length = strlen(server_names[i]);
 
-	maj_stat = gss_acquire_cred(&min_stat, target_name, 0,
-			GSS_C_NULL_OID_SET, GSS_C_ACCEPT,
-			&gssd_creds, NULL, NULL);
+		maj_stat = gss_import_name(&min_stat, &name,
+				oid,
+				&target_name);
 
-	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_acquire_cred", maj_stat, min_stat, g_mechOid);
-		ignore_maj_stat = gss_display_name(&ignore_min_stat,
-				target_name, &pbuf, NULL);
-		if (ignore_maj_stat == GSS_S_COMPLETE) {
-			printerr(1, "Unable to obtain credentials for '%.*s'\n",
-				 pbuf.length, pbuf.value);
-			ignore_maj_stat = gss_release_buffer(&ignore_min_stat,
-							     &pbuf);
+		if (maj_stat != GSS_S_COMPLETE) {
+			pgsserr("gss_import_name", maj_stat, min_stat, g_mechOid);
+			return (FALSE);
+		}
+
+		maj_stat = gss_acquire_cred(&min_stat, target_name, 0,
+				GSS_C_NULL_OID_SET, GSS_C_ACCEPT,
+				&newcred->cred, NULL, NULL);
+
+		if (maj_stat != GSS_S_COMPLETE) {
+			pgsserr("gss_acquire_cred", maj_stat, min_stat, g_mechOid);
+			ignore_maj_stat = gss_display_name(&ignore_min_stat,
+					target_name, &pbuf, NULL);
+
+			if (ignore_maj_stat == GSS_S_COMPLETE) {
+				printerr(0, "Unable to obtain credentials for '%.*s'\n",
+						pbuf.length, pbuf.value);
+				ignore_maj_stat = gss_release_buffer(&ignore_min_stat,
+						&pbuf);
+			}
+		}
+
+		ignore_maj_stat = gss_release_name(&ignore_min_stat, &target_name);
+
+		if (maj_stat == GSS_S_COMPLETE) {
+			newcred->server_name = server_names[i];
+			gssd_cred_add(newcred);
 		}
+		else
+			return (FALSE);
 	}
 
-	ignore_maj_stat = gss_release_name(&ignore_min_stat, &target_name);
+	if (i == 0) {
+		printerr(0, "No server names entered for gssd_acquire_creds\n");
+		return (FALSE);
+	}
 
-	return (maj_stat == GSS_S_COMPLETE);
+	return (TRUE);
 }
 
 int gssd_check_mechs(void)
diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
index 67b3077..e6e2fee 100644
--- a/utils/gssd/gss_util.h
+++ b/utils/gssd/gss_util.h
@@ -35,9 +35,16 @@
 #include <rpc/rpc.h>
 #include "write_bytes.h"
 
-extern gss_cred_id_t	gssd_creds;
-
-int gssd_acquire_cred(char *server_name, const gss_OID oid);
+/* Global gssd_credentials handles */
+typedef struct gssd_cred {
+	struct gssd_cred *next;
+	char 		 *server_name;
+	gss_cred_id_t    cred;
+} gssd_cred;
+extern struct gssd_cred *gssd_creds;
+
+void gssd_cred_add(struct gssd_cred *newcred);
+int gssd_acquire_creds(char **server_names, const gss_OID oid);
 void pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat,
 	const gss_OID mech);
 int gssd_check_mechs(void);
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 17af2da..504a37c 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -167,11 +167,38 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal [-p principal ...]]\n",
 		progname);
 	exit(1);
 }
 
+static char **
+service_list_add(char **service_list, char *newprinc)
+{
+	int i = 0;
+
+	if (service_list)
+		for (i=0; service_list[i]; i++)
+			;
+	if (!service_list)
+		service_list = malloc(sizeof(*service_list) * (i + 2));
+	else
+		service_list = realloc(service_list, sizeof(*service_list) * (i + 2));
+	if (!service_list) {
+		perror("malloc");
+		exit(1);
+	}
+	service_list[i + 1] = NULL;
+	service_list[i] = malloc(strlen(newprinc) + 1);
+	if (!service_list[i]) {
+		perror("malloc");
+		exit(1);
+	}
+	sprintf(service_list[i], "%s", newprinc);
+
+	return service_list;
+}
+
 int
 main(int argc, char *argv[])
 {
@@ -183,7 +210,8 @@ main(int argc, char *argv[])
 	int opt, status;
 	extern char *optarg;
 	char *progname;
-	char *principal = NULL;
+	char *default_service_list[] = { GSSD_SERVICE_NAME, (char *)NULL };
+	char **service_list = NULL;
 
 	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
 		switch (opt) {
@@ -203,7 +231,7 @@ main(int argc, char *argv[])
 				rpc_verbosity++;
 				break;
 			case 'p':
-				principal = optarg;
+				service_list = service_list_add(service_list, optarg);
 				break;
 			default:
 				usage(argv[0]);
@@ -249,11 +277,11 @@ main(int argc, char *argv[])
 	signal(SIGHUP, sig_hup);
 
 	if (get_creds) {
-		if (principal)
-			status = gssd_acquire_cred(principal, 
+		if (service_list)
+			status = gssd_acquire_creds(service_list,
 				((const gss_OID)GSS_C_NT_USER_NAME));
 		else
-			status = gssd_acquire_cred(GSSD_SERVICE_NAME, 
+			status = gssd_acquire_creds(default_service_list,
 				(const gss_OID)GSS_C_NT_HOSTBASED_SERVICE);
 		if (status == FALSE) {
 			printerr(0, "unable to obtain root (machine) credentials\n");
@@ -262,6 +290,9 @@ main(int argc, char *argv[])
 				"/etc/krb5.keytab?\n");
 			exit(1);
 		}
+	} else {
+		struct gssd_cred null_cred = { .cred = NULL };
+		gssd_cred_add(&null_cred);
 	}
 
 	if (!fg)
diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
index 1c7bb32..d425b83 100644
--- a/utils/gssd/svcgssd.man
+++ b/utils/gssd/svcgssd.man
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.svcgssd \- server-side rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p principal]"
+.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p principal [-p principal ...]]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 0ecbab6..cf8ba8a 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -408,6 +408,7 @@ handle_nullreq(FILE *f) {
 	static char		*cp;
 	int32_t			ctx_endtime;
 	char			*hostbased_name = NULL;
+	struct gssd_cred	*gssd_cc;
 
 	printerr(1, "handling null request\n");
 
@@ -443,24 +444,31 @@ handle_nullreq(FILE *f) {
 		memcpy(&ctx, in_handle.value, in_handle.length);
 	}
 
-	maj_stat = gss_accept_sec_context(&min_stat, &ctx, gssd_creds,
-			&in_tok, GSS_C_NO_CHANNEL_BINDINGS, &client_name,
-			&mech, &out_tok, &ret_flags, NULL, NULL);
-
-	if (maj_stat == GSS_S_CONTINUE_NEEDED) {
-		printerr(1, "gss_accept_sec_context GSS_S_CONTINUE_NEEDED\n");
+	for (gssd_cc = gssd_creds; gssd_cc; gssd_cc = gssd_cc->next) {
+		printerr(1, "trying to accept context as %s\n", gssd_cc->server_name);
+		maj_stat = gss_accept_sec_context(&min_stat, &ctx, gssd_cc->cred,
+				&in_tok, GSS_C_NO_CHANNEL_BINDINGS, &client_name,
+				&mech, &out_tok, &ret_flags, NULL, NULL);
+
+		if (maj_stat == GSS_S_CONTINUE_NEEDED) {
+		    printerr(1, "gss_accept_sec_context GSS_S_CONTINUE_NEEDED\n");
+
+		    /* Save the context handle for future calls */
+		    out_handle.length = sizeof(ctx);
+		    memcpy(out_handle.value, &ctx, sizeof(ctx));
+		    goto continue_needed;
+		} else if (maj_stat == GSS_S_COMPLETE) {
+		    break; /* we have found a matching credential */
+		}
 
-		/* Save the context handle for future calls */
-		out_handle.length = sizeof(ctx);
-		memcpy(out_handle.value, &ctx, sizeof(ctx));
-		goto continue_needed;
-	}
-	else if (maj_stat != GSS_S_COMPLETE) {
 		printerr(1, "WARNING: gss_accept_sec_context failed\n");
 		pgsserr("handle_nullreq: gss_accept_sec_context",
 			maj_stat, min_stat, mech);
-		goto out_err;
 	}
+
+	if (maj_stat != GSS_S_COMPLETE)
+		goto out_err;
+
 	if (get_ids(client_name, mech, &cred)) {
 		/* get_ids() prints error msg */
 		maj_stat = GSS_S_BAD_NAME; /* XXX ? */
-- 
1.7.5

