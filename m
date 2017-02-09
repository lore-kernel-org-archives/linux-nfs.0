Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35130 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdBINMN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 08:12:13 -0500
Received: by mail-qt0-f174.google.com with SMTP id x49so2991464qtc.2
        for <linux-nfs@vger.kernel.org>; Thu, 09 Feb 2017 05:12:12 -0800 (PST)
Received: from hut.sorenson.redhat.com (198-0-247-150-static.hfc.comcastbusiness.net. [198.0.247.150])
        by smtp.gmail.com with ESMTPSA id k8sm9083590qke.29.2017.02.09.05.12.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:12:11 -0800 (PST)
To: linux-nfs@vger.kernel.org
From: Frank Sorenson <sorenson@redhat.com>
Subject: [nfs-utils PATCH] Replace non-thread-safe strtok function calls in
 gssd
Message-ID: <6481e076-509a-1b60-bc46-7ac537ca24fe@redhat.com>
Date: Thu, 9 Feb 2017 07:10:02 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit fae681fa84f328cf601f34452b5a97f5d54ca2e2
Author: Frank Sorenson <sorenson@redhat.com>
Date:   2017-02-04 14:05:48 -0600

    gssd: replace non-thread-safe strtok
    
    gssd uses the non-thread-safe strtok() function, which
    can lead to incorrect program behavior.  In addition,
    strtok() modifies the input string, so error messages
    may be incomplete.
    
    Replace strtok() with the thread-safe strtok_r() and a
    per-thread state variable.  Also duplicate the input
    string for use when outputting error messages.
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d74d372..ba6ec29 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -729,10 +729,18 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	char			*target = NULL;
 	char			*service = NULL;
 	char			*enctypes = NULL;
+	char			*saveptr;
+	char			*upcall_str;
 
 	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
 
-	for (p = strtok(info->lbuf, " "); p; p = strtok(NULL, " ")) {
+	upcall_str = strdup(info->lbuf);
+	if (upcall_str == NULL) {
+		printerr(0, "ERROR: malloc failure\n");
+		goto out_nomem;
+        }
+
+	for (p = strtok_r(info->lbuf, " ", &saveptr); p; p = strtok_r(NULL, " ", &saveptr)) {
 		if (!strncmp(p, "mech=", strlen("mech=")))
 			mech = p + strlen("mech=");
 		else if (!strncmp(p, "uid=", strlen("uid=")))
@@ -748,7 +756,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (!mech || strlen(mech) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "failed to find gss mechanism name "
-			    "in upcall string '%s'\n", info->lbuf);
+			    "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -761,7 +769,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (!uidstr) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "failed to find uid "
-			    "in upcall string '%s'\n", info->lbuf);
+			    "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -774,7 +782,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (target && strlen(target) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			 "failed to parse target name "
-			 "in upcall string '%s'\n", info->lbuf);
+			 "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -789,7 +797,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (service && strlen(service) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			 "failed to parse service type "
-			 "in upcall string '%s'\n", info->lbuf);
+			 "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -802,6 +810,8 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 		do_error_downcall(clp->gssd_fd, uid, -EACCES);
 	}
 out:
+	free(upcall_str);
+out_nomem:
 	free(info);
 	return;
 }
