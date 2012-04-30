Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41994 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756743Ab2D3WoB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Apr 2012 18:44:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/2] NFS: Fix a compile issue when CONFIG_NFS_V4_1 is undefined
Date: Mon, 30 Apr 2012 18:44:00 -0400
Message-Id: <1335825840-22006-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335825840-22006-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335825840-22006-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

struct nfs_direct_req can't compile when struct pnfs_ds_commit_info
is undefined.

Reported-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
---
 include/linux/nfs_xdr.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c940d46..6deb8f0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1176,6 +1176,11 @@ struct nfs41_free_stateid_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
+#else
+
+struct pnfs_ds_commit_info {
+};
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_page;
-- 
1.7.7.6

