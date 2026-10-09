Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0026F4F30CD
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563716; cv=none; b=hrrDut9LwZ1POSpaMIvA3CTLMP6hZcLhiNOA1mKOIiVBilykax5TyR+LWHltqgNTpsRfvB71mtlr3vMBGA4qkMaP0gX5Qq7rP0KSKBH7gWTiUmSh0CMMGuMBUHT5K6Dp7bETmtTmqXMFMKEIpGoQx6Gn/i/1ekLFcd/ypChqgVE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563716; c=relaxed/simple;
	bh=4YvIvV33Rgz7PPjDiHTXqlg/BYRMY+ERWlSuFhj16yM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fUT/uhu8E+QauVbs0/oxUbi1CUSiU03Qwdza79iD/3Ibvmu0AUWnOGceCGRhvB2b3PCa1ysRIg88SzGQ7Pmd+IOCyukLimyPk6bT60CGJUWtOO1v8ZIEl0tzyg4qLEsGRRKFxQ1vGlsT6DuY5uTupnnxDUD1wFwU8LDw6Lq+SlU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ABQDbgWp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ABQDbgWp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D1681F0089D;
	Fri,  9 Oct 2026 16:35:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563709;
	bh=ImeVku3HMK9pNnHc+YkUSsdWMntLxtR5pJiAKa/SUnw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ABQDbgWp++3fkJw1yHbvl82kabjbt/2AzsSNCZxEKx/WweTXdcmsQqegQbuZqS4mr
	 Sqb4zjoJItlWZx6AHGl4E7vPFvE/Mv8jmLGfBZ9+V4/bpaZI1gonSZPYDLPoZ35fB8
	 XL2kPTu9gS+YDXCC2Sz1p/s//Bc1JLoCtN9NKeJaNVdp8k+0zgtR8252u5dZZjSdlP
	 CDXEaiZXojRXw+O4HbfCIFTtv3Gi7lvjXdm+JWPCcdYK75B6JWJNcBrRlAxBoWlVlf
	 HHSzZidhJy7jT415tbyTq91awfQbirVZvc254Wm8pInfCl5bGenLiF9TeLjfKcVSb/
	 i212DPyWyBLeg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:35:01 -0400
Subject: [PATCH pynfs v3 7/9] Add verify_mode_and_acl() helper to nfs4acl
 modules
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-7-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2280; i=cel@kernel.org;
 h=from:subject:message-id; bh=I5AiQMwESOwdSC/2UIVrs5kuQ1ZFYZUYK4vD+/CqX/A=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5ylt6/ZQeZcgZdqpLbQW264iYNxoUfT5Tb
 Ikr851KJS+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 l1HnD/9Qkk9KzaHuAdZK68i0Z1Wo6dslALgzBTcKMYbPooZeoBuuXxFtBwXLSzFBJW225ukUDWf
 7bywDKFUWGyGQBAkoTXW5Mpqx+rE50kx1MSDae5MbQ9QQn7KLuzQXkape67rzM8eEQALvPi5ns3
 Mfb4/B1YQM/eFjTxn95p9JDoZGTQ+uRLY2jWQcN+S4oJ77Y1UDODPNx8cCKzHcNmJNz4cExRfa7
 /kE6L2J357YJT3yinhdPmI70of89+pgGBj1otVWTgboi1zgFmDxWFR7jyM2na9r3A4Il7kILN4W
 CH2p/nCbAOtLkwrJQfJIaIiTtW/z49vCvrxgB57Dv0KAEw6EHs56Mol625hitlmrZXX+o4fhsPz
 2WWHgsC5KTjvIn5SsNH2D7kYTuSiKDoiSt/yhduCIR1mIxNkNxHzZdM5DLOlDTpgqT/M5sc1d/N
 z14CRjgTiHetVrvlGXnsLbN/kDEnka1vMKIJcdWeaoTXIo0t3Z0iuSS7LAHhKfAw4ajkyqWbAWx
 xxy9eyH1Q43mRgKy3sQ7cH/S+uh3hDDbr9cF6Shlo48rM9raTrnixGfClv8/AR/XgVJY8INO2EF
 4ubfqq6dj6AX58++hyJYAejVyC8qqd4fsYYE3e7N42p51YfU8OLvSRrrT2rPG0AR2YORw9UhLGK
 cGzynwQfn9AJ2/w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

I'm about to add new tests that set a test ACL and mode bits
simultaneously. This is common code for the new tests, so introduce
a utility function to verify the ACL and mode bits.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.0/nfs4acl.py | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 653e53dc313f..c49a4256d467 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -365,6 +365,42 @@ def verify_acl(returned_acl, expected_acl):
                  access_mask_to_str(missing)))
         pos = j + 1
 
+def verify_mode_and_acl(attrs_dict, expected_acl, operation="operation"):
+    """Verify that MODE and ACL attributes match expectations
+
+    This helper encapsulates the common pattern of verifying both ACL
+    and mode derivation per RFC 8881 Section 6.3.2.
+
+    Args:
+        attrs_dict: Dictionary of attributes (must contain FATTR4_ACL and FATTR4_MODE)
+        expected_acl: The ACL that should be present
+        operation: Name of operation for error messages (default: "operation")
+
+    Raises:
+        AssertionError: If verification fails
+    """
+    # Check that both attributes are present
+    if FATTR4_ACL not in attrs_dict:
+        raise AssertionError(
+            "ACL attribute not returned after %s" % operation)
+    if FATTR4_MODE not in attrs_dict:
+        raise AssertionError(
+            "MODE attribute not returned after %s" % operation)
+
+    # Verify ACL matches expected
+    verify_acl(attrs_dict[FATTR4_ACL], expected_acl)
+
+    # Verify mode matches RFC 8881 derivation from the requested ACL.
+    # Deriving from the returned ACL would only check that the server
+    # agrees with itself, so a server that widened both would pass.
+    returned_mode = attrs_dict[FATTR4_MODE] & 0o777
+    expected_mode = acl2mode_rfc8881(expected_acl)
+
+    if returned_mode != expected_mode:
+        raise AssertionError(
+            "MODE (0%o) does not match RFC 8881 Section 6.3.2 derivation "
+            "from requested ACL (expected 0%o)" % (returned_mode, expected_mode))
+
 def printableacl(acl):
     type_str = ["ACCESS", "DENY"]
     out = ""

-- 
2.54.0

