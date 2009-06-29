From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/31] getport: RPC_PROGNOTREGISTERED is a permanent error
Date: Mon, 29 Jun 2009 13:36:23 -0400
Message-ID: <20090629173622.2076.61556.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:55356 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbZF2Rgn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:36:43 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcbind returns RPC_PROGNOTREGISTERED if it knows for certain that an
RPC program is not supported for a given transport.  This is a
permanent and authoritative error, so the library's rpcbind query API
should never retry the query -- it will only get the same answer.

A similar change was submitted for libtirpc.  Unlike rpcb_getaddr(3t),
mount.nfs's rpcbind client only retries once (with RPCB3PROC_GETADDR),
but an extra TCP socket in this case would leave another port in
TIME_WAIT.  It's infrequent enough, but might as well get rid of it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index bc0f121..71f02f3 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -469,7 +469,7 @@ static unsigned short nfs_gp_rpcb_getaddr(CLIENT *client,
 		case RPC_SUCCESS:
 			if ((uaddr == NULL) || (uaddr[0] == '\0')) {
 				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
-				continue;
+				return 0;
 			}
 
 			port = nfs_universal2port(uaddr);

