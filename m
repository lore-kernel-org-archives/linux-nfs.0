Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55896 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbaAGVFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 16:05:13 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: better VERIFY comment
Date: Tue,  7 Jan 2014 16:04:31 -0500
Message-Id: <1389128674-16951-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1389128674-16951-1-git-send-email-bfields@redhat.com>
References: <1389128674-16951-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This confuses me every time.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 41e34df..dadff09 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1069,8 +1069,10 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				    cstate->current_fh.fh_dentry, &p,
 				    count, verify->ve_bmval,
 				    rqstp, 0);
-
-	/* this means that nfsd4_encode_fattr() ran out of space */
+	/*
+	 * If nfsd4_encode_fattr() ran out of space, assume that's because
+	 * the attributes are longer (hence different) than those given:
+	 */
 	if (status == nfserr_resource)
 		status = nfserr_not_same;
 	if (status)
-- 
1.7.9.5

