Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:37234 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbaGUVVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 17:21:48 -0400
From: Kamal Mostafa <kamal@canonical.com>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Kamal Mostafa <kamal@canonical.com>, kernel-team@lists.ubuntu.com
Subject: [3.8.y.z extended stable] Patch "NFS: populate ->net in mount data when remounting" has been added to staging queue
Date: Mon, 21 Jul 2014 14:21:44 -0700
Message-Id: <1405977704-2628-1-git-send-email-kamal@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a note to let you know that I have just added a patch titled

    NFS: populate ->net in mount data when remounting

to the linux-3.8.y-queue branch of the 3.8.y.z extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.8.y-queue

This patch is scheduled to be released in version 3.8.13.27.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.8.y.z tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

------

>From e6468e9aa021873e938ae5b44c09b873e42bee91 Mon Sep 17 00:00:00 2001
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
index b056b16..f4d000a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2167,6 +2167,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
 	data->nfs_server.port = nfss->port;
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
+	data->net = current->nsproxy->net_ns;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);

--
1.9.1

