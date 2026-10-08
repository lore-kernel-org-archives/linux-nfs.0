Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6233A4EFFC4
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:18:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483524; cv=none; b=ayghybqXyv6KREF1eGz9QwSdIEL2OqCZpUb4ldz6uarvu+XMlWKkfBS1EwDsfqqo6JIalerGvjimek3OpQrq+hLg+thNSe3vS3cxR9+6bJ6eYwWtWP5m7uSA71rGWJQZ2W3deyQH+7u/Kxpa4kTn5werxuv63hHGRJWJP1Ej7rI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483524; c=relaxed/simple;
	bh=dVxNXgLPChIB8OpFA97Tyit5Ylny2d9jinnHFRhu/uk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=m741uJdjLmaUBz9EpnQANygCPjy6D969Iiz/7jSRTayLdCJfM/xd6G9x28nJUdG+YWtkQ9EZ8QJzehCdJ06JqFRksm85cuJJl+hQwKHIu5/CwsenhbWjjAug1zt3wbJ4eicK88aoG0Fuk33EosbjRWpT7ofmLqfP8tsEXFV0z6c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QZXnbxu9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QZXnbxu9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C1FA51F00893;
	Thu,  8 Oct 2026 18:18:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483523;
	bh=bcbQnuZQsoUU5xH27A0QbjFMKZZAoA2JZlFtk/XOnz0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QZXnbxu9tr7mlsNbVS+7c4m2Kgq0e4ZkdD4OQGMyuAdeNKdNlkbwCmRDV3wO7LPpL
	 UalpukI1iaE+3OM3uvKfocGXJSvNlWjFIFxjjBwTwpUeSn7DIstByvgJpaeOwU45aF
	 xJVQ5NMP03opfwUcu/VuZd5UTEiT9sAnL0URYMwz61NK83oEzO3Jza5cfOfZXzR9lT
	 hmR5dGY+KxliXofZ15n/wZNN/TXiBu6h5VpsFNNaNUerzxTLP9fq0DUQU92tQmsQ9X
	 ew5Pe9wGMhCCsF4lPAnxeGZ6az6G7P2F95KRzTTRlvkeIoj9tgsAkWO2DMg9E4Od22
	 oao7K/hEwaR+Q==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 08 Oct 2026 14:18:30 -0400
Subject: [PATCH 4/5] NFSD: Report unsupported delegation upgrade and
 downgrade
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261008-want-read-v1-4-e372262857c8@kernel.org>
References: <20261008-want-read-v1-0-e372262857c8@kernel.org>
In-Reply-To: <20261008-want-read-v1-0-e372262857c8@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=7398; i=cel@kernel.org;
 h=from:subject:message-id; bh=dVxNXgLPChIB8OpFA97Tyit5Ylny2d9jinnHFRhu/uk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqx95/74EBbuyRr1ylwN+NfGVj7vTx30LXSVUb/
 koGy0PCpKCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasfefwAKCRAzarMzb2Z/
 lxMpD/wMsNJi2EoZ0DDkdl+VIyyVax8Cpeb0O2o4B/qtHogNSDVSn9byGo7Zc8h26/9DFsWWRO3
 ceMzFWV5C9sqBkE1NefLxYqIHlL5O3ilS9o7gOFtc4pg/JXB5z2FsUpic6iefCSken4v0zZ0/tT
 +LxonY6AJ+3eVNnP14PGtP+z/WK9+anZLHQzeYDzh6nsEVIkhBnKoaK5NYKvVYSfXX86oiJCK3g
 /2jtJx85ivAEjABQWcrNIGeWecu0Ug4mmA293lwTcT0fkjVrJl8oODxyXMyVXCUGLkCNI8iY+Sv
 +fKVreTZRZKvxbX1WihRvrSlk84Bs0JwtvVyOgSmguzrkx7SaqwCof3YYLm1M9xk9QGUAxc48FR
 AomWxUN+9/sB1UPhwzax26F0lAdfxBvxkADPTqb+QqHj7FHIfcPRsIJrc+Gvy0aA7M/OkNOsp5s
 khKqGsMbhsxiBzMmzX2YWjeBqbdzuSs0yiCtGnXUBtd5jKvGe5i7o5+HsnmvAUpejRqSmSYNG87
 7ovSqH8cE2ScPHve3W98qWmueMxCWYRL3o2F5Mv6G8/dnj0G09+tFnV0s7gjvKItYRXvMlRGtWp
 S4DNqf7grqpSfDs7yRAcEAw06NcIFmbwm30Zp542n5dpa5z0FQA/ZU5v5z5tln9zEldRs7T8CTQ
 AYvJH1FSmgL36zw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 8881 Section 18.16.3 defines an OPEN that sets
OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG, from a client holding an
OPEN_DELEGATE_READ delegation on the file, as a request to upgrade
the OPEN_DELEGATE_READ delegation. Likewise, an OPEN that sets
OPEN4_SHARE_ACCESS_WANT_READ_DELEG from a client holding an
OPEN_DELEGATE_WRITE delegation is a request to downgrade. A server
that supports neither upgrade nor downgrade replies with ond_why
set to WND4_NOT_SUPP_UPGRADE or WND4_NOT_SUPP_DOWNGRADE.

NFSD supports neither, but replies with WND4_RESOURCE to both
requests, inviting the client to ask again, futilely.
nfsd4_deleg_xgrade_none_ext() exists to supply the correct reasons,
but nfsd4_process_open2() calls it only when the delegation type in
the reply is still OPEN_DELEGATE_NONE, and nfs4_open_delegation()
has already replaced OPEN_DELEGATE_NONE with OPEN_DELEGATE_NONE_EXT
before nfsd4_process_open2() makes the check.

Have nfs4_set_delegation() report the type of the delegation the
client already holds, and have nfsd4_open_deleg_none_ext() choose
the upgrade or downgrade reason from the held type. Remove the
unreachable helper.

Fixes: d24433cdc91c ("nfsd41: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 65 +++++++++++++++++++++++++----------------------------
 1 file changed, 30 insertions(+), 35 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6ed53864c9be..6bb70d50e9d9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1481,10 +1481,12 @@ static void destroy_unhashed_deleg(struct nfs4_delegation *dp)
  * @fp:      a pointer to the nfs4_file we're granting a delegation on
  *
  * Return:
- *      On success: true iff an existing delegation is found
+ *      The delegation @clp already holds on @fp, or NULL if it holds
+ *      none. No reference is taken: the pointer is valid only while
+ *      the caller holds fi_lock.
  */
 
-static bool
+static struct nfs4_delegation *
 nfs4_delegation_exists(struct nfs4_client *clp, struct nfs4_file *fp)
 {
 	struct nfs4_delegation *searchdp = NULL;
@@ -1497,10 +1499,10 @@ nfs4_delegation_exists(struct nfs4_client *clp, struct nfs4_file *fp)
 	list_for_each_entry(searchdp, &fp->fi_delegations, dl_perfile) {
 		searchclp = searchdp->dl_stid.sc_client;
 		if (clp == searchclp) {
-			return true;
+			return searchdp;
 		}
 	}
-	return false;
+	return NULL;
 }
 
 /**
@@ -7000,14 +7002,15 @@ nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
 static struct nfs4_delegation *
 nfs4_set_delegation(struct nfsd4_open *open,
 		    const struct nfsd4_compound_state *cstate,
-		    struct nfs4_ol_stateid *stp, struct svc_fh *parent)
+		    struct nfs4_ol_stateid *stp, struct svc_fh *parent,
+		    u32 *held_type)
 {
 	bool deleg_ts = nfsd4_want_deleg_timestamps(open);
 	struct nfs4_client *clp = stp->st_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfs4_file *fp = stp->st_stid.sc_file;
 	struct nfs4_clnt_odstate *odstate = stp->st_clnt_odstate;
-	struct nfs4_delegation *dp;
+	struct nfs4_delegation *dp, *held;
 	struct nfsd_file *nf = NULL;
 	struct file_lease *fl;
 	int status = 0;
@@ -7066,9 +7069,11 @@ nfs4_set_delegation(struct nfsd4_open *open,
 
 	spin_lock(&nn->deleg_lock);
 	spin_lock(&fp->fi_lock);
-	if (nfs4_delegation_exists(clp, fp))
+	held = nfs4_delegation_exists(clp, fp);
+	if (held) {
+		*held_type = held->dl_type;
 		status = -EEXIST;
-	else if (nfsd4_verify_setuid_write(open, nf))
+	} else if (nfsd4_verify_setuid_write(open, nf))
 		status = -EPERM;
 	else if (!rcu_dereference_protected(fp->fi_deleg_file,
 					    lockdep_is_held(&fp->fi_lock))) {
@@ -7140,6 +7145,10 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	spin_lock(&clp->cl_lock);
 	spin_lock(&fp->fi_lock);
 	status = hash_delegation_locked(dp, fp);
+	if (status == -EEXIST) {
+		held = nfs4_delegation_exists(clp, fp);
+		*held_type = held->dl_type;
+	}
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&clp->cl_lock);
 	spin_unlock(&nn->deleg_lock);
@@ -7159,16 +7168,23 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	return ERR_PTR(status);
 }
 
-static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
+static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status,
+				      u32 held_type)
 {
 	open->op_delegate_type = OPEN_DELEGATE_NONE_EXT;
 	if (status == -EAGAIN)
 		open->op_why_no_deleg = WND4_CONTENTION;
 	else {
 		open->op_why_no_deleg = WND4_RESOURCE;
-		switch (open->op_deleg_want) {
+		switch (open->op_deleg_want & NFS4_SHARE_WANT_TYPE_MASK) {
 		case OPEN4_SHARE_ACCESS_WANT_READ_DELEG:
+			if (deleg_is_write(held_type))
+				open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
+			break;
 		case OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG:
+			if (deleg_is_read(held_type))
+				open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
+			break;
 		case OPEN4_SHARE_ACCESS_WANT_ANY_DELEG:
 			break;
 		case OPEN4_SHARE_ACCESS_WANT_CANCEL:
@@ -7268,6 +7284,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 	struct nfs4_client *clp = stp->st_stid.sc_client;
 	struct svc_fh *parent = NULL;
 	struct nfs4_delegation *dp;
+	u32 held_type = OPEN_DELEGATE_NONE;
 	struct kstat stat;
 	int status = 0;
 	int cb_up;
@@ -7299,7 +7316,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = nfs4_set_delegation(open, &resp->cstate, stp, parent);
+	dp = nfs4_set_delegation(open, &resp->cstate, stp, parent,
+				 &held_type);
 	if (IS_ERR(dp)) {
 		status = PTR_ERR(dp);
 		goto out_no_deleg;
@@ -7341,28 +7359,10 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 
 	/* 4.1 client asking for a delegation? */
 	if (open->op_deleg_want)
-		nfsd4_open_deleg_none_ext(open, status);
+		nfsd4_open_deleg_none_ext(open, status, held_type);
 	return;
 }
 
-static void nfsd4_deleg_xgrade_none_ext(struct nfsd4_open *open,
-					struct nfs4_delegation *dp)
-{
-	if (deleg_is_write(dp->dl_type)) {
-		if (open->op_deleg_want & OPEN4_SHARE_ACCESS_WANT_READ_DELEG) {
-			open->op_delegate_type = OPEN_DELEGATE_NONE_EXT;
-			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
-		} else if (open->op_deleg_want & OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG) {
-			open->op_delegate_type = OPEN_DELEGATE_NONE_EXT;
-			open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
-		}
-	}
-	/* Otherwise the client must be confused wanting a delegation
-	 * it already has, therefore we don't return
-	 * OPEN_DELEGATE_NONE_EXT and reason.
-	 */
-}
-
 /* Are we returning only a delegation stateid? */
 static bool open_xor_delegation(struct nfsd4_open *open)
 {
@@ -7509,11 +7509,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	status = nfs_ok;
 	trace_nfsd_open(&stp->st_stid.sc_stateid);
 out:
-	/* 4.1 client trying to upgrade/downgrade delegation? */
-	if (open->op_delegate_type == OPEN_DELEGATE_NONE && dp &&
-	    open->op_deleg_want)
-		nfsd4_deleg_xgrade_none_ext(open, dp);
-
 	if (fp)
 		put_nfs4_file(fp);
 	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)

-- 
2.55.0

