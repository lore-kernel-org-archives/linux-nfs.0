Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbaKDQZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 11:25:06 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA4GP6Gr019714
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 4 Nov 2014 11:25:06 -0500
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA4GP6VS030736
	for <linux-nfs@vger.kernel.org>; Tue, 4 Nov 2014 11:25:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] build: Revert using a symbol version map
Date: Tue,  4 Nov 2014 11:25:04 -0500
Message-Id: <1415118304-5696-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 045d2e46 cause a number of systems to be
undefined during run time in rpc.idmapd.

Having this type of versioning is not necessary in
this type of a library so the patch was reverted.

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=1159943

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 Makefile.am  |  3 +--
 nfsidmap.map | 31 -------------------------------
 2 files changed, 1 insertion(+), 33 deletions(-)
 delete mode 100644 nfsidmap.map

diff --git a/Makefile.am b/Makefile.am
index 69bbcbc..85f19c8 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -26,9 +26,8 @@ pkglib_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_LIB)
 #  		by this library.
 
 libnfsidmap_la_SOURCES = libnfsidmap.c cfg.c strlcpy.c cfg.h nfsidmap_internal.h queue.h
-libnfsidmap_la_LDFLAGS = -version-info 3:0:3 -Wl,--version-script=$(srcdir)/nfsidmap.map
+libnfsidmap_la_LDFLAGS = -version-info 3:0:3
 libnfsidmap_la_LIBADD = -ldl
-libnfsidmap_la_DEPENDENCIES = nfsidmap.map
 
 nsswitch_la_SOURCES = nss.c
 nsswitch_la_LDFLAGS = -module -avoid-version
diff --git a/nfsidmap.map b/nfsidmap.map
deleted file mode 100644
index 1e7cf7e..0000000
--- a/nfsidmap.map
+++ /dev/null
@@ -1,31 +0,0 @@
-V_0.26 {
-global:
-	nfs4_init_name_mapping;
-	nfs4_get_default_domain;
-	nfs4_uid_to_name;
-	nfs4_gid_to_name;
-	nfs4_uid_to_owner;
-	nfs4_gid_to_group_owner;
-	nfs4_name_to_uid;
-	nfs4_name_to_gid;
-	nfs4_owner_to_uid;
-	nfs4_owner_to_gid;
-	nfs4_group_owner_to_gid;
-	nfs4_gss_princ_to_ids;
-	nfs4_gss_princ_to_grouplist;
-	nfs4_gss_princ_to_ids_ex;
-	nfs4_gss_princ_to_grouplist_ex;
-	nfs4_set_debug;
-	idmap_verbosity;
-	idmap_log_func;
-	get_default_domain;
-	get_local_realms;
-local:
-	*;
-};
-/*
-V_0.27 {
-global:
-	...
-} V_0.26;
-*/
-- 
1.9.3

