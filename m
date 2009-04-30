From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 20/39] nfs41: Setup the backchannel
Date: Fri,  1 May 2009 02:22:28 +0300
Message-ID: <1241133748-954-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26106 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754773AbZD3XWm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:42 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The NFS v4.1 callback service has already been setup, and
rpc_xprt->serv points to the svc_serv structure describing it.
Invoke the xprt_setup_backchannel() initialization to pre-
allocate the necessary backchannel structures.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: change nfs4_put_session(nfs4_session**) to nfs4_destroy_session(nfs_session*)]
Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[moved xprt_setup_backchannel from nfs4_init_session to nfs4_init_backchannel]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ac6575c..4f75ec5 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -37,6 +37,7 @@
 #include <linux/in6.h>
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
+#include <linux/sunrpc/bc_xprt.h>
 
 #include <asm/system.h>
 
@@ -1096,6 +1097,14 @@ static int nfs4_init_callback(struct nfs_client *clp)
 	int error;
 
 	if (clp->rpc_ops->version == 4) {
+		if (nfs4_has_session(clp)) {
+			error = xprt_setup_backchannel(
+						clp->cl_rpcclient->cl_xprt,
+						NFS41_BC_MIN_CALLBACKS);
+			if (error < 0)
+				return error;
+		}
+
 		error = nfs_callback_up(clp->cl_minorversion,
 					clp->cl_rpcclient->cl_xprt);
 		if (error < 0) {
-- 
1.6.2.1

