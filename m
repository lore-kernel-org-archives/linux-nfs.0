Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58967 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755882Ab1GOR6A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 13:58:00 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH (RESEND) 08/12] nfs:  Pass srcaddr into mount request.
Date: Fri, 15 Jul 2011 10:56:04 -0700
Message-Id: <1310752568-21280-9-git-send-email-greearb@candelatech.com>
In-Reply-To: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
References: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

This starts tying the srcaddr logic together.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 60a36a2... eaf9c66... M	fs/nfs/internal.h
:100644 100644 d4c2d6b... 5ca6e12... M	fs/nfs/mount_clnt.c
:100644 100644 cb41131... e45f616... M	fs/nfs/super.c
 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |    1 +
 fs/nfs/super.c      |    2 ++
 3 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 60a36a2..eaf9c66 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -133,6 +133,7 @@ struct nfs_parsed_mount_data {
 /* mount_clnt.c */
 struct nfs_mount_request {
 	struct sockaddr		*sap;
+	struct sockaddr         *srcaddr;
 	size_t			salen;
 	char			*hostname;
 	char			*dirpath;
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index d4c2d6b..5ca6e12 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -155,6 +155,7 @@ int nfs_mount(struct nfs_mount_request *info)
 	struct rpc_create_args args = {
 		.net		= &init_net,
 		.protocol	= info->protocol,
+		.saddress	= info->srcaddr,
 		.address	= info->sap,
 		.addrsize	= info->salen,
 		.servername	= info->hostname,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cb41131..e45f616 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1600,6 +1600,8 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
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

