Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f173.google.com ([74.125.82.173]:62130 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCog (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:36 -0400
Received: by mail-we0-f173.google.com with SMTP id q54so4517020wes.32
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:34 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id i11sm1314215wiw.11.2013.05.10.19.44.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:34 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 32/38] pnfsd: cosmetic fixes
Date: Sat, 11 May 2013 05:44:30 +0300
Message-Id: <1368240270-968-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 fs/nfsd/nfs4pnfsd.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 27f717f..7a5ba09 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1268,8 +1268,10 @@ struct create_recall_list_arg {
 	return ret;
 }
 
-/* Create a layoutrecall structure for each client based on the
- * original structure. */
+/*
+ * Create a layoutrecall structure for each client based on the
+ * original structure.
+ */
 int
 create_layout_recall_list(struct list_head *todolist, unsigned *todo_len,
 			  struct nfsd4_pnfs_cb_layout *cbl,
@@ -1348,7 +1350,7 @@ struct create_recall_list_arg {
 				put_layoutrecall(pending);
 			}
 			--todo_len;
-				status = -ENOMEM;
+			status = -ENOMEM;
 		}
 	}
 
-- 
1.7.11.7

