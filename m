Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:54436 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753286AbdJaAJ6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 20:09:58 -0400
Received: by mail-io0-f196.google.com with SMTP id e89so31184894ioi.11
        for <linux-nfs@vger.kernel.org>; Mon, 30 Oct 2017 17:09:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] nfsd: CLOSE SHOULD return the invalid special stateid for NFSv4.x (x>0)
Date: Mon, 30 Oct 2017 20:09:48 -0400
Message-Id: <20171031000951.18294-3-trond.myklebust@primarydata.com>
In-Reply-To: <20171031000951.18294-2-trond.myklebust@primarydata.com>
References: <20171031000951.18294-1-trond.myklebust@primarydata.com>
 <20171031000951.18294-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b246aaa20863..0fa42c704b9a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -63,6 +63,9 @@ static const stateid_t zero_stateid = {
 static const stateid_t currentstateid = {
 	.si_generation = 1,
 };
+static const stateid_t close_stateid = {
+	.si_generation = 0xffffffffU,
+};
 
 static u64 current_sessionid = 1;
 
@@ -5390,6 +5393,11 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_close_open_stateid(stp);
 	mutex_unlock(&stp->st_mutex);
 
+	/* See RFC5661 sectionm 18.2.4 */
+	if (stp->st_stid.sc_client->cl_minorversion)
+		memcpy(&close->cl_stateid, &close_stateid,
+				sizeof(close->cl_stateid));
+
 	/* put reference from nfs4_preprocess_seqid_op */
 	nfs4_put_stid(&stp->st_stid);
 out:
-- 
2.13.6

