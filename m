Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35470 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbJ1UHG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2015 16:07:06 -0400
Received: by igpw7 with SMTP id w7so12458657igp.0
        for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2015 13:07:05 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by smtp.gmail.com with ESMTPSA id o74sm17112809ioo.8.2015.10.28.13.07.05
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 13:07:05 -0700 (PDT)
Subject: [PATCH] gssd: Make TCP the default protocol for GSSD connections.
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 28 Oct 2015 16:07:04 -0400
Message-ID: <20151028200612.5365.33553.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No failure case if gssd doesn't recognize the kernel's requested
protocol. Caught with "protocol=rdma" upcall.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Just spit-balling.

 utils/gssd/gssd_proc.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1d8e6a7..7569295 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -890,16 +890,9 @@ create_auth_rpc_client(struct clnt_info *clp,
 	printerr(2, "creating %s client for server %s\n", clp->protocol,
 			clp->servername);
 
-	if ((strcmp(clp->protocol, "tcp")) == 0) {
-		protocol = IPPROTO_TCP;
-	} else if ((strcmp(clp->protocol, "udp")) == 0) {
+	protocol = IPPROTO_TCP;
+	if ((strcmp(clp->protocol, "udp")) == 0)
 		protocol = IPPROTO_UDP;
-	} else {
-		printerr(0, "WARNING: unrecognized protocol, '%s', requested "
-			 "for connection to server %s for user with uid %d\n",
-			 clp->protocol, clp->servername, uid);
-		goto out_fail;
-	}
 
 	switch (addr->sa_family) {
 	case AF_INET:

