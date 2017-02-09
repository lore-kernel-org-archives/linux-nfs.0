Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:36254 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdBIXN4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 18:13:56 -0500
Received: by mail-qk0-f177.google.com with SMTP id 11so21581785qkl.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Feb 2017 15:13:11 -0800 (PST)
Received: from hut.sorenson.redhat.com (198-0-247-150-static.hfc.comcastbusiness.net. [198.0.247.150])
        by smtp.gmail.com with ESMTPSA id m85sm10416047qkl.28.2017.02.09.15.04.01
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 15:04:01 -0800 (PST)
To: linux-nfs@vger.kernel.org
From: Frank Sorenson <sorenson@redhat.com>
Subject: [nfs-utils PATCH V2 2/2] Duplicate upcall string for use in error
 messages
Message-ID: <778cd9e3-7b3a-654d-5fdd-bc0f63743041@redhat.com>
Date: Thu, 9 Feb 2017 17:04:00 -0600
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Author: Frank Sorenson <sorenson@redhat.com>
Date:   2017-02-09 16:51:44 -0600

    gssd:  Duplicate the upcall string for error messages
    
    strsep() modifies the input string, so error messages
    may output only part of the upcall string.
    
    Make a copy of the upcall string, and use that in any
    error messages.
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 30c6ace..4fc81c3 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -729,10 +729,17 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	char			*target = NULL;
 	char			*service = NULL;
 	char			*enctypes = NULL;
+	char			*upcall_str;
 	char			*pbuf = info->lbuf;
 
 	printerr(2, "\n%s: '%s' (%s)\n", __func__, info->lbuf, clp->relpath);
 
+	upcall_str = strdup(info->lbuf);
+	if (upcall_str == NULL) {
+		printerr(0, "ERROR: malloc failure\n");
+		goto out_nomem;
+	}
+
 	while ((p = strsep(&pbuf, " "))) {
 		if (!strncmp(p, "mech=", strlen("mech=")))
 			mech = p + strlen("mech=");
@@ -749,7 +756,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (!mech || strlen(mech) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "failed to find gss mechanism name "
-			    "in upcall string '%s'\n", info->lbuf);
+			    "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -762,7 +769,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (!uidstr) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			    "failed to find uid "
-			    "in upcall string '%s'\n", info->lbuf);
+			    "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -775,7 +782,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (target && strlen(target) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			 "failed to parse target name "
-			 "in upcall string '%s'\n", info->lbuf);
+			 "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -790,7 +797,7 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 	if (service && strlen(service) < 1) {
 		printerr(0, "WARNING: handle_gssd_upcall: "
 			 "failed to parse service type "
-			 "in upcall string '%s'\n", info->lbuf);
+			 "in upcall string '%s'\n", upcall_str);
 		goto out;
 	}
 
@@ -803,6 +810,8 @@ handle_gssd_upcall(struct clnt_upcall_info *info)
 		do_error_downcall(clp->gssd_fd, uid, -EACCES);
 	}
 out:
+	free(upcall_str);
+out_nomem:
 	free(info);
 	return;
 }
