Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19419 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932868Ab1CWN2C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:02 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/12] NFSv4.1: don't send COMMIT to ds for data sync writes
Date: Wed, 23 Mar 2011 09:27:44 -0400
Message-Id: <1300886875-5016-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Based on consensus reached in Feb 2011 interim IETF meeting regarding
use of LAYOUTCOMMIT, it has been decided that a NFS_DATA_SYNC return
from a WRITE to data server should not initiate a COMMIT.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/write.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 55a8c36..92b4a66 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -474,7 +474,10 @@ nfs_clear_request_commit(struct nfs_page *req)
 static inline
 int nfs_write_need_commit(struct nfs_write_data *data)
 {
-	return data->verf.committed != NFS_FILE_SYNC;
+	if (data->verf.committed == NFS_DATA_SYNC)
+		return data->lseg == NULL;
+	else
+		return data->verf.committed != NFS_FILE_SYNC;
 }
 
 static inline
-- 
1.7.2.1

