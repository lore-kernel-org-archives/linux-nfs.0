Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538Ab1AMTUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 14:20:06 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0DJK5Di011199
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 14:20:05 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p0DJK4bm007053
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 14:20:05 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Improve debugging during lib initialization.
Date: Thu, 13 Jan 2011 14:20:02 -0500
Message-Id: <1294946402-14041-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Removed unnecessary new lines and dded debug code that
displays what Realms will be used.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfsidmap.c |   27 ++++++++++++++++++++++++---
 1 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/libnfsidmap.c b/libnfsidmap.c
index 6415707..19d0d79 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -246,7 +246,7 @@ int nfs4_init_name_mapping(char *conffile)
 			default_domain = IDMAPD_DEFAULT_DOMAIN;
 		}
 	}
-	IDMAP_LOG(1, ("libnfsidmap: using%s domain: %s\n",
+	IDMAP_LOG(1, ("libnfsidmap: using%s domain: %s",
 		(dflt ? " (default)" : ""), default_domain));
 
 	/* Get list of "local equivalent" realms.  Meaning the list of realms
@@ -274,9 +274,30 @@ int nfs4_init_name_mapping(char *conffile)
 		local_realms->cnt++;
 	}
 
+	if (idmap_verbosity >= 1) {
+		struct conf_list_node *r;
+		char *buf = NULL;
+		int siz=0;
+
+		if (local_realms) {
+			TAILQ_FOREACH(r, &local_realms->fields, link) {
+				siz += (strlen(r->field)+4);
+			}
+			buf = malloc(siz);
+			if (buf) {
+				TAILQ_FOREACH(r, &local_realms->fields, link) {
+					sprintf(buf, "'%s' ", r->field);
+				}
+				IDMAP_LOG(1, ("libnfsidmap: Realms list: %s", buf));
+				free(buf);
+			}
+		} else 
+			IDMAP_LOG(1, ("libnfsidmap: Realms list: <NULL> "));
+	}
+
 	nfs4_methods = conf_get_list("Translation", "Method");
 	if (nfs4_methods) {
-		IDMAP_LOG(1, ("libnfsidmap: processing 'Method' list\n"));
+		IDMAP_LOG(1, ("libnfsidmap: processing 'Method' list"));
 		if (load_plugins(nfs4_methods, &nfs4_plugins) == -1)
 			return -ENOENT;
 	} else {
@@ -294,7 +315,7 @@ int nfs4_init_name_mapping(char *conffile)
 
 	gss_methods = conf_get_list("Translation", "GSS-Methods");
 	if (gss_methods) {
-		IDMAP_LOG(1, ("libnfsidmap: processing 'GSS-Methods' list\n"));
+		IDMAP_LOG(1, ("libnfsidmap: processing 'GSS-Methods' list"));
 		if (load_plugins(gss_methods, &gss_plugins) == -1)
 			goto out;
 	}
-- 
1.7.3.3

