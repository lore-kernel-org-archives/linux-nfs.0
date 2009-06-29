From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/31] getport: RPCB_GETADDR r_owner should be an empty string
Date: Mon, 29 Jun 2009 13:34:59 -0400
Message-ID: <20090629173458.2076.48916.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36104 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758000AbZF2RfW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:35:22 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some servers reject RPCB_GETADDR requests with a non-empty r_owner
field.  "RPC: Server can't decode arguments"

An empty string is already used by libtirpc and the kernel
for RPCB_GETADDR requests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index cf1677e..926bab8 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -458,10 +458,6 @@ static int nfs_gp_ping(CLIENT *client, struct timeval timeout)
 /*
  * Initialize the rpcb argument for a GETADDR request.
  *
- * The rpcbind daemon ignores the parms.r_owner field in GETADDR
- * requests, but we plant an eye-catcher to help distinguish these
- * requests in network traces.
- *
  * Returns 1 if successful, and caller must free strings pointed
  * to by r_netid and r_addr; otherwise 0.
  */
@@ -489,7 +485,7 @@ static int nfs_gp_init_rpcb_parms(const struct sockaddr *sap,
 	parms->r_vers	= version;
 	parms->r_netid	= netid;
 	parms->r_addr	= addr;
-	parms->r_owner	= "nfs-utils";	/* eye-catcher */
+	parms->r_owner	= "";
 
 	return 1;
 }

