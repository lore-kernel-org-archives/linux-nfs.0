Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029412;
	b=mMKlkGw4O1h5tvwGIWIoWtXgKYhLvzNI0woJGYOoa17a2l5Z5lq+9i09EowYMrvbSFPk
	 KDU0l99gmSsspMpa2tt4W8TNz2yvbpaNG5+eAUw2IffNL5rtM7i2fp42ndnRHRv4EPLum
	 vqerLoilZI2U9Q+wlRjIHuSENQvFV5d23/p3tB25OIzMFqCTrYXKz74kOlhh5GhOkKfp5
	 TNWY0QI7fyX94BzWU5MeKzXl9EnbQ36Uk0vzaWZuAmKloM82nTGMKP9U6r0f/mOi4BUJr
	 YRiVu3N0KATT8Y8QhDViH494YPce4noSsKA0lRlC1Tao/q0+AO1aNjvcTeNxECOxh5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029412;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=/ztlEV23vB56CncnFIHrYgjsm2izfVvNk4FB8plQMl0=;
	b=LOVZZ52E9O6tiIasZRQ0PenK8ESXdRhMcEfki/+fTuZGZNbpsKnx+ZiPDRiLI9TR3gIZ
	 ei1fc4+baEJvP6Cf/XMWktqy9IZTHPmVLuS/dCZj0NYIKhH9pIJerUPC7VhcQqP1g9ozF
	 h+iFPSZEqfXI78veaPnWnOVsOHJyOdsgh991XpJBWctwmpTntyhZ8UPwCprExoA5I09G7
	 78562CqyCSU588GVCM1rZHkj9XTmPZAcAOktbOvZRlFGBr4G+dm4IikRbXrJN939+10fT
	 qv9GjBgKkAKswUYMzjC6E4vwtPN5nezWoWFBlPr/W721Us/rm5g/y50NN+9EkZHFwyw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XEl0JXlj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F34C60A2608
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XEl0JXlj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FB391F000C8;
	Wed, 18 Nov 2026 19:16:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029412;
	bh=/ztlEV23vB56CncnFIHrYgjsm2izfVvNk4FB8plQMl0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XEl0JXljwgkVPkcNmwnPaf2ZI26ppFvASRp0Ulqh0CclIuuizFPQlRfPuREb2EepX
	 Y0tfD75BpoMLhGr+QGs/C62TsW6+G0/S4235LO4kR4vLOx7JZOSnvQicWURrpyNe6h
	 9c0pC9zuoYerc+uR+L2nTXGoVXtfY9eEkqG55F28MSn9H3ZjshFu5GgQZ1F+qsztaL
	 b3dn3F8yIw2IpvESvhsABhxlmRQ2o1mhlc86OdmWW0Tznc/kdqs3oEws/+buXv6fyl
	 WpYBKIW/CzqjlH7At2Ng5fVsf4u+MwJy8NUVhnvOOR58Y+AchROwuQMtKf0/zmnm6j
	 vrhTqo2SIJ9Og==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 18 Nov 2026 11:16:43 -0800
Subject: [PATCH pynfs 4/6] server41tests: check that times seen via
 CB_GETATTR survive return
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
Message-Id: <20261118-delegts-v1-4-9bd252eea637@kernel.org>
References: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
In-Reply-To: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5826; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=oJBNfyFxwQH3Pl61veuBW5Ip272prQ1Drc0nrYcPbDk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmiJJ6IlEpWW+5/H/pydircNkf8NpDKDOHiX
 sFjT3fsZmCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35ogAKCRAADmhBGVaC
 FaH4D/4uzI/4KRS3oC75ftsDqU0jt6bHCDW+zv9N1UX7zJTDgfFH3OgxEDJoMuvPzs7H0wUOeH8
 Cozdyh0yvmSCycLHjfp10akrIF3doHsE5KVB8ZhkGa9nYwy+8uMMixeiBuPN3AJH8cpgPC7vnMi
 lg4+897wMR6jxy8VyTGRiWZImtNiz/TUMKKUBHRhH1ilkCwQq8tbXWY06nRmmUxOA3NVivweDB2
 pDpu6okPbYvkItyYUExD+vJ+Uh9lPZZCJwnsqa3WV5/gip+VvbiN/kbMGc+fkEdsWk/XwVMdQoi
 mowFWnY0mqXsI/Nxom/b7ufk/nhqRQj3rlZn3l8Cyrj+8qtWvv++dAVhIndZ2kEurTOYEFWzOLG
 ki/QRXxS+zfq9XtYpc4XfZalpRtReEWl8LKn1PfggRJAUIJD1j65Cs3KMyOf2L8s34YUAQLMybG
 x28J5kTTJ3wc6n9gov1WOteDOANqRKIZkAvtItJFejGXKNFApjJuHAcSbu/0Ce2Q/tmwTn+2Erh
 jd8mfpDeg9p/M3InF5+UGUdKMzoqqN+wkTlXsFpBu6U94S7QrQZO3uW1yQWIwbd5oSuKprocEa2
 QfvR2L1ICkXQEDpAIb9UHpNXa0mNtbBJhXV2C2Ys5v3A00+zkniC3brtu6aB75il2+lIqZ0kr6v
 ATcylYvTbcK64JQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

While a timestamp delegation is out, another client's GETATTR reports
the times the holder returned in CB_GETATTR. Those must not change
when the holder later SETATTRs the same times and returns the
delegation.

Add DELEG30: after the WRITE, have a second client GETATTR, answer
CB_GETATTR with an mtime after the server's WRITE stamp, then return
as in DELEG28. Require that size, time_modify and time_metadata match
across the second client's view, the holder's last GETATTR and a
GETATTR after DELEGRETURN. Don't compare change across the holder's
SETATTR, which replaces the server's WRITE stamp and so may bump it;
git's index doesn't record it.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 59 ++++++++++++++++++++++++++++++++---
 1 file changed, 54 insertions(+), 5 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 07f91cac58a9..8ab60929a1eb 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -665,8 +665,10 @@ def testCbGetattrAfterSyncWrite(t, env):
 # Attributes that a stat-based cache (e.g. git's index) records
 _STAT_ATTRS = [FATTR4_CHANGE, FATTR4_SIZE, FATTR4_TIME_MODIFY, FATTR4_TIME_METADATA]
 
-def _check_stat_same(before, after, when):
+def _check_stat_same(before, after, when, change=True):
     for attr, name in ((FATTR4_CHANGE, "change"), (FATTR4_SIZE, "size")):
+        if attr == FATTR4_CHANGE and not change:
+            continue
         if before[attr] != after[attr]:
             fail(f"{name} moved {when}: {before[attr]} -> {after[attr]}")
     for attr, name in ((FATTR4_TIME_MODIFY, "time_modify"),
@@ -674,9 +676,18 @@ def _check_stat_same(before, after, when):
         if compareTimes(before[attr], after[attr]) != 0:
             fail(f"{name} moved {when}: {before[attr]} -> {after[attr]}")
 
-def _deleg_times_open(t, env):
-    """Create a file and get an OPEN_DELEGATE_WRITE_ATTRS_DELEG delegation"""
+def _deleg_times_open(t, env, cbattrs=None, cb=None):
+    """Create a file and get an OPEN_DELEGATE_WRITE_ATTRS_DELEG delegation
+
+    If cb is given, CB_GETATTR is answered with cbattrs, and sets cb.
+    """
     sess = env.c1.new_client_session(b"%s_1" % env.testname(t))
+    if cb is not None:
+        def getattr_post_hook(arg, env, res):
+            res.obj_attributes = cbattrs
+            env.notify = cb.set
+            return res
+        sess.client.cb_post_hook(OP_CB_GETATTR, getattr_post_hook)
 
     res = sess.compound([op.putrootfh(),
                          op.getattr(nfs4lib.list2bitmap([FATTR4_SUPPORTED_ATTRS,
@@ -717,10 +728,13 @@ def _deleg_times_return(sess, env, fh, delegstateid, ts):
     check(res)
     return res.resarray[-2].obj_attributes
 
-def _testDelegTimesStable(t, env, early_stamp=False):
+def _testDelegTimesStable(t, env, early_stamp=False, observe=False):
+    cb = threading.Event()
+    cbattrs = {}
     size = 5
 
-    sess1, fh, stateid, delegstateid = _deleg_times_open(t, env)
+    sess1, fh, stateid, delegstateid = _deleg_times_open(t, env, cbattrs, cb)
+    attrs1 = do_getattrdict(sess1, fh, [FATTR4_CHANGE])
 
     # A client stamps mtime when the application writes, which is before
     # the WRITE reaches the server
@@ -733,6 +747,23 @@ def _testDelegTimesStable(t, env, early_stamp=False):
         env.sleep(.1)
         ts = _server_now(sess1, env, env.testname(t) + b"_clock")
 
+    if observe:
+        # No need to bump FATTR4_CHANGE because we've already flushed our data
+        cbattrs[FATTR4_CHANGE] = attrs1[FATTR4_CHANGE]
+        cbattrs[FATTR4_SIZE] = size
+        cbattrs[FATTR4_TIME_DELEG_ACCESS] = ts
+        cbattrs[FATTR4_TIME_DELEG_MODIFY] = ts
+
+        sess2 = env.c1.new_client_session(b"%s_2" % env.testname(t))
+        slot = sess2.compound_async([op.putfh(fh),
+                                     op.getattr(nfs4lib.list2bitmap(_STAT_ATTRS))])
+        completed = cb.wait(2)
+        res = sess2.listen(slot)
+        if not completed:
+            fail("CB_GETATTR not received")
+        check(res)
+        seen = res.resarray[-1].obj_attributes
+
     held = _deleg_times_return(sess1, env, fh, delegstateid, ts)
     after = do_getattrdict(sess1, fh, _STAT_ATTRS)
     res = close_file(sess1, fh, stateid=stateid)
@@ -741,6 +772,10 @@ def _testDelegTimesStable(t, env, early_stamp=False):
     # A server may ignore a proxied time_modify that is before the file's
     if not early_stamp and compareTimes(held[FATTR4_TIME_MODIFY], ts) != 0:
         fail(f"delegated time_modify not applied: {held[FATTR4_TIME_MODIFY]} != {ts}")
+    if observe:
+        # The SETATTR replaces the server's WRITE stamp, so change may move
+        _check_stat_same(seen, held, "when the holder set the times it "
+                         "reported in CB_GETATTR", change=False)
     _check_stat_same(held, after, "after DELEGRETURN")
 
 def testDelegTimesReturn(t, env):
@@ -766,3 +801,17 @@ def testDelegTimesReturnEarlyStamp(t, env):
     CODE: DELEG29
     """
     _testDelegTimesStable(t, env, early_stamp=True)
+
+def testDelegTimesCbGetattr(t, env):
+    """Attributes seen through CB_GETATTR survive the holder's return
+
+    Get a write delegation with delegated timestamps and WRITE. A second
+    client's GETATTR triggers CB_GETATTR, which reports a time_modify later
+    than the server's WRITE stamp. The holder then sets that same time and
+    returns the delegation. The second client's view, the holder's last
+    view and a GETATTR after DELEGRETURN must all match.
+
+    FLAGS: deleg all
+    CODE: DELEG30
+    """
+    _testDelegTimesStable(t, env, observe=True)

-- 
2.56.1

