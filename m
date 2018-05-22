Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:32455 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751336AbeEVSkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 14:40:51 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] [SUNRPC] make sure to clone timeout values
Date: Tue, 22 May 2018 14:40:48 -0400
Message-ID: <20180522184048.21586-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <olga.kornievskaia@gmail.com>

For pNFS, the operations to DS currently timeout in 10s. According
to the spec, the client must not be re-trying an NFSv4.1 operation
unless the connection was broken.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 net/sunrpc/clnt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6e432ec..97517eb 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -668,6 +668,7 @@ struct rpc_clnt *
 		.prognumber	= clnt->cl_prog,
 		.version	= clnt->cl_vers,
 		.authflavor	= flavor,
+		.timeout	= clnt->cl_timeout,
 	};
 	return __rpc_clone_client(&args, clnt);
 }
-- 
1.8.3.1

