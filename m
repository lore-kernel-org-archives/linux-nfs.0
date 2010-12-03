Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:35301 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962Ab0LCUk1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 15:40:27 -0500
Date: Fri, 3 Dec 2010 15:40:24 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 1/2] pretty_sig: little-endian
Message-ID: <20101203204024.GA9814@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index ea8b8ec..0d8705f 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -58,10 +58,8 @@ static char *pretty_sig(char *sig, uint32_t siglen)
 		int i;
 
 		sigval = 0;
-		for (i = 0; i < siglen; i++) {
-			sigval <<= 8;
-			sigval += ((unsigned char *)sig)[i];
-		}
+		for (i = 0; i < siglen; i++)
+			sigval |= ((unsigned char *)sig)[i] << (i * 8);
 		sprintf(rs, "0x%0llx", sigval);
 	} else {
 		if (siglen > sizeof rs - 4) {
-- 
1.7.1

