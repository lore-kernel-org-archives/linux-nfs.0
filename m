From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] mount command: remove local getport() implementation
Date: Mon, 01 Dec 2008 13:48:56 -0500
Message-ID: <20081201184856.10436.41766.stgit@ingres.1015granger.net>
References: <20081201183616.10436.71066.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: steved@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43793 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbYLASur (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:50:47 -0500
In-Reply-To: <20081201183616.10436.71066.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate local getport() implementation from utils/mount/network.c, as
it is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   76 +------------------------------------------------
 1 files changed, 2 insertions(+), 74 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8d96e12..0c68993 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -449,78 +449,6 @@ err_connect:
 	return RPC_ANYSOCK;
 }
 
-/*
- * getport() is very similar to pmap_getport() with the exception that
- * this version tries to use an ephemeral port, since reserved ports are
- * not needed for GETPORT queries.  This conserves the very limited
- * reserved port space, which helps reduce failed socket binds
- * during mount storms.
- *
- * A side effect of calling this function is that rpccreateerr is set.
- */
-static unsigned short getport(struct sockaddr_in *saddr,
-				unsigned long program,
-				unsigned long version,
-				unsigned int proto)
-{
-	struct sockaddr_in bind_saddr;
-	unsigned short port = 0;
-	int socket;
-	CLIENT *clnt = NULL;
-	enum clnt_stat stat;
- 
-	bind_saddr = *saddr;
-	bind_saddr.sin_port = htons(PMAPPORT);
-
-	socket = get_socket(&bind_saddr, proto, PMAP_TIMEOUT, FALSE, TRUE);
-	if (socket == RPC_ANYSOCK) {
-		if (proto == IPPROTO_TCP &&
-		    rpc_createerr.cf_error.re_errno == ETIMEDOUT)
-			rpc_createerr.cf_stat = RPC_TIMEDOUT;
-		return 0;
-	}
-
-	switch (proto) {
-	case IPPROTO_UDP:
-		clnt = clntudp_bufcreate(&bind_saddr,
-					 PMAPPROG, PMAPVERS,
-					 RETRY_TIMEOUT, &socket,
-					 RPCSMALLMSGSIZE,
-					 RPCSMALLMSGSIZE);
-		break;
-	case IPPROTO_TCP:
-		clnt = clnttcp_create(&bind_saddr,
-				      PMAPPROG, PMAPVERS,
-				      &socket,
-				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
-		break;
-	}
-	if (clnt != NULL) {
-		struct pmap parms = {
-			.pm_prog	= program,
-			.pm_vers	= version,
-			.pm_prot	= proto,
-		};
-
-		stat = clnt_call(clnt, PMAPPROC_GETPORT,
-				 (xdrproc_t)xdr_pmap, (caddr_t)&parms,
-				 (xdrproc_t)xdr_u_short, (caddr_t)&port,
-				 TIMEOUT);
-		if (stat) {
-			clnt_geterr(clnt, &rpc_createerr.cf_error);
-			rpc_createerr.cf_stat = stat;
-		}
-		clnt_destroy(clnt);
-		if (stat != RPC_SUCCESS)
-			port = 0;
-		else if (port == 0)
-			rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
-	}
-	close(socket);
-
-	return port;
-}
-
 static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
 			 const rpcprog_t program, const rpcvers_t version,
 			 const unsigned short protocol,
@@ -843,9 +771,9 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
  * @prot: target RPC protocol
  * @caddr: filled in with our network address
  *
- * Sigh... getport() doesn't actually check the version number.
+ * Sigh... GETPORT queries don't actually check the version number.
  * In order to make sure that the server actually supports the service
- * we're requesting, we open and RPC client, and fire off a NULL
+ * we're requesting, we open an RPC client, and fire off a NULL
  * RPC call.
  *
  * caddr is the network address that the server will use to call us back.

