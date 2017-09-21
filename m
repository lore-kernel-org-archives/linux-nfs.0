Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751629AbdIUOim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Sep 2017 10:38:42 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3C1AE81E03
        for <linux-nfs@vger.kernel.org>; Thu, 21 Sep 2017 14:38:42 +0000 (UTC)
From: Rinku Kothiya <rkothiya@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: [PATCH] Added method used for inherit-only flag by linux bz 1493905
Date: Thu, 21 Sep 2017 20:08:35 +0530
Message-Id: <1506004715-10767-1-git-send-email-rkothiya@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 nfs4_acl.5 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4_acl.5 b/nfs4_acl.5
index 224df9b..9e77048 100644
--- a/nfs4_acl.5
+++ b/nfs4_acl.5
@@ -264,7 +264,7 @@ added.  The former is the "effective" inherited ACE (used in the subdirectory's
 own permissions checks); the latter is the "heritable" inherited ACE (when the 
 subdirectory has directories created within it, they inherit it).  This approach 
 makes it easier to modify access rights to the subdirectory itself without 
-modifying its heritable ACEs.
+modifying its heritable ACEs. Linux uses this approach. 
 .PP
 .ns
 .SH A WARNING ABOUT DENY ACES 
-- 
2.7.5

