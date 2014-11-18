Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754464AbaKROGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 09:06:47 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jMu007984
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:46 -0500
Received: from bcodding-csb.redhat.com (vpn-60-200.rdu2.redhat.com [10.10.60.200])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAIE6jQd002680
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2014 09:06:45 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] nfsmount.conf: Always parse versions
Date: Tue, 18 Nov 2014 09:06:43 -0500
Message-Id: <faafa3196744558c93158242a7363dcd0a467351.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
In-Reply-To: <cover.1416319371.git.bcodding@redhat.com>
References: <cover.1416319371.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to make decisions about which default version to use when only the
major version is specified, the nfsmount.conf Defaultvers options should
always be parsed, even when a version has already been specified.  Remove
the check and bypass for parsing the Defaultvers options from nfsmount.conf.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/configfile.c |   34 ----------------------------------
 1 files changed, 0 insertions(+), 34 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index a0072f1..0a4cc04 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -228,35 +228,6 @@ void free_all(void)
 		free(entry);
 	}
 }
-static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
-static int 
-check_vers(char *mopt, char *field)
-{
-	int i, found=0;
-
-	/*
-	 * First check to see if the config setting is one 
-	 * of the many version settings
-	 */
-	for (i=0; versions[i]; i++) { 
-		if (strcasestr(field, versions[i]) != NULL) {
-			found++;
-			break;
-		}
-	}
-	if (!found)
-		return 0;
-	/*
-	 * It appears the version is being set, now see
-	 * if the version appears on the command 
-	 */
-	for (i=0; versions[i]; i++)  {
-		if (strcasestr(mopt, versions[i]) != NULL)
-			return 1;
-	}
-
-	return 0;
-}
 
 struct nfs_version config_default_vers;
 unsigned long config_default_proto;
@@ -331,11 +302,6 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 		snprintf(buf, BUFSIZ, "%s=", node->field);
 		if (opts && strcasestr(opts, buf) != NULL)
 			continue;
-		/* 
-		 * Protocol verions can be set in a number of ways
-		 */
-		if (opts && check_vers(opts, node->field))
-			continue;
 
 		if (lookup_entry(node->field) != NULL)
 			continue;
-- 
1.7.1

