Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36323 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab2BSHu1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Feb 2012 02:50:27 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 1/2] NFS: Ensure that the nfs_client 'net' field is always set
Date: Sun, 19 Feb 2012 08:50:20 +0100
Message-Id: <1329637821-6986-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the nfs_parsed_mount_data->net field is initialised in
the nfs_parse_mount_options() function, which means that it only
gets set if we're using text based mounts. The legacy binary
mount interface is therefore broken.

Fix is to initialise the ->net field in nfs_alloc_parsed_mount_data.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/super.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d05024a..6708f30 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -911,6 +911,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 		data->auth_flavor_len	= 1;
 		data->version		= version;
 		data->minorversion	= 0;
+		data->net		= current->nsproxy->net_ns;
 		security_init_mnt_opts(&data->lsm_opts);
 	}
 	return data;
@@ -1110,8 +1111,6 @@ static int nfs_parse_mount_options(char *raw,
 
 	free_secdata(secdata);
 
-	mnt->net = current->nsproxy->net_ns;
-
 	while ((p = strsep(&raw, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
 		unsigned long option;
-- 
1.7.7.6

