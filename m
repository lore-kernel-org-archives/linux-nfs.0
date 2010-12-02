Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35717 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757743Ab0LBOkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 09:40:11 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: decorate truncated signatures with "..."
Date: Thu,  2 Dec 2010 16:40:08 +0200
Message-Id: <1291300808-14568-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CF7A8F9.8010902@panasas.com>
References: <4CF7A8F9.8010902@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/blkmapd/device-process.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 0584bf9..ea8b8ec 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -64,10 +64,12 @@ static char *pretty_sig(char *sig, uint32_t siglen)
 		}
 		sprintf(rs, "0x%0llx", sigval);
 	} else {
-		if (siglen > sizeof rs - 1)
-			siglen = sizeof rs - 1;
+		if (siglen > sizeof rs - 4) {
+			siglen = sizeof rs - 4;
+			sprintf(&rs[siglen], "...");
+		} else
+			rs[siglen] = '\0';
 		memcpy(rs, sig, siglen);
-		rs[siglen] = '\0';
 	}
 	return rs;
 }
-- 
1.7.2.3

