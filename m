From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/31] getport: Convert TCP connection refused to RPC_CANTRECV
Date: Mon, 29 Jun 2009 13:37:00 -0400
Message-ID: <20090629173659.2076.27504.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:54048 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756096AbZF2RhY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:24 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a similar vein to the timeout logic we just restored, a refused
TCP connection should be mapped to an equivalent UDP error code:
RPC_CANTRECV.

This is new behavior for TCP connections; the legacy mount command
appears to have simply failed immediately if a TCP connection was
refused during an rpcbind query.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index e39f809..f5ba4ef 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -79,6 +79,9 @@ nfs_gp_map_tcp_errorcodes(const unsigned short protocol)
 	case ETIMEDOUT:
 		rpc_createerr.cf_stat = RPC_TIMEDOUT;
 		break;
+	case ECONNREFUSED:
+		rpc_createerr.cf_stat = RPC_CANTRECV;
+		break;
 	}
 }
 

