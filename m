Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41599 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758449Ab1FWCZ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 22:25:57 -0400
Received: by gyh3 with SMTP id 3so562081gyh.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 19:25:56 -0700 (PDT)
From: Tom Haynes <loghyr@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: [PATCH 1/2] Multiple clnt_broadcast, rename static reference
Date: Wed, 22 Jun 2011 21:26:06 -0500
Message-Id: <1308795967-7605-2-git-send-email-tdh@excfb.com>
In-Reply-To: <1308795967-7605-1-git-send-email-tdh@excfb.com>
References: <1308795967-7605-1-git-send-email-tdh@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Signed-off-by: Tom Haynes <tdh@excfb.com>
---
 tools/pmapbrd.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/pmapbrd.c b/tools/pmapbrd.c
index c447ced..2bb05b6 100644
--- a/tools/pmapbrd.c
+++ b/tools/pmapbrd.c
@@ -98,7 +98,7 @@ static bool_t xdr_rmtcallres ARGS_((XDR *, struct rmtcallres *));
 #define RPROC_NUM (u_long)1
 #endif
 
-static enum clnt_stat clnt_broadcast ARGS_((int, unsigned long, unsigned long,
+static enum clnt_stat clnt_broadcast_time ARGS_((int, unsigned long, unsigned long,
 		unsigned long, xdrproc_t, void *, xdrproc_t, void *,
 		resultproc_t, struct timeval *));
 
@@ -174,7 +174,7 @@ main(argc, argv)
 		 * XXX shouldn't have to cast eachresult?
 		 */
 		clnt_stat =
-		    clnt_broadcast(sock, RPROG, RVERS, RPROC_NUM, xdr_void, &a,
+		    clnt_broadcast_time(sock, RPROG, RVERS, RPROC_NUM, xdr_void, &a,
 		    xdr_void, &b, (resultproc_t)eachresult, &t);
 		if(clnt_stat != RPC_TIMEDOUT) {
 			printf("error: clnt_stat = %d\n", clnt_stat);
@@ -305,7 +305,8 @@ getbroadcastnets(sock, buf)
 }
 
 static enum clnt_stat 
-clnt_broadcast(sock, prog, vers, proc, xargs, argsp, xresults, resultsp, eachresult, t)
+clnt_broadcast_time(sock, prog, vers, proc, xargs, argsp, xresults,
+			resultsp, eachresult, t)
 	int		sock;
 #ifdef SVR3
 	ulong		prog;		/* program number */
-- 
1.7.3.4

