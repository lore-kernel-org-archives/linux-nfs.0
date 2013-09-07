Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:52573 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770Ab3IGXSh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 19:18:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/6] NFSv4: Disallow security negotiation for lookups when 'sec=' is specified
Date: Sat, 7 Sep 2013 19:18:11 -0400
Message-ID: <1378595893-60395-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378595893-60395-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that nfs4_proc_lookup_common respects the NFS_MOUNT_SECFLAVOUR
flag.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 68551ea..122b934 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3154,7 +3154,9 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 			err = -EPERM;
 			if (client != *clnt)
 				goto out;
-
+			/* No security negotiation if the user specified 'sec=' */
+			if (NFS_SERVER(dir)->flags & NFS_MOUNT_SECFLAVOUR)
+				goto out;
 			client = nfs4_create_sec_client(client, dir, name);
 			if (IS_ERR(client))
 				return PTR_ERR(client);
-- 
1.8.3.1

