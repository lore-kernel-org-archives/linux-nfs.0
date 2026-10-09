Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69B304EF15D
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563716; cv=none; b=UvMD7KVJdtbToCEE/Q8dccvxxw67VOxq3wAHsIgxxcU0wN3Kj7dEnUzwvUqMLpHWZtyjIwhTE/HcxRWfEUKKN+aZhST//MxjRjVGI6HdzmBD3Bwx7+ZkNZ+J7FL2YDJq3S25Hup6rXVidxaBkYHtmL1VivF1M5RD9XjuViLXaqQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563716; c=relaxed/simple;
	bh=O1kdSxdQj2fMEMNWPucbtuoxsbGPdD7ACQ9bY9LjCpc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LOFnkCZIwGX3HwU3xHaTI9ufWvEVrRnTyTsSh2U1phN7e/ZtuogeA+n0jMijarIFVqH5ypVE2jn3REttKanHtJ+vtWM1fDBhn8fVZf7lTSzylO3nDhsdUpOvFD8+8s5Zv2TtlyscK5cMJPGdeGC4b7d39KxMWRtMgUh60xR0Jjw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KhTN0l+l; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KhTN0l+l"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 799E61F0089B;
	Fri,  9 Oct 2026 16:35:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563708;
	bh=AAgj6Orr7zhXqLVi62vrw7OyaoJnOjaaoBefQOXiLH0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KhTN0l+lhogeIgvaBfYZ8oYgWLVxwwHq2NsggcQItPUt0FEeyZPSmvirUKU0aA8ex
	 /QDJHFjjhgK276/XEfNejNwtu82vkTgdOrUww0f0YXZ7n7lZpCYuoEsNgic+BsAfqn
	 TdXM39+lhsAjNVVx7LbhXFBo/qE73UaXjx22rDQHBbAcztaV5GFiqFGtthlKh5VISK
	 9hvIVr2WvhZ/uv7AOKy+jOhQ6yFIthAKNUYPHkXLklYXXFnCGjs98dPGh40Hm2AnYp
	 y752fYP4K5R3Yv7Vkg9wKo1Vt1QkIfQncaj2ClWONGIuz+gxz6c38BIqJ+I7PK9qXQ
	 rwdRdD0oj78Hg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:34:59 -0400
Subject: [PATCH pynfs v3 5/9] Add make_test_acl() helper to nfs4acl modules
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-5-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1587; i=cel@kernel.org;
 h=from:subject:message-id; bh=qBmUpfN63WkhEgfzxzkYrq+71a2p1qZeWyC3AVV7JHw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5271SBI98q3zyAvRaWrgxqKed1cVuVn+87
 SD3aDfxiuOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 l1EnD/0VSGDVQfuJT2ONMNBs49OKddVcDsJYAe729KUFiCk+bo83ECcH1haw4YOjzJ7JZj9blWm
 TGNPSdWjvZ+SaO3bmqUFFzL597Ick/pAqwIm/f0ry7bOZH+y6/tm828/Gm9IqY3r3W0XQnKTSsg
 2+ni+GzV2PQvmZCpqX4aOOvlDSHytm8/V1td758sSP0gra4lWS3eVJ7U5GlPQRio5b1msYLEuhY
 7wIEpOnwTrg5j4Pg6/KLhdio4aq7K55vYipAdU6CcFNWOEzlhUci8K73XGgf5I5PnGBLAUstq5B
 IyX9vSmvQYY2dvpwvpwNaetKesAiYz8sQGzWnuesGFkdEW6ZZRC5lbFRo+i9FW/y9tSZ3bS0pBh
 9kl3Qh1haJGOaWpGf5dJvEgEs/Vmigeea3afob55H4to4zLmkP0RMkqMR5ikYggNchqZsWElxMr
 pp70ZzASK6KnsLJDmaw9swSc3eEdLXdnjKy6RZ66XjHCP3zPAax7oMQtQ8uslwi9rJyEIrp2YNR
 eNcY08HLKbN4lX0ZkvikAZnO2ocG5w6Ku/+mw+7cV94EWZSuJytFtr6IDJnMvr+RywwW4vK4a/t
 jQmCL2nUXJp3T//3QN8gSG9U1pqgSb83N/E2y5kAY68wYN9TP70cnQvE2hNZ7Oq0ZFcczU3ENSF
 0V2a4xa0xNf+DKA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

I'm about to add several new tests that set a test ACL. This is
common code for all these tests, so introduce a utility function
to construct this ACL for each test.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.0/nfs4acl.py | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index fa7951723dbc..97509b5d1d57 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -78,6 +78,28 @@ def mode2acl(mode, dir=False):
              nfsace4(DENIED, 0, negate(other), "EVERYONE@")
              ]
 
+def make_test_acl():
+    """Create a test ACL that maps cleanly to POSIX ACLs
+
+    Uses OWNER@, GROUP@, and EVERYONE@ to match POSIX user/group/other
+    structure, which helps servers that map NFSv4 ACLs to POSIX ACLs.
+
+    Includes both WRITE_DATA and APPEND_DATA for write permission, since
+    Linux NFS server's conservative NFSv4-to-POSIX mapping requires both
+    to grant POSIX write permission.
+    """
+    return [
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | ACE4_READ_ACL,
+                b"OWNER@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"GROUP@"),
+        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
+                ACE4_READ_DATA,
+                b"EVERYONE@")
+    ]
+
 def acl2mode(acl):
     """Translate an acl into a 3-digit octal mode"""
     names = ["OWNER@", "GROUP@", "EVERYONE@"]

-- 
2.54.0

