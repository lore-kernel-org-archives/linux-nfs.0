Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031140Ab2CITtv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:49:51 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29Jno8n029967
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:49:50 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/7] Kill SPKM3: Remove spkm3 references from svcgssd
Date: Fri,  9 Mar 2012 14:49:40 -0500
Message-Id: <1331322586-4631-2-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/svcgssd_mech2file.c |    1 -
 utils/gssd/svcgssd_proc.c      |    8 ++------
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/svcgssd_mech2file.c b/utils/gssd/svcgssd_mech2file.c
index 65de8d01fedba026f35b11c4bd689f634579ef8d..a3177f6ff8ab7e0ee5eef7c830ce2c2042553c3c 100644
--- a/utils/gssd/svcgssd_mech2file.c
+++ b/utils/gssd/svcgssd_mech2file.c
@@ -53,7 +53,6 @@ struct mech2file {
 
 struct mech2file m2f[] = {
 	{{9, "\052\206\110\206\367\022\001\002\002"}, "krb5"},
-	{{7, "\053\006\001\005\005\001\003"}, "spkm3"},
 	{{7, "\053\006\001\005\005\001\009"}, "lipkey"},
 	{{0,0},""},
 };
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index c714d99dd654aaff3b3369bebcbc0df0946284dd..0d4f78d9668396aaebb05ab97804cfb1e8d5ed5a 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -369,12 +369,8 @@ get_hostbased_client_name(gss_name_t client_name, gss_OID mech,
 	if (g_OID_equal(&krb5oid, mech)) {
 		if (get_krb5_hostbased_name(&name, &cname) == 0)
 			*hostbased_name = cname;
-	}
-
-	/* No support for SPKM3, just print a warning (for now) */
-	if (g_OID_equal(&spkm3oid, mech)) {
-		printerr(1, "WARNING: get_hostbased_client_name: "
-			 "no hostbased_name support for SPKM3\n");
+	} else {
+		printerr(1, "WARNING: unknown/unsupport mech OID\n");
 	}
 
 	res = 0;
-- 
1.7.7.6

