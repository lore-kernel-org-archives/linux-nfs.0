From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] SUNRPC: Use rpcbind version 2 GETPORT
Date: Wed, 25 Jun 2008 17:24:39 -0400
Message-ID: <20080625212438.3171.67773.stgit@ellison.1015granger.net>
References: <20080625212101.3171.86703.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:64668 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbYFYVaH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2008 17:30:07 -0400
In-Reply-To: <20080625212101.3171.86703.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Change the version 2 procedure name to GETPORT.  It's the same
procedure number as GETADDR, but version 2 implementations usually refer
to it as GETPORT.

This also now matches the procedure name used in the version 2 procedure
entry in the rpcb_next_version[] array, making it slightly less confusing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b939b90..8648570 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -576,7 +576,7 @@ out_err:
 static struct rpc_procinfo rpcb_procedures2[] = {
 	PROC(SET,		mapping,	set),
 	PROC(UNSET,		mapping,	set),
-	PROC(GETADDR,		mapping,	getport),
+	PROC(GETPORT,		mapping,	getport),
 };
 
 static struct rpc_procinfo rpcb_procedures3[] = {

