Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:51933 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467Ab3ESNlH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 May 2013 09:41:07 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id BDD4828042A
	for <linux-nfs@vger.kernel.org>; Sun, 19 May 2013 15:30:27 +0200 (CEST)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 7A14213E96
	for <linux-nfs@vger.kernel.org>; Sun, 19 May 2013 15:30:25 +0200 (MEST)
From: tigran.mkrtchyan@desy.de
To: linux-nfs@vger.kernel.org
Cc: bfields@fieldses.org, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] fix typo in the man page
Date: Sun, 19 May 2013 15:27:59 +0200
Message-Id: <1368970079-10028-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>


Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 man/man5/nfs4_acl.5 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man5/nfs4_acl.5 b/man/man5/nfs4_acl.5
index 6b4fa88..3d5731f 100644
--- a/man/man5/nfs4_acl.5
+++ b/man/man5/nfs4_acl.5
@@ -202,7 +202,7 @@ if either this
 .I permission 
 is set in the file/directory or if the delete-child 
 .I permission
-is set in its parent direcory.
+is set in its parent directory.
 .TP
 .B D
 delete-child - remove a file or subdirectory from within the given directory
-- 
1.8.1.4

