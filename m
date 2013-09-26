Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:61651 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:08 -0400
Received: by mail-qa0-f46.google.com with SMTP id j7so4637700qaq.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:07 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 33/49] pnfsd: Add IP address validation to nfsd4_set_pnfs_dlm_device()
Date: Thu, 26 Sep 2013 14:42:05 -0400
Message-Id: <1380220925-14207-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Anderle <eanderle@umich.edu>

We should catch errors in the format at the time the list is given to
the kernel, rather than just returning garbage to the client and letting
the client fail.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
[removed unused 'len' parameter]
[fixup rpc_pton parameters for 3.4]
[fixup rpc_pton include file]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsdlm.c | 30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 906c370..ddc2188 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -23,6 +23,7 @@
 
 #include <linux/nfsd/debug.h>
 #include <linux/nfsd/nfs4pnfsdlm.h>
+#include <linux/sunrpc/addr.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
 
@@ -56,6 +57,25 @@ struct dlm_device_entry {
 	return NULL;
 }
 
+bool nfsd4_validate_pnfs_dlm_device(char *ds_list, int *num_ds)
+{
+	char *start = ds_list;
+
+	*num_ds = 0;
+
+	while (*start) {
+		struct sockaddr_storage tempAddr;
+		int ipLen = strcspn(start, ",");
+
+		if (!rpc_pton(&init_net, start, ipLen,
+			      (struct sockaddr *)&tempAddr, sizeof(tempAddr)))
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
@@ -109,12 +129,10 @@ struct dlm_device_entry {
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
+	if (!nfsd4_validate_pnfs_dlm_device(new->ds_list, &(new->num_ds)))
+		goto out_free;
 
 	dprintk("%s disk_name %s num_ds %d ds_list %s\n", __func__,
 		new->disk_name, new->num_ds, new->ds_list);
-- 
1.8.3.1

