Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBCBD4EFFDA
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563714; cv=none; b=g2ky6xuJ3hjC+//CEnAY9H436OT27jH2aAGaX9mxCFRS2eg7WxK+aBYViSgOqKRJiL1HsfqKY8nK56iERHuvyKe4EhfcP68httPZt8N5d5Uvn5vdMLuATYdIPlW9AeCWskU3SVSDGYN4GAKONx6GzjgJPpeum1IAmkdRe2Hqo50=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563714; c=relaxed/simple;
	bh=uj5wpJT0KykO2bkeVLEkxeynfCNFg9bDO0ywJ6UadUM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AFMJbc29aX6rJoNKePRhPlUstE59q7QP+PDaJ0Ksc3ZVABZjfEii6ZK7zADpjlSBsjdnvyfKvo632GjmPsUvvaE9V+0U5UcWJ4AStumM1zOOpJoBdDwBDMTMzqVxSX1SC8hxt96iqv+4QXc8pXZMt5LGz6DGFGKpa9nrHI0FRaw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hQ1PQeEZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hQ1PQeEZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 08F4D1F0089C;
	Fri,  9 Oct 2026 16:35:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563709;
	bh=tiU27J9rrCIwQrP/as36GVRRt6hwf9Osik5KyXYL86k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hQ1PQeEZXQt3GxD/Da+8gHjX6XQNMn3K8SyOjGAD6OF4GUQ74Gns8QbJdzenbkZ/k
	 MGhiAutB8TOR/u1AMVBhcANxLFa6UuU2GIyAlXwYSaj+ZAlGgFKt5UtkFSCBJoEV4p
	 JohuG2A3G6WnGUhcrZ1Ufh7ce/hm2PUtN/f1SeNs9RxEyAru70rDRlPElyneB8bMqV
	 wz+K9y3Z/FVtBUYC2bVPbN/P84AchdEZEKWqOKWObdYQtsYZGuich/1lXb22tXEguH
	 aBu0mNnrUuxRgYo129N6lKBl4Lpkq2/gfVOPjvbVPXsruh++34P+kmAiLZyVV3F+5e
	 6Sj3XMg9CQBWQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:35:00 -0400
Subject: [PATCH pynfs v3 6/9] Add verify_acl() helper to nfs4acl modules
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-6-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3345; i=cel@kernel.org;
 h=from:subject:message-id; bh=qQSnCl6pyMII/jOISjkK5jb+y63jEO0Z2wYhzyeQwHA=;
 b=owEBbAKT/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5Eb1qD/trxuRPcn2IhCTwggR0Sj2K5sL0D
 izvk8p5Q+uJAjIEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 l1ROD/jxxvdOUIEUsibZhJnjzbSvJ//fGjQmTFr/chDhenqiT2t3Y1z35LyAOmwlGfynRXTJhJh
 YEAwQyOMogLQSKwqDiL/C7BmOu3bANdC7K82NlFwZa4WAzMZY1Yik5wyHJlEKNpQTtKm+hNadqZ
 HmGqGJzgaLYTUP6eT5DglbV2EbCBAGOML8QsO8On+t1UxY+z5PcFT94x+Ye+EZ1qNP9qIU26C8B
 P2458YO83WS8wu8xOWb7OZD7xj3YvIG/K3Y++npX2HxnS/jGOMh3SZDpXPVT+adFWymslEpUsNq
 zgVR6OQCtK8rS8y2hYAssfdkD38ANQYJ6OOwnzGblpEo9vKtr2UJZYy56Zyu1zLNbQ3hH7kstEG
 krucvj8RU5nVY6H8OxDKvopn0aVi2GZMThpHRtaOoZ8tTrtzrIxuKj5IoqiNa6pVQS7ySrEhyv9
 ULkTzds7f7BOu2zCwLKkg3IOdxrlsXYBNxykkZJnvVXMvR81yd2skPjweLunBxoD0n23y2nvrd7
 N3fnokev2EWrpOa0cNvgjnt+ABm5b72uf81JXWIlwehz5Rsz4CdUj5ms7NX+7WDymP4TRPOIj5t
 nlfVKLS9ba9XG4PzTNMBI2pX4faCXL951jrClirJ0dRkexklMlyv2heeoy+lgbZyHemiSP0lfEg
 1QVy2UKp3abMY
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

I'm about to add several new tests that verify a test ACL. This is
common code for all these tests, so introduce a utility function
to verify the test ACL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.0/nfs4acl.py | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 97509b5d1d57..653e53dc313f 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -310,6 +310,61 @@ def access_mask_to_str(mask):
     ]
     return " | ".join(name for bit, name in perms if mask & bit) or "(none)"
 
+def verify_acl(returned_acl, expected_acl):
+    """Verify that returned ACL contains expected ACEs
+
+    Server may insert additional ACEs anywhere, but the requested ones
+    must be present in the requested order, with the requested type,
+    principal, and flags, and with at least the requested permissions.
+
+    Raises AssertionError if verification fails.
+    """
+    if len(returned_acl) < len(expected_acl):
+        raise AssertionError(
+            "Returned ACL has fewer entries than requested: "
+            "expected at least %d, got %d" % (len(expected_acl), len(returned_acl)))
+
+    # Verify the ACEs we set are present (server may add additional ACEs)
+    pos = 0
+    for i, expected_ace in enumerate(expected_acl):
+        # RFC 8881 Section 6.2.1.4.1: ACE4_IDENTIFIER_GROUP is ignored on
+        # the special identifiers
+        flag_mask = ~0
+        if expected_ace.who.endswith(b"@"):
+            flag_mask = ~ACE4_IDENTIFIER_GROUP
+        expected_flag = expected_ace.flag & flag_mask
+        # A server may split one principal's grant across several ACEs,
+        # so keep searching past a candidate whose mask falls short and
+        # remember it for the error message
+        candidate = None
+        for j in range(pos, len(returned_acl)):
+            returned_ace = returned_acl[j]
+            if (returned_ace.type != expected_ace.type or
+                returned_ace.who != expected_ace.who or
+                (returned_ace.flag & flag_mask) != expected_flag):
+                continue
+            candidate = returned_ace
+            # Check that requested permissions are present (server may add more)
+            if (returned_ace.access_mask & expected_ace.access_mask) == expected_ace.access_mask:
+                break
+        else:
+            if candidate is None:
+                raise AssertionError(
+                    "ACE %d (type %d, flag 0x%x, who %s) not found in returned ACL" %
+                    (i, expected_ace.type, expected_ace.flag, expected_ace.who))
+            returned_ace = candidate
+            missing = expected_ace.access_mask & ~returned_ace.access_mask
+            raise AssertionError(
+                "ACE %d access_mask mismatch:\n"
+                "  Expected: %s\n"
+                "  Got:      %s\n"
+                "  Missing:  %s" %
+                (i,
+                 access_mask_to_str(expected_ace.access_mask),
+                 access_mask_to_str(returned_ace.access_mask),
+                 access_mask_to_str(missing)))
+        pos = j + 1
+
 def printableacl(acl):
     type_str = ["ACCESS", "DENY"]
     out = ""

-- 
2.54.0

