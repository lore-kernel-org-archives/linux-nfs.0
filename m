Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029412;
	b=FrA43NmFAZv4q1TJZiG+WLGS5R9Dmz/eZ5jStgkAWpsFnONokb2KRIQ+hbRIVvIWXcjd
	 i5Xi+UJGrxS4AxMhUXFKfRhkDueyZOrxwq3aPpGcax1IMDNtOMDQHXM/LbS+Dv+AVW86e
	 LtcUTtBFs5zP7vbtgG9eIyJulcqTdsg6X1YQtUAzaQutzdFcMK2Uitu3YQWkcKv0Qj+vs
	 WLkD6jMNPZnKt7/76huEENjaAOszlcbHnTa0YXyJl0t5Yqy1omA3SlTc0F0bjA2dHJiVr
	 kUj8JBUbds6HBEwFKA0+zpxat+hjQbTFUhbjXPJ46JEFMX8OuDS3Ftil+8YPUUhm3BA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029412;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=r6piKG3M4Zy3ZBK8Mb4wfEKYRKvrUUOCniDJzWIbnK4=;
	b=eTSru1XnLlNMm8VBfqPtxak0TlNukTg/iV2Mfd5aV3izUv2t/x9MW6VGHkdRBh8oJMVs
	 NYoNmFgUsg6IXh91IBTZBDfNj94YcFTLdmRdMne6CLwFXn8lF9Ft1eXbI99ca2CInGn+1
	 AnhmlaqCoD32hlyECHvqT+hFoMS/DkHpCeZinN9k8n0KAFkjzM7VjTzjmW4HgrRyioV3D
	 GkHqE+uzH7c6t52EYOx+Tp9v150VUDN5xsxQreyk3o6bbOXbGZCbIBCIUEpccB3dcBVgP
	 H/V0oL0z042xBzycUWcRkn3nzoZGWM8NtgYZYBqHglra3GOG7r5c+2ZetxU6Kst3NEA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eFCzY1Fl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DC18606A337
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eFCzY1Fl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F36E41F000C4;
	Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029412;
	bh=r6piKG3M4Zy3ZBK8Mb4wfEKYRKvrUUOCniDJzWIbnK4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eFCzY1FlL8h193AnRvlLBbrrjvyogrSpNGJX8ytfZ9TWJ05K8yR/jzxMTt0htZcf0
	 XFZo0roEF7aX3SoFfSH3JyHyoEiKiXADODBjuen/y/cSYf6HPUvr0rdRTWAmLuXNAI
	 wSUVHjaNIGiJpXOMH8SnXn/kDO97ndaK98sG7uVLRcYE2P6W7rke+TgG0Y6jgq7QUs
	 8w7vNHXNAfHGu5YyJeFZoLb7EaSpbTrBYXd4FyBu7AL578FehpvdtOlRt7SfMGh3vn
	 6nYRraDYR8gLBz3TjetcVEoy6GCJiREkZvpIi+EHggST5xPUm+GU9zYCnSlCrqEOHr
	 4GL6GlM9z25pA==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 18 Nov 2026 11:16:42 -0800
Subject: [PATCH pynfs 3/6] server41tests: check delegated times that
 predate the server's WRITE
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
Message-Id: <20261118-delegts-v1-3-9bd252eea637@kernel.org>
References: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
In-Reply-To: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2800; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=SD/DQ44WmhCBYBGNiAQPPt42G7YI91ryFCwis5QZbQA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmiSPkebaGAsSfLGE6jHWSgJ6eeoJTsBvbTG
 DD9vqN0vcmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35ogAKCRAADmhBGVaC
 FcsID/9MGjg5KjzCfhExt8g5Lun7G0B5U++KKNtUld9WIIRVSzzYV3eN5CDD66ajfrYxsfVccA0
 C3noPj760rsJAvX/o+z/voxrGDRDsCaOLhPIbjT1hxbq/nP0K62yN3g+4mI3Y1Rek5Tz00wUQjM
 XhbGm95d6YWVwZ2AXwoC23ful4DzMCHmqZfkxnjfIxeR1dzIrjU5MnQmcl+6dX/h1uCxwb1u4rF
 QfaHQWpe1hInPjkFrlWNkb4CyiuQY5GYNmvh6niL05Z3XVoj+d4xxK3aCoqXOsk6RIFVlCPU8b0
 uh1YB1GhipL/7uwyMpdfpNxA97WbVoTr5kLCY4oiS1XTHD9yeYyOC9ZWs6FCLvIk8VSsXFN8ETB
 UzT+7+ylqv3AxfZbpLj2YfE3Aj70+uJenHuevgnyJhJo+mmNuEOQoEwH8PtBT0wID2TgU/qIJ8e
 iHZRUBAZfdJqCUcKwTDAz2VtOQ8Dw2YcFjhYmGpj8vtoLRq1lyqiwxbVgcSOnAOO8Q5tQ98vAdZ
 t3PlnlOzlyoPgSDJNnZoS85gJVg5g29vPbF4XC8HcSms9fk3otjywpZ5hkr83Du0KSerC9c1cl/
 NN1du5/KaAksR3vs6oBGyh0cbMZmoFKo4i4GHTAlgm7ZvO5xfspd136OHsYAIV8VrKxtx0nyLOx
 jMQjaZet8tMz2BQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A client stamps mtime on write(2) and flushes later, so the delegated
mtime it returns is usually older than the server's WRITE stamp. The
server can't move ctime backward to match. Over NFSv4.2, git t1092
has seen stat-dirty files from this.

Add DELEG29: as DELEG28, but sample the delegated time before the
WRITE. RFC 9754 lets the server ignore a time older than the file's
time_modify, so don't require it to be applied; still require that
nothing moves across DELEGRETURN.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index ae07af9273e6..07f91cac58a9 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -717,22 +717,29 @@ def _deleg_times_return(sess, env, fh, delegstateid, ts):
     check(res)
     return res.resarray[-2].obj_attributes
 
-def _testDelegTimesStable(t, env):
+def _testDelegTimesStable(t, env, early_stamp=False):
     size = 5
 
     sess1, fh, stateid, delegstateid = _deleg_times_open(t, env)
 
+    # A client stamps mtime when the application writes, which is before
+    # the WRITE reaches the server
+    if early_stamp:
+        ts = _server_now(sess1, env, env.testname(t) + b"_clock")
+        env.sleep(.1)
     res = write_file(sess1, fh, b'z' * size, 0, delegstateid)
     check(res)
-    env.sleep(.1)
-    ts = _server_now(sess1, env, env.testname(t) + b"_clock")
+    if not early_stamp:
+        env.sleep(.1)
+        ts = _server_now(sess1, env, env.testname(t) + b"_clock")
 
     held = _deleg_times_return(sess1, env, fh, delegstateid, ts)
     after = do_getattrdict(sess1, fh, _STAT_ATTRS)
     res = close_file(sess1, fh, stateid=stateid)
     check(res)
 
-    if compareTimes(held[FATTR4_TIME_MODIFY], ts) != 0:
+    # A server may ignore a proxied time_modify that is before the file's
+    if not early_stamp and compareTimes(held[FATTR4_TIME_MODIFY], ts) != 0:
         fail(f"delegated time_modify not applied: {held[FATTR4_TIME_MODIFY]} != {ts}")
     _check_stat_same(held, after, "after DELEGRETURN")
 
@@ -748,3 +755,14 @@ def testDelegTimesReturn(t, env):
     CODE: DELEG28
     """
     _testDelegTimesStable(t, env)
+
+def testDelegTimesReturnEarlyStamp(t, env):
+    """Attributes seen under a timestamp delegation survive DELEGRETURN
+
+    As DELEG28, but the delegated time_modify predates the server's WRITE
+    stamp, as when a client stamps on write(2) and flushes later.
+
+    FLAGS: deleg all
+    CODE: DELEG29
+    """
+    _testDelegTimesStable(t, env, early_stamp=True)

-- 
2.56.1

