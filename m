Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab0FNUAD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 16:00:03 -0400
Date: Mon, 14 Jun 2010 16:00:01 -0400
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, eanderle@umich.edu
Subject: [PATCH] pnfsd: Add IP address validation to
	nfsd4_set_pnfs_dlm_device()
Message-ID: <20100614200001.GJ2745@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Eric Anderle <eanderle@umich.edu>

We should catch errors in the format at the time the list is given to
the kernel, rather than just returning garbage to the client and letting
the client fail.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4pnfsdlm.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 1cf1b69..b6d9f23 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -26,6 +26,7 @@
 #include <linux/nfsd/debug.h>
 #include <linux/nfsd/nfs4pnfsdlm.h>
 #include <linux/nfsd/nfs4layoutxdr.h>
+#include <linux/sunrpc/clnt.h>
 
 #include "nfsfh.h"
 #include "nfsd.h"
@@ -87,6 +88,24 @@ out:
 	return ret;
 }
 
+bool nfsd4_validate_pnfs_dlm_device(char *ds_list, int len, int *num_ds)
+{
+	char *start = ds_list;
+
+	*num_ds = 0;
+
+	while (*start) {
+		struct sockaddr_storage tempAddr;
+		int ipLen = strcspn(start, ",");
+
+		if (!rpc_pton(start, ipLen, (struct sockaddr *)&tempAddr, sizeof(tempAddr)))
+			return false;
+		(*num_ds)++;
+		start += ipLen + 1;
+	}
+	return true;
+}
+
 /*
  * pnfs_dlm_device string format:
  *     block-device-path:<ds1 ipv4 address>,<ds2 ipv4 address>
@@ -140,12 +159,10 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
 		goto out_free;
 	memcpy(new->ds_list, bufp, len);
 
-	/* count the number of comma-delimited DS IPs */
-	new->num_ds = 1;
-	while ((bufp = strchr(bufp, ',')) != NULL) {
-		new->num_ds++;
-		bufp++;
-	}
+
+	/*  validate the ips */
+	if (!nfsd4_validate_pnfs_dlm_device(new->ds_list, len, &(new->num_ds)))
+		goto out_free;
 
 	dprintk("%s disk_name %s num_ds %d ds_list %s\n", __func__,
 		new->disk_name, new->num_ds, new->ds_list);
-- 
1.7.0.4

