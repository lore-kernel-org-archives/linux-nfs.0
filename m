Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33617 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966506AbeF1OeY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jun 2018 10:34:24 -0400
Received: by mail-it0-f68.google.com with SMTP id k17-v6so21686674ita.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jun 2018 07:34:24 -0700 (PDT)
Subject: [PATCH v2] Handle GARBAGE_ARGS response in rpcbind query
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
Date: Thu, 28 Jun 2018 10:34:22 -0400
Message-ID: <20180628143422.14145.77695.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a report that some commercial NFS file servers still do not
support rpcbind v4 correctly. They return GARBAGE_ARGS instead of
PROG_MISMATCH or PROG_UNAVAIL, so our rpcbind client now errors out
immediately instead of trying a lower rpcbind version.

To address this, convert the "if () else if () else if ()" to a
switch statement to make it straightforward to add new status codes
to the error processing logic. Then, add a case for
RPC_CANTDECODEARGS (the API status code used when the remote
responds with GARBAGE_ARGS).

Reported-by: Yuan-Yao Sung <yysung@cs.nctu.edu.tw>
Fixes: 5e7b57bc20bd ("rpcinfo: change order of version to be ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Yuan-Yao Sung <yysung@cs.nctu.edu.tw>
---
 src/rpcb_clnt.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
index 4b44364..d6fefd0 100644
--- a/src/rpcb_clnt.c
+++ b/src/rpcb_clnt.c
@@ -846,6 +846,7 @@ __rpcb_findaddr_timed(program, version, nconf, host, clpp, tp)
 	struct netbuf *address = NULL;
 	rpcvers_t start_vers = RPCBVERS4;
 	struct netbuf servaddr;
+	struct rpc_err rpcerr;
 
 	/* parameter checking */
 	if (nconf == NULL) {
@@ -902,7 +903,8 @@ __rpcb_findaddr_timed(program, version, nconf, host, clpp, tp)
 		clnt_st = CLNT_CALL(client, (rpcproc_t)RPCBPROC_GETADDR,
 		    (xdrproc_t) xdr_rpcb, (char *)(void *)&parms,
 		    (xdrproc_t) xdr_wrapstring, (char *)(void *) &ua, *tp);
-		if (clnt_st == RPC_SUCCESS) {
+		switch (clnt_st) {
+		case RPC_SUCCESS:
 			if ((ua == NULL) || (ua[0] == 0)) {
 				/* address unknown */
 				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
@@ -924,12 +926,15 @@ __rpcb_findaddr_timed(program, version, nconf, host, clpp, tp)
 			    (char *)(void *)&servaddr);
 			__rpc_fixup_addr(address, &servaddr);
 			goto done;
-		} else if (clnt_st == RPC_PROGVERSMISMATCH) {
-			struct rpc_err rpcerr;
+		case RPC_PROGVERSMISMATCH:
 			clnt_geterr(client, &rpcerr);
 			if (rpcerr.re_vers.low > RPCBVERS4)
 				goto error;  /* a new version, can't handle */
-		} else if (clnt_st != RPC_PROGUNAVAIL) {
+			/* Try the next lower version */
+		case RPC_PROGUNAVAIL:
+		case RPC_CANTDECODEARGS:
+			break;
+		default:
 			/* Cant handle this error */
 			rpc_createerr.cf_stat = clnt_st;
 			clnt_geterr(client, &rpc_createerr.cf_error);

