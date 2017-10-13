Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13539 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752179AbdJMUz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Oct 2017 16:55:58 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 11/23] NFS handle COPY ERR_OFFLOAD_NO_REQS
Date: Fri, 13 Oct 2017 16:55:49 -0400
Message-ID: <20171013205550.65573-12-kolga@netapp.com>
In-Reply-To: <20171013205550.65573-1-kolga@netapp.com>
References: <20171013205550.65573-1-kolga@netapp.com>
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
index 51dab4c..58ece48 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -317,7 +317,11 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
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

