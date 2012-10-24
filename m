Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161045Ab2JXSLd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 14:11:33 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OIBXSv005431
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:33 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OIBWSD020176
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:32 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/5] Fixed warnings in src/g_canon_name.c
Date: Wed, 24 Oct 2012 14:08:40 -0400
Message-Id: <1351102124-24036-2-git-send-email-steved@redhat.com>
In-Reply-To: <1351102124-24036-1-git-send-email-steved@redhat.com>
References: <1351102124-24036-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yao Zhao <yao.zhao@windriver.com>

g_canon_name.c:125:5: warning: passing argument 2 of
'__gss_copy_namebuf' from incompatible pointer type [enabled by default]

the 2nd argument of __gss_copy_namebuf should be address of
*gss_buffer_t, but a *gss_buffer_t is assigned.

what __gss_copy_namebuf does is to alloc memory for a gss_buffer_desc
and copy from src and return its address.

if following code failed, gss_release_name will free
union_canon_name->external_name.value if it is not NULL.

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
---
 src/g_canon_name.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/src/g_canon_name.c b/src/g_canon_name.c
index 11a6b21..080befe 100644
--- a/src/g_canon_name.c
+++ b/src/g_canon_name.c
@@ -121,11 +121,17 @@ gss_canonicalize_name (OM_uint32 *minor_status,
 
     union_canon_name->mech_name = mech_name;
 
-    status = __gss_copy_namebuf(&union_input_name->external_name,
-				&union_canon_name->external_name);
-    if (status != GSS_S_COMPLETE)
-	goto failure;
-
+    union_canon_name->external_name.value = (void*) malloc(
+                      union_input_name->external_name.length + 1);
+    if (!union_canon_name->external_name.value)
+        goto failure;
+
+    memcpy(union_canon_name->external_name.value, 
+           union_input_name->external_name.value, 
+           union_input_name->external_name.length);
+    union_canon_name->external_name.length = 
+                      union_input_name->external_name.length; 
+   
     if (union_input_name->name_type != GSS_C_NO_OID) {
 	status = generic_gss_copy_oid(minor_status,
 				      union_input_name->name_type,
-- 
1.7.11.7

