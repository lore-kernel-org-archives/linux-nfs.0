Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34607 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1LEINo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 03:13:44 -0500
Received: by mail-bw0-f46.google.com with SMTP id zv3so1472947bkb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Dec 2011 00:13:44 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] ctl: always return a value from find_dm_name
Date: Mon,  5 Dec 2011 10:13:39 +0200
Message-Id: <1323072819-18243-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDC7C4E.1040901@tonian.com>
References: <4EDC7C4E.1040901@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 ctl.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/ctl.c b/ctl.c
index 959ef6a..7432a09 100644
--- a/ctl.c
+++ b/ctl.c
@@ -494,7 +494,7 @@ find_dm_name(int major, int minor)
 	if (((fd = get_output("/sbin/dmsetup", argv)) == -1) ||
 	    ((fp = fdopen(fd, "r")) == NULL)) {
 		printf("%s: get_output/fdopen failed\n", __func__);
-		return;
+		return NULL;
 	}
 	while (fgets(buf, sizeof (buf), fp) != NULL) {
 		t = __token_init(buf, '\t');
@@ -545,6 +545,7 @@ error:
 	
 	fclose(fp);
 	(void) wait(&status);
+	return NULL;
 }
 
 static int
-- 
1.7.6

