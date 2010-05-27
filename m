From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 1/1] nfsiostat.man: Add linebreak before --version option
Date: Wed, 26 May 2010 18:28:20 -0700
Message-ID: <1274923700-18972-1-git-send-email-kevin.constantine@disneyanimation.com>
Cc: chuck.lever@oracle.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([198.187.190.101]:42019 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753131Ab0E0Bh7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 21:37:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsiostat man file was missing a linebreak before the --verbose option

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 tools/nfs-iostat/nfsiostat.man |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
index 7b1e0a8..99e04fb 100644
--- a/tools/nfs-iostat/nfsiostat.man
+++ b/tools/nfs-iostat/nfsiostat.man
@@ -57,6 +57,7 @@ displays statistics related to the page cache
 .TP
 .B \-s " or " \-\-sort
 Sort NFS mount points by ops/second
+.TP
 .B \-\-version
 show program's version number and exit
 .SH FILES
-- 
1.6.5.2

