Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33703 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbbGMJeA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:34:00 -0400
Received: by pdbqm3 with SMTP id qm3so77481100pdb.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:33:59 -0700 (PDT)
Message-ID: <55A38603.8030003@gmail.com>
Date: Mon, 13 Jul 2015 17:33:55 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 11/14] nfsd: Remove duplicate checking of nfsd_net in nfs4_laundromat()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8205542..d342769 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4335,8 +4335,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
-			continue;
 		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
 			t = dp->dl_time - cutoff;
 			new_timeo = min(new_timeo, t);
-- 
2.4.3

