Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:45576 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753017Ab1CJPnX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 10:43:23 -0500
From: Mark Brown <broonie@opensource.wolfsonmicro.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, patches@opensource.wolfsonmicro.com,
        Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] NFS: Fix handling of commmand line options for NFSROOT
Date: Thu, 10 Mar 2011 15:43:18 +0000
Message-Id: <1299771798-29285-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commmit 972903 (NFS: NFSROOT should default to "proto=udp") added a
default NFS mount option using the existing in-kernel code to parse
mount options out of the command line. This exposed a bug in the
existing code - it would not add a , separating the existing options
from the new options resulting in strings such as "udprsize=1024"
rather than "udp,rsize=1024"

Fix this by adding a , before the new options if the options are not
empty when we append.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 fs/nfs/nfsroot.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 0bc654f..309df59 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -193,10 +193,15 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
 	 * @incoming now points to the rest of the string; if it
 	 * contains something, append it to our root options buffer
 	 */
-	if (incoming != NULL && *incoming != '\0')
+	if (incoming != NULL && *incoming != '\0') {
+		if (nfs_root_options[0] != '\0' &&
+		    root_nfs_cat(nfs_root_options, ",",
+						sizeof(nfs_root_options)))
+			return -1;
 		if (root_nfs_cat(nfs_root_options, incoming,
 						sizeof(nfs_root_options)))
 			return -1;
+	}
 
 	/*
 	 * Possibly prepare for more options to be appended
-- 
1.7.2.3

