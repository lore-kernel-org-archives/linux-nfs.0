From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 6/6] nfsd: get rid of NFSD_VERSION
Date: Mon, 15 Dec 2008 19:42:24 +0200
Message-ID: <1229362944-9885-1-git-send-email-bhalevy@panasas.com>
References: <49469601.7020101@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53681 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583AbYLORmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:42:43 -0500
In-Reply-To: <49469601.7020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/nfsd.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2126940..e19f459 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -23,7 +23,6 @@
 /*
  * nfsd version
  */
-#define NFSD_VERSION		"0.5"
 #define NFSD_SUPPORTED_MINOR_VERSION	0
 
 /*
-- 
1.6.0.2

