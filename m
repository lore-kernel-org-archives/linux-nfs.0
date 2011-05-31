Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:56522 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108Ab1EaSVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 14:21:04 -0400
Received: by yia27 with SMTP id 27so1882798yia.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 May 2011 11:21:03 -0700 (PDT)
Message-ID: <4DE53171.7070808@gmail.com>
Date: Tue, 31 May 2011 14:20:33 -0400
From: Michael Groshans <mikegroshans@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd: Correctly set netid to tcp or tcp6 for non-local exports
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Michael Groshans <groshans@umich.edu>

Decide whether or not to send tcp or tcp6 in the netid field of GETDEVICEINFO
replies by checking for the presence of a colon in the address.

Signed-off by: Michael Groshans <groshans@umich.edu>
---
 fs/nfsd/nfs4pnfsdlm.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 0068ba0..1159cca 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -319,9 +319,6 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 			goto out;
 		}
 
-		daddr->r_netid.data = "tcp";
-		daddr->r_netid.len = 3;
-
 		len = strcspn(bufp, ",");
 		daddr->r_addr.data = kmalloc(len + 4, GFP_KERNEL);
 		memcpy(daddr->r_addr.data, bufp, len);
@@ -332,6 +329,14 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 		memcpy(daddr->r_addr.data + len, ".8.1", 4);
 		daddr->r_addr.len = len + 4;
 
+		if (strcspn(daddr->r_addr.data, ":") - 1 == daddr->r_addr.len) {
+			daddr->r_netid.data = "tcp";
+			daddr->r_netid.len = 3;
+		} else {
+			daddr->r_netid.data = "tcp6";
+			daddr->r_netid.len = 4;
+		}
+
 		fdev.fl_device_list[i].fl_multipath_length = 1;
 		fdev.fl_device_list[i].fl_multipath_list = daddr;
 
-- 
1.7.3.4
