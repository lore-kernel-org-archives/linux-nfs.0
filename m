Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F06A43FD29
	for <linux-nfs@vger.kernel.org>; Thu,  9 Jul 2026 19:02:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783623772; cv=none; b=EAkUiiBPUjjKy8LWdZ6UC+TyxaIWAvCpJ89KPAhNBCwukQ6I3sS6xoR08HAMYkoGAm9InZ3Xz6PR84rmJw3EPgTybzphSOmG76vq7YusYBYoHNmJMKaAYg7YKoEsCX1K4n90dkn2DznjZTskaCNHEsLE976PuXdUvLpjOJreXNo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783623772; c=relaxed/simple;
	bh=T/R8pnmMWGvctonmrBsto0yOvvlSPXFeomVdFybnhWs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=P5LUJ22M+aWtDB2593SJY/azaFOG5oDK8wPzXL1mHDW13fvIIHBT7dU40fb3y2IBgXaIDBU43/n44l3PeFad2HSJdqi2KOt97W0f2T1LR2Pvw4BZOMDIiOZZ8+TC6r3wWQgdZ47cxOloJaTj0A2N/gC6tYImzkmqp7621m2yPtI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JD9EX3FK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JD9EX3FK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D4A01F00A3D;
	Thu,  9 Jul 2026 19:02:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783623769;
	bh=HboVW+NjNdpEea21akfprCAJMjCI4/lALMIDhEy3xDs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JD9EX3FK5QRWUVdEChyuPgT/1GnO33hRBSK3Xe937ko/JbJN2o34aCklEIg/0mco4
	 LLdcxbRIv5/aJXc4NSPKb/CY5+eYzB+7ocih0cpn8fMCHZnRxpOdrsFk5dnbnD/A8Z
	 0J+48lPQHWgQbYMDXevkF6jPVqw6TNDdeBswwqCD+IyQcvTJLJrJh5TopShXPIaymj
	 a6BnRemGixxx+oL7C7T1JLR+hPMpoMq/1VQDp46fng9zeh2CVJOBh0z/LgfsR5NxZZ
	 OkBSZADyLMIemx9WczAXVCuNRtLyb20xcvsG/FEPXbLTMgGWY4sOv+ivFtjgCFvau5
	 kN4JP9NvkV9oA==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 09 Jul 2026 15:02:31 -0400
Subject: [PATCH pynfs 03/13] server41tests: test async COPY with
 OFFLOAD_STATUS polling
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260709-copy-v1-3-849bf581d7cb@kernel.org>
References: <20260709-copy-v1-0-849bf581d7cb@kernel.org>
In-Reply-To: <20260709-copy-v1-0-849bf581d7cb@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2366; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=T/R8pnmMWGvctonmrBsto0yOvvlSPXFeomVdFybnhWs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqT/BS/mzQ+zxycWOzWedcBJXZhdLZJCeItn8t6
 9yKiwSVQoGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCak/wUgAKCRAADmhBGVaC
 Fd5bD/970CqufaOUrybtZXh4uXGjCdv5zvziJjlJ29j+Ns2tfauIgMFcYYYHCkrLqLPlKJIeJqh
 yoX7Hc2faVsHoqPdFbvO55S/3Dr0Eh2IFRsqoHIxbmkesszu+t3HLJFHFv3UU74HtiRUGqmqotu
 Lx3/lnoxLhOtQldh/Qu6D9myUJK6T50ga+2fMT/cu3F2OXwhIoj3PxtcrOjpsgaBFXzL/Z7r7cS
 azf90A8vVaYmprmReHWeU1RERUsZUoEE8oAizh6X9yklL/lW7aZ883Y+BfgKVYwslsfZ96T2Rlk
 pzvwvtzZ1eFOLvi/RQJ4VhTALkCbUdxhAKg4ytZGbSk7/vGLv+Ah4kf0stQkWFOE0Hgnei3xv0/
 bPaL34IX4hTbu7GsRfcS3ahMB2+wEuIJ2wrIiktBRqsosl3p1JHUWvP8mBXQqdDYXe1f5bjG3Ph
 EXmPNrQBytWQ6WypkXvHexl2427C7SvjVILc5dcI22OrF8BLwYtVYYQG7LJ2cgAclRIFJuqWj2/
 7ofL8VE38LNfWGcI+M1/dSErD4E2n26noEnnYdOnwA9Pex8QKX7NSPl59DACrCSI5hMfn1by205
 mBgOg8zcD2wAif1tQFFHD/KHk+R9eV6c60y0xlM2crxsdLxcs7yE2Z9JWw5A0IbSxUQc2QMUFBx
 FlfLiHYXhPteHrw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add _poll_offload_status() helper that polls OFFLOAD_STATUS in a loop
until the copy completes or a timeout is reached.

Add testAsyncCopy (COPY3) which writes 1MB to a source file, requests
an asynchronous copy (ca_synchronous=0), polls OFFLOAD_STATUS until
completion, and verifies the destination file contents.  If the server
chooses to perform the copy synchronously, the test still verifies the
result.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_copy.py | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/nfs4.1/server41tests/st_copy.py b/nfs4.1/server41tests/st_copy.py
index bfc64bbe1584..8c320173db1f 100644
--- a/nfs4.1/server41tests/st_copy.py
+++ b/nfs4.1/server41tests/st_copy.py
@@ -122,6 +122,39 @@ def testCopyWithOffset(t, env):
     if res.data != b"B" * 4096:
         fail("Destination data at offset 512 does not match expected content")
 
+def testAsyncCopy(t, env):
+    """request async copy, poll OFFLOAD_STATUS, verify data
+
+    FLAGS: copy
+    CODE: COPY3
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    src_fh, src_stateid = _create_and_open(sess, env.testname(t))
+    data = b"C" * (1024 * 1024)
+    _write_data(sess, src_fh, src_stateid, data)
+
+    dst_fh, dst_stateid = _create_and_open(sess, env.testname(t) + b"_dst")
+
+    res = _do_copy(sess, src_fh, src_stateid, dst_fh, dst_stateid,
+                   count=len(data), synchronous=0)
+    check(res)
+    cr = res.resarray[-1]
+
+    if not cr.cr_resok4.cr_requirements.cr_synchronous:
+        copy_stateid = cr.cr_response.wr_callback_id[0]
+        status = _poll_offload_status(sess, dst_fh, copy_stateid)
+        if status.osr_complete[0] != NFS4_OK:
+            fail("Async copy completed with error: %d" % status.osr_complete[0])
+        if status.osr_count != len(data):
+            fail("Expected %d bytes copied, got %d" %
+                 (len(data), status.osr_count))
+    else:
+        if cr.cr_response.wr_count != len(data):
+            fail("Sync copy returned %d bytes, expected %d" %
+                 (cr.cr_response.wr_count, len(data)))
+
+    _verify_data(sess, dst_fh, dst_stateid, data)
+
 def testZeroLengthCopy(t, env):
     """test that zero-length copy copies to EOF
 

-- 
2.55.0

