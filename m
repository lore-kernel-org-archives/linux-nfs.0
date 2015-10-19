Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50412 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644AbbJSVzm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2015 17:55:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: improve client_has_state to check for unused openowners
Date: Mon, 19 Oct 2015 17:55:35 -0400
Message-Id: <1445291735-16717-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1445291735-16717-1-git-send-email-bfields@redhat.com>
References: <1445291735-16717-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

At least in the v4.0 case openowners can hang around for a while after
last close, but they shouldn't really block (for example), a new mount
with a different principal.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1159a2321e37..151357bcfe99 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2269,16 +2269,20 @@ nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
 	clid->flags = new->cl_exchange_flags;
 }
 
+static bool client_has_openowners(struct nfs4_client *clp)
+{
+	struct nfs4_openowner *oo;
+
+	list_for_each_entry(oo, &clp->cl_openowners, oo_perclient) {
+		if (!list_empty(&oo->oo_owner.so_stateids))
+			return true;
+	}
+	return false;
+}
+
 static bool client_has_state(struct nfs4_client *clp)
 {
-	/*
-	 * Note clp->cl_openowners check isn't quite right: there's no
-	 * need to count owners without stateid's.
-	 *
-	 * Also note in 4.0 case should also be checking for openowners
-	 * kept around just for close handling.
-	 */
-	return !list_empty(&clp->cl_openowners)
+	return !client_has_openowners(clp)
 #ifdef CONFIG_NFSD_PNFS
 		|| !list_empty(&clp->cl_lo_states)
 #endif
-- 
2.4.3

