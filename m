Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6FD74EE843
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474460; cv=none; b=EyRsIN/5B0W7DVUU2wEka36hmojayFxKKXKfjDLLCCVm7/a+5e2vgnTohvUbL9jToEOutMRum8KiyhvPtKIKQzPC9F7oXigxL7MgwTnUONdAS9rlOnm354BWKZ3LE7C0tRkMmNwUhc4q6YLzZuAQZTu3G2wFsYIbbrywvOJlZnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474460; c=relaxed/simple;
	bh=U0s4mxX+UBKA82KCvme2B3wiLYQ7bAZC1YPZqWecKMw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aheFDo2n2E1TpwoTJ9RhqVUWJjW1YI0EjcMV+/urvZSNCK5ESoMz0GbtjsE/yN1KdBdaBDWrkHMsY8iv2U0AmDNOq7N/7BqYWvlymqpZuaYnx8LLF45f7dgu8NXFw8qTGYlxDjCssWFHamVXNd2JrTtuRTenhZ9dfHQQaBDXZ9k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B5Hvi3Hz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B5Hvi3Hz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C0CE1F00893;
	Thu,  8 Oct 2026 15:47:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474451;
	bh=eiFXop1O5UF5YSowQh8ubU6ARQxtZANswpqt3aNfqgQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=B5Hvi3HzGaLBGP3nu9Jkcsu0l68AGBwCiU3O7iSQ70VMl26U9Qh9XAW9nC0cCungo
	 vvAkApAJ4HcgSnH2uyG1+msmIBd7sLpxSC8qiDp0hva3+zqUu5y3CZSC5Hq28ISz18
	 uxb1gpu3P5gwVudJeoVFFivLQqP7nJ6XQb7LmCnp3uPdqXUlTPRAtJV6eG5wDC4JBZ
	 UTEKK9QuFdLVMYgu8seSTBU03zxHQKNI59YzIwbdxu02BFa2I1d+PBmn+nsgbGqio8
	 J/qERNIHEDd1NdQH0vJh1LbfjeXKGjBM9ex2zOoaxPqgsugXUYn0teiKTKllLofS8+
	 TXxyVS4CypWrA==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/8] pynfs: add test for OPEN(CLAIM_FH) with WANT_READ_DELEG
Date: Thu,  8 Oct 2026 11:47:22 -0400
Message-ID: <20261008154729.77787-2-cel@kernel.org>
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

The delegation tests request a delegation only through CLAIM_NULL,
and OPEN7 pairs CLAIM_FH with WANT_NO_DELEG. No test covers a client
that already holds a filehandle and asks for a delegation with
OPEN(CLAIM_FH). On a server that does not implement WANT_DELEGATION,
that OPEN is the only way to ask.

Add DELEG27. It creates a file, closes it, then sends OPEN(CLAIM_FH)
with WANT_READ_DELEG and expects a read delegation. A failure reports
the delegation type and ond_why that the server returned instead.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 61 +++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 6ae89d223c7f..c35ce8f5ec3b 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -625,3 +625,64 @@ def testCbGetattrAfterSyncWrite(t, env):
     if compareTimes(attrs2[FATTR4_TIME_MODIFY], attrs4[FATTR4_TIME_MODIFY]) != 0:
         fail(f"mtime after write ({attrs2[FATTR4_TIME_MODIFY]}) != "
              f"mtime from delegreturn ({attrs4[FATTR4_TIME_MODIFY]})")
+
+def _open_claim_fh(sess, fh, owner, access):
+    """OPEN by filehandle. No GETFH follows, so OPEN is the last result."""
+    open_op = op.open(0, access, OPEN4_SHARE_DENY_NONE, open_owner4(0, owner),
+                      openflag4(OPEN4_NOCREATE), open_claim4(CLAIM_FH))
+    return sess.compound([op.putfh(fh), open_op])
+
+def _open_claim_fh_retry(sess, fh, owner, access):
+    """Send OPEN(CLAIM_FH) again if the first reply carries no delegation
+
+    The first OPEN after CREATE_SESSION can race the server's backchannel
+    probe.
+    """
+    res = _open_claim_fh(sess, fh, owner, access)
+    check(res)
+    if not _got_deleg(res.resarray[-1].delegation):
+        res = _open_claim_fh(sess, fh, owner, access)
+        check(res)
+    return res
+
+def _delegreturn(sess, fh, deleg):
+    """Return the delegation, if OPEN granted one"""
+    if _got_deleg(deleg):
+        res = sess.compound([op.putfh(fh), op.delegreturn(deleg.stateid)])
+        check(res)
+
+def _deleg_desc(deleg):
+    desc = "%s" % open_delegation_type4.get(deleg.delegation_type,
+                                            deleg.delegation_type)
+    if deleg.delegation_type == OPEN_DELEGATE_NONE_EXT:
+        desc += ", ond_why %s" % why_no_delegation4.get(deleg.ond_why,
+                                                        deleg.ond_why)
+    return desc
+
+def testClaimFHReadDeleg(t, env):
+    """OPEN(CLAIM_FH) with WANT_READ_DELEG on a file with no open state
+
+    FLAGS: open deleg all
+    CODE: DELEG28
+    """
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    res = create_file(sess1, name, access=OPEN4_SHARE_ACCESS_BOTH |
+                      OPEN4_SHARE_ACCESS_WANT_NO_DELEG)
+    check(res)
+    fh = res.resarray[-1].object
+    res = close_file(sess1, fh, stateid=res.resarray[-2].stateid)
+    check(res)
+
+    res = _open_claim_fh_retry(sess1, fh, name, OPEN4_SHARE_ACCESS_READ |
+                               OPEN4_SHARE_ACCESS_WANT_READ_DELEG)
+    stateid = res.resarray[-1].stateid
+    deleg = res.resarray[-1].delegation
+    if deleg.delegation_type != OPEN_DELEGATE_READ:
+        _delegreturn(sess1, fh, deleg)
+        fail("Expected a read delegation, got %s" % _deleg_desc(deleg))
+
+    res = sess1.compound([op.putfh(fh), op.delegreturn(deleg.read.stateid)])
+    check(res)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
-- 
2.55.0

