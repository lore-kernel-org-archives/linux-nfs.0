Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32852 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbGMJci (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:32:38 -0400
Received: by pdbqm3 with SMTP id qm3so77462209pdb.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:32:38 -0700 (PDT)
Message-ID: <55A385B2.1040409@gmail.com>
Date: Mon, 13 Jul 2015 17:32:34 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 08/14] nfsd: Drop duplicate checking of seqid in nfsd4_create_session()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2edfedc..c94d1ef 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2548,11 +2548,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		cs_slot = &conf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
-		if (status == nfserr_replay_cache) {
-			status = nfsd4_replay_create_session(cr_ses, cs_slot);
-			goto out_free_conn;
-		} else if (cr_ses->seqid != cs_slot->sl_seqid + 1) {
-			status = nfserr_seq_misordered;
+		if (status) {
+			if (status == nfserr_replay_cache)
+				status = nfsd4_replay_create_session(cr_ses, cs_slot);
 			goto out_free_conn;
 		}
 	} else if (unconf) {
-- 
2.4.3

