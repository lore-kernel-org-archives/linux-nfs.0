Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35923 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCou (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:50 -0400
Received: by mail-wi0-f171.google.com with SMTP id hn3so1202873wib.16
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:49 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id i11sm1314985wiw.11.2013.05.10.19.44.48
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:48 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 36/38] pnfsd: deprecate cbl_seg.clientid
Date: Sat, 11 May 2013 05:44:44 +0300
Message-Id: <1368240284-1121-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use only cbl_sid for identification

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 0ef351d..45111fe 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1247,8 +1247,8 @@ struct create_recall_list_arg {
 	stateid_t *stid = (stateid_t *)&cbl->cbl_sid;
 	struct nfs4_layout *lo;
 
-	dprintk("%s: ino=%lu clientid=%llux iomode=%u", __func__,
-		fp->fi_inode->i_ino, cbl->cbl_seg.clientid,
+	dprintk("%s: ino=%lu stateid=" STATEID_FMT " iomode=%u", __func__,
+		fp->fi_inode->i_ino, STATEID_VAL(stid),
 		cbl->cbl_seg.iomode);
 
 	list_for_each_entry (ls, &fp->fi_lo_states, ls_perfile) {
@@ -1256,11 +1256,6 @@ struct create_recall_list_arg {
 		    !same_stid(stid, &ls->ls_stid.sc_stateid))
 			continue;
 
-		if (cbl->cbl_seg.clientid &&
-		    !same_clid(&ls->ls_client->cl_clientid,
-			       (clientid_t *)&cbl->cbl_seg.clientid))
-			continue;
-
 		list_for_each_entry (lo, &ls->ls_layouts, lo_perstate)
 			if (cbl->cbl_seg.layout_type == lo->lo_seg.layout_type &&
 			    lo_seg_overlapping(&cbl->cbl_seg, &lo->lo_seg) &&
-- 
1.7.11.7

