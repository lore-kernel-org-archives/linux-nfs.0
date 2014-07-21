Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:60529 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbaGUPDO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:14 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so5354993qge.38
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 10/40] nfsd: Slight cleanup of find_stateid()
Date: Mon, 21 Jul 2014 11:02:22 -0400
Message-Id: <1405954972-28904-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

In preparation of reference counting.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5100a737f862..d83f1a27aded 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1692,28 +1692,37 @@ static void gen_confirm(struct nfs4_client *clp)
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

