From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/8] NFS: Fix a reference leak in nfs_wb_cancel_page()
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.92404.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8838 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029Ab0AYWEI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:08 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM47KE014154
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:07 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---

 fs/nfs/write.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..dac8d76 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1541,6 +1541,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 			break;
 		}
 		ret = nfs_wait_on_request(req);
+		nfs_release_request(req);
 		if (ret < 0)
 			goto out;
 	}

