Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:40806 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742Ab3CXUwo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Mar 2013 16:52:44 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 8E56933D3D7
	for <linux-nfs@vger.kernel.org>; Sun, 24 Mar 2013 20:52:43 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH [nfs-utils]] README: drop version from file
Date: Sun, 24 Mar 2013 16:56:58 -0400
Message-Id: <1364158618-24619-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It clearly doesn't get maintained, so punt it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 README | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/README b/README
index 61702f7..7034c00 100644
--- a/README
+++ b/README
@@ -1,4 +1,4 @@
-This is version 1.2.6 of nfs-utils, the Linux NFS utility package.
+This is nfs-utils, the Linux NFS userland utility package.
 
 
 0. PROJECT RESOURCES
-- 
1.8.1.2

