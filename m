Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54479 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733Ab1KAWOL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Nov 2011 18:14:11 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RLMaw-00013t-Se
	for linux-nfs@vger.kernel.org; Tue, 01 Nov 2011 18:14:10 -0400
Date: Tue, 1 Nov 2011 18:14:10 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Update NFSD MAINTAINER
Message-ID: <20111101221410.GC1891@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.de>

Neil hasn't really been at all active as a maintainer for some years now.
So move his maintainership to CREDITS

(But thanks to Neil for continuing help with nfsd!--jbf)

Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 CREDITS     |    5 +++++
 MAINTAINERS |    1 -
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/CREDITS b/CREDITS
index 07e32a8..557da47 100644
--- a/CREDITS
+++ b/CREDITS
@@ -514,6 +514,11 @@ S: Bessemerstraat 21
 S: Amsterdam
 S: The Netherlands
 
+N: NeilBrown
+E: neil@brown.name
+P: 4096R/566281B9 1BC6 29EB D390 D870 7B5F  497A 39EC 9EDD 5662 81B9
+D: NFSD Maintainer 2000-2007
+
 N: Zach Brown
 E: zab@zabbo.net
 D: maestro pci sound
diff --git a/MAINTAINERS b/MAINTAINERS
index 51d42fb..37fffbc 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3685,7 +3685,6 @@ S:	Odd Fixes
 
 KERNEL NFSD, SUNRPC, AND LOCKD SERVERS
 M:	"J. Bruce Fields" <bfields@fieldses.org>
-M:	Neil Brown <neilb@suse.de>
 L:	linux-nfs@vger.kernel.org
 W:	http://nfs.sourceforge.net/
 S:	Supported
-- 
1.7.5.4

