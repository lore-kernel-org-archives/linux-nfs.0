From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] SUNRPC: Use AUTH_NULL for GETPORT/GETADDR requests
Date: Fri, 15 May 2009 11:33:09 -0400
Message-ID: <20090515153309.17053.44496.stgit@ingres.1015granger.net>
References: <20090515153111.17053.3822.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39845 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbZEOPdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2009 11:33:16 -0400
In-Reply-To: <20090515153111.17053.3822.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcbind servers do not require RPC authentication, so AUTH_NULL is all
that is needed.  This saves a few bytes on the wire, and a bit of
computational expense on both ends.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index beee6da..3083597 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -141,7 +141,7 @@ static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 		.servername	= "localhost",
 		.program	= &rpcb_program,
 		.version	= version,
-		.authflavor	= RPC_AUTH_UNIX,
+		.authflavor	= RPC_AUTH_NULL,
 		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
 
@@ -158,7 +158,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.servername	= hostname,
 		.program	= &rpcb_program,
 		.version	= version,
-		.authflavor	= RPC_AUTH_UNIX,
+		.authflavor	= RPC_AUTH_NULL,
 		.flags		= (RPC_CLNT_CREATE_NOPING |
 					RPC_CLNT_CREATE_NONPRIVPORT),
 	};

