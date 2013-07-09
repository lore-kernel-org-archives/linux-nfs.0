Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53881 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab3GIDT2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 23:19:28 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UwOSe-00010O-5a
	for linux-nfs@vger.kernel.org; Mon, 08 Jul 2013 23:19:28 -0400
Date: Mon, 8 Jul 2013 23:19:28 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: support minorversion 1 by default
Message-ID: <20130709031928.GN29071@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We now have minimal minorversion 1 support; turn it on by default.

This can still be turned off with "echo -4.1 >/proc/fs/nfsd/versions".

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfssvc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 262df5c..6b9f48c 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -116,7 +116,7 @@ struct svc_program		nfsd_program = {
 
 };
 
-u32 nfsd_supported_minorversion;
+u32 nfsd_supported_minorversion = 1;
 
 int nfsd_vers(int vers, enum vers_op change)
 {
-- 
1.7.9.5

