From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NFS: Fix up data types of fields in
	nfs_parsed_mount_options
Date: Thu, 31 Jan 2008 15:00:27 -0500
Message-ID: <20080131200027.17975.69157.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: miklos@szeredi.hu, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:53933 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759360AbYAaUBB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2008 15:01:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: make data types of fields in nfs_parsed_mount_options more
consistent with other uses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0f56196..4769ed6 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -45,9 +45,9 @@ struct nfs_parsed_mount_data {
 		struct sockaddr_storage	address;
 		size_t			addrlen;
 		char			*hostname;
-		unsigned int		version;
+		u32			version;
 		unsigned short		port;
-		int			protocol;
+		unsigned short		protocol;
 	} mount_server;
 
 	struct {
@@ -55,7 +55,7 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
-		int			protocol;
+		unsigned short		protocol;
 	} nfs_server;
 };
 

