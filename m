Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52729 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754000AbbG3Hda (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:30 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 07/15] RDS: Convert to ib_alloc_mr
Date: Thu, 30 Jul 2015 10:32:40 +0300
Message-Id: <1438241568-3685-8-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/rds/iw_rdma.c | 5 +++--
 net/rds/iw_send.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index dba8d08..6a8fbd6 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -667,11 +667,12 @@ static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool,
 	struct ib_mr *mr;
 	int err;
 
-	mr = ib_alloc_fast_reg_mr(rds_iwdev->pd, pool->max_message_size);
+	mr = ib_alloc_mr(rds_iwdev->pd, IB_MR_TYPE_MEM_REG,
+			 pool->max_message_size);
 	if (IS_ERR(mr)) {
 		err = PTR_ERR(mr);
 
-		printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_mr failed (err=%d)\n", err);
+		printk(KERN_WARNING "RDS/IW: ib_alloc_mr failed (err=%d)\n", err);
 		return err;
 	}
 
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 334fe98..86152ec 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -153,9 +153,10 @@ void rds_iw_send_init_ring(struct rds_iw_connection *ic)
 		sge->length = sizeof(struct rds_header);
 		sge->lkey = 0;
 
-		send->s_mr = ib_alloc_fast_reg_mr(ic->i_pd, fastreg_message_size);
+		send->s_mr = ib_alloc_mr(ic->i_pd, IB_MR_TYPE_MEM_REG,
+					 fastreg_message_size);
 		if (IS_ERR(send->s_mr)) {
-			printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_mr failed\n");
+			printk(KERN_WARNING "RDS/IW: ib_alloc_mr failed\n");
 			break;
 		}
 
-- 
1.8.4.3

