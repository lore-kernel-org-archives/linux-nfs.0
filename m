Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79C753446AD
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 19:22:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781896981; cv=none; b=XKcH0ZiSuEkzYdnE6uZN1DbJeQ6FRiI15F8Z768euV2GoAa4uUOC7IDRayfwCcmDFUd61M5NH/vmksfXowPU1Ez8fSkz2om/lloaRJdghRjNC9DQHyRpRzXmrmn3NMEtFZdrG9W6A5hp4XtVRxLr7ERDKXCzDsU/AtVsiCDl7M0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781896981; c=relaxed/simple;
	bh=BxNCqqO60sZZPhkEyBi/1B4Zt1N+PhuaNllES/H9tIo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pLo4nuUHvAzXSqzRigILrbGhqgJqc78wGWLTllsycwUzwv4z/U28kQWCJjIQjW1odj0P+e3kMbHK9hgy6LKVoqnn0VNGygf5z4TuMHJf1Qm0d2m4EWN5tjMb/PaKch6NkALVCS41VvGlbx0u0P/x6FhEMUyuCEesP3KvtVcr/sM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hqiQMpsC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hqiQMpsC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 676301F00A3F;
	Fri, 19 Jun 2026 19:22:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781896976;
	bh=DgMpRbmKR7P3SSTK2+tzmrQP7DHfXHe3usj5h291eFc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hqiQMpsC1l0UiAsrmJNMhyTI/jHBo1enU71nNF6TiDg5obwGBkQMuAJOUVsYgU+Xb
	 kckVM+AFPdBHE0MNvK8jm7fyoSy4Zz3IF9NcRE7nnbt2LaiZuMSC2nBaHF4lSAMAIf
	 hpUSvs2PLreq/R0IOM1nL2hEb4X/PMsoxvjGjhAvqkfFP9X3F5t0vE8/2onlse/95H
	 3AseVSpjUGYhqAdD+1WIggyaDVWLNv0IrG201m+fWTvksbEQYNupujB+Qs77ByRX9v
	 hIMOMaANnRXSxM1wvC2z+cOF67QB+SGSCfU3o5uKYAqPPnDFtC5F7r5q8155688pwB
	 bqxU1TvpijHqA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 19 Jun 2026 15:22:33 -0400
Subject: [PATCH pynfs v3 14/26] server41tests: add test for RENAME event
 notifications
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260619-dir-deleg-v3-14-1077ce8aab1b@kernel.org>
References: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
In-Reply-To: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Scott Mayhew <smayhew@redhat.com>, 
 linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2659; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=BxNCqqO60sZZPhkEyBi/1B4Zt1N+PhuaNllES/H9tIo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNZb70dfpUrdjfFt2GJGzVqjyMLb0OlmAbsWei
 idiSWoLsmWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajWW+wAKCRAADmhBGVaC
 FbomD/9k0Iawd0OjolxN3owUPETkJjG9VxvnYh4mAIiJBFffT6uFBp4RpsnqZxByyefFzzNzIoH
 Kcyziuq1SdSsIYPrvhDbjlD5VpUg4Ic5n70X+cKZULrmXFhW8utSywnaSfN+ch6uCyjhgOzjKZo
 cN8R8B2O6Vb8xOttlyTqZTIGl3nTISk1186QSrY9CH/uv41kpdn3Apohg6DYcXA+7jrzJlJVT2O
 uQYesLWtOEIuNEpt8kLSUYXOxA+HKH/tk0/U6CzR+CTenFf3VTqfK+vaeiU8NTYkM+pr0KmQ1YQ
 +uMOnTfqqLg77kEhd1aVVme9z2n4xMTGE+o+Z3MI79j36JjQOHAAfFxN61KCxTeRbHuQxwYaba8
 Ydchd0NtuRk8XQXsLp/DyCHl5X01mIa+mlvuHesJzF4FrN5exkxLFJWxm4wh7heEncrX2MFj7lC
 cZfioZ6FMgC2LXA8ZUD5yRzAcvkKrVWoDolHi/Ghg7RFj2lMY6LzBT+cFkmB2asqGXTUE0Oi82N
 YEbwkwzTqllO28Gwt4Cdq5AqIg9hnGUghWj4EbE9dTeQCRd5BvgThi+jA7qXvRwui2pQWwyuyQI
 Qfz+Xm1adfQ4JuT9eTxubOVfg47vkQjZm6IGNTTHP/Fr/kCMp2B8mBoTrtv8XtMdyQHwtzP9FsM
 HF6GwEyhSngfIkg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Request a dir delegation with RENAME_ENTRY notifications. Create a
file, then rename it from a second client. Verify the server sends
a CB_NOTIFY with the correct RENAME event.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_dir_deleg.py | 47 ++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/nfs4.1/server41tests/st_dir_deleg.py b/nfs4.1/server41tests/st_dir_deleg.py
index e906633a7972..00d74b2c7300 100644
--- a/nfs4.1/server41tests/st_dir_deleg.py
+++ b/nfs4.1/server41tests/st_dir_deleg.py
@@ -460,3 +460,50 @@ def testDirDelegAdd(t, env):
         fail("Expected ADD notification, got %d" % evt_type)
     if evt.nad_new_entry.ne_file != env.testname(t):
         fail("Wrong entry name in ADD notification")
+
+def testDirDelegRename(t, env):
+    """Create a dir_deleg that accepts notification of RENAME events
+
+    FLAGS: dirdeleg all
+    CODE: DIRDELEG11
+    """
+    c = env.c1
+    cb = threading.Event()
+
+    sess1, fh, deleg = _getDirDeleg(t, env,
+                                     [NOTIFY4_RENAME_ENTRY,
+                                      NOTIFY4_GFLAG_EXTEND], cb)
+
+    claim = open_claim4(CLAIM_NULL, env.testname(t))
+    owner = open_owner4(0, b"owner")
+    how = openflag4(OPEN4_CREATE, createhow4(GUARDED4, {FATTR4_SIZE:0}))
+    open_op = [ op.putfh(fh), op.open(0,
+                                      OPEN4_SHARE_ACCESS_WRITE | OPEN4_SHARE_ACCESS_WANT_NO_DELEG,
+                                      OPEN4_SHARE_DENY_NONE, owner, how, claim), op.getfh() ]
+    res = sess1.compound(open_op)
+    check(res)
+    open_stateid = res.resarray[-2].stateid
+    file_fh = res.resarray[-1].object
+    close_file(sess1, file_fh, stateid=open_stateid)
+
+    sess2 = c.new_client_session(b"%s_2" % env.testname(t))
+    topdir = c.homedir + [t.code.encode('utf8')]
+    oldpath = topdir + [env.testname(t)]
+    newpath = topdir + [b"%s_2" % env.testname(t)]
+    res = rename_obj(sess2, oldpath, newpath)
+    check(res)
+
+    completed = cb.wait(2)
+
+    delegreturn_op = [ op.putfh(fh), op.delegreturn(deleg) ]
+    res = sess1.compound(delegreturn_op)
+    check(res)
+
+    if (not completed or not cb.got_notify):
+        fail("Didn't receive a CB_NOTIFY from the server!")
+
+    evt_type, evt = decode_notify_event(cb.changes[0])
+    if evt_type != NOTIFY4_RENAME_ENTRY:
+        fail("Expected RENAME notification, got %d" % evt_type)
+    if evt.nrn_old_entry.nrm_old_entry.ne_file != env.testname(t):
+        fail("Wrong old entry name in RENAME notification")

-- 
2.54.0

