Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21893 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756016Ab0J0TgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Oct 2010 15:36:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] Ensure we check libnfsidmap for function 'nfs4_owner_to_uid'
Date: Wed, 27 Oct 2010 15:35:56 -0400
Message-Id: <1288208156-13874-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1288208156-13874-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1288208156-13874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1288208156-13874-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The new idmapper requires a more recent version of libnfsidmap. Ensure
that autoconf checks for this.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 aclocal/libnfsidmap.m4 |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/aclocal/libnfsidmap.m4 b/aclocal/libnfsidmap.m4
index cfcde2f..00a1405 100644
--- a/aclocal/libnfsidmap.m4
+++ b/aclocal/libnfsidmap.m4
@@ -6,6 +6,9 @@ AC_DEFUN([AC_LIBNFSIDMAP], [
   AC_CHECK_LIB([nfsidmap], [nfs4_init_name_mapping], [libnfsidmap=1],
                [AC_MSG_ERROR([libnfsidmap not found.])])
 
+  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], ,
+               [AC_MSG_ERROR([libnfsidmap version too old.])])
+
   AC_CHECK_HEADERS([nfsidmap.h], ,
                    [AC_MSG_ERROR([libnfsidmap headers not found.])])
 
-- 
1.7.2.3

