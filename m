Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3C85C64ED6
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Feb 2023 15:07:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233938AbjBCPH4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Feb 2023 10:07:56 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47932 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233871AbjBCPHn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2023 10:07:43 -0500
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 96D70A42A8;
        Fri,  3 Feb 2023 07:07:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
        MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
        :Reply-To:Content-Type:Content-ID:Content-Description;
        bh=hAZBDljuWATtT7MZb8+aicFX05OEHsXWwcxbzwocn/Y=; b=BeevEGfHXEz3RQ2pm30ri/lLot
        7BknWxcTJCe8bHwiFgaBXD6npSlvAv3IEIcsbkShJ3RfjiaydSSo5L6SFdm8AJ7WoHjFa/htGhWkp
        4wGSwgvGKmly4xNp6v5luVv0iyrkXZnWP2/pz7K3wCYJcXHk5hRM2nDzle/Au3h9vm087+yLkb6az
        7ehquK3STiJQhULDlHMJ2qG5Ug/GxsArwlHmPwoqzm3C5tnanQyZve2lPxuQhUSgjWjv2GmcjIlnY
        Visqz9lIqxv7q/UIrUmyPC1LhCL2btyMsdEUNkOGFE9y6nnV9zO5myX06OAAMNCoqqAdLUEkSnYKd
        aGyQrdEg==;
Received: from [2001:4bb8:19a:272a:910:bb67:7287:f956] (helo=localhost)
        by bombadil.infradead.org with esmtpsa (Exim 4.94.2 #2 (Red Hat Linux))
        id 1pNxeV-002am6-95; Fri, 03 Feb 2023 15:06:59 +0000
From:   Christoph Hellwig <hch@lst.de>
To:     Jens Axboe <axboe@kernel.dk>
Cc:     Ilya Dryomov <idryomov@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Minchan Kim <minchan@kernel.org>,
        Sergey Senozhatsky <senozhatsky@chromium.org>,
        Keith Busch <kbusch@kernel.org>,
        Sagi Grimberg <sagi@grimberg.me>,
        Chaitanya Kulkarni <kch@nvidia.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        David Howells <dhowells@redhat.com>,
        Marc Dionne <marc.dionne@auristor.com>,
        Xiubo Li <xiubli@redhat.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>,
        Mike Marshall <hubcap@omnibond.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-block@vger.kernel.org, ceph-devel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, kvm@vger.kernel.org,
        netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        devel@lists.orangefs.org, io-uring@vger.kernel.org,
        linux-mm@kvack.org, Johannes Thumshirn <johannes.thumshirn@wdc.com>
Subject: [PATCH 07/23] nvme: use bvec_set_virt to initialize special_vec
Date:   Fri,  3 Feb 2023 16:06:18 +0100
Message-Id: <20230203150634.3199647-8-hch@lst.de>
X-Mailer: git-send-email 2.39.0
In-Reply-To: <20230203150634.3199647-1-hch@lst.de>
References: <20230203150634.3199647-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Use the bvec_set_virt helper to initialize the special_vec.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Chaitanya Kulkarni <kch@nvidia.com>
Reviewed-by: Johannes Thumshirn <johannes.thumshirn@wdc.com>
---
 drivers/nvme/host/core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/nvme/host/core.c b/drivers/nvme/host/core.c
index 505e16f20e57fa..7ba1accc3c22a4 100644
--- a/drivers/nvme/host/core.c
+++ b/drivers/nvme/host/core.c
@@ -806,9 +806,7 @@ static blk_status_t nvme_setup_discard(struct nvme_ns *ns, struct request *req,
 	cmnd->dsm.nr = cpu_to_le32(segments - 1);
 	cmnd->dsm.attributes = cpu_to_le32(NVME_DSMGMT_AD);
 
-	req->special_vec.bv_page = virt_to_page(range);
-	req->special_vec.bv_offset = offset_in_page(range);
-	req->special_vec.bv_len = alloc_size;
+	bvec_set_virt(&req->special_vec, range, alloc_size);
 	req->rq_flags |= RQF_SPECIAL_PAYLOAD;
 
 	return BLK_STS_OK;
-- 
2.39.0

