From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/31] getport: Restore historical TCP connect timeout error
	code
Date: Mon, 29 Jun 2009 13:36:51 -0400
Message-ID: <20090629173650.2076.36481.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35615 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762AbZF2RhM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:12 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The latest versions of mount.nfs appear not to fall back to
UDP if TCP isn't available on the server.

Our new nfs_getport() implementation is missing a bit of logic
from the original mount getport() implementation.  Without it,
nfs_probe_port() sees a TCP connect timeout as a permanent error,
so it fails immediately instead of attempting to try again with
UDP.

Similar changes for our new ping API (see the old clnt_ping()
function, which is still in utils/mount/network.c).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index aa9c154..e39f809 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -66,6 +66,23 @@ static const rpcvers_t default_rpcb_version = PMAPVERS;
 #endif	/* !HAVE_LIBTIRPC */
 
 /*
+ * Historical: Map TCP connect timeouts to timeout
+ * error code used by UDP.
+ */
+static void
+nfs_gp_map_tcp_errorcodes(const unsigned short protocol)
+{
+	if (protocol != IPPROTO_TCP)
+		return;
+
+	switch (rpc_createerr.cf_error.re_errno) {
+	case ETIMEDOUT:
+		rpc_createerr.cf_stat = RPC_TIMEDOUT;
+		break;
+	}
+}
+
+/*
  * There's no easy way to tell how the local system's networking
  * and rpcbind is configured (ie. whether we want to use IPv6 or
  * IPv4 loopback to contact RPC services on the local host).  We
@@ -188,10 +205,13 @@ static CLIENT *nfs_gp_get_rpcbclient(struct sockaddr *sap,
 		NULL,
 	};
 	rpcprog_t rpcb_prog = nfs_getrpcbyname(RPCBPROG, rpcb_pgmtbl);
+	CLIENT *clnt;
 
 	nfs_gp_set_port(sap, nfs_gp_get_rpcb_port(transport));
-	return nfs_get_rpcclient(sap, salen, transport, rpcb_prog,
-					version, timeout);
+	clnt = nfs_get_rpcclient(sap, salen, transport, rpcb_prog,
+							version, timeout);
+	nfs_gp_map_tcp_errorcodes(transport);
+	return clnt;
 }
 
 /*
@@ -634,6 +654,7 @@ int nfs_rpc_ping(const struct sockaddr *sap, const socklen_t salen,
 						program, version, &tout);
 	if (client != NULL) {
 		result = nfs_gp_ping(client, tout);
+		nfs_gp_map_tcp_errorcodes(protocol);
 		CLNT_DESTROY(client);
 	}
 
@@ -757,6 +778,7 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
 						program, version, &timeout);
 		if (client != NULL) {
 			result = nfs_gp_ping(client, timeout);
+			nfs_gp_map_tcp_errorcodes(protocol);
 			CLNT_DESTROY(client);
 		}
 	}

