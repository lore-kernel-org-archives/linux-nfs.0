Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:50816 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752025AbbJOQIG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 12:08:06 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org, jlayton@poochiereds.net
Cc: Andrew Elble <aweits@rit.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Olga Kornievskaia <aglo@umich.edu>
Subject: [PATCH v3] nfsd: eliminate sending duplicate and repeated delegations
Date: Thu, 15 Oct 2015 12:07:28 -0400
Message-Id: <1444925248-14399-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've observed the nfsd server in a state where there are
multiple delegations on the same nfs4_file for the same client.
The nfs client does attempt to DELEGRETURN these when they are presented to
it - but apparently under some (unknown) circumstances the client does not
manage to return all of them. This leads to the eventual
attempt to CB_RECALL more than one delegation with the same nfs
filehandle to the same client. The first recall will succeed, but the
next recall will fail with NFS4ERR_BADHANDLE. This leads to the server
having delegations on cl_revoked that the client has no way to FREE
or DELEGRETURN, with resulting inability to recover. The state manager
on the server will continually assert SEQ4_STATUS_RECALLABLE_STATE_REVOKED,
and the state manager on the client will be looping unable to satisfy
the server.

List discussion also reports a race between OPEN and DELEGRETURN that
will be avoided by only sending the delegation once to the
client. This is also logically in accordance with RFC5561 9.1.1 and 10.2.

So, let's:

1.) Not hand out duplicate delegations.
2.) Only send them to the client once.

RFC 5561:

9.1.1:
"Delegations and layouts, on the other hand, are not associated with a
specific owner but are associated with the client as a whole
(identified by a client ID)."

10.2:
"...the stateid for a delegation is associated with a client ID and may be
used on behalf of all the open-owners for the given client.  A
delegation is made to the client as a whole and not to any specific
process or thread of control within it."

Reported-by: Eric Meddaugh <etmsys@rit.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 106 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 90 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0f1d5691b795..da21df673ed9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -765,16 +765,74 @@ void nfs4_unhash_stid(struct nfs4_stid *s)
 	s->sc_type = 0;
 }
 
-static void
+static int
+same_clid(clientid_t *cl1, clientid_t *cl2)
+{
+	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
+}
+
+/**
+ * nfs4_get_existing_delegation - Discover if this delegation already exists
+ * @clp:     a pointer to the nfs4_client we're granting a delegation to
+ * @fp:      a pointer to the nfs4_file we're granting a delegation on
+ *
+ * Return:
+ *      On success: NULL if an existing delegation was not found.
+ *
+ *      On error: -EAGAIN if one was previously granted to this nfs4_client
+ *                 for this nfs4_file.
+ *
+ */
+
+static int
+nfs4_get_existing_delegation(struct nfs4_client *clp, struct nfs4_file *fp)
+{
+	struct nfs4_delegation *searchdp = NULL;
+	struct nfs4_client *searchclp = NULL;
+
+	lockdep_assert_held(&state_lock);
+	lockdep_assert_held(&fp->fi_lock);
+
+	list_for_each_entry(searchdp, &fp->fi_delegations, dl_perfile) {
+		searchclp = searchdp->dl_stid.sc_client;
+		if (clp == searchclp) {
+			return -EAGAIN;
+		}
+	}
+	return 0;
+}
+
+/**
+ * hash_delegation_locked - Add a delegation to the appropriate lists
+ * @dp:     a pointer to the nfs4_delegation we are adding.
+ * @fp:     a pointer to the nfs4_file we're granting a delegation on
+ *
+ * Return:
+ *      On success: NULL if the delegation was successfully hashed.
+ *
+ *      On error: -EAGAIN if one was previously granted to this
+ *                 nfs4_client for this nfs4_file. Delegation is not hashed.
+ *
+ */
+
+static int
 hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
+	int status;
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
+
 	lockdep_assert_held(&state_lock);
 	lockdep_assert_held(&fp->fi_lock);
 
+	status = nfs4_get_existing_delegation(clp, fp);
+	if (status)
+		return status;
+	++fp->fi_delegees;
 	atomic_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
-	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
+	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	return 0;
 }
 
 static bool
@@ -1833,12 +1891,6 @@ same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
 	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
 }
 
-static int
-same_clid(clientid_t *cl1, clientid_t *cl2)
-{
-	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
-}
-
 static bool groups_equal(struct group_info *g1, struct group_info *g2)
 {
 	int i;
@@ -3945,6 +3997,18 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 	return fl;
 }
 
+/**
+ * nfs4_setlease - Obtain a delegation by requesting lease from vfs layer
+ * @dp:   a pointer to the nfs4_delegation we're adding.
+ *
+ * Return:
+ *      On success: Return code will be 0 on success.
+ *
+ *      On error: -EAGAIN if there was an existing delegation.
+ *                 nonzero if there is an error in other cases.
+ *
+ */
+
 static int nfs4_setlease(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
@@ -3976,16 +4040,19 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
 		goto out_unlock;
 	/* Race breaker */
 	if (fp->fi_deleg_file) {
-		status = 0;
-		++fp->fi_delegees;
-		hash_delegation_locked(dp, fp);
+		status = hash_delegation_locked(dp, fp);
 		goto out_unlock;
 	}
 	fp->fi_deleg_file = filp;
-	fp->fi_delegees = 1;
-	hash_delegation_locked(dp, fp);
+	fp->fi_delegees = 0;
+	status = hash_delegation_locked(dp, fp);
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
+	if (status) {
+		/* Should never happen, this is a new fi_deleg_file  */
+		WARN_ON_ONCE(1);
+		goto out_fput;
+	}
 	return 0;
 out_unlock:
 	spin_unlock(&fp->fi_lock);
@@ -4005,6 +4072,15 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 	if (fp->fi_had_conflict)
 		return ERR_PTR(-EAGAIN);
 
+	spin_lock(&state_lock);
+	spin_lock(&fp->fi_lock);
+	status = nfs4_get_existing_delegation(clp, fp);
+	spin_unlock(&fp->fi_lock);
+	spin_unlock(&state_lock);
+
+	if (status)
+		return ERR_PTR(status);
+
 	dp = alloc_init_deleg(clp, fh, odstate);
 	if (!dp)
 		return ERR_PTR(-ENOMEM);
@@ -4023,9 +4099,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
 		status = -EAGAIN;
 		goto out_unlock;
 	}
-	++fp->fi_delegees;
-	hash_delegation_locked(dp, fp);
-	status = 0;
+	status = hash_delegation_locked(dp, fp);
 out_unlock:
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
-- 
2.4.6

