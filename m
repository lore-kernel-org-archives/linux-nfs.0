From: Dean Hildebrand <seattleplus@gmail.com>
Subject: [PATCH 1/2] NFS:Prevent infinite loop in decode_attr_fs_locations.
Date: Fri, 17 Oct 2008 15:52:06 -0700
Message-ID: <1224283927-4639-1-git-send-email-dhildeb@us.ibm.com>
Cc: Dean Hildebrand <dhildeb@us.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:15230 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677AbYJQWwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2008 18:52:11 -0400
Received: by wf-out-1314.google.com with SMTP id 27so880150wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2008 15:52:10 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An infinite loop could occur if n > NFS4_FS_LOCATIONS_MAXENTRIES.
or if m > NFS4_FS_LOCATION_MAXSERVERS.

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
---
 fs/nfs/nfs4xdr.c |   49 ++++++++++++++++++++++++++++++-------------------
 1 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..0b4c565 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2577,14 +2577,31 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	READ32(n);
 	if (n <= 0)
 		goto out_eio;
+
+	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
+		dprintk("\n%s: Using first %u of %d fs locations\n",
+			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, n);
+		n = NFS4_FS_LOCATIONS_MAXENTRIES;
+	}
+
 	res->nlocations = 0;
 	while (res->nlocations < n) {
 		u32 m;
+		unsigned int totalserv, i;
 		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
 
 		READ_BUF(4);
 		READ32(m);
 
+		totalserv = m;
+		if (m >  NFS4_FS_LOCATION_MAXSERVERS) {
+			dprintk("\n%s: Using first %u of %u servers "
+				"returned for location %u\n",
+				__func__, NFS4_FS_LOCATION_MAXSERVERS,
+				m, res->nlocations);
+			m = NFS4_FS_LOCATION_MAXSERVERS;
+		}
+
 		loc->nservers = 0;
 		dprintk("%s: servers ", __func__);
 		while (loc->nservers < m) {
@@ -2593,29 +2610,23 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			if (unlikely(status != 0))
 				goto out_eio;
 			dprintk("%s ", server->data);
-			if (loc->nservers < NFS4_FS_LOCATION_MAXSERVERS)
-				loc->nservers++;
-			else {
-				unsigned int i;
-				dprintk("%s: using first %u of %u servers "
-					"returned for location %u\n",
-						__func__,
-						NFS4_FS_LOCATION_MAXSERVERS,
-						m, res->nlocations);
-				for (i = loc->nservers; i < m; i++) {
-					unsigned int len;
-					char *data;
-					status = decode_opaque_inline(xdr, &len, &data);
-					if (unlikely(status != 0))
-						goto out_eio;
-				}
-			}
+			loc->nservers++;
 		}
+
+		/* Decode and ignore overflow servers */
+		for (i = loc->nservers; i < totalserv; i++) {
+			unsigned int len;
+			char *data;
+			status = decode_opaque_inline(xdr, &len, &data);
+			if (unlikely(status != 0))
+				goto out_eio;
+		}
+
 		status = decode_pathname(xdr, &loc->rootpath);
 		if (unlikely(status != 0))
 			goto out_eio;
-		if (res->nlocations < NFS4_FS_LOCATIONS_MAXENTRIES)
-			res->nlocations++;
+
+		res->nlocations++;
 	}
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
-- 
1.5.3.3

