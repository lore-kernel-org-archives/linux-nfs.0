Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:64317 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbaF3PwG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:06 -0400
Received: by mail-qa0-f44.google.com with SMTP id hw13so6594472qab.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:06 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 066/114] nfsd: don't allow CLOSE to proceed until refcount on stateid drops
Date: Mon, 30 Jun 2014 11:49:35 -0400
Message-Id: <1404143423-24381-67-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove client_mutex protection, it'll be possible to have an
in-flight operation using an openstateid when a CLOSE call comes in.
If that happens, we can't just put the sc_file reference and clear its
pointer without risking an oops.

Fix this by ensuring that v4.0 CLOSE operations wait for the refcount
to drop before proceeding to do so.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d97f3d3743f3..4d504c83d8d8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -86,6 +86,12 @@ static DEFINE_MUTEX(client_mutex);
  */
 static DEFINE_SPINLOCK(state_lock);
 
+/*
+ * A waitqueue for all in-progress 4.0 CLOSE operations that are waiting for
+ * the refcount on the open stateid to drop.
+ */
+static DECLARE_WAIT_QUEUE_HEAD(close_wq);
+
 static struct kmem_cache *openowner_slab;
 static struct kmem_cache *lockowner_slab;
 static struct kmem_cache *file_slab;
@@ -626,8 +632,10 @@ static void nfs4_put_stid(struct nfs4_stid *s)
 {
 	struct nfs4_client *clp = s->sc_client;
 
-	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock))
+	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock)) {
+		wake_up_all(&close_wq);
 		return;
+	}
 	remove_stid_locked(clp, s);
 	spin_unlock(&clp->cl_lock);
 	s->sc_free(s);
@@ -3051,11 +3059,23 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct net *net)
 
 	dprintk("NFSD: move_to_close_lru nfs4_openowner %p\n", oo);
 
+	/*
+	 * We know that we hold one reference via nfsd4_close, and another
+	 * "persistent" reference for the client. If the refcount is higher
+	 * than 2, then there are still calls in progress that are using this
+	 * stateid. We can't put the sc_file reference until they are finished.
+	 * Wait for the refcount to drop to 2. Since it has been unhashed,
+	 * there should be no danger of the refcount going back up again at
+	 * this point.
+	 */
+	wait_event(close_wq, atomic_read(&s->st_stid.sc_count) == 2);
+
 	release_all_access(s);
 	if (s->st_stid.sc_file) {
 		put_nfs4_file(s->st_stid.sc_file);
 		s->st_stid.sc_file = NULL;
 	}
+
 	release_last_closed_stateid(oo);
 	oo->oo_last_closed_stid = s;
 	list_move_tail(&oo->oo_close_lru, &nn->close_lru);
-- 
1.9.3

