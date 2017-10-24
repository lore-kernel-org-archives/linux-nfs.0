Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:9199 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751505AbdJXRrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Oct 2017 13:47:47 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 11/12] NFS handle COPY ERR_OFFLOAD_NO_REQS
Date: Tue, 24 Oct 2017 13:47:24 -0400
Message-ID: <20171024174725.74870-12-kolga@netapp.com>
In-Reply-To: <20171024174725.74870-1-kolga@netapp.com>
References: <20171024174725.74870-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If client sent async COPY and server replied with
ERR_OFFLOAD_NO_REQS, client should retry with a synchronous copy.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3e9d033..8f2ead3 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -316,7 +316,11 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		if (err == -ENOTSUPP) {
 			err = -EOPNOTSUPP;
 			break;
-		} if (err == -EAGAIN) {
+		} else if (err == -EAGAIN) {
+			dst_exception.retry = 1;
+			continue;
+		} else if (err == -NFS4ERR_OFFLOAD_NO_REQS && !args.sync) {
+			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
 		}
-- 
1.8.3.1

