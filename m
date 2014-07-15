Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:53222 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbaGOV3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 17:29:42 -0400
From: Kamal Mostafa <kamal@canonical.com>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kamal Mostafa <kamal@canonical.com>, kernel-team@lists.ubuntu.com
Subject: [3.13.y.z extended stable] Patch "NFS: populate ->net in mount data when remounting" has been added to staging queue
Date: Tue, 15 Jul 2014 14:29:39 -0700
Message-Id: <1405459779-11347-1-git-send-email-kamal@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    NFS: populate ->net in mount data when remounting

to the linux-3.13.y-queue branch of the 3.13.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.13.y-queue

This patch is scheduled to be released in version 3.13.11.5.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.13.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

------

>From 11011b30354f55150938e36cda49de819ca70ac8 Mon Sep 17 00:00:00 2001
From: Mateusz Guzik <mguzik@redhat.com>
Date: Tue, 10 Jun 2014 12:44:12 +0200
Subject: NFS: populate ->net in mount data when remounting

commit a914722f333b3359d2f4f12919380a334176bb89 upstream.

Otherwise the kernel oopses when remounting with IPv6 server because
net is dereferenced in dev_get_by_name.

Use net ns of current thread so that dev_get_by_name does not operate on
foreign ns. Changing the address is prohibited anyway so this should not
affect anything.

Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 fs/nfs/super.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 910ed90..05c3a6e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2246,6 +2246,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
 	data->version = nfsvers;
 	data->minorversion = nfss->nfs_client->cl_minorversion;
+	data->net = current->nsproxy->net_ns;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);

--
1.9.1

