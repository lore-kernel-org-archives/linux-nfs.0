From: Liuwenyi <qingshenlwy@gmail.com>
Subject: [PATCHv2 09/12]posix_acl: Add the check items
Date: Mon, 21 Dec 2009 19:59:52 +0800
Message-ID: <4B2F6338.2040609@gmail.com>
Reply-To: qingshenlwy@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
To: bfields@fieldses.org, neilb@suse.de, ffilzlnx@us.ibm.com,
	bharrosh@panasas.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, strongzgy@gmail.com,
	onlyflyer@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756678AbZLUL4q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

move the ACL validation check in to fs/posix_acl.c.
Including nullpointer check and PTR_ERR check.

---
Signed-off-by: Liuwenyi <qingshenlwy@gmail.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Frank Filz <ffilzlnx@us.ibm.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

---

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 8815068..0c2cd6c 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -135,27 +135,21 @@ nfs4_acl_posix_to_nfsv4(struct posix_acl *pacl,
struct posix_acl *dpacl,
struct nfs4_acl *acl;
int size = 0;

- if (pacl) {
- if (posix_acl_valid(pacl) < 0)
- return ERR_PTR(-EINVAL);
- size += 2*pacl->a_count;
- }
- if (dpacl) {
- if (posix_acl_valid(dpacl) < 0)
- return ERR_PTR(-EINVAL);
- size += 2*dpacl->a_count;
- }
+ if (posix_acl_valid(pacl) < 0)
+ return ERR_PTR(-EINVAL);
+ size += 2*pacl->a_count;
+
+ if (posix_acl_valid(dpacl) < 0)
+ return ERR_PTR(-EINVAL);
+ size += 2*dpacl->a_count;

/* Allocate for worst case: one (deny, allow) pair each: */
acl = nfs4_acl_new(size);
if (acl == NULL)
return ERR_PTR(-ENOMEM);

- if (pacl)
- _posix_to_nfsv4_one(pacl, acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
-
- if (dpacl)
- _posix_to_nfsv4_one(dpacl, acl, flags | NFS4_ACL_TYPE_DEFAULT);
+ _posix_to_nfsv4_one(pacl, acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
+ _posix_to_nfsv4_one(dpacl, acl, flags | NFS4_ACL_TYPE_DEFAULT);

return acl;
}

-- 
Best Regards,
Liuwenyi
