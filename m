Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:45040 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968218Ab3HIQwc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:52:32 -0400
Received: by mail-ye0-f174.google.com with SMTP id q9so1300585yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:52:31 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id v32sm20695277yhc.12.2013.08.09.09.52.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:52:30 -0700 (PDT)
Subject: [PATCH v2 31/33] NFS: Implement support for NFS4ERR_LEASE_MOVED
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:52:29 -0400
Message-ID: <20130809165229.5362.54228.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With NFSv4 minor version 0, the asynchronous lease RENEW
heartbeat can return NFS4ERR_LEASE_MOVED.  Error recovery logic for
async RENEW is a separate code path from the generic NFS proc paths,
so it must be updated to handle LEASE_MOVED as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 11283da..ecf8e96 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4158,7 +4158,13 @@ static void nfs4_renew_done(struct rpc_task *task, void *calldata)
 	struct nfs_client *clp = data->client;
 	unsigned long timestamp = data->timestamp;
 
-	if (task->tk_status < 0) {
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -NFS4ERR_LEASE_MOVED:
+		nfs4_schedule_lease_moved_recovery(clp);
+		break;
+	default:
 		/* Unless we're shutting down, schedule state recovery! */
 		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) == 0)
 			return;

