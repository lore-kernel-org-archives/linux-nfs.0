Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41701 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754754AbdCBQDU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:03:20 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 15/19] NFS make COPY synchronous xdr configurable
Date: Thu, 2 Mar 2017 11:01:19 -0500
Message-ID: <20170302160123.30375-16-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of hardcoding always sending async copy, make it
configurable. In case, we get ERR_OFFLOAD_NO_REQS and we need to
resend the operation as synchronous.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c      | 2 ++
 fs/nfs/nfs42xdr.c       | 2 +-
 include/linux/nfs_xdr.h | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 7a1b2ae..b29f2c9 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -248,6 +248,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	size_t count = args->count;
 	int status;
 	uint64_t ret_count;
+	bool sync = false;
 
 	if (nss) {
 		args->cp_src = nss;
@@ -272,6 +273,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
+	args->sync = sync;
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
 	switch (status) {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 9e388e1..d300b77 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -199,7 +199,7 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint64(xdr, args->count);
 
 	encode_uint32(xdr, 1); /* consecutive = true */
-	encode_uint32(xdr, 0); /* synchronous = false */
+	encode_uint32(xdr, args->sync);
 	if (args->cp_src == NULL) { /* intra-ssc */
 		encode_uint32(xdr, 0); /* no src server list */
 		return;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2ed335e..c210e93 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1373,6 +1373,7 @@ struct nfs42_copy_args {
 	u64				count;
 	/* Support one source server */
 	struct nl4_servers		*cp_src;
+	bool				sync;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1

