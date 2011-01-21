Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:51919 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486Ab1AUQx2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jan 2011 11:53:28 -0500
Date: Fri, 21 Jan 2011 11:53:21 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 1/3] change device offset to signed to match the spec
Message-ID: <9b6eda16d795d78680a409db58713ee683c30f49.1295627825.git.rees@umich.edu>
References: <cover.1295627825.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1295627825.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-discovery.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
index 8fe3b29..a55ccfe 100644
--- a/utils/blkmapd/device-discovery.h
+++ b/utils/blkmapd/device-discovery.h
@@ -51,7 +51,7 @@ struct bl_volume {
 };
 
 struct bl_sig_comp {
-	uint64_t bs_offset;		/* In bytes */
+	int64_t bs_offset;		/* In bytes */
 	uint32_t bs_length;		/* In bytes */
 	char *bs_string;
 };
-- 
1.7.1

