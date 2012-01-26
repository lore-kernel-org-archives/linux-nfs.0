Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61212 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab2AZVy3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 16:54:29 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/3] NFS: Update idmapper documentation
Date: Thu, 26 Jan 2012 16:54:25 -0500
Message-Id: <1327614865-29322-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 Documentation/filesystems/nfs/idmapper.txt |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/Documentation/filesystems/nfs/idmapper.txt b/Documentation/filesystems/nfs/idmapper.txt
index 120fd3c..fe03d10 100644
--- a/Documentation/filesystems/nfs/idmapper.txt
+++ b/Documentation/filesystems/nfs/idmapper.txt
@@ -4,13 +4,21 @@ ID Mapper
 =========
 Id mapper is used by NFS to translate user and group ids into names, and to
 translate user and group names into ids.  Part of this translation involves
-performing an upcall to userspace to request the information.  Id mapper will
-user request-key to perform this upcall and cache the result.  The program
-/usr/sbin/nfs.idmap should be called by request-key, and will perform the
-translation and initialize a key with the resulting information.
+performing an upcall to userspace to request the information.  There are two
+ways NFS could obtain this information: placing a call to /sbin/request-key
+or by placing a call to the rpc.idmap daemon.
+
+NFS will attempt to call /sbin/request-key first.  If this succeeds, the
+result will be cached using the generic request-key cache.  This call should
+only fail if /etc/request-key.conf is not configured for the id_resolver key
+type, see the "Configuring" section below if you wish to use the request-key
+method.
+
+If the call to /sbin/request-key fails (if /etc/request-key.conf is not
+configured with the id_resolver key type), then the idmapper will ask the
+legacy rpc.idmap daemon for the id mapping.  This result will be stored
+in a custom NFS idmap cache.
 
- NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
- feature.
 
 ===========
 Configuring
-- 
1.7.8.4

