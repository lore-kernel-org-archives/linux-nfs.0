Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51296 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655AbaLIFmZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:42:25 -0500
Subject: [PATCH 19/19] nfs-utils: gssd - simplify handle_gssd_upcall
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:42:16 +0100
Message-ID: <20141209054216.24756.44477.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stumbled across this function, just had to simplify it. No mallocs
necessary, one quick loop to find the parameters. Much simpler.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd_proc.c |  106 +++++++++++++++++-------------------------------
 1 file changed, 38 insertions(+), 68 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index a5a46ef..d733339 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -713,6 +713,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	int			lbuflen = 0;
 	char			*p;
 	char			*mech = NULL;
+	char			*uidstr = NULL;
 	char			*target = NULL;
 	char			*service = NULL;
 	char			*enctypes = NULL;
@@ -729,72 +730,53 @@ handle_gssd_upcall(struct clnt_info *clp)
 
 	printerr(2, "%s: '%s'\n", __func__, lbuf);
 
-	/* find the mechanism name */
-	if ((p = strstr(lbuf, "mech=")) != NULL) {
-		mech = malloc(lbuflen);
-		if (!mech)
-			goto out;
-		if (sscanf(p, "mech=%s", mech) != 1) {
-			printerr(0, "WARNING: handle_gssd_upcall: "
-				    "failed to parse gss mechanism name "
-				    "in upcall string '%s'\n", lbuf);
-			goto out;
-		}
-	} else {
+	for (p = strtok(lbuf, " "); p; p = strtok(NULL, " ")) {
+		if (!strncmp(p, "mech=", strlen("mech=")))
+			mech = p + strlen("mech=");
+		else if (!strncmp(p, "uid=", strlen("uid=")))
+			uidstr = p + strlen("uid=");
+		else if (!strncmp(p, "enctypes=", strlen("enctypes=")))
+			enctypes = p + strlen("enctypes=");
+		else if (!strncmp(p, "target=", strlen("target=")))
+			target = p + strlen("target=");
+		else if (!strncmp(p, "service=", strlen("service=")))
+			service = p + strlen("service=");
+	}
+
+	if (!mech || strlen(mech) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "failed to find gss mechanism name "
 			    "in upcall string '%s'\n", lbuf);
-		goto out;
+		return;
 	}
 
-	/* read uid */
-	if ((p = strstr(lbuf, "uid=")) != NULL) {
-		if (sscanf(p, "uid=%d", &uid) != 1) {
-			printerr(0, "WARNING: handle_gssd_upcall: "
-				    "failed to parse uid "
-				    "in upcall string '%s'\n", lbuf);
-			goto out;
-		}
-	} else {
+	if (uidstr) {
+		uid = (uid_t)strtol(uidstr, &p, 10);
+		if (p == uidstr || *p != '\0')
+			uidstr = NULL;
+	}
+
+	if (!uidstr) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "failed to find uid "
 			    "in upcall string '%s'\n", lbuf);
-		goto out;
+		return;
 	}
 
-	/* read supported encryption types if supplied */
-	if ((p = strstr(lbuf, "enctypes=")) != NULL) {
-		enctypes = malloc(lbuflen);
-		if (!enctypes)
-			goto out;
-		if (sscanf(p, "enctypes=%s", enctypes) != 1) {
-			printerr(0, "WARNING: handle_gssd_upcall: "
-				    "failed to parse encryption types "
-				    "in upcall string '%s'\n", lbuf);
-			goto out;
-		}
-		if (parse_enctypes(enctypes) != 0) {
-			printerr(0, "WARNING: handle_gssd_upcall: "
-				"parsing encryption types failed: errno %d\n", errno);
-		}
+	if (enctypes && parse_enctypes(enctypes) != 0) {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			 "parsing encryption types failed: errno %d\n", errno);
+		return;
 	}
 
-	/* read target name */
-	if ((p = strstr(lbuf, "target=")) != NULL) {
-		target = malloc(lbuflen);
-		if (!target)
-			goto out;
-		if (sscanf(p, "target=%s", target) != 1) {
-			printerr(0, "WARNING: handle_gssd_upcall: "
-				    "failed to parse target name "
-				    "in upcall string '%s'\n", lbuf);
-			goto out;
-		}
+	if (target && strlen(target) < 1) {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			 "failed to parse target name "
+			 "in upcall string '%s'\n", lbuf);
+		return;
 	}
 
 	/*
-	 * read the service name
-	 *
 	 * The presence of attribute "service=" indicates that machine
 	 * credentials should be used for this request.  If the value
 	 * is "*", then any machine credentials available can be used.
@@ -802,16 +784,11 @@ handle_gssd_upcall(struct clnt_info *clp)
 	 * the specified service name (always "nfs" for now) should be
 	 * used.
 	 */
-	if ((p = strstr(lbuf, "service=")) != NULL) {
-		service = malloc(lbuflen);
-		if (!service)
-			goto out;
-		if (sscanf(p, "service=%s", service) != 1) {
-			printerr(0, "WARNING: handle_gssd_upcall: "
-				    "failed to parse service type "
-				    "in upcall string '%s'\n", lbuf);
-			goto out;
-		}
+	if (service && strlen(service) < 1) {
+		printerr(0, "WARNING: handle_gssd_upcall: "
+			 "failed to parse service type "
+			 "in upcall string '%s'\n", lbuf);
+		return;
 	}
 
 	if (strcmp(mech, "krb5") == 0 && clp->servername)
@@ -822,12 +799,5 @@ handle_gssd_upcall(struct clnt_info *clp)
 				 "received unknown gss mech '%s'\n", mech);
 		do_error_downcall(clp->gssd_fd, uid, -EACCES);
 	}
-
-out:
-	free(mech);
-	free(enctypes);
-	free(target);
-	free(service);
-	return;
 }
 

