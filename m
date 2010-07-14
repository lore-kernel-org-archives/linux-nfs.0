From: andros@netapp.com
Subject: [PATCH 1/1] SQUASHME pnfs-submit zero layout stateid on last layout segment removal
Date: Wed, 14 Jul 2010 13:05:08 -0400
Message-ID: <1279127108-2553-2-git-send-email-andros@netapp.com>
References: <1279127108-2553-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754090Ab0GNRFP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 13:05:15 -0400
In-Reply-To: <1279127108-2553-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Section 12.5.3 RFC 5661

"Once a client has no more layouts on a file, the layout stateid is no longer
valid and MUST NOT be used. Any attempt to use such a layout stateid will
result in NFS4ERR_BAD_STATEID."

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8b26104..3018ed6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -625,6 +625,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->lo_layouts);
 		spin_unlock(&clp->cl_lock);
+		pnfs_set_layout_stateid(lo, &zero_stateid);
 	}
 
 	dprintk("%s:Return\n", __func__);
-- 
1.6.6

