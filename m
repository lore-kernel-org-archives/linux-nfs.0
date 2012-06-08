Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3516 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757779Ab2FHPdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 11:33:00 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, joro@8bytes.org,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Use the NFS_DEFAULT_VERSION for v2 and v3 mounts
Date: Fri,  8 Jun 2012 11:32:56 -0400
Message-Id: <1339169576-27307-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Older versions of nfs utils don't always pass a "vers=" mount option for
NFS.  This chould lead to attempts at using NFS v0 due to a zeroed out
nfs_parsed_mount_data struct.  I solve this by setting the default NFS
version to NFS_DEFAULT_VERSION in the v2 and v3 cases (v4 has already been
taken care of by a similar patch).

Reported-by: Joerg Roedel <joro@&bytes.org>
Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ff656c0..97a3b30 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1867,6 +1867,7 @@ static int nfs23_validate_mount_data(void *options,
 	if (data == NULL)
 		goto out_no_data;
 
+	args->version = NFS_DEFAULT_VERSION;
 	switch (data->version) {
 	case 1:
 		data->namlen = 0;
-- 
1.7.10.3

