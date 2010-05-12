Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756316Ab0ELW3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 18:29:47 -0400
Date: Wed, 12 May 2010 18:29:46 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/9] nfsd4: keep a reference count on client while
	in use
Message-ID: <20100512222946.GE11389@fieldses.org>
References: <4BE9C7A2.8030801@panasas.com> <1273612434-13726-1-git-send-email-bhalevy@panasas.com> <20100512024030.GA27184@fieldses.org> <4BEA2E06.7070902@panasas.com> <4BEA4876.3030802@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BEA4876.3030802@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 12, 2010 at 09:19:34AM +0300, Benny Halevy wrote:
> On May. 12, 2010, 7:26 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> > On May. 12, 2010, 5:40 +0300, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> >> Something still doesn't look quite right: a sequence operation
> >> increments cl_count from 1 to 2; then, say, an exchangeid in another
> >> thread expires the client, dropping cl_count from 2 to 1; then the
> >> laundromat runs, sees cl_count 1, and decides it can expire the
> >> client.  Meanwhile, the original compound is still running.
> >>
> >> Am I missing something?
> > 
> > Yeah.  exchange_id doesn't touch cl_refcount.  It may call expire_client
> > explicitly which will unhash the client but will not destroy it if cl_refcount > 0
> > the laundromat won't the client either after that since it's not on the lru list
> > any more (and even if it would, it's refcount is still great than zero so it would
> > have been ignored)
> 
> Sorry, I misspoken.  exchange_id may decrement cl_refcount via expire_client()
> but still the laundromat won't see it as expire_client will have already removed the
> client from client_lru.

Yep, sorry for my confusion!

The special treatment of refcount == 1 still seems odd to me; with
expiry==0 trick it no longer seems necessary.

Another case:

	- Two 4.1 compounds arrive, both their sequence operations are
	  processed.
	- Independently, an exchange_id expires the client.
	- At this point, the reference count is 2.
	- One of the original compounds completes.  It renews the client
	  (because it hits reference count 1).
	- The second of the two original compounds completes.  It frees
	  the client.

I guess there's nothing fundamentally wrong with that, but it's a little
odd.

Wouldn't it be more straightforward to let cl_refcount be a count of the
number of outstanding compounds, and make release_session_client do:

	if cl_refcount >= 0
		return;
	if (client_is_expired(clp))
		free client;
	else
		renew client;

?

The following works for me. If you don't see any objection, I'll squash
this in and push out the result.

--b.

commit 9d1b08f5cd9f2367f76f8350595c2bc00876d57f
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed May 12 18:17:58 2010 -0400

    tmp-squashme: count only session users in cl_refcount

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 89b77fe..05ad0ae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -706,12 +706,12 @@ release_session_client(struct nfsd4_session *session)
 {
 	struct nfs4_client *clp = session->se_client;
 
-	spin_lock(&client_lock);
-	BUG_ON(clp->cl_refcount <= 0);
-	if (--clp->cl_refcount <= 0) {
+	if (!atomic_dec_and_lock(&clp->cl_refcount, &client_lock))
+		return;
+	if (is_client_expired(clp)) {
 		free_client(clp);
 		session->se_client = NULL;
-	} else if (clp->cl_refcount == 1)
+	} else
 		renew_client_locked(clp);
 	spin_unlock(&client_lock);
 	nfsd4_put_session(session);
@@ -765,8 +765,7 @@ expire_client(struct nfs4_client *clp)
 	list_del(&clp->cl_strhash);
 	spin_lock(&client_lock);
 	unhash_client_locked(clp);
-	BUG_ON(clp->cl_refcount <= 0);
-	if (--clp->cl_refcount <= 0)
+	if (atomic_dec_and_test(&clp->cl_refcount))
 		free_client(clp);
 	spin_unlock(&client_lock);
 }
@@ -854,7 +853,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	}
 
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
-	clp->cl_refcount = 1;
+	atomic_set(&clp->cl_refcount, 1);
 	atomic_set(&clp->cl_cb_set, 0);
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
@@ -1495,7 +1494,7 @@ out:
 	/* Hold a session reference until done processing the compound. */
 	if (cstate->session) {
 		nfsd4_get_session(cstate->session);
-		session->se_client->cl_refcount++;
+		atomic_inc(&session->se_client->cl_refcount);
 	}
 	spin_unlock(&client_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
@@ -2643,7 +2642,7 @@ nfs4_laundromat(void)
 				clientid_val = t;
 			break;
 		}
-		if (clp->cl_refcount > 1) {
+		if (atomic_read(&clp->cl_refcount)) {
 			dprintk("NFSD: client in use (clientid %08x)\n",
 				clp->cl_clientid.cl_id);
 			continue;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f263174..006c842 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -233,7 +233,8 @@ struct nfs4_client {
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
-	int			cl_refcount;	/* use under client_lock */
+	/* number of rpc's in progress over an associated session: */
+	atomic_t		cl_refcount;
 
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
