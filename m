Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36084 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753059AbeAQWLB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jan 2018 17:11:01 -0500
Received: by mail-io0-f193.google.com with SMTP id l17so12706755ioc.3
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jan 2018 14:11:01 -0800 (PST)
Subject: [PATCH] Remove unneeded reference to nfsidmap_internal.h
From: Chuck Lever <chuck.lever@oracle.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Jan 2018 17:10:59 -0500
Message-ID: <20180117221020.11056.59627.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This file is not part of "git clone" and is not #included from any
C file.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 support/nfsidmap/Makefile.am |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Hey Steve-

I don't see nfsidmap_internal.h anywhere.  Wondering if I missed
something?

diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
index 9466f92..8b5dfe4 100644
--- a/support/nfsidmap/Makefile.am
+++ b/support/nfsidmap/Makefile.am
@@ -25,7 +25,7 @@ pkgplugin_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_L
 #  <age> 	The number of previous additional interfaces supported
 #  		by this library.
 
-libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_internal.h nfsidmap_common.c
+libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_common.c
 libnfsidmap_la_LDFLAGS = -version-info 1:0:0
 libnfsidmap_la_LIBADD = -ldl ../../support/nfs/libnfsconf.la
 

