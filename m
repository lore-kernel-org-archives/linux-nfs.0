Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757551Ab2JXPvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 11:51:55 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OFptRH023314
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 11:51:55 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OFprVr026851
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 11:51:55 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Git ignored things that are generated during the build
Date: Wed, 24 Oct 2012 11:49:01 -0400
Message-Id: <1351093741-7663-3-git-send-email-steved@redhat.com>
In-Reply-To: <1351093741-7663-1-git-send-email-steved@redhat.com>
References: <1351093741-7663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 .gitignore | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/.gitignore b/.gitignore
index 73ae869..c998d2d 100644
--- a/.gitignore
+++ b/.gitignore
@@ -9,3 +9,18 @@ missing
 ltmain.sh
 src/Makefile.in
 src/gssglue/config.h.in
+Makefile
+config.log
+config.status
+libgssglue.pc
+libtool
+src/.deps/
+src/Makefile
+src/gssglue/config.h
+src/gssglue/stamp-h1
+src/gssglue/gssapi/gssapi.h
+src/libgssglue.la
+src/.libs/
+src/*.o
+src/*.lo
+
-- 
1.7.11.7

