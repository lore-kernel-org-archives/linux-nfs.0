Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40086 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753025AbcLCDx5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Dec 2016 22:53:57 -0500
Date: Fri, 2 Dec 2016 22:53:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] nfsd: add support for the umask attribute
Message-ID: <20161203035357.GE21785@fieldses.org>
References: <20161203035302.GC21785@fieldses.org>
 <20161203035330.GD21785@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161203035330.GD21785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Clients can set the umask attribute when creating files to cause the
server to apply it always except when inheriting permissions from the
parent directory.  That way, the new files will end up with the same
permissions as files created locally.

See https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02 for more
details.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  3 +++
 fs/nfsd/nfs4xdr.c  | 26 +++++++++++++++++++++-----
 fs/nfsd/nfsd.h     |  9 +++++++--
 fs/nfsd/nfssvc.c   |  4 ++--
 4 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e901cf124e9f..74a6e573e061 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -102,6 +102,9 @@ check_attr_support(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_attrnotsupp;
 	if (writable && !bmval_is_subset(bmval, writable))
 		return nfserr_inval;
+	if (writable && (bmval[2] & FATTR4_WORD2_MODE_UMASK) &&
+			(bmval[1] & FATTR4_WORD1_MODE))
+		return nfserr_inval;
 	return nfs_ok;
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 281739e1d477..79edde4577b2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -33,6 +33,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/fs_struct.h>
 #include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/namei.h>
@@ -299,7 +300,7 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 static __be32
 nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		   struct iattr *iattr, struct nfs4_acl **acl,
-		   struct xdr_netobj *label)
+		   struct xdr_netobj *label, int *umask)
 {
 	int expected_len, len = 0;
 	u32 dummy32;
@@ -457,6 +458,17 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			return nfserr_jukebox;
 	}
 #endif
+	if (bmval[2] & FATTR4_WORD2_MODE_UMASK) {
+		if (!umask)
+			goto xdr_error;
+		READ_BUF(8);
+		len += 8;
+		dummy32 = be32_to_cpup(p++);
+		iattr->ia_mode = dummy32 & (S_IFMT | S_IALLUGO);
+		dummy32 = be32_to_cpup(p++);
+		*umask = dummy32 & S_IRWXUGO;
+		iattr->ia_valid |= ATTR_MODE;
+	}
 	if (len != expected_len)
 		goto xdr_error;
 
@@ -651,7 +663,8 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		return status;
 
 	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
-				    &create->cr_acl, &create->cr_label);
+				    &create->cr_acl, &create->cr_label,
+				    &current->fs->umask);
 	if (status)
 		goto out;
 
@@ -896,13 +909,15 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 	case NFS4_OPEN_NOCREATE:
 		break;
 	case NFS4_OPEN_CREATE:
+		current->fs->umask = 0;
 		READ_BUF(4);
 		open->op_createmode = be32_to_cpup(p++);
 		switch (open->op_createmode) {
 		case NFS4_CREATE_UNCHECKED:
 		case NFS4_CREATE_GUARDED:
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
-				&open->op_iattr, &open->op_acl, &open->op_label);
+				&open->op_iattr, &open->op_acl, &open->op_label,
+				&current->fs->umask);
 			if (status)
 				goto out;
 			break;
@@ -916,7 +931,8 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 			READ_BUF(NFS4_VERIFIER_SIZE);
 			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
-				&open->op_iattr, &open->op_acl, &open->op_label);
+				&open->op_iattr, &open->op_acl, &open->op_label,
+				&current->fs->umask);
 			if (status)
 				goto out;
 			break;
@@ -1153,7 +1169,7 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
 	if (status)
 		return status;
 	return nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr,
-				  &setattr->sa_acl, &setattr->sa_label);
+				  &setattr->sa_acl, &setattr->sa_label, NULL);
 }
 
 static __be32
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 7155239b2908..d74c8c44dc35 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -359,6 +359,7 @@ void		nfsd_lockd_shutdown(void);
 
 #define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | \
+	FATTR4_WORD2_MODE_UMASK | \
 	NFSD4_2_SECURITY_ATTRS)
 
 extern u32 nfsd_suppattrs[3][3];
@@ -390,10 +391,14 @@ static inline bool nfsd_attrs_supported(u32 minorversion, u32 *bmval)
 	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
 	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
-#define NFSD_WRITEABLE_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
+#define MAYBE_FATTR4_WORD2_SECURITY_LABEL \
+	FATTR4_WORD2_SECURITY_LABEL
 #else
-#define NFSD_WRITEABLE_ATTRS_WORD2 0
+#define MAYBE_FATTR4_WORD2_SECURITY_LABEL 0
 #endif
+#define NFSD_WRITEABLE_ATTRS_WORD2 \
+	(FATTR4_WORD2_MODE_UMASK \
+	| MAYBE_FATTR4_WORD2_SECURITY_LABEL)
 
 #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
 	NFSD_WRITEABLE_ATTRS_WORD0
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index a2b65fc56dd6..e6bfd96734c0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -661,8 +661,8 @@ nfsd(void *vrqstp)
 	mutex_lock(&nfsd_mutex);
 
 	/* At this point, the thread shares current->fs
-	 * with the init process. We need to create files with a
-	 * umask of 0 instead of init's umask. */
+	 * with the init process. We need to create files with the
+	 * umask as defined by the client instead of init's umask. */
 	if (unshare_fs_struct() < 0) {
 		printk("Unable to start nfsd thread: out of memory\n");
 		goto out;
-- 
2.9.3

