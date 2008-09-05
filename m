From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/19] nfs-utils: Remove excess log reporting
Date: Fri, 05 Sep 2008 17:08:21 -0400
Message-ID: <20080905210820.10001.3551.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:49134 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbYIEVOT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:14:19 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The makesock() function already reports an error if it can't
create a socket.  Remove the redundant error check and logging done in
rpc_init() after a makesock() call.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/rpcmisc.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index 9d76e5d..506b595 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -151,10 +151,8 @@ rpc_init(char *name, int prog, int vers,
 			}
 			if (defport == 0)
 				sock = RPC_ANYSOCK;
-			else if ((sock = makesock(defport, IPPROTO_UDP)) < 0) {
-				xlog(L_FATAL, "%s: cannot make a UDP socket\n",
-						name);
-			}
+			else
+				sock = makesock(defport, IPPROTO_UDP);
 		}
 		if (sock == RPC_ANYSOCK)
 			sock = svcudp_socket (prog, 1);
@@ -181,10 +179,8 @@ rpc_init(char *name, int prog, int vers,
 			}
 			if (defport == 0)
 				sock = RPC_ANYSOCK;
-			else if ((sock = makesock(defport, IPPROTO_TCP)) < 0) {
-				xlog(L_FATAL, "%s: cannot make a TCP socket\n",
-						name);
-			}
+			else
+				sock = makesock(defport, IPPROTO_TCP);
 		}
 		if (sock == RPC_ANYSOCK)
 			sock = svctcp_socket (prog, 1);

