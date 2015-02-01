Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f175.google.com ([209.85.212.175]:46769 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbBAODd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Feb 2015 09:03:33 -0500
Received: by mail-wi0-f175.google.com with SMTP id fb4so11662221wid.2
        for <linux-nfs@vger.kernel.org>; Sun, 01 Feb 2015 06:03:32 -0800 (PST)
Received: from [192.168.1.1] ([87.112.17.102])
        by mx.google.com with ESMTPSA id hm6sm12709595wjb.32.2015.02.01.06.03.31
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Feb 2015 06:03:31 -0800 (PST)
Message-ID: <54CE322D.50402@gmail.com>
Date: Sun, 01 Feb 2015 14:03:25 +0000
From: Chris Mayo <aklhfex@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] statd: Fix test for foreground mode
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

daemon_init parameter has the opposite sense to code removed in commit 7addf9d

Signed-off-by: Chris Mayo <aklhfex@gmail.com>
---
 utils/statd/statd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 60ce6d1..6ff28f4 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -393,7 +393,7 @@ int main (int argc, char **argv)
 		simulator (--argc, ++argv);	/* simulator() does exit() */
 #endif
 
-	daemon_init(!(run_mode & MODE_NODAEMON));
+	daemon_init(run_mode & MODE_NODAEMON);
 
 	if (run_mode & MODE_LOG_STDERR) {
 		xlog_syslog(0);
-- 
2.0.5

