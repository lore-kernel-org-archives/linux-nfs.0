Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55697 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab1D0BII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Apr 2011 21:08:08 -0400
Message-ID: <4DB76CE6.9080404@cn.fujitsu.com>
Date: Wed, 27 Apr 2011 09:09:58 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: compare request's opcnt with session's maxops at
 nfsd4_sequence
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make sure nfs server can distinguish request contains more ops
than channel allowed.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fbde6f7..4f9fc68 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1749,6 +1749,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (!session)
 		goto out;
 
+	status = nfserr_too_many_ops;
+	if (((struct nfsd4_compoundargs *)rqstp->rq_argp)->opcnt >
+				 session->se_fchannel.maxops)
+		goto out;
+
 	status = nfserr_badslot;
 	if (seq->slotid >= session->se_fchannel.maxreqs)
 		goto out;
-- 
1.7.4.1


