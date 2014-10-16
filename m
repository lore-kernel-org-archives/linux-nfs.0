Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:65506 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbaJPTjh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:39:37 -0400
Received: by mail-ie0-f176.google.com with SMTP id rp18so4189347iec.35
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:39:37 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id hi1sm1273190igb.18.2014.10.16.12.39.36
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:39:36 -0700 (PDT)
Subject: [PATCH v1 10/16] NFS: Include transport protocol name in UCS client
 string
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:39:35 -0400
Message-ID: <20141016193935.13414.97081.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs_match_client() function asserts that different nfs_client
structures are used when mounting the same server with different
transport protocols. For example, if a Linux client mounts the same
server via NFSv3 with some UDP mounts and some TCP mounts, it will
use only two transports and two nfs_client structures: one shared
with all UDP mounts, and one shared with all TCP mounts.

When a uniform client string is in use (NFSv4.1, or NFSv4.0 with the
"migration" mount option), nfs_match_client() will ensure an
nfs_client structure and separate transport is created for mounts
with unique "proto=" settings (one for TCP and one for RDMA,
currently).

But EXCHANGE_ID sends exactly the same nfs_client_id4 string on both
transports. The server then believes that the client is trunking
over disparate transports, when it clearly is not. The open and lock
state that will appear on each transport is disjoint.

Now that NFSv4.1 over RDMA is supported, a user can mount the same
server with NFSv4.1 over TCP and RDMA concurrently. The client will
send an EXCHANGE_ID with the same client ID on both transports, and
it will also send a CREATE_SESSION on both.

To ensure the Linux client represents itself correctly to servers,
add the transport protocol name to the uniform client string. Each
transport instance should get its own client ID (and session) to
prevent trunking.

This doesn't appear to be a problem for NFSv4.0 without migration.
It also wasn't a problem for NFSv4.1 when TCP was the only available
transport.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6ca0c8e..a1243e7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4929,16 +4929,23 @@ nfs4_init_uniform_client_string(const struct nfs_client *clp,
 				char *buf, size_t len)
 {
 	const char *nodename = clp->cl_rpcclient->cl_nodename;
+	unsigned int result;
 
+	rcu_read_lock();
 	if (nfs4_client_id_uniquifier[0] != '\0')
-		return scnprintf(buf, len, "Linux NFSv%u.%u %s/%s",
+		result = scnprintf(buf, len, "Linux NFSv%u.%u %s/%s %s",
 				clp->rpc_ops->version,
 				clp->cl_minorversion,
 				nfs4_client_id_uniquifier,
-				nodename);
-	return scnprintf(buf, len, "Linux NFSv%u.%u %s",
+				nodename, rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_PROTO));
+	else
+		result = scnprintf(buf, len, "Linux NFSv%u.%u %s %s",
 				clp->rpc_ops->version, clp->cl_minorversion,
-				nodename);
+				nodename, rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_PROTO));
+	rcu_read_unlock();
+	return result;
 }
 
 /*

