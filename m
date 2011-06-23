Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:36821 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758449Ab1FWC0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 22:26:00 -0400
Received: by gwaa18 with SMTP id a18so561504gwa.19
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jun 2011 19:25:59 -0700 (PDT)
From: Tom Haynes <loghyr@gmail.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: [PATCH 2/2] Make the stat command handle leading blank spaces
Date: Wed, 22 Jun 2011 21:26:07 -0500
Message-Id: <1308795967-7605-3-git-send-email-tdh@excfb.com>
In-Reply-To: <1308795967-7605-1-git-send-email-tdh@excfb.com>
References: <1308795967-7605-1-git-send-email-tdh@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Signed-off-by: Tom Haynes <tdh@excfb.com>
---
 general/stat.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/general/stat.c b/general/stat.c
index 2ce604e..b9128ae 100644
--- a/general/stat.c
+++ b/general/stat.c
@@ -52,7 +52,9 @@ getnewch:
 		exit(1);
 	}
 	c = i & 0x7f;
-	if (c == '\n' || c == '\r' || c == 'r')
+	if (c == ' ' || c == '\t')
+		goto getnewch;
+	else if (c == '\n' || c == '\r' || c == 'r')
 		attfmt = 1;
 	else if (isdigit(c))
 		fmt = "%lf %*s %lf %*s %lf %*s";	/* BSD fmt */
-- 
1.7.3.4

