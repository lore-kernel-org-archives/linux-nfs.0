Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:45938 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab0KBUKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Nov 2010 16:10:13 -0400
Date: Tue, 2 Nov 2010 16:10:00 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 3/6] blkmapd: don't use atomicio() where it's not needed
Message-ID: <d90e2ddc2e722542453e4ffb1179caf4d6f209d2.1288726186.git.rees@umich.edu>
References: <cover.1288726186.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1288726186.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/blkmapd/device-process.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 9e91840..c4e72ea 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -121,7 +121,7 @@ read_cmp_blk_sig(const char *dev_name, struct bl_sig_comp *comp,
 		goto error;
 	}
 
-	if (atomicio(read, fd, sig, comp->bs_length) != comp->bs_length) {
+	if (read(fd, sig, comp->bs_length) != comp->bs_length) {
 		BL_LOG_ERR("File %s read error\n", dev_name);
 		goto error;
 	}
-- 
1.7.1

