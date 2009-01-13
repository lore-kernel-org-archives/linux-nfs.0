From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] SUNRPC: Don't use EPROTONOSUPPORT in svc_register()
Date: Tue, 13 Jan 2009 12:31:41 -0500
Message-ID: <20090113173141.6755.16134.stgit@ingres.1015granger.net>
References: <20090113172538.6755.83766.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:35591 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766AbZAMRcB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2009 12:32:01 -0500
In-Reply-To: <20090113172538.6755.83766.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC client returns EPROTONOSUPPORT if there is a protocol version
mismatch (ie the server doesn't support the RPC protocol version sent
by the client).

Since svc_register uses the RPC client, it's confusing when
svc_register's helpers return this errno for a problem not related to
a program number mismatch.

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

