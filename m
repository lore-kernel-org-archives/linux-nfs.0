Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:53477 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754578AbeCGU6k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 15:58:40 -0500
Received: by mail-it0-f68.google.com with SMTP id w63so4941820ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 07 Mar 2018 12:58:40 -0800 (PST)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id j130sm9248090ita.33.2018.03.07.12.58.38
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 12:58:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Fix an incorrect type in struct nfs_direct_req
Date: Wed,  7 Mar 2018 15:58:16 -0500
Message-Id: <20180307205817.5913-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The start offset needs to be of type loff_t.

Fixed: 5fadeb47dcc5c ("nfs: count DIO good bytes correctly with mirroring")
Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 8c10b0562e75..621c517b325c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -86,10 +86,10 @@ struct nfs_direct_req {
 	struct nfs_direct_mirror mirrors[NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX];
 	int			mirror_count;
 
+	loff_t			io_start;	/* Start offset for I/O */
 	ssize_t			count,		/* bytes actually processed */
 				max_count,	/* max expected count */
 				bytes_left,	/* bytes left to be sent */
-				io_start,	/* start of IO */
 				error;		/* any reported error */
 	struct completion	completion;	/* wait for i/o completion */
 
-- 
2.14.3

