From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/16] nfs-utils: Remove excess log reporting
Date: Thu, 04 Sep 2008 12:57:05 -0400
Message-ID: <20080904165704.1471.40730.stgit@manray.1015granger.net>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:56268 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbYIDQ7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:59:24 -0400
In-Reply-To: <20080904165122.1471.24485.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 49e88e8..09bbbb7 100644
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

