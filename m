Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:37871 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933439AbdGKQoc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:32 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 13/42] NFS handle COPY ERR_OFFLOAD_NO_REQS
Date: Tue, 11 Jul 2017 12:43:47 -0400
Message-ID: <20170711164416.1982-14-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If client sent async COPY and server replied with
ERR_OFFLOAD_NO_REQS, client should retry with a synchronous copy.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 8223726..dba2b62 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -309,6 +309,13 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 				&args, &res);
 		inode_unlock(file_inode(dst));
 		switch (err) {
+		case -NFS4ERR_OFFLOAD_NO_REQS:
+			if (!args.sync) {
+				args.sync = true;
+				dst_exception.retry = 1;
+				continue;
+			}
+			break;
 		case -ENOTSUPP:
 			server->caps &= ~NFS_CAP_COPY;
 			if (nfs42_files_from_same_server(src, dst))
-- 
1.8.3.1

