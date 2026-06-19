Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C4A934107F
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 19:22:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781896973; cv=none; b=rrlk5j3Nj0GDDzU37RoBeLhl0f52C0iGMxNicHvZeyO3yQkhxKEfQchqp2uMu7SV4rF0Mm8PwEeKtatqbJZd0Dpfyw6IX460J34t7dsipDFmOvMPPPNeZIyLtYsq4Q5bIOLBS0kKHwEOF7f0k8/kAp8IfwBFDFz+OtpZBcSEd+k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781896973; c=relaxed/simple;
	bh=9Y5wyPNM9nHmW0uxevgrqDPhGyreqSTj1VA0oF6muDs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=CuK4zcczfpgG3xgmAmlt14jwG2lUr2zc9TyXUSxGGaIh2pIhJi7kuEeahVTAiWv0/PTItazMrkTzqAhY7K7VWyfRaXX4Cd6mQ2A2kl1NKZqZ1T7br9ZAMqclc89tZJEjrsfozXNs7oJRH/jqaakB8JrEY1HZDp2VvoGJKcT5Lpw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Djq+J5Fi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Djq+J5Fi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D72171F00A3F;
	Fri, 19 Jun 2026 19:22:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781896966;
	bh=6dIcBSYYEPfBNbKWL/c+x/Su5RKHbkO08JW/G3SiRYk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Djq+J5Fi9FxhC+2/IGrDBT8HlKKkpaYuyiRLssWkfUA/TNdh1K9VM/N+0LACZMD9m
	 hoATKNvAH0PFyBuSJl90NRNDcNLJYGceCybaUTn4SAjWZ6BvFEmFX+GQWhUCvgzzRW
	 mnJqqP2Q69d5qnsnxZ4Ne1sz4Wi0GaKOTBjoZf1XaA7QC4DNpfXKjV1r2DjuIC7ZA0
	 zjli+LI3XWRzLkLYjMqD4jEp7FvqEkQKLfTfd5+pE4NJw9q0Ng8VPK6yfCl5s+5LCt
	 IoPx+f5AwwoZOIQHBqKyORo61W5WcCGkfu6yo0bM/OizbhpE1z2BvthhJBbqFLebNe
	 gUk1wCwuPTg8w==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 19 Jun 2026 15:22:25 -0400
Subject: [PATCH pynfs v3 06/26] server41tests: test remove triggers dir
 delegation recall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260619-dir-deleg-v3-6-1077ce8aab1b@kernel.org>
References: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
In-Reply-To: <20260619-dir-deleg-v3-0-1077ce8aab1b@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Scott Mayhew <smayhew@redhat.com>, 
 linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2372; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=9Y5wyPNM9nHmW0uxevgrqDPhGyreqSTj1VA0oF6muDs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqNZb5NepOl9FgPorWJuBDJGum52aj9y8FHP3na
 7Xxyu6WheWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajWW+QAKCRAADmhBGVaC
 FTg5D/9VypdPsPtSbtw5VFbOjj3yYtAdZGbgViecbh2XG3H2sDem4iMrjNNaSs0FNRo681WddTK
 2/JGHNZjA23/yhnxSO1SKF42HQrjQy2lgOE7MR7gXEBUPWlQH+3k7SjuiDDJKU4fNKIbJc1vc1v
 qWPdvGSmcY9w8MgHFuVIK129XPBWd0So0Sv2N27OwfnSDkRM0RB+rgI38EsnULdqG4vODIqdMKV
 /eDgGd7hsEoOXy7lnY1sMHxz0x0Mwlhykbc+u9HwpU/SmSKiMtrBflaNdqPW7OQTRNVYJU8R+bG
 QVZ9rbugXK88AXTnDymkoQJkv6+i80eEQlQwIFFKTeaOhvNW8sytzU8OFtGo/XsmcIC6sf1mHZb
 NWOZXuZJ5wAT23yZRhhTcc9KPFYuwQbwVRZQyw+MXHt0ydW4QJupGZgQt5723rS1GYdhU0bb6dW
 yMmFNjS0/OJYL2pzVnzfRB0AJVZnkOqGSYz7uFhaeZ1za3vnihwHFEEgICfSkvu3r2lun85TYm3
 T000kA6Rz7WLNge2/SdOhBGZAnhubEysphqjecNN35yQLLlusLv/0OR//wM9Nic3s9klcB8flqX
 pSFhdxpV3cy+r2ExSeFX6loOMKNElgFevcXV9Mij4sWH/lSCnZN9WyMwNWeem8A9GWmrwdiX3kb
 2RzAjVpnslr3Xaw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Get a dir delegation with no notification mask, create a file, then
remove it from a second client. Verify that the server issues a
CB_RECALL.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_dir_deleg.py | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_dir_deleg.py b/nfs4.1/server41tests/st_dir_deleg.py
index 5f46c08316e3..b2afc7cccb01 100644
--- a/nfs4.1/server41tests/st_dir_deleg.py
+++ b/nfs4.1/server41tests/st_dir_deleg.py
@@ -3,7 +3,7 @@ from .st_open import open_claim4
 from xdrdef.nfs4_const import *
 from xdrdef.nfs4_pack import NFS4Unpacker
 
-from .environment import check, fail, create_obj, use_obj
+from .environment import check, fail, create_obj, use_obj, close_file, rename_obj
 from xdrdef.nfs4_type import *
 import nfs_ops
 op = nfs_ops.NFS4ops()
@@ -148,3 +148,37 @@ def testDirDelegDuplicate(t, env):
     ops = [ op.putfh(fh), op.delegreturn(deleg) ]
     res = sess1.compound(ops)
     check(res)
+
+def testDirDelegRemoveRecall(t, env):
+    """Verify remove triggers dir delegation recall
+
+    FLAGS: dirdeleg all
+    CODE: DIRDELEG3
+    """
+    c = env.c1
+    recall = threading.Event()
+    sess1, fh, deleg = _getDirDeleg(t, env, [], recall)
+
+    # Create a file from sess1
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
+    # Remove the file from sess2 -- should trigger recall
+    sess2 = c.new_client_session(b"%s_2" % env.testname(t))
+    remove_op = [ op.putfh(fh), op.remove(env.testname(t)) ]
+    slot = sess2.compound_async(remove_op)
+    completed = recall.wait(2)
+    env.sleep(.1)
+
+    ops = [ op.putfh(fh), op.delegreturn(deleg) ]
+    res = sess1.compound(ops)
+    check(res)

-- 
2.54.0

