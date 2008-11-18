From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] showmount command: Remove unused local getport()
	implementation
Date: Tue, 18 Nov 2008 14:29:40 -0500
Message-ID: <20081118192940.22516.64133.stgit@ingres.1015granger.net>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:50627 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYKRTaf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Nov 2008 14:30:35 -0500
In-Reply-To: <20081118192711.22516.2801.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: remove showmount.c's local getport() implementation, now that
the showmount command uses the shared one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |  105 -------------------------------------------
 1 files changed, 0 insertions(+), 105 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index cbc8f1a..5951033 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -40,7 +40,6 @@
 #include "nfsrpc.h"
 
 #define TIMEOUT_UDP	3
-#define TIMEOUT_TCP	10
 #define TOTAL_TIMEOUT	20
 
 static char *	version = "showmount for " VERSION;
@@ -151,110 +150,6 @@ done:
 	return ret;
 }
 
-static unsigned short getport(struct sockaddr_in *addr,
-			 unsigned long prog, unsigned long vers, int prot)
-{
-	CLIENT *client;
-	enum clnt_stat status;
-	struct pmap parms;
-	int ret, sock;
-	struct sockaddr_in laddr, saddr;
-	struct timeval tout = {0, 0};
-	socklen_t len;
-	unsigned int send_sz = 0;
-	unsigned int recv_sz = 0;
-	unsigned short port;
-
-	memset(&laddr, 0, sizeof(laddr));
-	memset(&saddr, 0, sizeof(saddr));
-	memset(&parms, 0, sizeof(parms));
-
-	memcpy(&saddr, addr, sizeof(saddr));
-	saddr.sin_port = htons(PMAPPORT);
-
-	if (prot == IPPROTO_TCP) {
-		sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
-		if (sock == -1) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			return 0;
-		}
-
-		tout.tv_sec = TIMEOUT_TCP;
-
-		ret = connect_nb(sock, &saddr, &tout);
-		if (ret != 0) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			close(sock);
-			return 0;
-		}
-		client = clnttcp_create(&saddr,
-					PMAPPROG, PMAPVERS, &sock,
-					0, 0);
-	} else {
-		/*
-		 * bind to any unused port.  If we left this up to the rpc
-		 * layer, it would bind to a reserved port, which has been shown
-		 * to exhaust the reserved port range in some situations.
-		 */
-		sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
-		if (sock == -1) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
-			return 0;
-		}
-
-		laddr.sin_family = AF_INET;
-		laddr.sin_port = 0;
-		laddr.sin_addr.s_addr = htonl(INADDR_ANY);
-
-		tout.tv_sec = TIMEOUT_UDP;
-
-		send_sz = RPCSMALLMSGSIZE;
-		recv_sz = RPCSMALLMSGSIZE;
-
-		len = sizeof(struct sockaddr_in);
-		if (bind(sock, (struct sockaddr *)&laddr, len) < 0) {
-			close(sock);
-			sock = RPC_ANYSOCK;
-			/* FALLTHROUGH */
-		}
-		client = clntudp_bufcreate(&saddr, PMAPPROG, PMAPVERS,
-					   tout, &sock, send_sz, recv_sz);
-	}
-
-	if (!client) {
-		close(sock);
-		rpc_createerr.cf_stat = RPC_RPCBFAILURE;
-		return 0;
-	}
-
-	clnt_control(client, CLSET_FD_CLOSE, NULL);
-
-	parms.pm_prog = prog;
-	parms.pm_vers = vers;
-	parms.pm_prot = prot;
-
-	status = clnt_call(client, PMAPPROC_GETPORT,
-			   (xdrproc_t) xdr_pmap, (caddr_t) &parms,
-			   (xdrproc_t) xdr_u_short, (caddr_t) &port,
-			   tout);
-
-	if (status != RPC_SUCCESS) {
-		clnt_geterr(client, &rpc_createerr.cf_error);
-		rpc_createerr.cf_stat = status;
-		clnt_destroy(client);
-		return 0;
-	} else if (port == 0) {
-		rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
-	}
-
-	clnt_destroy(client);
-
-	return htons(port);
-}
-
 int main(int argc, char **argv)
 {
 	char hostname_buf[MAXHOSTLEN];

