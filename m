Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:42687 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284AbaGHSFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:21 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so5144842qab.34
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 033/100] nfsd: Slight cleanup of find_stateid()
Date: Tue,  8 Jul 2014 14:03:21 -0400
Message-Id: <1404842668-22521-34-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

In preparation of reference counting.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c59395c63df..522f0efe47a8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1699,28 +1699,37 @@ static void gen_confirm(struct nfs4_client *clp)
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

