Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C01A34D3B9
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474459; cv=none; b=ekuhodzEDUGWNOpxywCL8/hj2IbuCA7QBrPwin5ZHX9xPWVaN2eEq0qYSe0b/JWHpR2GBCRNDZhWEQpRBGfVmCh0RvGJV79031/zJRwGMYgpY/5iuRcJVeyLZK65NRgxH2UA/6dJQo3rm7hLR9qEOT/EuAmP30ZiFNQq5JKLzwQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474459; c=relaxed/simple;
	bh=9fvgbfR1vOJXIPL8N/RtYmoErF10T65PDKd0BOirwL0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BQK3OdrvuTjfi7OVhNSdbs4WERWP/M6XzcC6EZtqKExPeTf1vAYW5xzWbSevFrGDWb5OzqQsGSxQY/w5QqK3dkICeJFY+2nPYlLiOyDhZFeG9zgb5gibN+KKGxfEBKpPLqS0auOj94HikW57NWZuBoyYsBUrk7byeuZQic0FliQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aCSdtcK/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aCSdtcK/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F2EB1F0089A;
	Thu,  8 Oct 2026 15:47:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474452;
	bh=5F6iNU9eL5a2fFA41eJc7OLErOXmKWcwzFkC0mHS7/k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aCSdtcK/lPZnxd0fca7hhdA2N7yPDJqNNpUBMH4EUXb+7aGrNMAv61tKZ5ozljZEO
	 zP/kOAcJzQK+D7n5qARNDvIiPLkz0k0ocplrh3oT7PjqN513lFqonOwe85srRP7waZ
	 XdtAat0VtNSnxdizsjt9Tl0IrqYwusCQ9XbclFhb3z5V8dWGDFt/Mz0CXQRO1+OuIw
	 fYlv7Bu60nrDZoJOGBvS7y5TJlxBAdS3J6e5DUxrmCAX5HefrvVnq2KNXi12kN2CR7
	 jjC7Ql03rGTC/ebnQZZizTM9BXldcTwzZl1fSlrjZASczhqv4rYyEYMYr6lm2OCBWR
	 P7aFpiUpWG2fg==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 4/8] pynfs: add tests for SETATTR by a delegation holder
Date: Thu,  8 Oct 2026 11:47:25 -0400
Message-ID: <20261008154729.77787-5-cel@kernel.org>
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

A client that holds a delegation and then changes the file's mode
does not conflict with itself, so the server has no reason to recall
that delegation. A server that recalls it anyway costs the client
its delegation on every chmod, and no test checks for that.

Add DELEG30 and DELEG31, which take a write and a read delegation
and send a mode-changing SETATTR from the same session. Each fails
if a CB_RECALL arrives within two seconds or if TEST_STATEID no
longer accepts the delegation stateid. A server that does not grant
the delegation type the test asks for gets UNSUPPORTED, not a
failure.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 59 +++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 8addde6c4fbf..198555ce9b9d 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -800,3 +800,62 @@ def testClaimFHAfterRecall(t, env):
     if not passed:
         fail(results)
     print(results)
+
+def _check_deleg_stateid(sess, stateid):
+    res = sess.compound([op.test_stateid([stateid])])
+    check(res)
+    status = res.resarray[0].tsr_status_codes[0]
+    if status != NFS4_OK:
+        fail("TEST_STATEID on the delegation stateid returned %s" %
+             nfsstat4[status])
+
+def _testHolderSetattr(t, env, access, deleg_type):
+    recall = threading.Event()
+    def pre_hook(arg, env):
+        env.notify = recall.set
+    def post_hook(arg, env, res):
+        return res
+    name = env.testname(t)
+    sess1 = env.c1.new_client_session(b"%s_1" % name)
+    sess1.client.cb_pre_hook(OP_CB_RECALL, pre_hook)
+    sess1.client.cb_post_hook(OP_CB_RECALL, post_hook)
+
+    fh, stateid, deleg = __create_file_with_deleg(sess1, name, access)
+    if deleg.delegation_type != deleg_type:
+        _delegreturn(sess1, fh, deleg)
+        t.fail_support("Wanted %s, got %s" %
+                       (open_delegation_type4[deleg_type], _deleg_desc(deleg)))
+
+    res = sess1.compound([op.putfh(fh),
+                          op.setattr(nfs4lib.state00, {FATTR4_MODE: 0o600})])
+    recalled = recall.wait(2)
+    if recalled or res.status != NFS4_OK:
+        _delegreturn(sess1, fh, deleg)
+    if recalled:
+        fail("SETATTR by the delegation holder recalled its delegation")
+    check(res)
+    _check_deleg_stateid(sess1, deleg.stateid)
+
+    _delegreturn(sess1, fh, deleg)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
+
+def testWriteDelegHolderSetattr(t, env):
+    """SETATTR by the holder of a write delegation must not recall it
+
+    FLAGS: writedelegations deleg all
+    CODE: DELEG31
+    """
+    _testHolderSetattr(t, env, OPEN4_SHARE_ACCESS_BOTH |
+                       OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG,
+                       OPEN_DELEGATE_WRITE)
+
+def testReadDelegHolderSetattr(t, env):
+    """SETATTR by the holder of a read delegation must not recall it
+
+    FLAGS: deleg all
+    CODE: DELEG32
+    """
+    _testHolderSetattr(t, env, OPEN4_SHARE_ACCESS_READ |
+                       OPEN4_SHARE_ACCESS_WANT_READ_DELEG,
+                       OPEN_DELEGATE_READ)
-- 
2.55.0

