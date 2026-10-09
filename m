Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D09933955D7
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:35:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791563715; cv=none; b=REUvbXTez2l8GtNXZddXaHc3wrNX66J9eRIZvlI9KwgGs2I3i0gM/eUrUWLEsS/5W8Egl8TB5MPuOjpYoFmGNU2iCNS9SR+ITBuLTkaKz3Qymub1YYUui35xNNhjHXkaWgW8uW3+VP11ZSXsV+7qb1RNv8wi9ckMnn2jeD+RvG4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791563715; c=relaxed/simple;
	bh=2Lv/p//9H5rEAiy8rcse/VJhetK2zzFj3rO6k9RaIIU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=mQIZkGqdEmYBLWTiUlR/WG4BJRM7xyPHRO29IGcBOZ0pxTtg7zAobwSBGNsBs8Eu8QqTWU/ZBFUXYVWtEPp6H85T4i2r295Kzmo1opUc/Ux2HWagYEH8BBlltw4y7nKMFb+0zGPKCwdpFSh4AD2e++dBVm7sDC08H77fRam7TYg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LYT2Awip; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LYT2Awip"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB8AF1F0089A;
	Fri,  9 Oct 2026 16:35:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791563708;
	bh=a7tkDg/yKTh764QM9YQNGA1/+urxA52ewBHxHHSS0lY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LYT2AwipxJ70jNJezlhLd5X/F/uV7zdxpzs9FOYUDbDAioxrniBbhZfAVDXUdso29
	 K4MBPkmXNSk0kSH9d4+poPqjlKQQ9yr5Flv5AGUS9AeLveUrps2Kj9zOY7/LQBDVu7
	 nt+cqWUeMPOIov0wtGVjWe2kXBvga4e0Yt2EUQrEJdprS5Msw1kNvcB0+OhikNy8F6
	 8jjukUwBDqRq6xVJ+B04aOzZbEarq8ijUta3AMjYCGfFdopj8OvGhnQdimdR9ip2VK
	 NN+RqIl9FvR6dnWlWYs8+yH1eRRWmkNPiAkqXLH/YB6gueUYXGbx82oga+cfxzlzUd
	 aL9BEcxD3reyw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 09 Oct 2026 12:34:58 -0400
Subject: [PATCH pynfs v3 4/9] Add access_mask_to_str() helper to
 nfs4.0/nfs4acl.py
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261009-acl-mode-v3-4-ba487c5e66e0@kernel.org>
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, aurelien.couderc2002@gmail.com, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1497; i=cel@kernel.org;
 h=from:subject:message-id; bh=Wa+L74XEduuXjUgKdazZdb+1VUH8fOaN8cZ2OkYTkSo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqyRe5iJIU6RwknE1WgwkGMztjF+NXlPDNFZQtK
 Q4vsViFOP2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaskXuQAKCRAzarMzb2Z/
 l7OyD/4vVRVyTFcpxzyQQ8RnyxYznuzWI8M/eqRwkomdexWg01VjHuzB6nGkxSXgrbe7Anx1ehu
 sc0B5vyOqbmv/GGD1JqhXf4Jtalrr8r3Brs8fDrgaE37KfB93Aly/4xoNRHI22YB2E9Rc6gD6tR
 C2/ZOJ+zS8GE1CRLTYzCIH+al8+AwmfiNBiz9BrlOmhl4nVHuMd4nFQsSAOUN6Wl1YTlXhDhlf0
 Rr+ijgY/MVCzX3hUBx9L01GwH79r8uhAU9WjFP3nd0XxRjIsKT5tUyzd+94tqaLuDf9LXqlURAm
 ZLLylr6v/imqTgZW2szR4d/bytUijgi3IgBFLtnt/va4WQkyxYHIKHdMEg+suH6shbrzmDe1mVD
 in6mc/8n8LFeji8CbYg/zlzfoNj4QcC92hVq97HqLtZSGQN2SOQ4NClSx4u399OIgfaFyijvnha
 72iOSgEPXcEeMZfpYtcKvxziNe7FUzQylEvA9meBnqF1aooyAsMY1E5ekqMQpcFpBko22q4rVZh
 YzTTcnIlpOUGA3Wnzqn+KWE4f34VA/H5P2NKMZF0jg3deZWNT/EeTJF6mGJpq7VXbAIjAUKLlEt
 RXvIkIGY4NZ8qaH7MD47JzoSBrqueKFHFMFyfEq23Y+9hj7UHt04C29lV7vE+O+nXWaYCMTAAWM
 Eh+k1ooljvsX8dQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

I'm about to add several new ACL-related tests. Introduce
access_mask_to_str() to convert ACE access_mask values to human-
readable symbolic strings for the display output in these new
tests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 nfs4.0/nfs4acl.py | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/nfs4.0/nfs4acl.py b/nfs4.0/nfs4acl.py
index 4b6ca4921162..fa7951723dbc 100644
--- a/nfs4.0/nfs4acl.py
+++ b/nfs4.0/nfs4acl.py
@@ -268,6 +268,26 @@ def acl2mode_rfc8881(acl):
 
     return mode
 
+def access_mask_to_str(mask):
+    """Convert an ACE access_mask to a symbolic string representation"""
+    perms = [
+        (ACE4_READ_DATA, "READ_DATA"),
+        (ACE4_WRITE_DATA, "WRITE_DATA"),
+        (ACE4_APPEND_DATA, "APPEND_DATA"),
+        (ACE4_READ_NAMED_ATTRS, "READ_NAMED_ATTRS"),
+        (ACE4_WRITE_NAMED_ATTRS, "WRITE_NAMED_ATTRS"),
+        (ACE4_EXECUTE, "EXECUTE"),
+        (ACE4_DELETE_CHILD, "DELETE_CHILD"),
+        (ACE4_READ_ATTRIBUTES, "READ_ATTRIBUTES"),
+        (ACE4_WRITE_ATTRIBUTES, "WRITE_ATTRIBUTES"),
+        (ACE4_DELETE, "DELETE"),
+        (ACE4_READ_ACL, "READ_ACL"),
+        (ACE4_WRITE_ACL, "WRITE_ACL"),
+        (ACE4_WRITE_OWNER, "WRITE_OWNER"),
+        (ACE4_SYNCHRONIZE, "SYNCHRONIZE"),
+    ]
+    return " | ".join(name for bit, name in perms if mask & bit) or "(none)"
+
 def printableacl(acl):
     type_str = ["ACCESS", "DENY"]
     out = ""

-- 
2.54.0

