Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49126 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197Ab0I3QTk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/16] nfsd4: fix alloc_init_session BUILD_BUG_ON()
Date: Thu, 30 Sep 2010 12:19:05 -0400
Message-Id: <1285863553-8945-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Note we're allocating an array of nfsd4_slot *'s, not nfsd4_slot's.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d3f12dc..e305794 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -657,7 +657,7 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 	if (status)
 		goto out;
 
-	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot)
+	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot *)
 		     + sizeof(struct nfsd4_session) > PAGE_SIZE);
 
 	status = nfserr_jukebox;
-- 
1.7.0.4

