Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753519Ab1JSUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:39 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] NFS: Get rid of the unused nfs_write_data->flags field
Date: Wed, 19 Oct 2011 13:50:14 -0700
Message-Id: <1319057418-9851-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/nfs_xdr.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c1cceb8..c74595b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1155,7 +1155,6 @@ struct nfs_read_data {
 };
 
 struct nfs_write_data {
-	int			flags;
 	struct rpc_task		task;
 	struct inode		*inode;
 	struct rpc_cred		*cred;
-- 
1.7.6.4

