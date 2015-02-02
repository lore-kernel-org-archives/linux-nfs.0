Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:35120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932174AbbBBQP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 11:15:59 -0500
Date: Mon, 2 Feb 2015 11:15:57 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150202161557.GF22301@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The code seems to work.  The protocol looks stable.  The kernel's
version defaults can be overridden by rpc.nfsd arguments.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 314f5c8f8f1a..9277cc91c21b 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -119,6 +119,7 @@ struct svc_program		nfsd_program = {
 static bool nfsd_supported_minorversions[NFSD_SUPPORTED_MINOR_VERSION + 1] = {
 	[0] = 1,
 	[1] = 1,
+	[2] = 1,
 };
 
 int nfsd_vers(int vers, enum vers_op change)
-- 
1.9.3

