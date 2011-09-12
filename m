Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50083 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983Ab1ILWHB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:07:01 -0400
Received: by yxm8 with SMTP id 8so570132yxm.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:07:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] sm-notify: Avoid extra rpcbind queries
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:58 -0400
Message-ID: <20110912220658.10854.32782.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The logic in notify_host() watches the host->retries counter to see if
progress is not being made.  If progress stalls, notify_host() tries
another IP address.  This means sm-notify will generate a fresh
rpcbind query.

After an RPC succeeds, be sure to reset host->retries so sm-notify
doesn't start walking down the host's addrinfo list when we _are_
making progress.  In the common case, if the host responds, we avoid
extra rpcbind queries and send all requests for the host to the same
IP address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index aa202d3..690ec2a 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -699,6 +699,7 @@ smn_defer(struct nsm_host *host)
 static void
 smn_schedule(struct nsm_host *host)
 {
+	host->retries = 0;
 	host->xid = 0;
 	host->send_next = time(NULL);
 	host->timeout = NSM_TIMEOUT;

