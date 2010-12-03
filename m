Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:35480 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721Ab0LCUlG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 15:41:06 -0500
Date: Fri, 3 Dec 2010 15:41:03 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 2/2] silence compiler warnings
Message-ID: <20101203204103.GA9834@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 0d8705f..91b0afc 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -53,14 +53,13 @@ static char *pretty_sig(char *sig, uint32_t siglen)
 {
 	static char rs[100];
 	uint64_t sigval;
+	unsigned int i;
 
 	if (siglen <= sizeof(sigval)) {
-		int i;
-
 		sigval = 0;
 		for (i = 0; i < siglen; i++)
 			sigval |= ((unsigned char *)sig)[i] << (i * 8);
-		sprintf(rs, "0x%0llx", sigval);
+		sprintf(rs, "0x%0llx", (unsigned long long) sigval);
 	} else {
 		if (siglen > sizeof rs - 4) {
 			siglen = sizeof rs - 4;
-- 
1.7.1

