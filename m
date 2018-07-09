Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:57649 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932704AbeGITNj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:13:39 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 09/13] NFS handle COPY ERR_OFFLOAD_NO_REQS
Date: Mon, 9 Jul 2018 15:13:35 -0400
Message-ID: <20180709191339.44740-10-kolga@netapp.com>
In-Reply-To: <20180709191339.44740-1-kolga@netapp.com>
References: <20180709191339.44740-1-kolga@netapp.com>
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
index aeb9837..77451be 100644
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

