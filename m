Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.nrchpc.ac.cn ([211.103.180.228]:43887 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750793AbaBQHJt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Feb 2014 02:09:49 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH v3] NFSv4.1: new layout stateid can not be overwrite by one out of date
Date: Mon, 17 Feb 2014 15:08:01 +0800
Message-Id: <1392620881-26561-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <N>
References: <N>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If initiate_file_draining returned NFS4ERR_DELAY, all the lsegs of
a file might be released before the retrying cb_layout request arriving
at the client. In this situation,the list lo->plh_segs is empty, 
layoutget request of the file will use open stateid to obtain a new 
layout stateid. And if the retrying cb_layout request arrived at the 
client after the layoutget reply, new layout stateid would be overwrite 
by one out of date.

Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
---
 fs/nfs/callback_proc.c |    9 +++++++--
 fs/nfs/pnfs.c          |    3 ++-
 fs/nfs/pnfs.h          |    1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ae2e87b..5b20ace 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -170,10 +170,15 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
-					&args->cbl_range))
+					&args->cbl_range)) {
+		if (!test_and_set_bit(NFS_LAYOUT_BC_DELAY, &lo->plh_flags))
+			pnfs_get_layout_hdr(lo);
 		rv = NFS4ERR_DELAY;
-	else
+	} else {
+		if (test_and_clear_bit(NFS_LAYOUT_BC_DELAY, &lo->plh_flags))
+			pnfs_put_layout_hdr(lo);
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
+	}
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cb34024..998bc82 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -721,7 +721,8 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 		status = -EAGAIN;
 	} else if (!nfs4_valid_open_stateid(open_state)) {
 		status = -EBADF;
-	} else if (list_empty(&lo->plh_segs)) {
+	} else if (list_empty(&lo->plh_segs) &&
+			!test_bit(NFS_LAYOUT_BC_DELAY, &lo->plh_flags)) {
 		int seq;
 
 		do {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a4f4181..fb9b37e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -63,6 +63,7 @@ enum {
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
+	NFS_LAYOUT_BC_DELAY,	/*cb_layout are delayed*/
 };
 
 enum layoutdriver_policy_flags {
-- 
1.7.4.2

