Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59B6C4F30CE
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563711; cv=none; b=dOZTAsf76BgCpVQVXHi2QtnTbuWosZlKMRBUlEZEAi1ADD4+TOgvdwUwa/C0IA8ZPsjFylfMJEUgzAGvEFXTC8wq8su63KtCVRg42PhxZIGpmBrcUb90HoyTVxko/jpURYNr4KxU/xMsq5O2RhqFfpmpJceCAhisLOgbvbDD+q0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563711; c=relaxed/simple;
	bh=jMjWyO3pNuVWezeTo2bCy7hxdCJeVwofdXDUYYi/Hqg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UbQxOVIGGARuW+/+gr0Uvi+9KE8ulv0NsEdPvzPTxfMOJXFY2dNwOI+7HeLk0OON5RwDU9eLEmfdW/XwLMKMrd02LBfvQrUcy0pzWWHskKmpnVDNDI++Ayk7MHisASGHU/9SXB63p/oEerGPQZSZV0O8cdfXF2Suafor1LXLEyw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DY5P8nv/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DY5P8nv/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 67CC91F00899;
	Fri,  9 Oct 2026 16:35:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563707;
	bh=p7JGsSmw3JVxJPzKMMcuU4sIn+3I9mcV4IxZFfrwF+Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DY5P8nv//Wjx9OtU+JidfMLTICrbKFd7GDg4ogOdjuZ52uja6IS1z0udtoYwFeliQ
	 xEgs1lozgFhC2ExGSf/Em4tT2tauaFtpD/7MyhIgJnf8SzRo2hfYCVTnO15igyBLbk
	 cbdWk3cH9LeC5A6GI4zLWK/KEwm0fk2YL3F7mIniqG/YfvACqNXmYkemdO5UG6WM5G
	 i3k/lPXI8G0G9kx0O2P2BsFIvQkkQB3SVmQDMo3M0U8RmahvOiZqIxXEsf1MwmOfYs
	 /sxRm7AusCTvbsZlQCAWxMAHYIC4Ki/wyQgiwPkeXJ+TUFyxf94r1EzoDxToAhu+xh
	 iV0MkgWQ7O9+g==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:34:57 -0400
Subject: [PATCH pynfs v3 3/9] Add a helper to compute POSIX mode bits from
 NFSv4 ACLs
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-3-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3786; i=cel@kernel.org;
 h=from:subject:message-id; bh=i8rv74icUCeI7R0DgJt/MoyWMxMD22yl+pLRuaBtd50=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5fvb9lr8lVinidTBSnvWo83SIfX1YaAFFZ
 /s6eKxEoiaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 l+etEACVYgL0qyRtm+qyX1BEyfvLwbzluMSrbGeiPyKeBqnM5nIg1PyC9l0c1wkp5ojZ0z7sNbu
 0b0t4T66axJvmeMo/sS1f5/qf867fC+72XcqU/BR2ortdaqG2nl6m2uk4ibPG+XgRqlTqnO7awy
 efea8gKxPRjlJQQQx8g7nwUHubVZ4qXyCBy12ZRlhkQ/JUF/wUaRtYmo2Jymib/Rvbi/wJyyocl
 +SUsYiRUQD4vnJ4hfyC/+lQco3r66fOgqTGVvUD75+wZuD2cBAMWgGfzfWSjKAy30adULyQp1gx
 k3AB2QthN9dlD5NY4pnO9wS+CPgRtSi4Ax5Us9cn64rhCvCa1SkTqZzLTQSnrkmDrJM5dFMe6I5
 8XA9xrS4KmT5L1bp2nWiR/58yaW4sA2IjOYoy3IJDRIgXLu26CdiUU1XyHIYVMQfNnS5Axr7WpT
 5VIQv6oQQ2XTaNovzhjzIkExRVPTzvNuhhWJprFKOX5S29nkxxE+AVS03MQxRQ7b1h2vUc+pR3E
 0MYMg5B/w+61eTpP7Xus3EO9ufSJGgeFnh8cO6Pdewv93HuJlVQx/RAr+HmyB2M6Kvs5WUILLRt
 6N13WRCZ2fVGFqBfjpOScgkLmaybEEHMmrMpiDXrY7fEs57buOq9yG81qAzRswYxAghLtrpzbMZ
 O5OTFcwlGzNU4nw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

NFSv4 servers are permitted to adjust a file's mode bits when
the file's ACL is set. RFC 8881 Section 6.3.2 describes what is
expected.

I'm about to add new tests that set an ACL and then retrieve
the file's mode to verify that the server is following that
section of RFC 8881. Mode bit verification is common, so it
is added as a utility function.

To avoid duplicating this code for both NFSv4.0 and NFSv4.1
ACL-related tests (I'm expecting to see a common NFSv4 ACL
document published soon), a symlink is added to make ACL
utility functions visible to tests for both minor versions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.0/nfs4acl.py | 60 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 nfs4.1/nfs4acl.py |  1 +
 2 files changed, 61 insertions(+)

diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 69e0d0bcfbe1..4b6ca4921162 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -208,6 +208,66 @@ def chk_groups(acl, flags, not_mask):
             chk_triple(mask, allow, acl[0], flags | GROUP, not_mask)
         del acl[:1]
 
+def acl2mode_rfc8881(acl):
+    """
+    Compute mode from ACL according to RFC 8881 Section 6.3.2.
+
+    For each special identifier (OWNER@, GROUP@, EVERYONE@), evaluate the
+    ACL in order considering only ALLOW and DENY ACEs for EVERYONE@ and
+    the identifier under consideration. Then translate to mode bits:
+    - Read bit: Set if ACE4_READ_DATA is permitted
+    - Write bit: Set if BOTH ACE4_WRITE_DATA AND ACE4_APPEND_DATA are permitted
+    - Execute bit: Set if ACE4_EXECUTE is permitted
+
+    Returns the low-order 9 bits of the mode (user/group/other permissions).
+    """
+    identifiers = [
+        (b"OWNER@", MODE4_RUSR, MODE4_WUSR, MODE4_XUSR),
+        (b"GROUP@", MODE4_RGRP, MODE4_WGRP, MODE4_XGRP),
+        (b"EVERYONE@", MODE4_ROTH, MODE4_WOTH, MODE4_XOTH)
+    ]
+
+    mode = 0
+
+    for who, read_bit, write_bit, exec_bit in identifiers:
+        # Start with no permissions
+        allowed_mask = 0
+        denied_mask = 0
+
+        # Evaluate ACL in order, considering only ALLOW/DENY for this
+        # identifier and EVERYONE@
+        for ace in acl:
+            # Skip non-relevant ACEs
+            if ace.who not in (who, b"EVERYONE@"):
+                continue
+            if ace.type not in (ALLOWED, DENIED):
+                continue
+            # Skip inherit-only ACEs (they don't affect current permissions)
+            if ace.flag & ACE4_INHERIT_ONLY_ACE:
+                continue
+
+            if ace.type == ALLOWED:
+                # Add allowed permissions not already denied
+                allowed_mask |= (ace.access_mask & ~denied_mask)
+            elif ace.type == DENIED:
+                # Add denied permissions not already allowed
+                denied_mask |= (ace.access_mask & ~allowed_mask)
+
+        # Translate permitted mask to mode bits per RFC 8881 Section 6.3.2
+        # Read bit: ACE4_READ_DATA must be set
+        if allowed_mask & ACE4_READ_DATA:
+            mode |= read_bit
+
+        # Write bit: BOTH ACE4_WRITE_DATA and ACE4_APPEND_DATA must be set
+        if (allowed_mask & ACE4_WRITE_DATA) and (allowed_mask & ACE4_APPEND_DATA):
+            mode |= write_bit
+
+        # Execute bit: ACE4_EXECUTE must be set
+        if allowed_mask & ACE4_EXECUTE:
+            mode |= exec_bit
+
+    return mode
+
 def printableacl(acl):
     type_str = ["ACCESS", "DENY"]
     out = ""
diff --git a/nfs4.1/nfs4acl.py b/nfs4.1/nfs4acl.py
new file mode 120000
index 000000000000..f05cb4015424
--- /dev/null
+++ b/nfs4.1/nfs4acl.py
@@ -0,0 +1 @@
+../nfs4.0/nfs4acl.py
\ No newline at end of file

-- 
2.54.0

