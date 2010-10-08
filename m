Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60721 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757323Ab0JHQIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 12:08:35 -0400
Date: Fri, 8 Oct 2010 12:08:28 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, sfaibish <sfaibish@emc.com>,
        peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 3/4] blkmapd: don't use atomicio() where it's not needed
Message-ID: <01cee892445eb88bebec5655a8055de0c22857e8.1286552019.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1286552019.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
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
1.7.0.4

