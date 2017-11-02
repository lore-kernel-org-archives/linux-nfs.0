Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755759AbdKBPHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Nov 2017 11:07:24 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7376FC053FC2
        for <linux-nfs@vger.kernel.org>; Thu,  2 Nov 2017 15:07:24 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 332AD5D75E
        for <linux-nfs@vger.kernel.org>; Thu,  2 Nov 2017 15:07:24 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfs-utils: Remove dependency on libnfsidmap-devel package
Date: Thu,  2 Nov 2017 11:07:22 -0400
Message-Id: <20171102150723.31309-2-steved@redhat.com>
In-Reply-To: <20171102150723.31309-1-steved@redhat.com>
References: <20171102150723.31309-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Justin Mitchell <jumitche@redhat.com>

With commit a867b45 (Release: 2.2.1) the libnfsidmap-devel
package is now build from with the nfs-utils source tree.
So the programs dependent on libnfsidmap-devel need to
look inward verses outward for the nfsidmap.h header file.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/configure.ac b/configure.ac
index 9b2a502..c7651f2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -441,6 +441,8 @@ if test -n "$path_plugins" ; then
 fi
 AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
 
+AC_SUBST(AM_CPPFLAGS, "$AM_CPPFLAGS -I../../support/nfsidmap")
+
 dnl Check for IPv6 support
 AC_IPV6
 
-- 
2.13.6

