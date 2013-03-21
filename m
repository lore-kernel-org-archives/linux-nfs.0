Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60984 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311Ab3CUO4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/9] nfsd4: clientid lookup cleanup
Date: Thu, 21 Mar 2013 10:56:16 -0400
Message-Id: <1363877780-28825-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ef0337d..1464d62 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1376,12 +1376,12 @@ move_to_confirmed(struct nfs4_client *clp)
 }
 
 static struct nfs4_client *
-find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
+find_client_in_id_table(struct list_head *tbl, clientid_t *clid, bool sessions)
 {
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
-	list_for_each_entry(clp, &nn->conf_id_hashtbl[idhashval], cl_idhash) {
+	list_for_each_entry(clp, &tbl[idhashval], cl_idhash) {
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
@@ -1393,19 +1393,19 @@ find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 }
 
 static struct nfs4_client *
+find_confirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
+{
+	struct list_head *tbl = nn->conf_id_hashtbl;
+
+	return find_client_in_id_table(tbl, clid, sessions);
+}
+
+static struct nfs4_client *
 find_unconfirmed_client(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
-	struct nfs4_client *clp;
-	unsigned int idhashval = clientid_hashval(clid->cl_id);
+	struct list_head *tbl = nn->unconf_id_hashtbl;
 
-	list_for_each_entry(clp, &nn->unconf_id_hashtbl[idhashval], cl_idhash) {
-		if (same_clid(&clp->cl_clientid, clid)) {
-			if ((bool)clp->cl_minorversion != sessions)
-				return NULL;
-			return clp;
-		}
-	}
-	return NULL;
+	return find_client_in_id_table(tbl, clid, sessions);
 }
 
 static bool clp_used_exchangeid(struct nfs4_client *clp)
-- 
1.7.9.5

