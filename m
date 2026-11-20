Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795199780;
	b=tzcfAeMponGCzta8C4al1kitYKec9P5975I119aC8109gxpan9Cwe62R2Xbus+gBKfwh
	 BJAIGVMjEY03dtpm3+z/iTocnZtpliMGYgYuvwhG/cOQMuV2ZYfebKB2q+i2W7mMzhe9j
	 f/SJ4z8hdqEaT78xzcp364UIeM0wqsRFjQyDkCSHFwUA0Ld8TnYwTq80pac5bg6englbQ
	 +Vipqnpxl2IL73wUsqnXnx6+QvYO6YMn7mQr7zzsbUbGaulmJBRKivlkQhfAjQOVjkzHz
	 N4hmZM8S1SY5b4Lq+YnKURuqGJOhzO0ly6l1p87OvUSh2fthysKLCJNbLFFI4kva1tA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795199780;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=lnDNDedOfMxpHJz6DgeDIzqPXeGXDccrNqswxJ5646g=;
	b=2qIACNJrFuNymKW/lJP90tYUzdqmt1p8qCz/fbtXCXZFBcS2n92eaOimnHXKUbsk+qko
	 tfO580Wl3dr7ogAQcdi4XrWlhMKX5Vzp1zlZslcslL/+eCu3MNWs2K+gZ/aP29uPeJRDq
	 n2A6uF2IhWXO0QV417mb+yZImg1SqaasToWBoqTA9ahpqCjVbuUfj5BlUhBy6z3tKJUql
	 jh+eQNdzKM9kc0C/AmPiUwZqemgBSQjdo1UKSzY/yP9vSOXJnKrER/WqwpKiCepqpstnL
	 MZeOJm+O88vPUz5YuDhRNHisMTQRGLDf6biFbMwQjBXMLqbH4Y7ctg2xLKOibPt/TtQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=O9Jpq6yJ;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0971260A2613
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 18:36:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0971260A2613
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=O9Jpq6yJ
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795199778;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=lnDNDedOfMxpHJz6DgeDIzqPXeGXDccrNqswxJ5646g=;
	b=O9Jpq6yJAfyUnXWL765GNanVG9ZQNCQUyG4jt8qzPZZQyqpQjlBWEETj5qoVe+b1F8Eula
	TUfQlPc7AKuhZbioZglc0qP3SRLdN9GKmQkVt32KssPnqjTGADcpXKd8eVVFSpb33onibB
	HSw0ZXQCr2TgyAA+JKU35AB7tE1GYxM=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-696-fw8Bjm0BNP6op5bn-KBIQg-1; Fri,
 20 Nov 2026 18:36:14 +0000
X-MC-Unique: fw8Bjm0BNP6op5bn-KBIQg-1
X-Mimecast-MFC-AGG-ID: fw8Bjm0BNP6op5bn-KBIQg_1795199772
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7AA00195605A;
	Fri, 20 Nov 2026 18:36:12 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3D74F18004FF;
	Fri, 20 Nov 2026 18:36:12 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 48ED35C0748B;
	Fri, 20 Nov 2026 13:36:11 -0500 (EST)
From: Scott Mayhew <smayhew@redhat.com>
To: calum.mackay@cdmnet.org,
	jlayton@kernel.org,
	cel@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pynfs: report xattrs as unsupported instead of failures if the server doesn't support them
Date: Fri, 20 Nov 2026 13:36:10 -0500
Message-ID: <20261120183610.55288-1-smayhew@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Extended attributes are an optional feature, so a server not supporting
them shouldn't be treated as a hard failure.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_xattr.py | 72 +++++++++++++++++++++++---------
 1 file changed, 53 insertions(+), 19 deletions(-)

diff --git a/nfs4.1/server41tests/st_xattr.py b/nfs4.1/server41tests/st_xattr.py
index f67df95..f83fa74 100644
--- a/nfs4.1/server41tests/st_xattr.py
+++ b/nfs4.1/server41tests/st_xattr.py
@@ -28,10 +28,10 @@ def testGetXattrAttribute(t, env):
 
     bitmask = res.resarray[-1].obj_attributes[FATTR4_SUPPORTED_ATTRS]
     if bitmask & (1 << FATTR4_XATTR_SUPPORT) == 0:
-        fail("xattr_support is not included in the set of supported attributes")
+        t.fail_support("xattr_support is not included in the set of supported attributes")
 
     if FATTR4_XATTR_SUPPORT not in res.resarray[-1].obj_attributes:
-        fail("Server doesn't support extended attributes")
+        t.fail_support("Server doesn't support extended attributes")
 
 
 def testGetMissingAttr(t, env):
@@ -48,7 +48,9 @@ def testGetMissingAttr(t, env):
 
     fh = res.resarray[-2].object
     res = sess.compound([op.putfh(fh), op.getxattr("user.attr1".encode("UTF-8"))])
-    check(res, NFS4ERR_NOXATTR)
+    check(res, [NFS4ERR_NOXATTR, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
 def testCreateNewAttr(t, env):
     """Server MUST return NFS4_ON on create.
@@ -66,10 +68,14 @@ def testCreateNewAttr(t, env):
     key = "user.attr1".encode("UTF-8")
     value = "value1".encode("UTF-8")
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_CREATE, key, value)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.getxattr(key)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
     if value != res.resarray[-1].gxr_value:
         fail("Returned value doesn't")
 
@@ -89,10 +95,14 @@ def testCreateNewIfMissingAttr(t, env):
     key = "user.attr1".encode("UTF-8")
     value = "value1".encode("UTF-8")
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_EITHER, key, value)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.getxattr(key)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
     if value != res.resarray[-1].gxr_value:
         fail("Returned value doesn't match with expected one.")
 
@@ -112,7 +122,9 @@ def testUpdateOfMissingAttr(t, env):
     key = "user.attr1".encode("UTF-8")
     value = "value1".encode("UTF-8")
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_REPLACE, key, value)])
-    check(res, NFS4ERR_NOXATTR)
+    check(res, [NFS4ERR_NOXATTR, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
 def testExclusiveCreateAttr(t, env):
     """Server MUST return NFS4ERR_EXIST on create of existing attribute.
@@ -130,10 +142,14 @@ def testExclusiveCreateAttr(t, env):
     key = "user.attr1".encode("UTF-8")
     value = "value1".encode("UTF-8")
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_CREATE, key, value)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_CREATE, key, value)])
-    check(res, NFS4ERR_EXIST)
+    check(res, [NFS4ERR_EXIST, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
 def testUpdateExistingAttr(t, env):
     """Server MUST return NFS4_ON on update of existing attribute.
@@ -152,13 +168,19 @@ def testUpdateExistingAttr(t, env):
     value1 = "value1".encode("UTF-8")
     value2 = "value2".encode("UTF-8")
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_CREATE, key, value1)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_REPLACE, key, value2)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.getxattr(key)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
     if value2 != res.resarray[-1].gxr_value:
         fail("Returned value doesn't match with expected one.")
 
@@ -178,7 +200,9 @@ def testRemoveNonExistingAttr(t, env):
     key = "user.attr1".encode("UTF-8")
 
     res = sess.compound([op.putfh(fh), op.removexattr(key)])
-    check(res, NFS4ERR_NOXATTR)
+    check(res, [NFS4ERR_NOXATTR, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
 def testRemoveExistingAttr(t, env):
     """Server MUST return NFS4_ON on remove of existing attribute.
@@ -196,10 +220,14 @@ def testRemoveExistingAttr(t, env):
     key = "user.attr1".encode("UTF-8")
     value = "value1".encode("UTF-8")
     res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_CREATE, key, value)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.removexattr(key)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
 def testListNoAttrs(t, env):
     """Server MUST return NFS4_ON an empty list if no attributes defined.
@@ -216,7 +244,9 @@ def testListNoAttrs(t, env):
     fh = res.resarray[-2].object
 
     res = sess.compound([op.putfh(fh), op.listxattrs(0, 8192)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     if not res.resarray[-1].lxr_eof:
         fail("EOF flag is not set")
@@ -243,10 +273,14 @@ def testListAttrs(t, env):
     for key in keys:
         value = "value".encode("UTF-8")
         res = sess.compound([op.putfh(fh), op.setxattr(SETXATTR4_CREATE, key.encode("UTF-8"), value)])
-        check(res)
+        check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+        if (res.status == NFS4ERR_NOTSUPP):
+            t.fail_support("Server doesn't support extended attributes")
 
     res = sess.compound([op.putfh(fh), op.listxattrs(0, 8192)])
-    check(res)
+    check(res, [NFS4_OK, NFS4ERR_NOTSUPP])
+    if (res.status == NFS4ERR_NOTSUPP):
+        t.fail_support("Server doesn't support extended attributes")
 
     xattrs = [key.decode("UTF-8") for key in res.resarray[-1].lxr_names]
     if len(xattrs) != len(keys):
-- 
2.56.1

