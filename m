From: Dean Hildebrand <seattleplus@gmail.com>
Subject: [PATCH 2/2] NFS: Cleanup decode_attr_fs_locations function.
Date: Tue, 28 Oct 2008 10:32:00 -0700
Message-ID: <1225215120-11157-1-git-send-email-dhildeb@us.ibm.com>
Cc: Dean Hildebrand <dhildeb@us.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:58484 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbYJ1RcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2008 13:32:06 -0400
Received: by qw-out-2122.google.com with SMTP id 3so1388703qwe.37
        for <linux-nfs@vger.kernel.org>; Tue, 28 Oct 2008 10:32:04 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

a) Use correct data types.
b) Use nloc and nserv instead of n and m variable names.
c) Try to clean up formatting of debugging statements.
d) Move while loops to for loops.

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
---
 fs/nfs/nfs4xdr.c |   40 ++++++++++++++++++----------------------
 1 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0b4c565..421609f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2560,7 +2560,7 @@ out_eio:
 
 static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
 {
-	int n;
+	u32 nloc;
 	__be32 *p;
 	int status = -EIO;
 
@@ -2574,47 +2574,45 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	if (unlikely(status != 0))
 		goto out;
 	READ_BUF(4);
-	READ32(n);
-	if (n <= 0)
+	READ32(nloc);
+	if (nloc <= 0)
 		goto out_eio;
 
-	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
-		dprintk("\n%s: Using first %u of %d fs locations\n",
-			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, n);
-		n = NFS4_FS_LOCATIONS_MAXENTRIES;
+	if (nloc > NFS4_FS_LOCATIONS_MAXENTRIES) {
+		dprintk("\n%s: Using first %u of %u fs locations\n",
+			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, nloc);
+		nloc = NFS4_FS_LOCATIONS_MAXENTRIES;
 	}
 
-	res->nlocations = 0;
-	while (res->nlocations < n) {
-		u32 m;
-		unsigned int totalserv, i;
+	for (res->nlocations = 0; res->nlocations < nloc; res->nlocations++) {
+		u32 nserv;
+		unsigned int totalserv, j;
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
 		READ_BUF(4);
-		READ32(m);
+		READ32(nserv);
 
-		totalserv = m;
-		if (m >  NFS4_FS_LOCATION_MAXSERVERS) {
+		totalserv = nserv;
+		if (nserv >  NFS4_FS_LOCATION_MAXSERVERS) {
 			dprintk("\n%s: Using first %u of %u servers "
 				"returned for location %u\n",
 				__func__, NFS4_FS_LOCATION_MAXSERVERS,
-				m, res->nlocations);
-			m = NFS4_FS_LOCATION_MAXSERVERS;
+				nserv, res->nlocations);
+			nserv = NFS4_FS_LOCATION_MAXSERVERS;
 		}
 
-		loc->nservers = 0;
 		dprintk("%s: servers ", __func__);
-		while (loc->nservers < m) {
+		for (loc->nservers = 0; loc->nservers < nserv; loc->nservers++) {
 			struct nfs4_string *server = &loc->servers[loc->nservers];
 			status = decode_opaque_inline(xdr, &server->len, &server->data);
 			if (unlikely(status != 0))
 				goto out_eio;
 			dprintk("%s ", server->data);
-			loc->nservers++;
 		}
+		dprintk("\n");
 
 		/* Decode and ignore overflow servers */
-		for (i = loc->nservers; i < totalserv; i++) {
+		for (j = loc->nservers; j < totalserv; j++) {
 			unsigned int len;
 			char *data;
 			status = decode_opaque_inline(xdr, &len, &data);
@@ -2625,8 +2623,6 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		status = decode_pathname(xdr, &loc->rootpath);
 		if (unlikely(status != 0))
 			goto out_eio;
-
-		res->nlocations++;
 	}
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
-- 
1.5.4.5

