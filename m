Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39867 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab3AUUq7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:46:59 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 07/13] nfs: Pass srcaddr into mount request.
Date: Mon, 21 Jan 2013 12:45:53 -0800
Message-Id: <1358801159-18829-8-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This starts tying the srcaddr logic together.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |    1 +
 fs/nfs/super.c      |    2 ++
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index dbb2ee7..f4584b7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -148,6 +148,7 @@ struct nfs_parsed_mount_data {
 /* mount_clnt.c */
 struct nfs_mount_request {
 	struct sockaddr		*sap;
+	struct sockaddr         *srcaddr;
 	size_t			salen;
 	char			*hostname;
 	char			*dirpath;
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 015f71f..e574f3f 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -155,6 +155,7 @@ int nfs_mount(struct nfs_mount_request *info)
 	struct rpc_create_args args = {
 		.net		= info->net,
 		.protocol	= info->protocol,
+		.saddress	= info->srcaddr,
 		.address	= info->sap,
 		.addrsize	= info->salen,
 		.servername	= info->hostname,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 61b3dc9..57f0da3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1710,6 +1710,8 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
 						&args->mount_server.address,
+		.salen		= args->mount_server.addrlen,
+		.srcaddr	= (struct sockaddr *)&args->srcaddr.address,
 		.dirpath	= args->nfs_server.export_path,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
-- 
1.7.3.4

