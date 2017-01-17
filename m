Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:11763 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751171AbdAQUcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 15:32:52 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 05/10] NFS: Remove an extra if in _nfs4_recover_proc_open()
Date: Tue, 17 Jan 2017 15:32:00 -0500
Message-ID: <20170117203205.29033-6-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
References: <20170117203205.29033-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

It's simpler just to return the status unconditionally

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 83d31c93065e..02767aced45c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2215,11 +2215,8 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 
 	nfs_fattr_map_and_free_names(NFS_SERVER(dir), &data->f_attr);
 
-	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
+	if (o_res->rflags & NFS4_OPEN_RESULT_CONFIRM)
 		status = _nfs4_proc_open_confirm(data);
-		if (status != 0)
-			return status;
-	}
 
 	return status;
 }
-- 
2.11.0

