Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from brigitte.telenet-ops.be ([195.130.137.66]:49591 "EHLO
	brigitte.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698Ab1JBRjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Oct 2011 13:39:17 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH] nfs.man: Fix macro use
Date: Sun,  2 Oct 2011 19:40:13 +0200
Message-Id: <1317577213-26603-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The groff macros for filling (word-wrapping) and tabulation control are
lower-case, but are written in upper-case here and so have been ignored.

Change the .NF and .FI lines to lower-case.

Change the .TA lines to lower-case and fix the tab stops to work both
on a terminal and in Postscript output.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/mount/nfs.man |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index ce40933..2ad92d1 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1561,10 +1561,10 @@ To ensure that the saved mount options are not erased during a remount,
 specify either the local mount directory, or the server hostname and
 export pathname, but not both, during a remount.  For example,
 .P
-.NF
-.TA 2.5i
+.nf
+.ta 8n
 	mount -o remount,ro /mnt
-.FI
+.fi
 .P
 merges the mount option
 .B ro
-- 
1.7.6.3

