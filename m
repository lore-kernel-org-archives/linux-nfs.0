Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:33254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751898AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 885DAEB70C
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 711BB10A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 7/7] Added more -Werror= warning flags
Date: Tue, 20 Feb 2018 13:50:34 -0500
Message-Id: <20180220185034.26301-8-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some more -Werror warning flags that
didn't cause warnings but could catch
some in the future.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/configure.ac b/configure.ac
index b849f43..f4eba1f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -554,6 +554,19 @@ my_am_cflags="\
  -Werror=format=2 \
  -Werror=undef \
  -Werror=missing-include-dirs \
+ -Werror=strict-aliasing=2 \
+ -Werror=init-self \
+ -Werror=implicit-function-declaration \
+ -Werror=return-type \
+ -Werror=switch \
+ -Werror=overflow \
+ -Werror=int-conversion \
+ -Werror=parentheses \
+ -Werror=incompatible-pointer-types \
+ -Werror=misleading-indentation \
+ -Werror=aggregate-return \
+ -Werror=unused-result \
+ -fno-strict-aliasing \
 "
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
-- 
2.14.3

