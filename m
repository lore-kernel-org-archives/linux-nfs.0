Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbcDFSaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2016 14:30:52 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: steved@redhat.com
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils] mount.nfs: skip server address resolution on remount
Date: Wed,  6 Apr 2016 14:30:49 -0400
Message-Id: <83c9ef2c8e6c5ece11791e5c39609a1db9f716de.1459967426.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A remount might fail if name resolution returns a different server address,
as might occur if there are multiple name records for the server.  Since we
cannot change the server's address on a remount anyway, skip the lookup and
remove any set addresses in the options.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/mount/stropts.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 86829a9..634b58c 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -383,13 +383,26 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_nfs_proto_family(mi->options, &family))
 		return 0;
 
-	hint.ai_family = (int)family;
-	error = getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
-	if (error != 0) {
-		nfs_error(_("%s: Failed to resolve server %s: %s"),
-			progname, mi->hostname, gai_strerror(error));
-		mi->address = NULL;
-		return 0;
+	/*
+	 * A remount is not going to be able to change the server's address,
+	 * nor should we try to resolve another address for the server as we
+	 * may end up with a different address.
+	 */
+	if (mi->flags & MS_REMOUNT) {
+		po_remove_all(mi->options, "addr");
+	} else {
+		hint.ai_family = (int)family;
+		error = getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
+		if (error != 0) {
+			nfs_error(_("%s: Failed to resolve server %s: %s"),
+				progname, mi->hostname, gai_strerror(error));
+			mi->address = NULL;
+			return 0;
+		}
+
+		if (!nfs_append_addr_option(mi->address->ai_addr,
+						mi->address->ai_addrlen, mi->options))
+			return 0;
 	}
 
 	if (!nfs_set_version(mi))
@@ -398,10 +411,6 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
-	if (!nfs_append_addr_option(mi->address->ai_addr,
-					mi->address->ai_addrlen, mi->options))
-		return 0;
-
 	return 1;
 }
 
-- 
1.7.1

