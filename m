Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:65523 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718Ab3J2JjQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:16 -0400
Received: by mail-we0-f176.google.com with SMTP id w62so7835382wes.35
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:15 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 2/7] nfsd4: need to destroy revoked delegations in destroy_client
Date: Tue, 29 Oct 2013 11:39:12 +0200
Message-Id: <1383039552-27209-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[use list_splice_init]
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a403502..a66b0ad 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1129,6 +1129,13 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		destroy_delegation(dp);
 	}
+	spin_lock(&recall_lock);
+	list_splice_init(&clp->cl_revoked, &reaplist);
+	spin_unlock(&recall_lock);
+	while (!list_empty(&reaplist)) {
+		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
+		destroy_revoked_delegation(dp);
+	}
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
 		release_openowner(oo);
-- 
1.8.3.1

