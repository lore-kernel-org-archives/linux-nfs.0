From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NFS: Fix up data types of fields in
	nfs_parsed_mount_options
Date: Fri, 14 Mar 2008 14:10:15 -0400
Message-ID: <20080314181015.29830.5951.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:9822 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755933AbYCNSKc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:10:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: make data types of fields in nfs_parsed_mount_options more
consistent with other uses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9319927..6e1b943 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -46,9 +46,9 @@ struct nfs_parsed_mount_data {
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
@@ -56,7 +56,7 @@ struct nfs_parsed_mount_data {
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
-		int			protocol;
+		unsigned short		protocol;
 	} nfs_server;
 
 	struct security_mnt_opts lsm_opts;

