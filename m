Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47846 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823AbaCWBMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/50] nfsd4: remove redundant check from nfsd4_check_resp_size
Date: Sat, 22 Mar 2014 21:11:37 -0400
Message-Id: <1395537141-10389-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

cstate->slot and ->session are each set together in nfsd4_sequence.  If
one is non-NULL, so is the other.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ebefc42..143780d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3584,8 +3584,6 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 		return 0;
 
 	session = resp->cstate.session;
-	if (session == NULL)
-		return 0;
 
 	if (xb->page_len == 0) {
 		length = (char *)resp->p - (char *)xb->head[0].iov_base + pad;
-- 
1.8.5.3

