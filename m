Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34731 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbcADSVy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:54 -0500
Received: by mail-io0-f172.google.com with SMTP id 1so116647506ion.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:54 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 12/18] NFSv4.1/pNFS: Use nfs4_stateid_copy for copying stateids
Date: Mon,  4 Jan 2016 13:21:10 -0500
Message-Id: <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7a452895169f..7e0f2b9a9b10 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -385,7 +385,7 @@ static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
 		enum pnfs_iomode iomode;
 		bool send;
 
-		stateid = lo->plh_stateid;
+		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
 		iomode = lo->plh_return_iomode;
 		send = pnfs_prepare_layoutreturn(lo);
 		spin_unlock(&inode->i_lock);
@@ -1007,7 +1007,7 @@ _pnfs_return_layout(struct inode *ino)
 		dprintk("NFS: %s no layout to return\n", __func__);
 		goto out;
 	}
-	stateid = nfsi->layout->plh_stateid;
+	nfs4_stateid_copy(&stateid, &nfsi->layout->plh_stateid);
 	/* Reference matched in nfs4_layoutreturn_release */
 	pnfs_get_layout_hdr(lo);
 	empty = list_empty(&lo->plh_segs);
@@ -1098,7 +1098,7 @@ bool pnfs_roc(struct inode *ino)
 			goto out_noroc;
 	}
 
-	stateid = lo->plh_stateid;
+	nfs4_stateid_copy(&stateid, &lo->plh_stateid);
 	/* always send layoutreturn if being marked so */
 	if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 				   &lo->plh_flags))
-- 
2.5.0

