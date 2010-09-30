Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab0I3QTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/16] nfsd4: fix alloc_init_session return type
Date: Thu, 30 Sep 2010 12:19:06 -0400
Message-Id: <1285863553-8945-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This returns an nfs error, not -ERRNO.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e305794..ebddcc1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -639,9 +639,7 @@ static inline int slot_bytes(struct nfsd4_channel_attrs *ca)
 	return ca->maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
 }
 
-static int
-alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
-		   struct nfsd4_create_session *cses)
+static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new, tmp;
 	struct nfsd4_slot *sp;
-- 
1.7.0.4

