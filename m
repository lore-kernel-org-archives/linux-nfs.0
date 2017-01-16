Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34213 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751122AbdAPAXt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2017 19:23:49 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so12937512pfb.1
        for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2017 16:23:49 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] SUNRPC: Make sure authorize svc when meeting SVC_CLOSE
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <090f6673-1bb3-d626-e27e-6be5afcda782@gmail.com>
Date: Mon, 16 Jan 2017 08:23:37 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 4d712ef1db05 "svcauth_gss: Close connection when
 dropping an incoming message" will close connection,
but forget authorizing the svc when meeting SVC_CLOSE.

That, there will be an module reference to sunrpc,
and some memory leak.

When mounting an nfs filesystem, the reference leak increase one.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/svc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 75f290b..63ca2ea 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1155,6 +1155,11 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 	case SVC_DENIED:
 		goto err_bad_auth;
 	case SVC_CLOSE:
+		/*
+		 * Makesure authorise svc if progp->pg_authenticate fail,
+		 * it's harmless if svc_authenticate fail.
+		 */
+		svc_authorise(rqstp);
 		goto close;
 	case SVC_DROP:
 		goto dropit;
-- 
2.9.3

