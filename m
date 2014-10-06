Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares08.inai.de ([46.4.84.70]:52491 "EHLO ares08.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbaJFV0x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Oct 2014 17:26:53 -0400
From: Jan Engelhardt <jengelh@inai.de>
To: steved@redhat.com
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] build: use a symbol version map
Date: Mon,  6 Oct 2014 23:19:34 +0200
Message-Id: <1412630374-23246-6-git-send-email-jengelh@inai.de>
In-Reply-To: <1412630374-23246-1-git-send-email-jengelh@inai.de>
References: <1412630374-23246-1-git-send-email-jengelh@inai.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The symbol versions are used by the dynamic linker (and other things,
like rpm) to ensure that a program does not run with an outdated
library that still has the same SONAME.

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---
 Makefile.am  |  3 ++-
 nfsidmap.map | 27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 1 deletion(-)
 create mode 100644 nfsidmap.map

diff --git a/Makefile.am b/Makefile.am
index 85f19c8..69bbcbc 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -26,8 +26,9 @@ pkglib_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_LIB)
 #  		by this library.
 
 libnfsidmap_la_SOURCES = libnfsidmap.c cfg.c strlcpy.c cfg.h nfsidmap_internal.h queue.h
-libnfsidmap_la_LDFLAGS = -version-info 3:0:3
+libnfsidmap_la_LDFLAGS = -version-info 3:0:3 -Wl,--version-script=$(srcdir)/nfsidmap.map
 libnfsidmap_la_LIBADD = -ldl
+libnfsidmap_la_DEPENDENCIES = nfsidmap.map
 
 nsswitch_la_SOURCES = nss.c
 nsswitch_la_LDFLAGS = -module -avoid-version
diff --git a/nfsidmap.map b/nfsidmap.map
new file mode 100644
index 0000000..540835c
--- /dev/null
+++ b/nfsidmap.map
@@ -0,0 +1,27 @@
+V_0.26 {
+global:
+	nfs4_init_name_mapping;
+	nfs4_get_default_domain;
+	nfs4_uid_to_name;
+	nfs4_gid_to_name;
+	nfs4_uid_to_owner;
+	nfs4_gid_to_group_owner;
+	nfs4_name_to_uid;
+	nfs4_name_to_gid;
+	nfs4_owner_to_uid;
+	nfs4_owner_to_gid;
+	nfs4_group_owner_to_gid;
+	nfs4_gss_princ_to_ids;
+	nfs4_gss_princ_to_grouplist;
+	nfs4_gss_princ_to_ids_ex;
+	nfs4_gss_princ_to_grouplist_ex;
+	nfs4_set_debug;
+local:
+	*;
+};
+/*
+V_0.27 {
+global:
+	...
+} V_0.26;
+*/
-- 
2.0.0

