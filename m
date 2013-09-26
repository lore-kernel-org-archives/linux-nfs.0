Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:61751 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSmo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:42:44 -0400
Received: by mail-qa0-f47.google.com with SMTP id k4so4620649qaq.20
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:42:43 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 41/49] pnfsd: dlm pnfs_export_operations
Date: Thu, 26 Sep 2013 14:42:38 -0400
Message-Id: <1380220958-14575-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Declare a global pnfs_export_operations struct for use with DLM cluster
file systems who wish to be exported by pnfs.

Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: define dlm export ops for the !CONFIG_PNFSD case]
[gfs2: set pnfs_dlm_export_ops only for CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 include/linux/nfsd/nfs4pnfsdlm.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/nfsd/nfs4pnfsdlm.h b/include/linux/nfsd/nfs4pnfsdlm.h
index a4f3477..eb31123 100644
--- a/include/linux/nfsd/nfs4pnfsdlm.h
+++ b/include/linux/nfsd/nfs4pnfsdlm.h
@@ -35,6 +35,9 @@
 
 #ifdef CONFIG_PNFSD
 
+/* For use by DLM cluster file systems exported by pNFSD */
+extern const struct pnfs_export_operations pnfs_dlm_export_ops;
+
 int nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len);
 
 void nfsd4_pnfs_dlm_shutdown(void);
-- 
1.8.3.1

