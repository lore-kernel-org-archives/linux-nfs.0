Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55200 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559AbbAFQ3b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:31 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 01/18] nfs: add LAYOUT_TYPE_MAX enum value
Date: Tue,  6 Jan 2015 17:28:24 +0100
Message-Id: <1420561721-9150-2-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
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

