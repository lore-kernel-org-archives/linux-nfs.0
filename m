From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/23] SUNRPC: Don't return EPROTONOSUPPORT in
	svc_register()'s helpers
Date: Wed, 18 Mar 2009 20:46:59 -0400
Message-ID: <20090319004658.32404.99901.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17012 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbZCSAs2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:48:28 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC client returns -EPROTONOSUPPORT if there is a protocol version
mismatch (ie the remote RPC server doesn't support the RPC protocol
version sent by the client).

Helpers for the svc_register() function return -EPROTONOSUPPORT if they
don't recognize the passed-in IPPROTO_ value.

These are two entirely different failure modes.

Have the helpers return -ENOPROTOOPT instead of -EPROTONOSUPPORT.  This
will allow callers to determine more precisely what the underlying
problem is, and decide to report or recover appropriately.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d72ff44..17e0d72 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -749,7 +749,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 		netid = RPCBIND_NETID_TCP;
 		break;
 	default:
-		return -EPROTONOSUPPORT;
+		return -ENOPROTOOPT;
 	}
 
 	return rpcb_v4_register(program, version,
@@ -785,7 +785,7 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 		netid = RPCBIND_NETID_TCP6;
 		break;
 	default:
-		return -EPROTONOSUPPORT;
+		return -ENOPROTOOPT;
 	}
 
 	return rpcb_v4_register(program, version,

