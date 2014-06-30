Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:57086 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaF3Pvi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:38 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so2126497qgd.21
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 046/114] nfsd: Slight cleanup of find_stateid()
Date: Mon, 30 Jun 2014 11:49:15 -0400
Message-Id: <1404143423-24381-47-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

In preparation of reference counting.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f5865a8e3081..54c9631a602c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1660,28 +1660,37 @@ static void gen_confirm(struct nfs4_client *clp)
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
-static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
+static struct nfs4_stid *
+find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
-	spin_lock(&cl->cl_lock);
 	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
-	spin_unlock(&cl->cl_lock);
 	if (!ret || !ret->sc_type)
 		return NULL;
 	return ret;
 }
 
+static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
+{
+	struct nfs4_stid *ret;
+
+	spin_lock(&cl->cl_lock);
+	ret = find_stateid_locked(cl, t);
+	spin_unlock(&cl->cl_lock);
+	return ret;
+}
+
 static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
 
-	s = find_stateid(cl, t);
-	if (!s)
-		return NULL;
-	if (typemask & s->sc_type)
-		return s;
-	return NULL;
+	spin_lock(&cl->cl_lock);
+	s = find_stateid_locked(cl, t);
+	if (s != NULL && !(typemask & s->sc_type))
+		s = NULL;
+	spin_unlock(&cl->cl_lock);
+	return s;
 }
 
 static struct nfs4_client *create_client(struct xdr_netobj name,
-- 
1.9.3

