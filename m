Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:61964 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab3IBXZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 19:25:07 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] utils/exportfs/exports.man: quote command to preserve space
Date: Mon,  2 Sep 2013 19:24:55 -0400
Message-Id: <1378164295-2032-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/exportfs/exports.man | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index bc1de73..58c0f66 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -39,7 +39,7 @@ the export name using a backslash followed by the character code as three
 octal digits.
 .PP
 To apply changes to this file, run
-.BR exportfs \-ra
+.BR "exportfs \-ra"
 or restart the NFS server.
 .PP
 .SS Machine Name Formats
-- 
1.8.3.4

