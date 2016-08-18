Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40086 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755231AbcHSB5J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 21:57:09 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B250D79718
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 18:37:17 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7IIbGGT014077
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 14:37:17 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH 2/3] configure.ac: Ensure the resolver library is installed
Date: Thu, 18 Aug 2016 14:37:14 -0400
Message-Id: <1471545435-15543-2-git-send-email-steved@redhat.com>
In-Reply-To: <1471545435-15543-1-git-send-email-steved@redhat.com>
References: <1471545435-15543-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 1 +
 1 file changed, 1 insertion(+)

diff --git a/configure.ac b/configure.ac
index 5944166..52e12c8 100644
--- a/configure.ac
+++ b/configure.ac
@@ -13,6 +13,7 @@ LT_INIT
 AC_PROG_CC
 
 # Checks for libraries.
+AC_CHECK_LIB([resolv], [res_querydomain])
 
 AC_ARG_ENABLE([ldap],
 	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:@default=detect@:>@])])
-- 
2.7.4

