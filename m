Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbbLJQMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 11:12:31 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: [PATCH 1/2] nfsstat: update nfs client operations
Date: Thu, 10 Dec 2015 11:12:28 -0500
Message-Id: <745dd74bb752e97b40c79d27c29427c0942f952c.1449763231.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FSID_PRESENT was missing, and LAYOUTGET and GETDEVICEINFO were switched.
Update all the client operations.  Also, increase the output width a bit
and pull out a column for these longer new operation names.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/nfsstat/nfsstat.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 9f481db..b882c41 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -31,7 +31,7 @@ enum {
 	SRVPROC3_SZ = 22,
 	CLTPROC3_SZ = 22,
 	SRVPROC4_SZ = 2,
-	CLTPROC4_SZ = 49,
+	CLTPROC4_SZ = 60,
 	SRVPROC4OPS_SZ = 59,
 };
 
@@ -127,19 +127,31 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
 	"setacl",    "fs_locations",
-	"rel_lkowner", "secinfo",
+	"rel_lkowner", "secinfo", "fsid_present",
 	/* nfsv4.1 client ops */
 	"exchange_id",
-	"create_ses",
-	"destroy_ses",
+	"create_session",
+	"destroy_session",
 	"sequence",
-	"get_lease_t",
+	"get_lease_time",
 	"reclaim_comp",
-	"layoutget",
 	"getdevinfo",
+	"layoutget",
 	"layoutcommit",
 	"layoutreturn",
 	"getdevlist",
+	"secinfo_no",
+	"test_stateid",
+	"free_stateid",
+	"getdevicelist",
+	"bind_conn_to_ses",
+	"destroy_clientid",
+	/* nfsv4.2 client ops */
+	"seek",
+	"allocate",
+	"deallocate",
+	"layoutstats",
+	"clone",
 };
 
 static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
@@ -823,13 +835,13 @@ print_callstats(const char *hdr, const char **names,
 		total += info[i];
 	if (!total)
 		total = 1;
-	for (i = 0; i < nr; i += 6) {
-		for (j = 0; j < 6 && i + j < nr; j++)
-			printf("%-13s", names[i+j]);
+	for (i = 0; i < nr; i += 5) {
+		for (j = 0; j < 5 && i + j < nr; j++)
+			printf("%-17s", names[i+j]);
 		printf("\n");
-		for (j = 0; j < 6 && i + j < nr; j++) {
+		for (j = 0; j < 5 && i + j < nr; j++) {
 			pct = ((unsigned long long) info[i+j]*100)/total;
-			printf("%-8u%3llu%% ", info[i+j], pct);
+			printf("%-8u%3llu%%     ", info[i+j], pct);
 		}
 		printf("\n");
 	}
-- 
1.7.1

