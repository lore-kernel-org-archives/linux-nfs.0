Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:32776 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751182AbeC2F7y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2018 01:59:54 -0400
Subject: [PATCH v2] NFSv3/acl: forget acl cache after setattr
From: chendt <chendt.fnst@cn.fujitsu.com>
To: <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>
References: <ca4d7366-bc4c-1710-13a2-f99510c53be4@cn.fujitsu.com>
Message-ID: <2a720d30-6471-5352-56a3-3d615bff5352@cn.fujitsu.com>
Date: Thu, 29 Mar 2018 14:01:21 +0800
MIME-Version: 1.0
In-Reply-To: <ca4d7366-bc4c-1710-13a2-f99510c53be4@cn.fujitsu.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sync of ACL with std permissions fail，We need to forget the ACL cache after setattr.

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
ls -l testfile
chacl -l testfile

Output：
-rw-rwxrw- 1 root root 0 Mar 28 05:29 testfile
testfile [u::r--,g::rwx,o::rw-]

Signed-off-by: chendt.fnst <chendt.fnst@cn.fujitsu.com>
Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs3proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 7327930..fcb0c40 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -139,6 +139,8 @@
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	if (status == 0)
+		if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
+			nfs_zap_acl_cache(inode);
 		nfs_setattr_update_inode(inode, sattr, fattr);
 	dprintk("NFS reply setattr: %d\n", status);
 	return status;
-- 
1.8.3.1


