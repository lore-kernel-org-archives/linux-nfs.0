Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:48576
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752786AbbIPSuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2015 14:50:18 -0400
Message-ID: <1442429367.24127.6.camel@localhost.localdomain>
Subject: [PATCH] Use a separate superblock if mount requires a different
 security flavor
From: Frank Filz <ffilzlnx@mindspring.com>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com, Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Sep 2015 11:49:27 -0700
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a server has two exports from the same filesystem but with different
security flavors allowed, when the client mounts first one and then the
second, the same super block was being used. This resulted in the
security flavor for the first export being applied to access to the
second export.

The fix is simply to check the security flavor of the nfs_server
temporarily constructed for the second mount within nfs_compare_super.

Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
---
 fs/nfs/super.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 084af10..44d60f1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2455,6 +2455,9 @@ static int nfs_compare_super(struct super_block
*sb, void *data)
        struct nfs_server *server = sb_mntdata->server, *old =
NFS_SB(sb);
        int mntflags = sb_mntdata->mntflags;
 
+       if(old->client->cl_auth->au_flavor
+          != server->client->cl_auth->au_flavor)
+               return 0;
        if (!nfs_compare_super_address(old, server))
                return 0;
        /* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
-- 
1.9.3



