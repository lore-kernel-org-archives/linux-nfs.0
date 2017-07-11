Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:37871 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934047AbdGKQoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:37 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 19/42] NFS also send OFFLOAD_CANCEL to source server
Date: Tue, 11 Jul 2017 12:43:53 -0400
Message-ID: <20170711164416.1982-20-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In case of copy is cancelled, also send OFFLOAD_CANCEL to the source
server.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 36b265a..b7c08a9 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -206,12 +206,14 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	if (copy->count <= 0)
 		status = -copy->error;
 
+out_free:
 	kfree(copy);
 	return status;
 out_cancel:
 	nfs42_do_offload_cancel_async(dst, &copy->stateid);
-	kfree(copy);
-	return status;
+	if (!nfs42_files_from_same_server(src, dst))
+		nfs42_do_offload_cancel_async(src, src_stateid);
+	goto out_free;
 }
 
 static ssize_t _nfs42_proc_copy(struct file *src,
-- 
1.8.3.1

