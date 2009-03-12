From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/40] SUNRPC: rpcbind actually interprets r_owner string
Date: Thu, 12 Mar 2009 12:08:37 -0400
Message-ID: <20090312160836.16019.55413.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:25245 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbZCLQJR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:09:17 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC 1833 has little to say about the contents of r_owner; it only
specifies that it is a string, and states that it is used to control
who can UNSET an entry.

Our port of rpcbind (from Sun) assumes this string contains a numeric
UID value, not alphabetical or symbolic characters, but checks this
value only for AF_LOCAL RPCB_SET or RPCB_UNSET requests.  In all other
cases, rpcbind ignores the contents of the r_owner string.

The reference user space implementation of rpcb_set(3) uses a numeric
UID for all SET/UNSET requests (even via the network) and an empty
string for all other requests.  We emulate that behavior here to
maintain bug-for-bug compatibility.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 317eb8a..4e86dfe 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -63,9 +63,16 @@ enum {
  * r_owner
  *
  * The "owner" is allowed to unset a service in the rpcbind database.
- * We always use the following (arbitrary) fixed string.
+ *
+ * For AF_LOCAL SET/UNSET requests, rpcbind treats this string as a
+ * UID which it maps to a local user name via a password lookup.
+ * In all other cases it is ignored.
+ *
+ * For SET/UNSET requests, user space provides a value, even for
+ * network requests, and GETADDR uses an empty string.  We follow
+ * those precedents here.
  */
-#define RPCB_OWNER_STRING	"rpcb"
+#define RPCB_OWNER_STRING	"0"
 #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
 
 static void			rpcb_getport_done(struct rpc_task *, void *);
@@ -566,7 +573,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_xprt = xprt_get(xprt);
 	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
 	map->r_addr = rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR);
-	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
+	map->r_owner = "";
 	map->r_status = -EIO;
 
 	child = rpcb_call_async(rpcb_clnt, map, proc);

