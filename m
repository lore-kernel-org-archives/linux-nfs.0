Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41375 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbAVLLM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 06:11:12 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 01/20] nfs: add LAYOUT_TYPE_MAX enum value
Date: Thu, 22 Jan 2015 12:09:47 +0100
Message-Id: <1421925006-24231-2-git-send-email-hch@lst.de>
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This gives us a nice upper bound for later use in nfѕd.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/nfs4.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 022b761..8a3589c 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -516,6 +516,7 @@ enum pnfs_layouttype {
 	LAYOUT_NFSV4_1_FILES  = 1,
 	LAYOUT_OSD2_OBJECTS = 2,
 	LAYOUT_BLOCK_VOLUME = 3,
+	LAYOUT_TYPE_MAX
 };
 
 /* used for both layout return and recall */
-- 
1.9.1

