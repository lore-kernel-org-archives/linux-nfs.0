Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:54641 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab0KSQgM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 11:36:12 -0500
Received: by gwb20 with SMTP id 20so59737gwb.19
        for <linux-nfs@vger.kernel.org>; Fri, 19 Nov 2010 08:36:12 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: fix synopsis of rpcproc_encode_null()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 19 Nov 2010 11:36:08 -0500
Message-ID: <20101119163415.2262.76340.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Missed one instance of an encoder returning int instead of void.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi -

Build-tested only.  This can be squashed into [PATCH 11/12].


 net/sunrpc/clnt.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 85f93c9..78c18fe 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1770,9 +1770,8 @@ out_overflow:
 	goto out_garbage;
 }
 
-static int rpcproc_encode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
+static void rpcproc_encode_null(void *rqstp, struct xdr_stream *xdr, void *obj)
 {
-	return 0;
 }
 
 static int rpcproc_decode_null(void *rqstp, struct xdr_stream *xdr, void *obj)

