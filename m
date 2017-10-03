Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from da1vs04.rockwellcollins.com ([205.175.227.52]:10361 "EHLO
        da1vs04.rockwellcollins.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751101AbdJCSnY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Oct 2017 14:43:24 -0400
From: Matt Weber <matthew.weber@rockwellcollins.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org,
        Matt Weber <matthew.weber@rockwellcollins.com>
Subject: [PATCH] nfs-utils: add missing include of stdint.h
Date: Tue,  3 Oct 2017 13:33:57 -0500
Message-Id: <1507055637-4928-1-git-send-email-matthew.weber@rockwellcollins.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Glibc bump to 2.26 exposed this missing header when building
with the following combination using an i386 internal toolchain.
gcc5.4.0
bin2.28.1
linux4.1.43

Upstream: https://bugzilla.linux-nfs.org/show_bug.cgi?id=312

Signed-off-by: Matthew Weber <matthew.weber@rockwellcollins.com>
---
 support/nsm/rpc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/nsm/rpc.c b/support/nsm/rpc.c
index 4e5f40e..d91c6ea 100644
--- a/support/nsm/rpc.c
+++ b/support/nsm/rpc.c
@@ -40,6 +40,7 @@
 
 #include <time.h>
 #include <stdbool.h>
+#include <stdint.h>
 #include <string.h>
 #include <unistd.h>
 #include <fcntl.h>
-- 
1.9.1

