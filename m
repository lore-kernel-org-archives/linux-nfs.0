Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49543 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757966Ab0LNO7M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:59:12 -0500
Received: by iwn9 with SMTP id 9so864340iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:59:11 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 29/31] SUNRPC: Determine value of "nrprocs" automatically
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:59:09 -0500
Message-ID: <20101214145908.2293.97087.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Just fixed a panic where the nrprocs field in a different upper layer
client was set by hand incorrectly.  Use the compiler-generated method
used by the other upper layer protocols.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d2a2ea0..43838c7 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -57,10 +57,6 @@ enum {
 	RPCBPROC_GETSTAT,
 };
 
-#define RPCB_HIGHPROC_2		RPCBPROC_CALLIT
-#define RPCB_HIGHPROC_3		RPCBPROC_TADDR2UADDR
-#define RPCB_HIGHPROC_4		RPCBPROC_GETSTAT
-
 /*
  * r_owner
  *
@@ -975,19 +971,19 @@ static struct rpcb_info rpcb_next_version6[] = {
 
 static struct rpc_version rpcb_version2 = {
 	.number		= RPCBVERS_2,
-	.nrprocs	= RPCB_HIGHPROC_2,
+	.nrprocs	= ARRAY_SIZE(rpcb_procedures2),
 	.procs		= rpcb_procedures2
 };
 
 static struct rpc_version rpcb_version3 = {
 	.number		= RPCBVERS_3,
-	.nrprocs	= RPCB_HIGHPROC_3,
+	.nrprocs	= ARRAY_SIZE(rpcb_procedures3),
 	.procs		= rpcb_procedures3
 };
 
 static struct rpc_version rpcb_version4 = {
 	.number		= RPCBVERS_4,
-	.nrprocs	= RPCB_HIGHPROC_4,
+	.nrprocs	= ARRAY_SIZE(rpcb_procedures4),
 	.procs		= rpcb_procedures4
 };
 

