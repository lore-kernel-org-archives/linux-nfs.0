Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:32891 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751079AbdCQVFK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 17:05:10 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v2 09/12] NFS make COPY synchronous xdr configurable
Date: Fri, 17 Mar 2017 17:03:54 -0400
Message-ID: <20170317210357.48079-10-kolga@netapp.com>
In-Reply-To: <20170317210357.48079-1-kolga@netapp.com>
References: <20170317210357.48079-1-kolga@netapp.com>
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
index 2ffd96d..32b08ea 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -204,6 +204,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	size_t count = args->count;
 	int status;
 	uint64_t ret_count;
+	bool sync = false;
 
 	status = nfs4_set_rw_stateid(&args->src_stateid, src_lock->open_context,
 				     src_lock, FMODE_READ);
@@ -224,6 +225,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
+	args->sync = sync;
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
 	switch (status) {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 059d074..1f12574 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -158,7 +158,7 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint64(xdr, args->count);
 
 	encode_uint32(xdr, 1); /* consecutive = true */
-	encode_uint32(xdr, 0); /* synchronous = false */
+	encode_uint32(xdr, args->sync);
 	encode_uint32(xdr, 0); /* src server list */
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6c6130f..a04862c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1371,6 +1371,7 @@ struct nfs42_copy_args {
 	u64				dst_pos;
 
 	u64				count;
+	bool				sync;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1

