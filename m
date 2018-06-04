Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35763 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753654AbeFDOxi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 10:53:38 -0400
Received: by mail-io0-f195.google.com with SMTP id u4-v6so14654978iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 07:53:37 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q2-v6sm4442044ioh.40.2018.06.04.07.53.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 07:53:35 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w54ErYpe004629
        for <linux-nfs@vger.kernel.org>; Mon, 4 Jun 2018 14:53:34 GMT
Subject: [PATCH v1 2/2] NFSv4.0: Remove transport protocol name from non-UCS
 client ID
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 04 Jun 2018 10:53:34 -0400
Message-ID: <20180604145334.11877.12862.stgit@manet.1015granger.net>
In-Reply-To: <20180604144154.11877.19298.stgit@manet.1015granger.net>
References: <20180604144154.11877.19298.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 69dd716c5ffd ("NFSv4: Add socket proto argument to
setclientid") (2007) added the transport protocol name to the client
ID string, but the patch description doesn't explain why this was
necessary.

At that time, the only transport protocol name that would have been
used is "tcp" (for both IPv4 and IPv6), resulting in no additional
distinctiveness of the client ID string.

Since there is one client instance, the server should recognize it's
state whether the client is connecting via TCP or RDMA. Same client,
same lease.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fa6f9a2..aa07745 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5595,8 +5595,6 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 		strlen(clp->cl_rpcclient->cl_nodename) +
 		1 +
 		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR)) +
-		1 +
-		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO)) +
 		1;
 	rcu_read_unlock();
 	if (nfs4_client_id_uniquifier[0] != '\0')
@@ -5615,20 +5613,16 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 
 	rcu_read_lock();
 	if (nfs4_client_id_uniquifier[0] != '\0')
-		scnprintf(str, len, "Linux NFSv4.0 %s/%s/%s %s",
+		scnprintf(str, len, "Linux NFSv4.0 %s/%s/%s",
 			  clp->cl_rpcclient->cl_nodename,
 			  nfs4_client_id_uniquifier,
 			  rpc_peeraddr2str(clp->cl_rpcclient,
-					   RPC_DISPLAY_ADDR),
-			  rpc_peeraddr2str(clp->cl_rpcclient,
-					   RPC_DISPLAY_PROTO));
+					   RPC_DISPLAY_ADDR));
 	else
-		scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
+		scnprintf(str, len, "Linux NFSv4.0 %s/%s",
 			  clp->cl_rpcclient->cl_nodename,
 			  rpc_peeraddr2str(clp->cl_rpcclient,
-					   RPC_DISPLAY_ADDR),
-			  rpc_peeraddr2str(clp->cl_rpcclient,
-					   RPC_DISPLAY_PROTO));
+					   RPC_DISPLAY_ADDR));
 	rcu_read_unlock();
 
 	clp->cl_owner_id = str;

