From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] SUNRPC: Don't return EPROTONOSUPPORT in svc_register()'s
	helpers
Date: Fri, 23 Jan 2009 11:46:08 -0500
Message-ID: <20090123164608.27126.28088.stgit@ingres.1015granger.net>
References: <20090123164302.27126.56411.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:41022 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756830AbZAWQtF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 11:49:05 -0500
In-Reply-To: <20090123164302.27126.56411.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC client returns -EPROTONOSUPPORT if there is a protocol version
mismatch (ie the remote RPC server doesn't support the RPC protocol
version sent by the client).

Helpers for the svc_register() function return -EPROTONOSUPPORT if they
don't recognize the passed-in IPPROTO_ value.

These are two entirely different errors.

Have the helpers return -ENOPROTOOPT instead of -ENOPROTOOPT.  This will
allow callers to determine and report more precisely what the problem is.

This patch is part of a series that addresses
   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index c51fed4..a278a82 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -750,7 +750,7 @@ static int __svc_rpcb_register4(const u32 program, const u32 version,
 		netid = RPCBIND_NETID_TCP;
 		break;
 	default:
-		return -EPROTONOSUPPORT;
+		return -ENOPROTOOPT;
 	}
 
 	return rpcb_v4_register(program, version,
@@ -786,7 +786,7 @@ static int __svc_rpcb_register6(const u32 program, const u32 version,
 		netid = RPCBIND_NETID_TCP6;
 		break;
 	default:
-		return -EPROTONOSUPPORT;
+		return -ENOPROTOOPT;
 	}
 
 	return rpcb_v4_register(program, version,

