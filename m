Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46380 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752010AbdGFNnF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jul 2017 09:43:05 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFSv4.2 fix size storage for nfs42_proc_copy
Date: Thu, 6 Jul 2017 09:43:02 -0400
Message-ID: <20170706134302.98550-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return size of COPY is u64 but it was assigned to an "int" status.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 319a47d..6c2db51 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -146,7 +146,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	loff_t pos_src = args->src_pos;
 	loff_t pos_dst = args->dst_pos;
 	size_t count = args->count;
-	int status;
+	ssize_t status;
 
 	status = nfs4_set_rw_stateid(&args->src_stateid, src_lock->open_context,
 				     src_lock, FMODE_READ);
-- 
1.8.3.1

