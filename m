Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A30D4EF13E
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563710; cv=none; b=J8b9zKZhKxwMxYAygiB55s6NMKTZryKiIwxBFlucvWCEH1WT+HiLFrT7aMAkhQKziLUlrZcijlIfJEi9rufb9YAQbFMUax4Zl1vAYq4V9Cs1d569skP0t0BbajPH/YqXW+KVIn5vQFrrb3AyTKqM/oi/uEwxnplRl7K/FDH6I+8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563710; c=relaxed/simple;
	bh=CTx51NQBxrXj8h2Xc6Poa7wo279YHkav0q5B+tVgoic=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AqpUe9AiGWnxLvyVjfPpvzyIRHeonmbFWXYP0PXNd2z6BAndcT5RGy9Wt6aASje0zGMPvTRrniaj2As+31k1aRvSHCZHFnkwJF5NOxK0YM2upFl2S0yyBJwlo//pcaEHmj31b7vnx0tLBI0QfSrliFF8SHFchP+i0qC/PJvnIr8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g/3r7u40; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g/3r7u40"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D93A91F00898;
	Fri,  9 Oct 2026 16:35:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563707;
	bh=puH3AqWM8Mj+EpclGKFav2Q6AoSIYXc3dg+oTxwWb48=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=g/3r7u40BZry+wvE6Ot5rdY6lS/NYB+QCqHaKbgbhA8tjfvg2dqyjEiLxWd49mmN1
	 Xm5ua2BjrGbklkIEK8TQWUAQ8YY3bmtb99vM9WGo0IzuX/oM0kuF2QomTjMiaFT5sJ
	 2o74JS1vYeZgUjhjxdL2mFYlxDQQmA9qlBlokb1YDCnzu2tNTjjJlFMCzFENAaOxGe
	 yjxXHbJ1j3SokqKmnXNsxfZLEhxAng50mUal5fMDDvp50J0G4rlS2Vu2IJI9MoEGsn
	 0dXgY5JCEE7crGCtWS/3WZoL9DOLSOG6YAxQFq0NKHOziwkkoSWpqTTDvgpEFZUPJY
	 ichqtg8mg2vtQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:34:56 -0400
Subject: [PATCH pynfs v3 2/9] Add helper to format attribute bitmaps
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-2-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1068; i=cel@kernel.org;
 h=from:subject:message-id; bh=n0d14yLVNNqMnto3MwGi/y3QyrDZ1DgPYzGrhxrmeD4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe4Ez5TIBBwBM5K7Q2RPunnE0IRbKfBGujOS
 a4dxy7oHpOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuAAKCRAzarMzb2Z/
 l45hEACiiDk31O30vZA5XvDj1Ne56mUaHrP9KacnlCfokM1puxYa3nsgHC4lvuupOvR2z/OwKMG
 mV1rs+kguMFxXw6cxppYBP6BTPkcyGieJBZ+8psF5KDfJTjB8mAyahxcMHyBbN+xumosxyEPLgG
 wiLLiZCcDTBLBh1EQ7cAY485rRsCVOUwHBmYRouwkGWSQ1aWjV0H5p5r650BoMeCxY6QkCVbVTn
 rPQK8EAy/xqCRT3tTCKELTl2DG5IkeLZVqaxTMHtTN9BcvE571shDdhifQ7Mtb8yvrl5wMJi6jx
 QMO0PRU2OKLyzmnm7IK3XJQz5hpHklFQD8uld66q601iUf7nBvN/tuGn+09qY3VW8mH7sIfDBK9
 6h4EVKY94PLpx4eExT3nRkHLHfMdGcfnCmYwbtahtGd/HjYYovIjVc3NF1nHjdfAq6q4RM9CF6J
 tqpoYsrGGafSvqPhZGDBNMKy0WSfuY68RdtTAlqqkWLfwpQvu1gpiUGK/UmuZ/iL9xKg62t+xL0
 mnkAcaJ+d64Pesbg2U5GKMNVaW+AHM6cmZMffgpfRYTrnldZXjzCdxX3J2GAonafdjGI3C9/CDM
 vJcL1E0h46k/fPSGFyt3XO5AgUJaYW8RwKXfaeVEHl/xukK77d6TRae8Xe8JWez+K1Z0OthO3Wa
 aeupW5bQTlegd+A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

I'm about to add several new attribute-related tests. Introduce
attr_bitmap_to_str() in nfs4lib.py to convert attribute bitmaps to
human-readable symbolic strings.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.1/nfs4lib.py | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/nfs4.1/nfs4lib.py b/nfs4.1/nfs4lib.py
index d3a1550f1ce1..9652cf41bef4 100644
--- a/nfs4.1/nfs4lib.py
+++ b/nfs4.1/nfs4lib.py
@@ -564,6 +564,14 @@ def attr_name(bitnum):
     """Returns string corresponding to attr bitnum"""
     return bitnum2attr.get(bitnum, "unknown_%r" % bitnum)
 
+def attr_bitmap_to_str(bitmap):
+    """Convert an attribute bitmap to a symbolic string representation"""
+    bits = bitmap2list(bitmap)
+    if not bits:
+        return "(none)"
+    names = [bitnum2attr.get(bit, "unknown_%d" % bit).upper() for bit in bits]
+    return ", ".join(names)
+
 class NFS4Error(Exception):
     def __init__(self, status, attrs=0, lock_denied=None, tag=None, check_msg=None):
         self.status = status

-- 
2.54.0

