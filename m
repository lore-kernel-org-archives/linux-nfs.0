Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:48281 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab1HFHlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 03:41:32 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH 4/6] nfsiostat.man: Fix missing I in ".I <interval>"
Date: Sat,  6 Aug 2011 09:41:17 +0200
Message-Id: <1312616479-312-5-git-send-email-luk@debian.org>
In-Reply-To: <1312616479-312-1-git-send-email-luk@debian.org>
References: <1312616479-312-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix syntax for missing I in .I according to a patch from Simon Paillard <spaillard@debian.org> in Debian bug #624261.

Signed-off-by: Luk Claes <luk@debian.org>
---
 tools/nfs-iostat/nfsiostat.man |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
index 99e04fb..3ec245d 100644
--- a/tools/nfs-iostat/nfsiostat.man
+++ b/tools/nfs-iostat/nfsiostat.man
@@ -24,7 +24,7 @@ parameter is
 specified, the value of 
 .I <count> 
 determines the number of reports generated at
-. <interval> 
+.I <interval> 
 seconds apart. if the interval parameter is 
 specified without the
 .I <count> 
-- 
1.7.5.4

