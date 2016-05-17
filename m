Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:35654 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827AbcEQQ3C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 12:29:02 -0400
Received: by mail-qg0-f65.google.com with SMTP id b14so1829350qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 09:29:01 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Subject: [PATCH v4 06/13] pnfs: keep track of the return sequence number in pnfs_layout_hdr
Date: Tue, 17 May 2016 12:28:41 -0400
Message-Id: <1463502528-11519-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we want to selectively do a LAYOUTRETURN, we need to specify a
stateid that represents most recent layout acquisition that is to be
returned.

When we mark a layout stateid to be returned, we update the return
sequence number in the layout header with that value, if it's newer
than the existing one. Then, when we go to do a LAYOUTRETURN on
layout header put, we overwrite the seqid in the stateid with the
saved one, and then zero it out.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/pnfs.c | 11 ++++++++---
 fs/nfs/pnfs.h |  1 +
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 18b6f950e300..39432a3705b4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -899,6 +899,7 @@ pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
 	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
 		return false;
 	lo->plh_return_iomode = 0;
+	lo->plh_return_seq = 0;
 	pnfs_get_layout_hdr(lo);
 	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
 	return true;
@@ -969,6 +970,7 @@ static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
 		bool send;
 
 		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
+		stateid.seqid = cpu_to_be32(lo->plh_return_seq);
 		iomode = lo->plh_return_iomode;
 		send = pnfs_prepare_layoutreturn(lo);
 		spin_unlock(&inode->i_lock);
@@ -1747,7 +1749,8 @@ out_forget_reply:
 }
 
 static void
-pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
+pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
+			 u32 seq)
 {
 	if (lo->plh_return_iomode == iomode)
 		return;
@@ -1755,6 +1758,8 @@ pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
 		iomode = IOMODE_ANY;
 	lo->plh_return_iomode = iomode;
 	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+	if (!lo->plh_return_seq || pnfs_seqid_is_newer(seq, lo->plh_return_seq))
+		lo->plh_return_seq = seq;
 }
 
 /**
@@ -1793,7 +1798,7 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				continue;
 			remaining++;
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
-			pnfs_set_plh_return_iomode(lo, return_range->iomode);
+			pnfs_set_plh_return_info(lo, return_range->iomode, lseg->pls_seq);
 		}
 	return remaining;
 }
@@ -1811,7 +1816,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	bool return_now = false;
 
 	spin_lock(&inode->i_lock);
-	pnfs_set_plh_return_iomode(lo, range.iomode);
+	pnfs_set_plh_return_info(lo, range.iomode, lseg->pls_seq);
 	/*
 	 * mark all matching lsegs so that we are sure to have no live
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 361fa5494aa5..3476c9850678 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -195,6 +195,7 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_flags;
 	nfs4_stateid		plh_stateid;
 	u32			plh_barrier; /* ignore lower seqids */
+	u32			plh_return_seq;
 	enum pnfs_iomode	plh_return_iomode;
 	loff_t			plh_lwb; /* last write byte for layoutcommit */
 	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
-- 
2.5.5

