Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f47.google.com ([74.125.83.47]:43732 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab3JFHol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Oct 2013 03:44:41 -0400
Received: by mail-ee0-f47.google.com with SMTP id d49so2551140eek.6
        for <linux-nfs@vger.kernel.org>; Sun, 06 Oct 2013 00:44:40 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] SQUASHME: pnfsd: fixup error code for layout_commit
Date: Sun,  6 Oct 2013 10:44:36 +0300
Message-Id: <1381045476-30766-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <5251140B.4000203@primarydata.com>
References: <5251140B.4000203@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index a117a5d..e37a169 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -949,8 +949,12 @@ struct super_block *
 	nfserr = nfs4_process_layout_stateid(clp, &lcp->lc_sid,
 					     NFS4_LAYOUT_STID, &ls);
 	nfs4_unlock_state();
-	if (nfserr)
+	if (nfserr) {
+		/* fixup error code as per RFC5661 */
+		if (nfserr == nfserr_bad_stateid)
+			nfserr = nfserr_badlayout;
 		goto out;
+	}
 
 	if (sb->s_pnfs_op->layout_commit) {
 		struct nfs4_file *fp = ls->ls_file;
-- 
1.8.3.1

