Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBD57347BD9
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 19:22:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781896978; cv=none; b=bqrmWd9gT/JseGU5fR/QKtWp1aNq0c2SrgEiOHc60zqWusGSumB0FLvJEa2E41PvfrX0sEEpko2RNJsYFJBc5CfiN+O608cgh679iW9/WruDsyaGZht3rMdpyYE53rzxSik3F5NkxHW23sd4ElDsGx8IXjQ+Lp5s5kkSl5DSVoU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781896978; c=relaxed/simple;
	bh=PH/MCE8DV7ZLCGiCCfxKvH3qzQKQ81Xw1fbkm86c02A=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MxQPlgxoQ4dkHUmznlS0Ot/Lua6T1stgHBwngFklhUCWFyR9wGFxUu4d/D8o/gy7VN5KO5i+iLs4lCSSDqqlo0IyBTND9nYofa1dwEM7qq+qa8M0hVfhnAm+vEIDlDnxcOZkzyFC3lTXGQR9MH5QniSjEG5zWlSZUhK47Z2h0Cw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cL0Uf5mG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cL0Uf5mG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9F1B31F00ADF;
	Fri, 19 Jun 2026 19:22:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781896971;
	bh=fKXzlHGQVGGnqZ1OInLvKropPmhDqdd5g0cRF9RPPx4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cL0Uf5mGsxWG9iDjitO3CJ3eaX6l32cW4kRmIyZVQTjuUJZkuz1l3bUulx4oJGuKj
	 5f9QdmyOX7+6/uxYM9aTXBhuGTm2r/qGm2uxaBVQu9vIu0cLdc3iCUDpRiPviIHfJC
	 rU3BmTxxBRiatBvUwG/7i/MHwG8GGOlsACVt8bu6KcOrKPSCYxwg9E4ZzgvtC+nixN
	 Xi3o9VYLDz5gpT2Ya+j72l+0Heohcuof95jIUr9UTSfJII6/sIJchu3fowXX6WVUCj
	 EjL7lq01GxgiUFW3/caXWbuztpkAH1YKXtfvlYWBgozW19rwOtSbUJoZPkm8LI+UiU
	 WZtHJ9Re3QjGw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 19 Jun 2026 15:22:29 -0400
Subject: [PATCH pynfs v3 10/26] server41tests: test no notifications
 without GFLAG_EXTEND
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260619-dir-deleg-v3-10-1077ce8aab1b@kernel.org>
References: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
In-Reply-To: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Scott Mayhew <smayhew@redhat.com>, 
 linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2159; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=PH/MCE8DV7ZLCGiCCfxKvH3qzQKQ81Xw1fbkm86c02A=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNZb6BJbBN2a5InU1jZvOgKbUjv4rp5c/bM5em
 QfTiSJsxcSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajWW+gAKCRAADmhBGVaC
 FeZHD/9oeDnOKfZBoWTI7Wx0RwDzQKHLvv26rqvPISbzers31pr9hnyPVDs2Le42JU1H8x4GkOE
 ceBYrYFDRaqHr4oW9SL5cTPwMctI9HgrvkXyKga7lklJg6ZArOHlM5fs0BXaIZebYC3Yv5ddnXs
 0Fxwa3xEY3S8GcIkgHmASw3VNWRjYuy+2rBMgBugK6p51XhjvrAtVd9OcBzR+2m2hJR40M4HWhy
 ipe46ATMmI3n0FgZnYAH7MJz/LH/6m/0ufQm+/xUiFIz+8MD7L4pIWJxN9k+n1ExxNRJT48dmS/
 oFXjTdh3fZVKLkBBQk7oyWSclgypMxFGuICAJ81ZuLoNIvEgYCSXq3ag2FQzthVDxXQSaUANlrz
 znVJGAkgS9I1dbywnBafjt3aaPliv5yYM9uas5302x7L34gnc7e7rfb6leMbbLYKscTtAeSM6UF
 zzY6l2e6a/Qh+hZvordY6H6r4+sdSgPQxfVDP7n20OPLznYdeQtIsYtO3eGh62kHcFVUWI3eC5g
 kDCIGljgma6NNHyGez2/GyqfLQ+QY1mQ9Jq7rNVVfbWGol3AXSAd7DL9MfqSFoXvC/tmKgeopU1
 Zy0sKTJtbGr8dBzBhz/X7KTdQ/KDwoVZ0mbEJNFaY2SZv9OUUMU4Y/0zYjEhMFJyTlxMga5e3ng
 A8xMo9mgp0+R7xw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Request a dir delegation with NOTIFY4_ADD_ENTRY but without
NOTIFY4_GFLAG_EXTEND. Verify the server issues a CB_RECALL
instead of CB_NOTIFY when a file is created.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_dir_deleg.py | 37 ++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/nfs4.1/server41tests/st_dir_deleg.py b/nfs4.1/server41tests/st_dir_deleg.py
index 008e45d4cf64..4afcc40f515a 100644
--- a/nfs4.1/server41tests/st_dir_deleg.py
+++ b/nfs4.1/server41tests/st_dir_deleg.py
@@ -278,3 +278,40 @@ def testDirDelegLinkRecall(t, env):
     ops = [ op.putfh(fh), op.delegreturn(deleg) ]
     res = sess1.compound(ops)
     check(res)
+
+def testDirDelegNoGflag(t, env):
+    """Verify recall instead of notification without NOTIFY4_GFLAG_EXTEND
+
+    FLAGS: dirdeleg all
+    CODE: DIRDELEG7
+    """
+    c = env.c1
+    cb = threading.Event()
+    sess1, fh, deleg = _getDirDeleg(t, env, [NOTIFY4_ADD_ENTRY], cb)
+
+    sess2 = c.new_client_session(b"%s_2" % env.testname(t))
+    claim = open_claim4(CLAIM_NULL, env.testname(t))
+    owner = open_owner4(0, b"owner")
+    how = openflag4(OPEN4_CREATE, createhow4(GUARDED4, {FATTR4_SIZE:0}))
+    open_op = [ op.putfh(fh), op.open(0,
+                                      OPEN4_SHARE_ACCESS_WRITE | OPEN4_SHARE_ACCESS_WANT_NO_DELEG,
+                                      OPEN4_SHARE_DENY_NONE, owner, how, claim), op.getfh() ]
+    slot = sess2.compound_async(open_op)
+    completed = cb.wait(2)
+    env.sleep(.1)
+
+    ops = [ op.putfh(fh), op.delegreturn(deleg) ]
+    res = sess1.compound(ops)
+    check(res)
+
+    # Reap the async open and close any file it created
+    res = sess2.listen(slot)
+    if res.status == NFS4_OK:
+        open_stateid = res.resarray[-2].stateid
+        file_fh = res.resarray[-1].object
+        close_file(sess2, file_fh, stateid=open_stateid)
+
+    if cb.got_notify:
+        fail("Got CB_NOTIFY without GFLAG_EXTEND")
+    if not cb.got_recall:
+        fail("Expected CB_RECALL without GFLAG_EXTEND, but didn't get one")

-- 
2.54.0

