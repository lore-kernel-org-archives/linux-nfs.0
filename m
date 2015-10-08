Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35213 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753859AbbJHHv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Oct 2015 03:51:57 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v3 17/26] IB/srp: Remove srp_finish_mapping
Date: Thu,  8 Oct 2015 10:51:00 +0300
Message-Id: <1444290669-5252-18-git-send-email-sagig@mellanox.com>
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No callers left, remove it.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Bart Van Assche <bart.vanassche@sandisk.com>
---
 drivers/infiniband/ulp/srp/ib_srp.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index 6d399378928d..d4a5a9b86390 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -1368,16 +1368,6 @@ static int srp_map_finish_fr(struct srp_map_state *state,
 	return n;
 }
 
-static int srp_finish_mapping(struct srp_map_state *state,
-			      struct srp_rdma_ch *ch)
-{
-	struct srp_target_port *target = ch->target;
-	struct srp_device *dev = target->srp_host->srp_dev;
-
-	return dev->use_fast_reg ? srp_map_finish_fr(state, ch) :
-				   srp_map_finish_fmr(state, ch);
-}
-
 static int srp_map_sg_entry(struct srp_map_state *state,
 			    struct srp_rdma_ch *ch,
 			    struct scatterlist *sg, int sg_index)
-- 
1.8.4.3

