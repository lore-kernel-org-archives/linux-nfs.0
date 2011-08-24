Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42819 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab1HXPd4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 11:33:56 -0400
Received: by mail-ew0-f46.google.com with SMTP id 4so527255ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Aug 2011 08:33:56 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] statd: Report count of loaded hosts correctly
To: linux-nfs@vger.kernel.org
Date: Wed, 24 Aug 2011 11:33:53 -0400
Message-ID: <20110824153353.3138.98630.stgit@matisse.1015granger.net>
In-Reply-To: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
References: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fix a debugging message to report correctly the count of hosts loaded
when statd starts up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/monitor.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 325dfd3..286a5e2 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -249,7 +249,7 @@ void load_state(void)
 
 	count = nsm_load_monitor_list(load_one_host);
 	if (count)
-		xlog(D_GENERAL, "Loaded %u previously monitored hosts");
+		xlog(D_GENERAL, "Loaded %u previously monitored hosts", count);
 }
 
 /*

