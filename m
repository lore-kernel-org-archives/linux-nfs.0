Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:17279 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754755AbdCBQDU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:03:20 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 19/19] NFS if we got partial copy ignore errors
Date: Thu, 2 Mar 2017 11:01:23 -0500
Message-ID: <20170302160123.30375-20-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
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
index 232447d..7a8f770 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -222,7 +222,8 @@ static int handle_async_copy(struct nfs42_copy_res *res,
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

