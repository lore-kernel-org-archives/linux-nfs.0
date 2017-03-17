Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:8116 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751331AbdCQVES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 17:04:18 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v2 11/12] NFS if we got partial copy ignore errors
Date: Fri, 17 Mar 2017 17:03:56 -0400
Message-ID: <20170317210357.48079-12-kolga@netapp.com>
In-Reply-To: <20170317210357.48079-1-kolga@netapp.com>
References: <20170317210357.48079-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't ignore ENOSPC. Otherwise, try next copy chunk

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 850fa10..acd884d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -178,7 +178,8 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	}
 out:
 	*ret_count = copy->count;
-	status = -copy->error;
+	if (copy->count < 0 || copy->error == ENOSPC)
+		status = -copy->error;
 	if (copy->count && copy->verf.committed != NFS_FILE_SYNC)
 		status = nfs_commit_file(dst, &copy->verf.verifier);
 	kfree(copy);
-- 
1.8.3.1

