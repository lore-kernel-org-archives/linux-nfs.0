Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:41806 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752737AbeC1KKr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 06:10:47 -0400
From: chendt <chendt.fnst@cn.fujitsu.com>
Subject: [PATCH] NFSv3/acl: forget acl cache after setattr
To: <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <ca4d7366-bc4c-1710-13a2-f99510c53be4@cn.fujitsu.com>
Date: Wed, 28 Mar 2018 18:12:23 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sync of ACL with std permissions fail，do We need to forget the ACL
cache after setattr?

Reproduction:
#!/bin/bash
touch testfile
cat <<EOF >testfile
#!/bin/bash
echo "Test was executed"
EOF
chmod u=rwx testfile
chmod g=rw- testfile
chmod o=r-- testfile

chacl u::r--,g::rwx,o:rw- testfile
chmod u+w testfile
ls -ln testfile
chacl -l testfile

Output：
-rw-rwxrw- 1 root root 0 Mar 28 05:29 testfile
testfile [u::r--,g::rwx,o::rw-]

Signed-off-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
---
 fs/nfs/nfs3proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 7327930..ef3e17c 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -140,6 +140,7 @@
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr, fattr);
+		forget_all_cached_acls(inode);
 	dprintk("NFS reply setattr: %d\n", status);
 	return status;
 }
-- 
1.8.3.1



