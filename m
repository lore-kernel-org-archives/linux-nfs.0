From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/31] support: Don't return RPC_UNKNOWNHOST from rpc_socket.c
Date: Mon, 29 Jun 2009 13:36:04 -0400
Message-ID: <20090629173603.2076.38198.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:38713 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbZF2Rhi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:38 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC_UNKNOWNHOST means a hostname isn't known -- basically it's
EAI_NONAME from getaddrinfo(3).  Since the functions in rpc_socket.c
don't take a hostname argument, RPC_UNKNOWNHOST is not an appropriate
return code from these functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpc_socket.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 2f76542..a2255c3 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -458,7 +458,7 @@ CLIENT *nfs_get_rpcclient(const struct sockaddr *sap,
 		}
 		break;
 	default:
-		rpc_createerr.cf_stat = RPC_UNKNOWNHOST;
+		rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 		return NULL;
 	}
 
@@ -521,7 +521,7 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
 		}
 		break;
 	default:
-		rpc_createerr.cf_stat = RPC_UNKNOWNHOST;
+		rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 		return NULL;
 	}
 

