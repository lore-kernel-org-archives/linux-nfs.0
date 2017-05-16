Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:33528 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750799AbdEPQAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 12:00:20 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFS fix COMMIT after COPY
Date: Tue, 16 May 2017 12:00:15 -0400
Message-ID: <20170516160015.20582-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a typo in the commit e092693443b995c8e3a565a73b5fdb05f1260f9b
"NFS append COMMIT after synchronous COPY"

Reported-by: Eryu Guan <eguan@redhat.com>
Fixes: e092693443b ("NFS append COMMIT after synchronous COPY")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 929d09a..319a47d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -177,7 +177,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		goto out;
 
-	if (!nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
+	if (nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
 				    &res->commit_res.verf->verifier)) {
 		status = -EAGAIN;
 		goto out;
-- 
1.8.3.1

