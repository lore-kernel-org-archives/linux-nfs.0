Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029412;
	b=3ZhovfOUyA+eDWP3rl08qh1GJjhliff0ggIbddG1mLP/jsoCbAx4c8cnIOo1IltVQ767
	 nZoCd4uhtjMaGcsO3kZ1M7ru/SFRUfTluydT++sx05Vp3M/TYIostRRfWVPCdM70YK3nR
	 N/xokMQa3yyW6IT8ZDYv8I+ITQJ9ZO775VJXYCieR0i689hvxQKXRyKFJo2PwUivqNN3E
	 R9IhOYroAmg3/zM9q6U2lLd6QyYMLAzQZvPBKJzHk/7dvAFXKg2YbW2yFWNOoi27XSsuq
	 eYk2MIEuTU3XoSOwLEgoyKdAH4riWfM0lyDdtSVx0eSeeigs1RyIHukX6vPBcD5gnOg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029412;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VtAFpeinW46k6m2KGwSGTtiWQHGlEh6lssq8MUrVdR0=;
	b=NquRzDX27zMcGp9IsFWawJyfm2gjiC+uaTsEemHWaGWbuMbIz1cgrkCceLwDsNLoCEME
	 hVoa1qwBYTW+yqNNYTuBxW7RLJoRMoUnV3rX3r/u0iOxGsV9gRyM9SfRusQVQIYXukT+5
	 m6AJqTDhrSkwb9zIt9MGBtAoY9QTl6u0Z/7TsHD+91E1oZSpyh8WbNnl1htlH2RI+RL0t
	 uEW52HrLVc55/+jI408mgPAd+RdamTK+Ygu2RMSeOuRylVplYvxeoPx6Vs1TVUw01V0de
	 4Ih5Bm83eO6yeRwGLWUABgSZOYT569bverlQSoJiHG1K4eIU9ZiH7eNHYT0Y6WBz7pQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RxBxUk6U;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1696606A33E
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RxBxUk6U
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3F7C1F000C5;
	Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029411;
	bh=VtAFpeinW46k6m2KGwSGTtiWQHGlEh6lssq8MUrVdR0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RxBxUk6Ug7Ybj/rmtUzEs+q212aGjA6vfhQK2DEhhdFtwIUmiX7ZR/e8iS6Wui8x2
	 Jyqppjq221Xx2GR7LA/ggnhpS8+PoJP4CBeTltlIB+2tx9rV4w/F7KbPaia/cGTDDe
	 eJG4GaDk0RQTPjQLA3TWJ93xN1jt3ehLOuusYXKSFJwajis+FpPolhutUcl93RLDZv
	 ynUWFrqfEw3eY4hWtgdlgTf77HqTwjECjoVCbz996nneEGUspHc44qEG8zmXZzjQVi
	 ebd0JGRqsnjcsBIrBQ4JUFk8d1gbbSDFFAZ/1WklMShTORFBFS5GXrvTLN5NdySu3P
	 cLm1ElKkMu7lg==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 18 Nov 2026 11:16:41 -0800
Subject: [PATCH pynfs 2/6] server41tests: check that delegated times
 survive DELEGRETURN
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261118-delegts-v1-2-9bd252eea637@kernel.org>
References: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
In-Reply-To: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5298; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=PNioEzmEYrkHIdX9SHCPVgecWuWXrsU6aLXqJ9V8I88=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmiPo+D19ExrsTlwuifg0IcKJJK/AmZmwTXN
 FEcdfKtCx2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35ogAKCRAADmhBGVaC
 FXgeD/9h7K/uYB2YguUjLx+qmFiRJP/h1DB0Mj19JD6jUiMdWSN4Q5TiixZlNlH+DLESFvAuPbZ
 5E8YoxMEEk+BsUMgPFbdLaTGbRER65/5wJSDcc/wV0kQT8ehI43gniSLVdu8UYK4aRCpE044TbW
 vdqqLq7PieM3u+bNAko3gCFjLeELzNin39IyFGFfXOL0FvOLn0UeGilgloL+B6cRZsNmWnkLY6h
 L9gq2rulMT7dRvay1iY9xY1VZMvY4HWrGdnr0c50qrRdHFYDMMfWjxFSsEKpBQT8gbx+3p3Ofdy
 CgwwQxlSxc6+Ko8whZ7j0eCRgeosUOjVDQoxkbgyY9AMv82bL9TZ2Eiq1IQHlsFUhLsYEYo0k5V
 41A53c0e3WcPX6PhpFMPW/v27WY2uKJbEiA33XbDh8fUP4vOOjSbSFPkG8uc6+TlmmeAS5AHO3k
 mYunz7EjwNcHqyD4MEeweZwiLYpgD2INoZcVh8CIBxfvjAACKkVKeme+ZgnR3ZvadyfJfr6zK5B
 FXiCNYb6A+jI7EYZUbK5Ws+pjs7+JJyxwlpaebFTQ0bgKggUh67Tg69FdeBIqnWROk2oMBLqIxR
 2ykgCQayF/pes0odWCRsPpfiz9wxfJW2K9k5/VV0qjXP44K2cYxuCnhzsxh4tc91TlVkdRdiPg+
 /AU61QmhI1wMDSQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Git's index records each file's c/mtime and size and treats any later
difference as a modification. Over NFSv4.2 with delegated timestamps,
git t1092 has found files whose times changed after DELEGRETURN, e.g.
when nfsd stamped "now" over the holder's mtime at return.

Add DELEG28: get an OPEN_DELEGATE_WRITE_ATTRS_DELEG delegation, WRITE,
then return it the way the Linux client does
(SETATTR(delegated times)|GETATTR|DELEGRETURN), with an mtime after the
server's WRITE stamp. Require that the server applies the mtime, and
that change, size, time_modify and time_metadata don't move across
DELEGRETURN.

The test is skipped if the server doesn't offer or grant delegated
timestamps.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 87 +++++++++++++++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 55e4e3a437bf..ae07af9273e6 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -661,3 +661,90 @@ def testCbGetattrAfterSyncWrite(t, env):
     if compareTimes(attrs2[FATTR4_TIME_MODIFY], attrs4[FATTR4_TIME_MODIFY]) != 0:
         fail(f"mtime after write ({attrs2[FATTR4_TIME_MODIFY]}) != "
              f"mtime from delegreturn ({attrs4[FATTR4_TIME_MODIFY]})")
+
+# Attributes that a stat-based cache (e.g. git's index) records
+_STAT_ATTRS = [FATTR4_CHANGE, FATTR4_SIZE, FATTR4_TIME_MODIFY, FATTR4_TIME_METADATA]
+
+def _check_stat_same(before, after, when):
+    for attr, name in ((FATTR4_CHANGE, "change"), (FATTR4_SIZE, "size")):
+        if before[attr] != after[attr]:
+            fail(f"{name} moved {when}: {before[attr]} -> {after[attr]}")
+    for attr, name in ((FATTR4_TIME_MODIFY, "time_modify"),
+                       (FATTR4_TIME_METADATA, "time_metadata")):
+        if compareTimes(before[attr], after[attr]) != 0:
+            fail(f"{name} moved {when}: {before[attr]} -> {after[attr]}")
+
+def _deleg_times_open(t, env):
+    """Create a file and get an OPEN_DELEGATE_WRITE_ATTRS_DELEG delegation"""
+    sess = env.c1.new_client_session(b"%s_1" % env.testname(t))
+
+    res = sess.compound([op.putrootfh(),
+                         op.getattr(nfs4lib.list2bitmap([FATTR4_SUPPORTED_ATTRS,
+                                                         FATTR4_OPEN_ARGUMENTS]))])
+    check(res)
+    caps = res.resarray[-1].obj_attributes
+    if (not caps[FATTR4_SUPPORTED_ATTRS] & (1 << FATTR4_OPEN_ARGUMENTS) or
+        not caps[FATTR4_OPEN_ARGUMENTS].oa_share_access_want &
+            (1 << OPEN_ARGS_SHARE_ACCESS_WANT_DELEG_TIMESTAMPS)):
+        t.fail_support("Server doesn't offer delegated timestamps")
+
+    openmask = (OPEN4_SHARE_ACCESS_READ |
+                OPEN4_SHARE_ACCESS_WRITE |
+                OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG |
+                OPEN4_SHARE_ACCESS_WANT_DELEG_TIMESTAMPS)
+    fh, stateid, deleg = __create_file_with_deleg(sess, env.testname(t), openmask)
+    if deleg.delegation_type != OPEN_DELEGATE_WRITE_ATTRS_DELEG:
+        t.fail_support("Didn't get a write delegation with delegated timestamps")
+    return sess, fh, stateid, deleg.write.stateid
+
+def _deleg_times_return(sess, env, fh, delegstateid, ts):
+    """Return the delegation the way the Linux client does
+
+    PUTFH|SETATTR(delegated times)|GETATTR|DELEGRETURN. Returns the GETATTR
+    result: the last attributes seen while the delegation was held.
+    """
+    ops = [op.putfh(fh),
+           op.setattr(delegstateid, {FATTR4_TIME_DELEG_ACCESS: ts,
+                                     FATTR4_TIME_DELEG_MODIFY: ts}),
+           op.getattr(nfs4lib.list2bitmap(_STAT_ATTRS)),
+           op.delegreturn(delegstateid)]
+    # The server may reject the proxied times with NFS4ERR_DELAY
+    for i in range(5):
+        res = sess.compound(ops)
+        if res.status != NFS4ERR_DELAY:
+            break
+        env.sleep(1)
+    check(res)
+    return res.resarray[-2].obj_attributes
+
+def _testDelegTimesStable(t, env):
+    size = 5
+
+    sess1, fh, stateid, delegstateid = _deleg_times_open(t, env)
+
+    res = write_file(sess1, fh, b'z' * size, 0, delegstateid)
+    check(res)
+    env.sleep(.1)
+    ts = _server_now(sess1, env, env.testname(t) + b"_clock")
+
+    held = _deleg_times_return(sess1, env, fh, delegstateid, ts)
+    after = do_getattrdict(sess1, fh, _STAT_ATTRS)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
+
+    if compareTimes(held[FATTR4_TIME_MODIFY], ts) != 0:
+        fail(f"delegated time_modify not applied: {held[FATTR4_TIME_MODIFY]} != {ts}")
+    _check_stat_same(held, after, "after DELEGRETURN")
+
+def testDelegTimesReturn(t, env):
+    """Attributes seen under a timestamp delegation survive DELEGRETURN
+
+    Get a write delegation with delegated timestamps, WRITE, then set a
+    delegated time_modify later than the server's WRITE stamp, GETATTR and
+    DELEGRETURN. A GETATTR after DELEGRETURN must report the same change,
+    size, time_modify and time_metadata.
+
+    FLAGS: deleg all
+    CODE: DELEG28
+    """
+    _testDelegTimesStable(t, env)

-- 
2.56.1

