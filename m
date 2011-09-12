Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42347 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab1ILWIl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:08:41 -0400
Received: by gwb15 with SMTP id 15so443236gwb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:08:41 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] sm-notify: Use correct retransmit timeout when sending a
	fresh RPC
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:50 -0400
Message-ID: <20110912220650.10854.66385.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

An RPC retransmit timeout should start out the same for each new RPC
request.  Don't increase the retransmit timeout after receiving the
reply to the rpcbind query.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 46447e8..aa202d3 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -701,8 +701,7 @@ smn_schedule(struct nsm_host *host)
 {
 	host->xid = 0;
 	host->send_next = time(NULL);
-	if (host->timeout >= NSM_MAX_TIMEOUT / 4)
-		host->timeout = NSM_MAX_TIMEOUT / 4;
+	host->timeout = NSM_TIMEOUT;
 	insert_host(host);
 }
 

