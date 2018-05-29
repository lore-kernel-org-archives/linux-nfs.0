Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:51618 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966399AbeE2Tyv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 15:54:51 -0400
Received: by mail-it0-f66.google.com with SMTP id d10-v6so19994325itj.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 12:54:50 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v126-v6sm6343017iod.58.2018.05.29.12.54.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 12:54:49 -0700 (PDT)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w4TJsmhs015270
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 19:54:48 GMT
Subject: [PATCH v1] gssd: Add "srchost=" upcall parameter
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Tue, 29 May 2018 15:54:48 -0400
Message-ID: <20180529195448.2291.73141.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The callback client used by NFSv4.0 servers to send CB calls has to
use a source principal that is the same as the target principal
that the client used to establish the forward channel.

In multi-homed server set-ups, the domain part of the principal's
hostname may not be the same as server's DNS domain. So gssd can
no longer assume that. The kernel can scrape that domain off the
forward channel's principal and pass that up to gssd.

This patch adds a new parameter, "srchost", to the kernel upcall.
When the kernel presents this new parameter in an upcall, gssd will
use it, along with the "service" parameter, to construct the service
principal for the keytab lookup.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/gssd/gssd_proc.c |   23 +++++++++++++----------
 utils/gssd/krb5_util.c |   27 ++++++++++++++++++---------
 utils/gssd/krb5_util.h |    2 +-
 3 files changed, 32 insertions(+), 20 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index ce73777..8767e26 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -520,8 +520,9 @@ out:
 }
 
 static AUTH *
-krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
-		    char *service, CLIENT **rpc_clnt)
+krb5_use_machine_creds(struct clnt_info *clp, uid_t uid,
+		       char *srchost, char *tgtname, char *service,
+		       CLIENT **rpc_clnt)
 {
 	AUTH	*auth = NULL;
 	char	**credlist = NULL;
@@ -534,7 +535,7 @@ krb5_use_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 
 	do {
 		gssd_refresh_krb5_machine_credential(clp->servername, NULL,
-						service);
+						     service, srchost);
 	/*
 	 * Get a list of credential cache names and try each
 	 * of them until one works or we've tried them all
@@ -594,8 +595,8 @@ out:
  * context on behalf of the kernel
  */
 static void
-process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
-		    char *service)
+process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *srchost,
+		    char *tgtname, char *service)
 {
 	CLIENT			*rpc_clnt = NULL;
 	AUTH			*auth = NULL;
@@ -643,7 +644,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 	if (auth == NULL) {
 		if (uid == 0 && (root_uses_machine_creds == 1 ||
 				service != NULL)) {
-			auth =	krb5_use_machine_creds(clp, uid, tgtname,
+			auth =	krb5_use_machine_creds(clp, uid, srchost, tgtname,
 							service, &rpc_clnt);
 			if (auth == NULL)
 				goto out_return_error;
@@ -714,7 +715,7 @@ handle_krb5_upcall(struct clnt_upcall_info *info)
 
 	printerr(2, "\n%s: uid %d (%s)\n", __func__, info->uid, clp->relpath);
 
-	process_krb5_upcall(clp, info->uid, clp->krb5_fd, NULL, NULL);
+	process_krb5_upcall(clp, info->uid, clp->krb5_fd, NULL, NULL, NULL);
 	free(info);
 }
 
@@ -728,11 +729,12 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	char			*uidstr = NULL;
 	char			*target = NULL;
 	char			*service = NULL;
+	char			*srchost = NULL;
 	char			*enctypes = NULL;
 	char			*upcall_str;
 	char			*pbuf = info->lbuf;
 
-	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
+	printerr(2, "%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
 
 	upcall_str = strdup(info->lbuf);
 	if (upcall_str == NULL) {
@@ -751,6 +753,8 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 			target = p + strlen("target=");
 		else if (!strncmp(p, "service=", strlen("service=")))
 			service = p + strlen("service=");
+		else if (!strncmp(p, "srchost=", strlen("srchost=")))
+			srchost = p + strlen("srchost=");
 	}
 
 	if (!mech || strlen(mech) < 1) {
@@ -802,7 +806,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	}
 
 	if (strcmp(mech, "krb5") == 0 && clp->servername)
-		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
+		process_krb5_upcall(clp, uid, clp->gssd_fd, srchost, target, service);
 	else {
 		if (clp->servername)
 			printerr(0, "WARNING: handle_gssd_upcall: "
@@ -815,4 +819,3 @@ out_nomem:
 	free(info);
 	return;
 }
-
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index b342b06..eba1aac 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -757,7 +757,8 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
  * the server hostname.
  */
 static int
-find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
+find_keytab_entry(krb5_context context, krb5_keytab kt,
+		  const char *srchost, const char *tgtname,
 		  krb5_keytab_entry *kte, const char **svcnames)
 {
 	krb5_error_code code;
@@ -781,7 +782,9 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 		goto out;
 
 	/* Get full local hostname */
-	if (gethostname(myhostname, sizeof(myhostname)) == -1) {
+	if (srchost) {
+		strcpy(myhostname, srchost);
+	} else if (gethostname(myhostname, sizeof(myhostname)) == -1) {
 		retval = errno;
 		k5err = gssd_k5_err_msg(context, retval);
 		printerr(1, "%s while getting local hostname\n", k5err);
@@ -807,10 +810,12 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	        myhostad[i+1] = 0;
 	}
 
-	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
-	if (retval) {
-		/* Don't use myhostname */
-		myhostname[0] = 0;
+	if (!srchost) {
+		retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
+		if (retval) {
+			/* Don't use myhostname */
+			myhostname[0] = 0;
+		}
 	}
 
 	code = krb5_get_default_realm(context, &default_realm);
@@ -1140,7 +1145,7 @@ gssd_get_krb5_machine_cred_list(char ***list)
 		if (ple->ccname) {
 			/* Make sure cred is up-to-date before returning it */
 			retval = gssd_refresh_krb5_machine_credential(NULL, ple,
-				NULL);
+								      NULL, NULL);
 			if (retval)
 				continue;
 			if (i + 1 > listsize) {
@@ -1231,7 +1236,7 @@ gssd_destroy_krb5_machine_creds(void)
 int
 gssd_refresh_krb5_machine_credential(char *hostname,
 				     struct gssd_k5_kt_princ *ple, 
-					 char *service)
+				     char *service, char *srchost)
 {
 	krb5_error_code code = 0;
 	krb5_context context;
@@ -1240,6 +1245,9 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 	char *k5err = NULL;
 	const char *svcnames[] = { "$", "root", "nfs", "host", NULL };
 
+	printerr(2, "%s: hostname=%s ple=%p service=%s srchost=%s\n",
+		__func__, hostname, ple, service, srchost);
+
 	/*
 	 * If a specific service name was specified, use it.
 	 * Otherwise, use the default list.
@@ -1270,7 +1278,8 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 	if (ple == NULL) {
 		krb5_keytab_entry kte;
 
-		code = find_keytab_entry(context, kt, hostname, &kte, svcnames);
+		code = find_keytab_entry(context, kt, srchost, hostname,
+					 &kte, svcnames);
 		if (code) {
 			printerr(0, "ERROR: %s: no usable keytab entry found "
 				 "in keytab %s for connection with host %s\n",
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index e3bbb07..b000b44 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -30,7 +30,7 @@ void gssd_free_krb5_machine_cred_list(char **list);
 void gssd_destroy_krb5_machine_creds(void);
 int  gssd_refresh_krb5_machine_credential(char *hostname,
 					  struct gssd_k5_kt_princ *ple, 
-					  char *service);
+					  char *service, char *srchost);
 char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
 void gssd_k5_get_default_realm(char **def_realm);
 

