Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50936 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754091AbbGXQSV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 12:18:21 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to
	device fastreg max depth
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Fri, 24 Jul 2015 11:18:21 -0500
Message-ID: <20150724161820.25617.63886.stgit@build2.ogc.int>
In-Reply-To: <20150724161331.25617.8475.stgit@build2.ogc.int>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the sg tablesize, which dictates fast register page list
depth to use, does not take into account the limits of the rdma device.
So adjust it once we discover the device fastreg max depth limit.  Also
adjust the max_sectors based on the resulting sg tablesize.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/ulp/iser/iscsi_iser.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/ulp/iser/iscsi_iser.c b/drivers/infiniband/ulp/iser/iscsi_iser.c
index 6a594aa..de8730d 100644
--- a/drivers/infiniband/ulp/iser/iscsi_iser.c
+++ b/drivers/infiniband/ulp/iser/iscsi_iser.c
@@ -640,6 +640,15 @@ iscsi_iser_session_create(struct iscsi_endpoint *ep,
 						   SHOST_DIX_GUARD_CRC);
 		}
 
+		/*
+		 * Limit the sg_tablesize and max_sectors based on the device
+		 * max fastreg page list length.
+		 */
+		shost->sg_tablesize = min_t(unsigned short, shost->sg_tablesize,
+			ib_conn->device->dev_attr.max_fast_reg_page_list_len);
+		shost->max_sectors = min_t(unsigned int,
+			1024, (shost->sg_tablesize * PAGE_SIZE) >> 9);
+
 		if (iscsi_host_add(shost,
 				   ib_conn->device->ib_device->dma_device)) {
 			mutex_unlock(&iser_conn->state_mutex);

