From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] SUNRPC: Use GETADDR for rpcbind version 4 queries
Date: Wed, 25 Jun 2008 17:24:47 -0400
Message-ID: <20080625212446.3171.62122.stgit@ellison.1015granger.net>
References: <20080625212101.3171.86703.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:63622 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbYFYV1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2008 17:27:44 -0400
In-Reply-To: <20080625212101.3171.86703.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some rpcbind servers that do support rpcbind version 4 do not support
the GETVERSADDR procedure.  Use GETADDR for querying rpcbind servers
via rpcbind version 4 instead of GETVERSADDR.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8648570..59b1d51 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -588,6 +588,7 @@ static struct rpc_procinfo rpcb_procedures3[] = {
 static struct rpc_procinfo rpcb_procedures4[] = {
 	PROC(SET,		mapping,	set),
 	PROC(UNSET,		mapping,	set),
+	PROC(GETADDR,		getaddr,	getaddr),
 	PROC(GETVERSADDR,	getaddr,	getaddr),
 };
 
@@ -595,7 +596,7 @@ static struct rpcb_info rpcb_next_version[] = {
 #ifdef CONFIG_SUNRPC_BIND34
 	{
 		.rpc_vers	= RPCBVERS_4,
-		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETVERSADDR],
+		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETADDR],
 	},
 	{
 		.rpc_vers	= RPCBVERS_3,
@@ -615,7 +616,7 @@ static struct rpcb_info rpcb_next_version6[] = {
 #ifdef CONFIG_SUNRPC_BIND34
 	{
 		.rpc_vers	= RPCBVERS_4,
-		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETVERSADDR],
+		.rpc_proc	= &rpcb_procedures4[RPCBPROC_GETADDR],
 	},
 	{
 		.rpc_vers	= RPCBVERS_3,

