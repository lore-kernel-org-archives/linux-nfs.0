Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49333 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766Ab1EaSUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 14:20:21 -0400
Received: by gyd10 with SMTP id 10so1876601gyd.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 May 2011 11:20:20 -0700 (PDT)
Message-ID: <4DE53146.3030208@umich.edu>
Date: Tue, 31 May 2011 14:19:50 -0400
From: Michael Groshans <groshans@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd: Prevent ipv6 address truncation in /proc/fs/nfsd/pnfs_dlm_device
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Michael Groshans <groshans@umich.edu>

ipv6 addresses in /proc/fs/nfsd/pnfs_dlm_device were being truncated because the
length was determined by looking for the next colon. Changed to use strlen()
instead.

Signed-off by: Michael Groshans <groshans@umich.edu>
---
 fs/nfsd/nfs4pnfsdlm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 006ded5..0068ba0 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -165,7 +165,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
 
 	/* data server list */
 	/* FIXME: need to check for comma separated valid ip format */
-	len = strcspn(bufp, ":");
+	len = strlen(bufp);
 	if (len > NFSD_DLM_DS_LIST_MAX)
 		goto out_free;
 	memcpy(new->ds_list, bufp, len);
-- 
1.7.3.4
