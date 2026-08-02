Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B4BF29E0E5
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690294; cv=none; b=PFs9uTyX5sVX+UWIZqzMMscPRyOM7jJvkQ7hKw2YYOwUfYKtkbePwI1T9TnvLtbNleqP0LOFEoHD73FaGLNbn3S9ECHIuTMVENaeo9mxPKsG3GEIgAwLuSAd/UslKgkM4H3JRRQxDdVt7dm90dGtwe0+Zldm8IMiuJ0q2bvLXMU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690294; c=relaxed/simple;
	bh=eBzAvM/Q2c1jMEN9CVxOlZ/5MXyh6dvHvyibW3EV7vQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ThGokWusbunAsWD6KbwKFeIdEc8pwlMjOpktrfGDUhKmEJLaoH4Fzf0m9ATjeo0MVoK9LB3yav04NjvXaOl8vcHXMLXMELVoRSCAmqDzCSoKAerKIIqFf2BlQWA/CyVaCl2x7q3GTDMTCKIh2emDF5H4ovozmAJx2TH8mWTf+1Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LyxYnNb+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LyxYnNb+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 97CF01F000E9;
	Sun,  2 Aug 2026 17:04:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690290;
	bh=QydtjS7SHeliS4szrvsNXcHuAl0I7+PR35AA1OZ4leQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LyxYnNb+9eg/WCDQbxMcFYxD6FruzikQ3Mip7yEeOCjcT7AeJlWgr42qDIAGIcie4
	 I51qCbix4NK1h3Ejd4znx+y9dDKQjDCN2fF4pPdzw3lqsVilNEv7x7KZkBdiz+0RMw
	 kFWHpRC/w3gqgWZOHBTyTGFsWOLrUbU/GZdzoo0/A9vbWZywIQ1yi7FvqJDqjef4Jm
	 uV44OyplvEOIC8ERDeXjwUL13KV51mWTcx0l+2pO9a6aVILJgUlvjYrhB7R3wHC18g
	 tcd+KO4W5qtMLIysoJwjTjvLsA4WldH4wGx4uO2AA3cot7Vf2e1aJYmKWUqJqlb/k3
	 nFPWezfjpooQw==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:36 -0400
Subject: [PATCH 9/9] NFSD: Send referring calls with CB_RECALL
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-9-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6042; i=cel@kernel.org;
 h=from:subject:message-id; bh=eBzAvM/Q2c1jMEN9CVxOlZ/5MXyh6dvHvyibW3EV7vQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iqaRxAp4uM3oMLkGzwkWDXvVQ0c8w7e74lY
 7g5Boft1EiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 lxIPD/9Qoe7R15p3UTmNMVBuVZBStnmEWycXnuaj7Wa25CvrbnAxUpjiWrJgy5SDn0rCqktob8v
 g7Wx5ziMUdz0Hxl8C0hIFyBv//UFXKp3hZFxkYyJKSq0h9oI7iOr14FCOwKMVXgMQSZOq7OkCfS
 flgYqksp2zEmOdYKtgkSmOO+4KW1FpSo/yluHjQyfkwImecO2UhGd5j5cK3s8Uv59YMgkVsly5U
 /oQdsJliiOQTkIL1M/01pvNQIs5w+nCyq8Ol5Dey9dsYhCE6ZKu0I9y6UFwEfy9s2XSgwghwIeC
 mMc2bBq29IZ0payYEoGMOEqj9LYJ0ZIhgekpDcE34IiRanBux+w9I0YZJI4spa9qKpFdf1iahzG
 9DaHi7B55ALmw5auoNANKVGlfBCjzmv42PqwAHi56vRBZQ5T3+mhrN21uAYhNtKRB0nt7jb6oVx
 aQNY7nMhfNYDCX/RumIQfTOzR61XQnhpdWTd71l4Q4pvMVx/NIDmZAbRoQrUWw3eiv7Yl4tCxYE
 9lj21oxA6P7rI/smCNVZzv2qhj17G07EhBqiUh1BspuNTn84RWmUrlNTOtPop7nlLs+kD+fPYUf
 l265oK+QGjBPTcAnSo4os8hMj0A8xA/SqVwcXU8Hug0bu8K6FcBESHnZ3Rlskx5EWkDC6kpxKlN
 ZPt5+TmPeU9LYUg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When CB_RECALL races ahead of the reply that granted the delegation,
the client has not yet recorded the delegation stateid and responds
NFS4ERR_BADHANDLE or NFS4ERR_BAD_STATEID. The slot that carried the
grant has not retired at that point, so NFSD cannot read the rejection
as proof that the client never held the delegation. It retries the
recall and, once the retries lapse, revokes a delegation the client is
by then able to return.

Remove the ambiguity with the referring call mechanism of RFC 8881
Section 2.10.6.3: until the slot that carried the grant retires, name
that request as a referring call in the CB_SEQUENCE of each recall. A
client that finds it still outstanding may respond NFS4ERR_DELAY, and
the recall is retried until the client has processed the grant.

A recall reuses one callback context across its retries, and ->prepare
does not run on every send. The granting request does not change, so a
send that inherits the previous list sends the right one. Retirement
of the granting slot drops the list, and nfs4_free_deleg() releases
what is left.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4callback.c |  7 +++++--
 fs/nfsd/nfs4state.c    | 54 +++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 47 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 509195d488c9..9afe2d78d39d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1530,12 +1530,14 @@ void nfsd41_cb_referring_call(struct nfsd4_callback *cb,
 
 /**
  * nfsd41_cb_destroy_referring_call_list - release referring call info
- * @cb: context of a callback that has completed
+ * @cb: context of callback to release referring calls from
  *
  * Callers who allocate referring calls using nfsd41_cb_referring_call() must
  * release those resources by calling nfsd41_cb_destroy_referring_call_list.
  *
- * Caller serializes access to @cb.
+ * Caller serializes access to @cb. No CB_COMPOUND for @cb may be in
+ * flight, because encode_cb_sequence4args() walks this list as it
+ * encodes.
  */
 void nfsd41_cb_destroy_referring_call_list(struct nfsd4_callback *cb)
 {
@@ -1557,6 +1559,7 @@ void nfsd41_cb_destroy_referring_call_list(struct nfsd4_callback *cb)
 		list_del(&rcl->__list);
 		kfree(rcl);
 	}
+	cb->cb_nr_referring_call_list = 0;
 }
 
 static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5774c7a1b3de..510380b6aa7a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1167,6 +1167,8 @@ static void nfs4_free_deleg(struct nfs4_stid *stid)
 	WARN_ON_ONCE(!list_empty(&dp->dl_perfile));
 	WARN_ON_ONCE(!list_empty(&dp->dl_perclnt));
 	WARN_ON_ONCE(!list_empty(&dp->dl_recall_lru));
+	/* The list outlives one recall, so ->release() cannot free it. */
+	nfsd41_cb_destroy_referring_call_list(&dp->dl_recall);
 	kmem_cache_free(deleg_slab, stid);
 	atomic_long_dec(&num_delegations);
 }
@@ -6091,6 +6093,18 @@ bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode)
 	return timeo > 0;
 }
 
+/*
+ * gen_sessionid() composes a sessionid from the client's clientid and a
+ * sequence counter, so the sequence alone identifies the granting session.
+ */
+static void nfsd4_recall_grant_sessionid(const struct nfs4_delegation *dp,
+					 struct nfsd4_sessionid *sid)
+{
+	sid->clientid = dp->dl_stid.sc_client->cl_clientid;
+	sid->sequence = dp->dl_recall_grant.sessionid_seq;
+	sid->reserved = 0;
+}
+
 static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
@@ -6103,14 +6117,7 @@ static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
 	if (!dp->dl_recall_grant.valid)
 		return false;
 
-	/*
-	 * gen_sessionid() composes a sessionid from the client's clientid
-	 * and a sequence counter, so the sequence alone identifies the
-	 * granting session.
-	 */
-	sid.clientid = clp->cl_clientid;
-	sid.sequence = dp->dl_recall_grant.sessionid_seq;
-	sid.reserved = 0;
+	nfsd4_recall_grant_sessionid(dp, &sid);
 
 	/*
 	 * A missing session does not prove the client saw the grant: a
@@ -6145,6 +6152,21 @@ static bool nfsd4_recall_grant_slot_retired(struct nfs4_delegation *dp)
 	return retired;
 }
 
+/*
+ * ->prepare does not run on every send: nfsd4_run_cb_work() skips it
+ * on a requeue, and a retry via rpc_restart_call_prepare() re-enters
+ * the RPC layer beneath it. The granting request does not change, so
+ * a send inherits a correct list. Retirement is the one transition
+ * the list has to follow.
+ */
+static void nfsd4_refresh_recall_grant(struct nfs4_delegation *dp)
+{
+	dp->dl_recall_grant.retired_at_send =
+			nfsd4_recall_grant_slot_retired(dp);
+	if (dp->dl_recall_grant.retired_at_send)
+		nfsd41_cb_destroy_referring_call_list(&dp->dl_recall);
+}
+
 static bool nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 {
 	struct nfs4_delegation *dp = cb_to_delegation(cb);
@@ -6167,8 +6189,17 @@ static bool nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 	}
 	spin_unlock(&nn->deleg_lock);
 
-	dp->dl_recall_grant.retired_at_send =
-			nfsd4_recall_grant_slot_retired(dp);
+	nfsd4_refresh_recall_grant(dp);
+
+	if (dp->dl_recall_grant.valid && !dp->dl_recall_grant.retired_at_send) {
+		struct nfsd4_sessionid sid;
+
+		nfsd4_recall_grant_sessionid(dp, &sid);
+		nfsd41_cb_referring_call(&dp->dl_recall,
+					 (struct nfs4_sessionid *)&sid,
+					 dp->dl_recall_grant.slotid,
+					 dp->dl_recall_grant.seqid);
+	}
 	return true;
 }
 
@@ -6225,8 +6256,7 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 			return 1;
 		}
 		if (!dp->dl_stid.sc_status && dp->dl_retries--) {
-			dp->dl_recall_grant.retired_at_send =
-					nfsd4_recall_grant_slot_retired(dp);
+			nfsd4_refresh_recall_grant(dp);
 			rpc_delay(task, 2 * HZ);
 			return 0;
 		}

-- 
2.54.0

