Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C5843451A6
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 19:23:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781896987; cv=none; b=MO96t8kPqYTHOevdM7rl1Msf4mF9fBuQO+cfGAM4pSWuXP3ziSPbf9uGNP6Tvgcbl7AJXaSQGPCXFB02els6mSj+Kka8+2HutwcXLA8G6ef++WKbiGo0Zl4XN84RqajV0DlbUf6bUrzA071lxDPIa1rsRg+Wb/GT2XA1A86zIgk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781896987; c=relaxed/simple;
	bh=hL48Sqb3PN+5/GnQVmgGN4B+qzGq/F8MXjKfbo/tkYU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dNrboSDXQXNVyVPRcrnXFdhti6r27Gp6Hi7IjZRD0STlTDZH8FwcrWuABPDzlGOiMl5H4mOA4vrJ5qgqpIpxsQx7LVeAgoR41ks93nvS9WcMHhdXmv3OwEUZ/3hlgrOsUWD75G/uhkqxuXk+rpRre0P6zxTwaquryZbmH4DluVM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dmiwJDDQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dmiwJDDQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5C94A1F00A3A;
	Fri, 19 Jun 2026 19:23:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781896982;
	bh=ICgd9RfSsgVaV51EBp99Fwsu/ljvSwFs1HONy1wCsbM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dmiwJDDQxHqCTyLjVRP+ctPosOv5T7cVI4UVIU6NNzBDWOJHb+9jSVIkTVNgYGx15
	 kPRP9KXzPGrY/bzVnIBFR5aZ1jR1c8AZSqwSFjzdcKdub4ddhf7IdnZ+KODLUieQhd
	 ZhTV8sc85On3RTolTbe46pi4UVRXxJbVo5qHa5J/tPNYUkYOGujzv9PhcuAFerv4Fh
	 v98jM6H+qinHeA8S6aA/o7Bi22VGz+5AOlbUWyItpWCvIoNuEP0YX0xokN/JUgyMCu
	 t9VhhznOwxzYMMEzTokUfZE++KH7oj80xEKNADozCuncy559dvVHE9pkq9bwubt6W7
	 +ttWgjcvImtFg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 19 Jun 2026 15:22:38 -0400
Subject: [PATCH pynfs v3 19/26] server41tests: verify filehandle in ADD
 notification
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260619-dir-deleg-v3-19-1077ce8aab1b@kernel.org>
References: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
In-Reply-To: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Scott Mayhew <smayhew@redhat.com>, 
 linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2761; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=hL48Sqb3PN+5/GnQVmgGN4B+qzGq/F8MXjKfbo/tkYU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNZb8hOiD/FOzytRIWPMufqGnFIjTza1V1rtZy
 U7HhbaZoDyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajWW/AAKCRAADmhBGVaC
 FY45D/9ZFtc9pXRA7IY4F67BX5cU6y1Ss9BH7cNBuLkaFXnJqWCUXtP0q/0Nt4lWeSQQ70bb56z
 b4fPMam5jVFQK1+D/SRfLS7I5K8DWTYwNev2eMMqTRRWqjEURFxAg27Xl6028Xku+QOmFKR26xJ
 Hs+YPlO1kovNDsMxlsTThy5YtjyNiDz52k+aioRbEzNK5F65nUZLzqIfovtIiVHDl0qslw+gi/2
 x+06/Qw5FkQw7zq5nWn4qm12ZGbq+jKrghYqmVUUVm1L3fo3/gsQbO3Ua7t9FdKqViLrWarydYq
 O0226RPa6BFg74EFuTH7O931U4R8DSjQrP1hyPtEmcEq3EzHyGo9p+KrqLipr7r5Uzmk2FFJS/9
 Yeakz3gzSGlL+afKiHFDWSEg2MHc+AiZ0d5Bm0LGjSyefQnW/GxzW+6xDmcocSIKb1L4evKK+L7
 GRdTWhHQYwvuwjevqtkQ/3aSK6ehD2hmulvbC5oaDuMUdqqsWiKol4xXOoOJaAGBKBQJjxwbZX6
 jd+FmICVENytmT2TAqoye2bOA+2ATJ9PFKHjTl35DiGic1yHh7Gl4mTzf/gCp/FlzflL8mgYO6P
 jSlwpwm9ZFbqKYf+uVPUYBNfPSHv1H2tskYCDz3QzB3dDQYWtk2Nec3UKqAAH7TtUy2jhJK1lwI
 ZeEExOys9Q7eg3w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Request a dir delegation with ADD_ENTRY notifications. Create a file
from a second client, recording its filehandle via GETFH. Verify the
ADD notification includes a filehandle attribute that matches.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_dir_deleg.py | 51 ++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/nfs4.1/server41tests/st_dir_deleg.py b/nfs4.1/server41tests/st_dir_deleg.py
index c4778da61dcd..5d7c1a8fbaca 100644
--- a/nfs4.1/server41tests/st_dir_deleg.py
+++ b/nfs4.1/server41tests/st_dir_deleg.py
@@ -687,3 +687,54 @@ def testDirDelegReturnStopsNotify(t, env):
 
     if cb.got_notify or cb.got_recall:
         fail("Received callback after DELEGRETURN")
+
+def testDirDelegFilehandle(t, env):
+    """Verify filehandle in ADD notification matches GETFH result
+
+    FLAGS: dirdeleg all
+    CODE: DIRDELEG16
+    """
+    c = env.c1
+    cb = threading.Event()
+    sess1, fh, deleg = _getDirDeleg(t, env,
+                                     [NOTIFY4_ADD_ENTRY,
+                                      NOTIFY4_GFLAG_EXTEND], cb)
+
+    sess2 = c.new_client_session(b"%s_2" % env.testname(t))
+    claim = open_claim4(CLAIM_NULL, env.testname(t))
+    owner = open_owner4(0, b"owner")
+    how = openflag4(OPEN4_CREATE, createhow4(GUARDED4, {FATTR4_SIZE:0}))
+    open_op = [ op.putfh(fh), op.open(0,
+                                      OPEN4_SHARE_ACCESS_WRITE | OPEN4_SHARE_ACCESS_WANT_NO_DELEG,
+                                      OPEN4_SHARE_DENY_NONE, owner, how, claim), op.getfh() ]
+    res = sess2.compound(open_op)
+    check(res)
+    open_stateid = res.resarray[-2].stateid
+    file_fh = res.resarray[-1].object
+
+    completed = cb.wait(2)
+
+    delegreturn_op = [ op.putfh(fh), op.delegreturn(deleg) ]
+    res = sess1.compound(delegreturn_op)
+    check(res)
+
+    close_file(sess2, file_fh, stateid=open_stateid)
+
+    remove_op = [ op.putfh(fh), op.remove(env.testname(t)) ]
+    res = sess2.compound(remove_op)
+    check(res)
+
+    if (not completed or not cb.got_notify):
+        fail("Didn't receive a CB_NOTIFY from the server!")
+
+    evt_type, evt = decode_notify_event(cb.changes[0])
+    if evt_type != NOTIFY4_ADD_ENTRY:
+        fail("Expected ADD notification, got %d" % evt_type)
+
+    attrs = evt.nad_new_entry.ne_attrs
+    attrs.attrmask = bitmap4_to_int(attrs.attrmask)
+    attr_dict = nfs4lib.fattr2dict(attrs)
+    if FATTR4_FILEHANDLE not in attr_dict:
+        fail("No filehandle in ADD notification attributes")
+    if attr_dict[FATTR4_FILEHANDLE] != file_fh:
+        fail("Filehandle in notification doesn't match GETFH result")

-- 
2.54.0

