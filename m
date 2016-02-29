Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755AbcB2WgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Feb 2016 17:36:04 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (Postfix) with ESMTPS id 83399C00124A
	for <linux-nfs@vger.kernel.org>; Mon, 29 Feb 2016 22:36:03 +0000 (UTC)
From: Benjamin Coddington <bcodding@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] gssd: Fix inner-loop variable reuse
Date: Mon, 29 Feb 2016 17:36:01 -0500
Message-Id: <7c093a92c6c61de8d4bf0f9620aea9ada789fe75.1456785264.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The var "i" is already in use iterating realmnames.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Fixes: "6597e391 gssd:  Don't assume the machine account will be in uppercase"
---
 utils/gssd/krb5_util.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 8ef8184..8dc64fe 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -796,7 +796,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	char **realmnames = NULL;
 	char myhostname[NI_MAXHOST], targethostname[NI_MAXHOST];
 	char myhostad[NI_MAXHOST+1];
-	int i, j, retval;
+	int i, j, k, retval;
 	char *default_realm = NULL;
 	char *realm;
 	char *k5err = NULL;
@@ -941,8 +941,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 				 * moving on to the svcname
 				 */
 				if (strcmp(svcnames[j],"$") == 0 && !tried_upper) {
-					for (i = 0; myhostad[i] != '$'; ++i) {
-						myhostad[i] = toupper(myhostad[i]);
+					for (k = 0; myhostad[k] != '$'; ++k) {
+						myhostad[k] = toupper(myhostad[k]);
 					}
 					j--;
 					tried_upper = 1;
-- 
1.7.1

