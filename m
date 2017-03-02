Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:36004 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752854AbdCBQPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:15:01 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 16/19] NFS handle COPY ERR_OFFLOAD_NO_REQS
Date: Thu, 2 Mar 2017 11:01:20 -0500
Message-ID: <20170302160123.30375-17-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
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
index b29f2c9..c9d8d7a 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -273,10 +273,17 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
+retry:
 	args->sync = sync;
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
 	switch (status) {
+	case -NFS4ERR_OFFLOAD_NO_REQS:
+		if (!sync) {
+			sync = true;
+			goto retry;
+		}
+		break;
 	case -ENOTSUPP:
 		server->caps &= ~NFS_CAP_COPY;
 		break;
-- 
1.8.3.1

