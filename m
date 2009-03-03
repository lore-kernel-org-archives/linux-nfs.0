From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/17] SUNRPC: Use "0" as r_owner
Date: Tue, 03 Mar 2009 17:33:25 -0500
Message-ID: <20090303223324.2933.57002.stgit@ingres.1015granger.net>
References: <20090303220539.2933.15015.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org, steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:31724 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033AbZCCWfM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 17:35:12 -0500
In-Reply-To: <20090303220539.2933.15015.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It turns out that, despite the spec, rpcbind interprets the string
passed in the r_owner argument for SET and UNSET requests.  It expects
it to be a numeric UID, rather than an arbitrary string.

Change the kernel's r_owner string to be "0".

This is a documentation change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 317eb8a..0a3b8f5 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -63,9 +63,11 @@ enum {
  * r_owner
  *
  * The "owner" is allowed to unset a service in the rpcbind database.
- * We always use the following (arbitrary) fixed string.
+ * rpcbind maps this string to a local user name via a passwd lookup
+ * for AF_LOCAL SET/UNSET requests, but via the network (ie how the
+ * kernel registers its services) it is pretty much ignored.
  */
-#define RPCB_OWNER_STRING	"rpcb"
+#define RPCB_OWNER_STRING	"0"
 #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
 
 static void			rpcb_getport_done(struct rpc_task *, void *);

