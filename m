From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] showmount: Remove unused local getport() implementation
Date: Tue, 05 Aug 2008 14:12:58 -0400
Message-ID: <20080805181258.23104.63378.stgit@manray.1015granger.net>
References: <20080805180004.23104.29661.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17702 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757977AbYHESNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:13:44 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id m75IDfkq025606
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:41 -0600
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m75IDeRs032766
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 12:13:40 -0600
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.2/8.14.2) with ESMTP id m75ICwu8023245
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 14:12:58 -0400
In-Reply-To: <20080805180004.23104.29661.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: remove showmount's local getport() implementation, now that it
uses the shared one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |  105 -------------------------------------------
 1 files changed, 0 insertions(+), 105 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 360f2fa..6812277 100644
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

