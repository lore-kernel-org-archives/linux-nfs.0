From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/4] nfsd: fix Documentation typo
Date: Mon, 28 Sep 2009 12:22:29 -0400
Message-ID: <1254154952-13083-2-git-send-email-bfields@citi.umich.edu>
References: <1254154952-13083-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48553 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbZI1QWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 12:22:13 -0400
In-Reply-To: <1254154952-13083-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Caught by Benny, thanks!

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 Documentation/filesystems/nfs41-server.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/filesystems/nfs41-server.txt b/Documentation/filesystems/nfs41-server.txt
index 5920fe2..1f95e77 100644
--- a/Documentation/filesystems/nfs41-server.txt
+++ b/Documentation/filesystems/nfs41-server.txt
@@ -41,7 +41,7 @@ interoperability problems with future clients.  Known issues:
 	  conformant with the spec (for example, we don't use kerberos
 	  on the backchannel correctly).
 	- no trunking support: no clients currently take advantage of
-	  trunking, but this is a mandatory failure, and its use is
+	  trunking, but this is a mandatory feature, and its use is
 	  recommended to clients in a number of places.  (E.g. to ensure
 	  timely renewal in case an existing connection's retry timeouts
 	  have gotten too long; see section 8.3 of the draft.)
-- 
1.6.0.4

