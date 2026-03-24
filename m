Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B232D402BA8
	for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2026 15:18:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774365494; cv=none; b=V0ZRfL/HF6osWTup+8qOAF1fGD5qZCOIlUV+zYPLz5KMtPc4H7cAsPa8UlszvcHvZVSWpIPbYaUIr4w5NVW5CPjfhSDOyanAdPrWLQTg5YSyCqc7jYQVxKegEHdcu348NrZtzx4HM3drlJOL9DzEc1QnE2DVz0Ki+oTUsIKsRHM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774365494; c=relaxed/simple;
	bh=YfnVfowzMjKJnRQO5r39B96UWiUO939OWFjytWOFqKI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=scGwTIX0yGmHcaiRzG6JezvPSjCOrfdDyOtXWwd3vTKlGEzofSAAMrw1CZyOSQLlKfNznKziBNpzNJLCLaOK1AnK7ukraRf4sreiZM5O2cijiHB5yxMFAKyA6ViUlYVRbhg8NHIPfe3aXZn/b/n+uFvSLViSRQob03f64YtFRtg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mN/ptFIA; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mN/ptFIA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A9B84C19424;
	Tue, 24 Mar 2026 15:18:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774365494;
	bh=YfnVfowzMjKJnRQO5r39B96UWiUO939OWFjytWOFqKI=;
	h=From:To:Cc:Subject:Date:From;
	b=mN/ptFIAMuXbTb8hAc96mHw2WZs09C7iCcEZuQQMpf7F3UZI1mHWEd19UJNYLtc/t
	 mWsJpLm+TGcbLGuj3Q9ZesElJ8G//aQo8f1sLfpLIUy3U6G8smTWSq2wYLJ35TDvZG
	 fYwIauZOAI4sjkRWaccuVWubRQEQ8slv1jiNtaYbzwhJNP9TeSjM9HsLiY66iutM24
	 6qfcBW1CL1sRiAhS7ghKq7kQYd4021hV11ae1o207SGIKC1+89uL5s7xyaaECcK69L
	 pjNdvEF/kHX8CqO8uNCgWGHoxwyHjHEc/N/JvsdABOKrL9XyWANZQlEg27vSo9AUuj
	 ql+2EmbPqa4mg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Fix delegation reference leak in nfsd4_revoke_states
Date: Tue, 24 Mar 2026 11:18:12 -0400
Message-ID: <20260324151812.85482-1-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

When revoking delegation state, nfsd4_revoke_states() takes an extra
reference on the stid before calling unhash_delegation_locked(). If
unhash_delegation_locked() returns false (the delegation was already
unhashed by a concurrent path), dp is set to NULL and
revoke_delegation() is skipped, but the extra reference is never
released. Each occurrence permanently pins the stid in memory. The
leaked reference also prevents nfs4_put_stid() from decrementing
cl_admin_revoked, leaving the counter permanently inflated.

Drop the extra reference in the failure path.

Fixes: 8dd91e8d31fe ("nfsd: fix race between laundromat and free_stateid")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b9c399b89df..0fefae6b0a48 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1389,7 +1389,8 @@ static void destroy_delegation(struct nfs4_delegation *dp)
  * stateid or it's called from a laundromat thread (nfsd4_landromat()) that
  * determined that this specific state has expired and needs to be revoked
  * (both mark state with the appropriate stid sc_status mode). It is also
- * assumed that a reference was taken on the @dp state.
+ * assumed that a reference was taken on the @dp state. This function
+ * consumes that reference.
  *
  * If this function finds that the @dp state is SC_STATUS_FREED it means
  * that a FREE_STATEID operation for this stateid has been processed and
@@ -1836,6 +1837,10 @@ void nfsd4_revoke_states(struct nfsd_net *nn, struct super_block *sb)
 					mutex_unlock(&stp->st_mutex);
 					break;
 				case SC_TYPE_DELEG:
+					/* Extra reference guards against concurrent
+					 * FREE_STATEID; revoke_delegation() consumes
+					 * it, otherwise release it directly.
+					 */
 					refcount_inc(&stid->sc_count);
 					dp = delegstateid(stid);
 					spin_lock(&state_lock);
@@ -1845,6 +1850,8 @@ void nfsd4_revoke_states(struct nfsd_net *nn, struct super_block *sb)
 					spin_unlock(&state_lock);
 					if (dp)
 						revoke_delegation(dp);
+					else
+						nfs4_put_stid(stid);
 					break;
 				case SC_TYPE_LAYOUT:
 					ls = layoutstateid(stid);
-- 
2.53.0

