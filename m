Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9AD04EFFD4
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563712; cv=none; b=VmNpLBKtyjE0TtKsawUvSQIDys0GxzWCOj9AqnBsD5rFW9zzDKib8unbQW9Bvoe4y2dtHrgJR/LGSja5FQYxZhoJrgCMMtNozn0uKx2NLDXH0KY2AtEKy0OIwZS81HoLjMiEfcxAuSNEe+tkmYii+dK0Aa6LuVQEwOMAlNT9t+s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563712; c=relaxed/simple;
	bh=mmrOPpwNuRRwN23HYRgOW9br4eI3+lc8x4eTzUjgviE=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=fkOZ10JSuO38Hf8eZO06OdxhcludvsUrP34oe4dvZ1mPlFjxXOvEKOiY4G9ThByQrtrkqGtGthYpG/BuKbYq6wuNxWxpaUZEH6uz8lMZ1RkWEyhuhTLZHoNp7aDakzUzYqWP4yuMmLnCFQW8iirrwWwuzRIqbHUcMxNvDJUv04M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N2nEJx34; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N2nEJx34"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA9A31F000FF;
	Fri,  9 Oct 2026 16:35:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563706;
	bh=O149LhRUze0l9fxnb0YRPYndx17W+cgyrCq861ZeJVQ=;
	h=From:Subject:Date:To:Cc;
	b=N2nEJx34dqGWptJHB3gWNfJnUYuzKYlsEotjda6CcOKD9dGVHhf7kgWMMwgYtF9v1
	 dRs0BaE3IFiTAm144zEAiDu5+k7d9NKWULogO9t66E6CrCaAv8+pi4C4KLRbnAZeGk
	 KsbyHIxxX8K5loJtKD8LVIGMa/K8/ueGzb7A1GmyDno3i8Uvp8K8BQRCW4vvra72n+
	 jFswFrAeayWTS086W5dcW89Y3AQol04hjUuY8EHQu27LObaJ9PJFOSVtsNBRJyMccB
	 nOrultcWpFM+9flyHBaLG85yJEqA6pF3TSeiRA4GOTmTBjwpF3p4urM9UXzMmSSd4o
	 /8R/9q0s1GIoA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH pynfs v3 0/9] pynfs tests for setting ACL+MODE
Date: Fri, 09 Oct 2026 12:34:54 -0400
Message-Id: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQ6CMBAAv0L2bGOhQdGvEA9t2cIaackuGg3h7
 7Z6nMlkNhBkQoFrtQHji4RSzGAOFfjJxhEVDZmh0c2p1rpT1j/UnAZUwXjT1rrz7eUMOV8YA71
 /qx6WTwwCt7+Wp7ujX8umhM4KKsc2+qmoxDRSPM5WVmTY9y/QIYlRkwAAAA==
X-Change-ID: 20261008-acl-mode-f3c35108c597
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3234; i=cel@kernel.org;
 h=from:subject:message-id; bh=mmrOPpwNuRRwN23HYRgOW9br4eI3+lc8x4eTzUjgviE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRewHmQEvMO0aWdYQwQFuELq1AnBpulIsjpaE
 usDklSEtqCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXsAAKCRAzarMzb2Z/
 lzZqD/sFn/PYKgPcKnbZZsZqaE74gqAfEnC2UyFEAH2CMFaPNCrBRbkT5Ixvp/dCxIgz+Ct6Fr4
 Gd/6Ngdkcx6ZNoSleY6ry9soHuS5iZhRB935uz6S/7unxtuA/oYmiAinv+5Oa2vJIpFZCKrfsR9
 IQDZL7alXoYGF/8LJEEw9rq8RtAVmRbzriiGojVYyOfGLf+jd4aGE4qnQPAPK6eZjUItW2rbJRz
 B2i/cMq6lhNzs9iVi17jHQpCH3R8RVoTaeAYYgSxdp0R/1Zly6qpaWflv4zVONnaQjjUMUvT3Hq
 /ahEWcjaiusw4JFHanrsAF0bdEuZVn1+slKtgrsw4Z9Y6JWFeySH1VZKhNROcvgQjQHDzzf30Dw
 FTt10Qln5J3fWznRCXbeqrIZ4DGW04+gZJAC0rIGhB97OMJeBRQE/Ai5LYb+wHOU/GvrpgNFLtG
 gPso99SiiXztvQipVBK3jZ8uAbn/Xlu5tn+SOx/G52SneuT3Da8AOr6ghbi3sEjuVTPdYgr93qY
 HcG0xpde5F3EsN/GRjMkg6iN9eJDjidBYEQ7ct/cBFc3Y36UI5Y8h6R2ZlGEa6oD9qqsfm+cVyA
 61FUkNVebw5Or69uXUpLQMXSQJAxYEFRsLiERigrWA1mBYg86naT5BzH8K6aPhYN+zPsa1U/6v7
 2aPLzf+h2irMOsA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

There are plenty of corner cases when an NFSv4 client requests
setting an NFSv4 ACL and POSIX mode bits in the a single SETATTR
request. It's even worse for NFS server implementations that have
to translate NFSv4 ACLs to POSIX ACLs.

Note that the in-kernel Linux NFS client itself does not support
NFSv4 ACLs since Linux is a POSIX ACL ecosystem. I believe it will
never send an OPEN(create) or SETATTR that sets an NFSv4 ACL and
mode bits simultaneously, relying on only user space tooling to set
the ACL. So we must depend on only pynfs for testing this particular
NFSD facility.

pynfs didn't have many tests in this particular category when I set
out to troubleshoot a recently reported ACL+MODE bug in NFSD. So
I've written a handful to exercise this specific case.

Claude and sashiko review found a number of issues in this old
series. Resending with fixes.

---
Changes in v3:
- Compare ACE who fields as bytes in acl2mode_rfc8881(), make_test_acl()
- Run testMixed's RFC 8881 mode check before pass_warn(), which raises
- Compare ACE flags in verify_acl()
- Let verify_acl() skip ACEs the server inserts before requested ones
- Let verify_acl() search past a matching ACE whose mask falls short
- Derive the expected mode from the requested ACL, not the returned one
- Fold SATT20/21 into SATT19 and drop the pass_warn() that always fired
- Require MODE in attrsset in SATT30, as SATT19 already does
- Mask the mode with 0o777, not 0o7777, in SATT22 and SATT30
- Warn rather than fail on the SHOULD clauses in SATT29 and SATT32
- Fail OPEN12 and OPEN8b when the REQUIRED suppattr_exclcreat is missing
- Verify the whole ACE, not just who, in testSetattrACLNamedPrincipals
- Fold OPEN9/10 and OPEN15-18 into OPEN14, which covers all create modes
- Rewrite the OPEN(create) patch description
- Correct the SATT30 item and test list in the SETATTR patch description
- Link to v2: https://lore.kernel.org/linux-nfs/20251125194936.770792-1-cel@kernel.org/

Changes in v2:
- De-duplicate code shared between NFSv4.0 and NFSv4.1
- Remove named principals tests for now
- Replace incorrect usage of binary strings
- Add missing patch descriptions

---
Chuck Lever (9):
      Add helper to report unsupported protocol features
      Add helper to format attribute bitmaps
      Add a helper to compute POSIX mode bits from NFSv4 ACLs
      Add access_mask_to_str() helper to nfs4.0/nfs4acl.py
      Add make_test_acl() helper to nfs4acl modules
      Add verify_acl() helper to nfs4acl modules
      Add verify_mode_and_acl() helper to nfs4acl modules
      Add tests for SETATTR with MODE and ACL
      Add tests for OPEN(create) with ACLs

 nfs4.0/nfs4acl.py                   | 193 ++++++++++
 nfs4.0/servertests/st_setattr.py    | 728 +++++++++++++++++++++++++++++++++++-
 nfs4.1/nfs4acl.py                   |   1 +
 nfs4.1/nfs4lib.py                   |   8 +
 nfs4.1/server41tests/environment.py |   3 +
 nfs4.1/server41tests/st_open.py     | 463 ++++++++++++++++++++++-
 6 files changed, 1392 insertions(+), 4 deletions(-)
---
base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
change-id: 20261008-acl-mode-f3c35108c597

Best regards,
--  
Chuck Lever

