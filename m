Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35580 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080Ab0LBOfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 09:35:46 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: blkmapd: fix pretty_sig short sig endianess agnosticity
Date: Thu,  2 Dec 2010 16:35:42 +0200
Message-Id: <1291300542-14378-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CF7A64D.8040802@panasas.com>
References: <4CF7A64D.8040802@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

How about this?

Benny

 utils/blkmapd/device-process.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 0c5060b..0584bf9 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -52,11 +52,17 @@
 static char *pretty_sig(char *sig, uint32_t siglen)
 {
 	static char rs[100];
-	unsigned long i = 0;
+	uint64_t sigval;
 
-	if (siglen <= sizeof i) {
-		memcpy(&i, sig, siglen);
-		sprintf(rs, "0x%0lx", i);
+	if (siglen <= sizeof(sigval)) {
+		int i;
+
+		sigval = 0;
+		for (i = 0; i < siglen; i++) {
+			sigval <<= 8;
+			sigval += ((unsigned char *)sig)[i];
+		}
+		sprintf(rs, "0x%0llx", sigval);
 	} else {
 		if (siglen > sizeof rs - 1)
 			siglen = sizeof rs - 1;
-- 
1.7.2.3

