Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29862 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571Ab3CABaM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 20:30:12 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/3] PNFS: set the default DS timeout to 60 seconds
Date: Thu, 28 Feb 2013 20:30:08 -0500
Message-Id: <1362101410-22544-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client should have 60 second default timeouts for DS operations, not 6
seconds.

NFS4_DEF_DS_TIMEO is used as "timeout in tenths of a second" in
nfs_init_timeout_values (and is not used anywhere else).
This matches up with the description of the module param dataserver_timeo.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4filelayout.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 8c07241..b8da955 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -36,7 +36,7 @@
  * Default data server connection timeout and retrans vaules.
  * Set by module paramters dataserver_timeo and dataserver_retrans.
  */
-#define NFS4_DEF_DS_TIMEO   60
+#define NFS4_DEF_DS_TIMEO   600 /* in tenths of a second */
 #define NFS4_DEF_DS_RETRANS 5
 
 /*
-- 
1.7.12.4 (Apple Git-37)

