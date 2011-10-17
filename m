Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44757 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617Ab1JQV4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/8] nfsd4: make is_open_owner boolean
Date: Mon, 17 Oct 2011 17:55:51 -0400
Message-Id: <1318888557-14719-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/state.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index aa14f06..87eecfd 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -335,13 +335,13 @@ struct nfs4_replay {
 struct nfs4_stateowner {
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_stateids;
-	int			so_is_open_owner; /* 1=openowner,0=lockowner */
 	struct nfs4_client *    so_client;
 	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
 	 * sequence id expected from the client: */
 	u32                     so_seqid;
 	struct xdr_netobj       so_owner;     /* open owner name */
 	struct nfs4_replay	so_replay;
+	bool			so_is_open_owner;
 };
 
 struct nfs4_openowner {
-- 
1.7.5.4

