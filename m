From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/11] SUNRPC: fix a typo
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.22144.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946251AbWJSRHt@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Chuck Lever <chuck.lever@oracle.com>

Yes, this actually passed tests the way it was.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 28100e0..757fc91 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1366,7 +1366,7 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 	if (xprt->slot == NULL)
 		return -ENOMEM;
 
-	if (ntohs(addr->sin_port != 0))
+	if (ntohs(addr->sin_port) != 0)
 		xprt_set_bound(xprt);
 	xprt->port = xs_get_random_port();
 
