Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:20210 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934041AbdGKQoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:32 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 14/42] NFS if we got partial copy ignore errors
Date: Tue, 11 Jul 2017 12:43:48 -0400
Message-ID: <20170711164416.1982-15-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index dba2b62..dfd43bc 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -179,7 +179,8 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 out:
 	*ret_count = copy->count;
 	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
-	status = -copy->error;
+	if (copy->count <= 0)
+		status = -copy->error;
 
 	kfree(copy);
 	return status;
-- 
1.8.3.1

