Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19419 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932884Ab1CWN2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:05 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/12] NFSv4.1: pull out code from nfs_commit_release
Date: Wed, 23 Mar 2011 09:27:48 -0400
Message-Id: <1300886875-5016-6-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Create a separate support function for later use by data server
commit code.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index dbc8018..f5f005e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1409,10 +1409,9 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 		return;
 }
 
-static void nfs_commit_release(void *calldata)
+static void nfs_commit_release_pages(struct nfs_write_data *data)
 {
-	struct nfs_write_data	*data = calldata;
-	struct nfs_page		*req;
+	struct nfs_page	*req;
 	int status = data->task.tk_status;
 
 	while (!list_empty(&data->pages)) {
@@ -1446,6 +1445,13 @@ static void nfs_commit_release(void *calldata)
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
+}
+
+static void nfs_commit_release(void *calldata)
+{
+	struct nfs_write_data *data = calldata;
+
+	nfs_commit_release_pages(data);
 	nfs_commit_clear_lock(NFS_I(data->inode));
 	nfs_commitdata_release(calldata);
 }
-- 
1.7.2.1

