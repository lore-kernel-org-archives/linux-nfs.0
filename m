From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/5] SUNRPC: Use correct XDR encoding procedure for rpcbind SET/UNSET
Date: Mon, 14 Jul 2008 16:03:26 -0400
Message-ID: <1216065811-28559-1-git-send-email-bfields@citi.umich.edu>
References: <76bd70e30807111211m567e9f8cv38a975bbc9df5758@mail.gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	chucklever@gmail.com, Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43915 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756235AbYGNUDe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jul 2008 16:03:34 -0400
In-Reply-To: <76bd70e30807111211m567e9f8cv38a975bbc9df5758-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The rpcbind versions 3 and 4 SET and UNSET procedures use the same
arguments as the GETADDR procedure.

While definitely a bug, this hasn't been a problem so far since the
kernel hasn't used version 3 or 4 SET and UNSET.  But this will change
in just a moment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpcb_clnt.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 24e93e0..0021fad 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -426,6 +426,10 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
 	map->r_status = status;
 }
 
+/*
+ * XDR functions for rpcbind
+ */
+
 static int rpcb_encode_mapping(struct rpc_rqst *req, __be32 *p,
 			       struct rpcbind_args *rpcb)
 {
@@ -581,14 +585,14 @@ static struct rpc_procinfo rpcb_procedures2[] = {
 };
 
 static struct rpc_procinfo rpcb_procedures3[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
+	PROC(SET,		getaddr,	set),
+	PROC(UNSET,		getaddr,	set),
 	PROC(GETADDR,		getaddr,	getaddr),
 };
 
 static struct rpc_procinfo rpcb_procedures4[] = {
-	PROC(SET,		mapping,	set),
-	PROC(UNSET,		mapping,	set),
+	PROC(SET,		getaddr,	set),
+	PROC(UNSET,		getaddr,	set),
 	PROC(GETADDR,		getaddr,	getaddr),
 	PROC(GETVERSADDR,	getaddr,	getaddr),
 };
-- 
1.5.5.rc1

