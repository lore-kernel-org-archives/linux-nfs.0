Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029413;
	b=rRJBhvgWQOIHqAm1fIjMnGzeWMv4aTP+6FjalHvrehLOgJ57EnBGgc4o/RNVmvsVZoQq
	 72EQkqYLLaJAhGg7lekssZ485+aLmPatnT1Y9Zbiz/mvwWORBU42nbJa7A6KNFahTDAQt
	 8rYDZ2MFqzeaiJiwM8bgTl9fbcZmprY5rIU3m+4Lb2Y5mjXz3Sh3lZFClfVglX0DnMlyR
	 lJFU1jtI1mHAzJxhxinLg4RZeDUaViqsEWwZwBJXZUoWPakjg7ic6Pgs0dl7eElTDHujH
	 EPjvrFExhvAF4u5M3ralnG4q+jd69h2Uc1o2ePj5iwRjNROki8LPgYlDWu5dxpR+vuA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029413;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=czrWNYyd7/Dz1OG10oI9Xfxe0MvlSwL6Nj6tD20RnTE=;
	b=raGeNKlZPxNGYqZAGCB5I4kLI+qd2a1kHujFTZO68XBu/mPM9Tnu9EIeJPRPvx09Vh3F
	 bm8NDfhSlMPqC9HHOybmDMdZunPFwgQPpEuG9RrnoduymDh2YP1tMeBWyEa3do6GNpNfC
	 3UOf+xGraX4fQol2TErCI9dfAENXLxYjaKDrT8voIXfRr2NXx9aIBvGxNbGLz5Os/ww/z
	 qXRAagtj9WMQhVQCP/zbYn7VgMB/RRjcdAdFNSEvOZDtzhM9B5AV8d45QZd8rD8wGlo/d
	 KFbs0Rnv9S39wRxS5Mj/yDpXYjOOtjxX8PLnuePYx74kHJMxc2Moi2Ttxwg6zYLXpdw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ANdOiuQq;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09D6D60A260E
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ANdOiuQq
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF5B41F000C7;
	Wed, 18 Nov 2026 19:16:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029412;
	bh=czrWNYyd7/Dz1OG10oI9Xfxe0MvlSwL6Nj6tD20RnTE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ANdOiuQqT83RcOlO9jX3WWzuPR3ETaF5jSXU/Vg6RM/EjPqm+dNdlisew3czVOKJC
	 OpaenUgAgzLvovzOg5belFwJVlK1e6HXeCl+WIl0cH+bf5QKzT2+iOkcVWqYIy0ahh
	 1cNaJykVgcJZ+1Wfqsdi6fMI5T6X//lBSBx+aWK845aleURPaVWC0WH2+Es3TYCywz
	 Ht4JgxC+CWI/r0qDpcpHVZjmkn0U7v5+1XQJjbE8Yrq6qugJ7B+7JXS26D8AfFGIk0
	 lHu1QuCD+eoi2+bjyXb3WMPwKUNWqhvKdAwY+hURHSFHVMTb0YGug8ya7xfRkVtamP
	 7LoonN92wqnLQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 18 Nov 2026 11:16:45 -0800
Subject: [PATCH pynfs 6/6] server41tests: check delegated times after a
 truncate survive return
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
Message-Id: <20261118-delegts-v1-6-9bd252eea637@kernel.org>
References: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
In-Reply-To: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2329; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=okk817SX7llrWHB9Z1zEDhTEyjHDl/OK1AQsQkWAA8Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmigxvsmlAV//liWNWxy6fcv7A8BLAU9FYrw
 wnyJwuEMz6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35ogAKCRAADmhBGVaC
 FTWiD/sFnkI6vWKK5AUe3c0xmhg7MlMvqDc7TPOspN5TLPG2Y0yEhIms6iYFJWjBnZvp6V8IYQ5
 TIO0/+tsO/QuLkUmeIhdKy8tCWvvL35fm0VRPGJXGjMdz1BvNfuYF6ATdUXH4o88pVowLV+f5a/
 gpNFnCNhhHBeHczFNg2RJdogySggy+xHM+YkQ8E4DbVWkJ/sfHHn8WaTp219A7RyWg5qlT6cZFJ
 EDq0QlCHH2NkBaEhzcrL7Fe53w1x/2Sm5X66DZYQFHAapDG5NhmgfGzdvx/Esio/y9XWBKgs3Gq
 DAZEYjisSeJVPWRdBA+rDE7J96hjQvrCjiPWJRzQlTHz5SwEYcN0r698tz3YknCnhUTT4FBFRtg
 QP5cwmJBktA+mztKiIzTeP2bb78KfjMcFeLcjY//0CdGEKpQ1IwoyJCr2cwHpITa1xZWzoqPKvX
 x2AKRI/fpVBNXVmvk5qehmPZleQGXtXHZrlyHBiDoR2aW+VqTljrY2vSFVkV/P143fbVBVAo+3k
 /Xe04YtMvbGRYmLeCAwPYZbjZ1R0M3av5bl675HhBA2YUW21rqsop/8IkiZm+KuP+ycpmWtmdbm
 YNC6Uhb4fZiUEVWUP0t22myOVkmuV1rmKtHhtZ08l9KWRq/c1iFaSxlGseAeZZzuCQ+02g3CcWo
 whQmYkj4Hlv0zTA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A size-changing SETATTR always has the server stamp c/mtime (RFC 8881
section 18.30.4), even under a timestamp delegation. The Linux client
had a bug where its delegated stamp could land before that, and
ctime then changed after DELEGRETURN.

Add DELEG32: WRITE, truncate to 0 with the delegation stateid, then
return with a delegated mtime after the truncate stamp. Require that
the server applies the mtime and that nothing moves across
DELEGRETURN.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index bf165a17cd29..8c80bb2584b4 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -827,3 +827,34 @@ def testDelegTimesCbGetattrEarlyStamp(t, env):
     CODE: DELEG31
     """
     _testDelegTimesStable(t, env, early_stamp=True, observe=True)
+
+def testDelegTimesTruncate(t, env):
+    """Attributes seen under a timestamp delegation survive DELEGRETURN
+
+    Get a write delegation with delegated timestamps, WRITE, then truncate
+    with a size-changing SETATTR, which has the server stamp c/mtime. Set a
+    delegated time_modify later than that stamp, GETATTR and DELEGRETURN.
+    A GETATTR after DELEGRETURN must report the same attributes.
+
+    FLAGS: deleg all
+    CODE: DELEG32
+    """
+    sess1, fh, stateid, delegstateid = _deleg_times_open(t, env)
+
+    res = write_file(sess1, fh, b'z' * 5, 0, delegstateid)
+    check(res)
+    res = sess1.compound([op.putfh(fh), op.setattr(delegstateid, {FATTR4_SIZE: 0})])
+    check(res)
+    env.sleep(.1)
+    ts = _server_now(sess1, env, env.testname(t) + b"_clock")
+
+    held = _deleg_times_return(sess1, env, fh, delegstateid, ts)
+    after = do_getattrdict(sess1, fh, _STAT_ATTRS)
+    res = close_file(sess1, fh, stateid=stateid)
+    check(res)
+
+    if held[FATTR4_SIZE] != 0:
+        fail(f"Bad size: {held[FATTR4_SIZE]} != 0")
+    if compareTimes(held[FATTR4_TIME_MODIFY], ts) != 0:
+        fail(f"delegated time_modify not applied: {held[FATTR4_TIME_MODIFY]} != {ts}")
+    _check_stat_same(held, after, "after DELEGRETURN")

-- 
2.56.1

