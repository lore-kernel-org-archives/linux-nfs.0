Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753693Ab1IVTpE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 15:45:04 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj3hV017829
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:03 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj088012846
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:03 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] configure.ac: Added a v4.1 dependency on v4.0
Date: Thu, 22 Sep 2011 15:44:59 -0400
Message-Id: <1316720699-2611-4-git-send-email-steved@redhat.com>
In-Reply-To: <1316720699-2611-1-git-send-email-steved@redhat.com>
References: <1316720699-2611-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Make sure v4.0 is enabled when v4.1 is enabled.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index 61b9c00..a7b418d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -76,6 +76,9 @@ AC_ARG_ENABLE(nfsv41,
 	enable_nfsv41=$enableval,
 	enable_nfsv41=yes)
 	if test "$enable_nfsv41" = yes; then
+		if test "$enable_nfsv4" != yes; then
+			AC_MSG_ERROR([NFS v4.1 is enabled but NFS v4 is not. Use --disable-nfsv41])
+		fi
 		BLKMAPD=blkmapd
 	else
 		enable_nfsv41=
-- 
1.7.6.2

