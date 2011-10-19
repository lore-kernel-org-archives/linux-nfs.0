Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab1JSUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] NFS: Get rid of the unused nfs_read_data->flags field
Date: Wed, 19 Oct 2011 13:50:13 -0700
Message-Id: <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/nfs_xdr.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1e31e1c..c1cceb8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1133,7 +1133,6 @@ struct nfs_page;
 #define NFS_PAGEVEC_SIZE	(8U)
 
 struct nfs_read_data {
-	int			flags;
 	struct rpc_task		task;
 	struct inode		*inode;
 	struct rpc_cred		*cred;
-- 
1.7.6.4

