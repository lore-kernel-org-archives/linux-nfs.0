Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B54EB4EE84A
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474455; cv=none; b=ZcqdjsxxdnJOUOD/sirjPtg/r4vkmBkPEmpqOchYkXVUgwOuqRs6JWl7j+iURjPmDw4Qnz7WjDBqXGUDmEQO56CX9mzhEZCY7rJakxh9WymzjTy/l4Yixg0tFYoGXSqgGNebVZS3wxQQWQ4h6HDeNFyajxP4OpaX5VHGIv5JvG4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474455; c=relaxed/simple;
	bh=zGwzbWEZjkjW3tzUqhw/9kKY1kPig26vGdHLq+wXnHk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PIz96YgtLoI5Wn9iVfZotGCUSpR+DLR4C0LbjZfBJ48vbepWIG39WZaeFg4ChxsBRTF1fxhTGGTbFpSvKSCCCOXuBNaBoMYcpVEFRWsSxW08gPblekhinE26d3D9szlyw9DgxnffLEw07e1EjVykWnxY6UQUiXdnfzqIdUyxQew=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=e2Ohj0a5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="e2Ohj0a5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 180CA1F00899;
	Thu,  8 Oct 2026 15:47:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474452;
	bh=l8nHSH6h4pq2Hw+PVWDxPa5pAo60p18idLHEkptQ3Xs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=e2Ohj0a5C6PSdq8XQxpmWoWFbfzFtdyZ5O9EqcdSbz5eVVYxJPAIWgEkkZfVba51V
	 6JasYoh/WOFjqHH2ngupIEsB86uroeoNsp0uyhx/Tu6Fs/qrS/OWtbvRcCI4u8OuDA
	 87IVmY9pq9HRtazxnLmBjYL0B7mcj55T/o6BF72hXWxZ8KyPXojrfNg2KlzmT20xm/
	 mBCA92z4oK3VCkC0HcKd/ZWakMek8ofgKW3lcyOIUFHWoS9d1OZDrvYPJnpQsDZ+Zh
	 sRFztozJSnoId6jX090dQwhk5LiCwHMGZUi7qN5azGhZv3fMaeioNwk0ALqPbRZdto
	 lq3Cx3nbGsX1A==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 3/8] pynfs: add test for a delegation request after a recall
Date: Thu,  8 Oct 2026 11:47:24 -0400
Message-ID: <20261008154729.77787-4-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261008154729.77787-1-cel@kernel.org>
References: <20261008154729.77787-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RFC 8881 Section 10.4.7 names re-establishing a recalled delegation
as a use for a delegation want. No test asks for a delegation again
once the conflicting open is gone, so a server that never grants one
on that file again, or that misreports why, goes unnoticed.

Add DELEG29. It has a second client recall a read delegation and
then close its open. The first client then sends OPEN(CLAIM_FH) with
WANT_READ_DELEG three times, at 0, 65, and 100 seconds, and the
failure message gives the outcome of each. The test accepts a
delegation or OPEN_DELEGATE_NONE_EXT with WND4_CONTENTION. A reply
that names another reason, or that is a bare OPEN_DELEGATE_NONE,
fails it. The delays separate a refusal that ends from one that does
not. NFSD, for one, blocks a recalled file for at least 30 seconds
and ages the block only when a delegation request arrives, so the
block can outlast the second request.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 73 +++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 56d227127a15..8addde6c4fbf 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -727,3 +727,76 @@ def testClaimFHUpgradeReadDeleg(t, env):
     check(res)
     res = close_file(sess1, fh, stateid=upgraded)
     check(res)
+
+def testClaimFHAfterRecall(t, env):
+    """OPEN(CLAIM_FH) with WANT_READ_DELEG after the delegation was
+       recalled and the conflicting open has been closed
+
+    The request is made three times: right after the conflicting open
+    is closed, 65 seconds later, and 100 seconds later. A server can
+    refuse a delegation on a recently recalled file for a while, and
+    it can age that refusal only when a request arrives. The last
+    request shows whether the refusal ever ends. Any reply may carry
+    a delegation or WND4_CONTENTION.
+
+    FLAGS: open deleg
+    CODE: DELEG30
+    """
+    recall = threading.Event()
+    def pre_hook(arg, env):
+        env.notify = recall.set
+    def post_hook(arg, env, res):
+        return res
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    sess1.client.cb_pre_hook(OP_CB_RECALL, pre_hook)
+    sess1.client.cb_post_hook(OP_CB_RECALL, post_hook)
+    access = OPEN4_SHARE_ACCESS_READ | OPEN4_SHARE_ACCESS_WANT_READ_DELEG
+    fh, stateid, deleg = __create_file_with_deleg(sess1, name, access)
+
+    sess2 = env.c1.new_client_session(b"%s_2" % name)
+    open_op = op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
+                      open_owner4(0, b"My Open Owner 2"),
+                      openflag4(OPEN4_NOCREATE), open_claim4(CLAIM_NULL, name))
+    slot = sess2.compound_async(env.home + [open_op])
+    completed = recall.wait(2)
+    env.sleep(.1)
+    res = sess1.compound([op.putfh(fh), op.delegreturn(deleg.read.stateid)])
+    check(res)
+    res = sess2.listen(slot)
+    if not completed:
+        fail("delegation break not received")
+    for i in range(5):
+        if res.status != NFS4ERR_DELAY:
+            break
+        env.sleep(1)
+        res = sess2.compound(env.home + [open_op])
+    check(res)
+    res = close_file(sess2, fh, stateid=res.resarray[-1].stateid)
+    check(res)
+
+    passed = True
+    results = []
+    elapsed = 0
+    for delay in (0, 65, 100):
+        # Sleep in short steps so that the lease does not expire
+        while elapsed < delay:
+            env.sleep(5)
+            elapsed += 5
+            check(sess1.compound([]))
+        res = _open_claim_fh(sess1, fh, name, access)
+        check(res)
+        stateid = res.resarray[-1].stateid
+        deleg = res.resarray[-1].delegation
+        _delegreturn(sess1, fh, deleg)
+        if (not _got_deleg(deleg) and
+            (deleg.delegation_type != OPEN_DELEGATE_NONE_EXT or
+             deleg.ond_why != WND4_CONTENTION)):
+            passed = False
+        results.append("after %i seconds: %s" % (delay, _deleg_desc(deleg)))
+    results = "; ".join(results)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
+    if not passed:
+        fail(results)
+    print(results)
-- 
2.55.0

