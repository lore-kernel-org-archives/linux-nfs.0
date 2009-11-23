From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 08/10] nfs41: add support for the exclusive create flags
Date: Mon, 23 Nov 2009 13:54:45 -0800
Message-ID: <1259013287-3349-8-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
 <1259013287-3349-5-git-send-email-batsakis@netapp.com>
 <1259013287-3349-6-git-send-email-batsakis@netapp.com>
 <1259013287-3349-7-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757290AbZKWV7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:25 -0500
In-Reply-To: <1259013287-3349-7-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In v4.1 the client MUST/SHOULD use the EXCLUSIVE4_1 flag instead of
EXCLUSIVE4, and GUARDED when the server supports persistent sessions.
For now (and until we support suppattr_exclcreat), we don't send any
attributes with EXCLUSIVE4_1 relying in the subsequent SETATTR as in v4.0

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |   12 +++++++++---
 fs/nfs/nfs4xdr.c  |   23 ++++++++++++++++++++---
 2 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef77d40..2de209c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -720,9 +720,15 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
 	p->o_arg.bitmask = server->attr_bitmask;
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
 	if (flags & O_EXCL) {
-		u32 *s = (u32 *) p->o_arg.u.verifier.data;
-		s[0] = jiffies;
-		s[1] = current->pid;
+		if (nfs4_has_persistent_session(server->nfs_client)) {
+			/* GUARDED */
+			p->o_arg.u.attrs = &p->attrs;
+			memcpy(&p->attrs, attrs, sizeof(p->attrs));
+		} else { /* EXCLUSIVE4_1 */
+			u32 *s = (u32 *) p->o_arg.u.verifier.data;
+			s[0] = jiffies;
+			s[1] = current->pid;
+		}
 	} else if (flags & O_CREAT) {
 		p->o_arg.u.attrs = &p->attrs;
 		memcpy(&p->attrs, attrs, sizeof(p->attrs));
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc36af4..3875759 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -52,6 +52,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_idmap.h>
 #include "nfs4_fs.h"
+#include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
 
@@ -135,7 +136,7 @@ static int nfs4_stat_to_errno(int);
 #define decode_lookup_maxsz	(op_decode_hdr_maxsz)
 #define encode_share_access_maxsz \
 				(2)
-#define encode_createmode_maxsz	(1 + encode_attrs_maxsz)
+#define encode_createmode_maxsz	(1 + encode_attrs_maxsz + encode_verifier_maxsz)
 #define encode_opentype_maxsz	(1 + encode_createmode_maxsz)
 #define encode_claim_null_maxsz	(1 + nfs4_name_maxsz)
 #define encode_open_maxsz	(op_encode_hdr_maxsz + \
@@ -1154,6 +1155,7 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 {
 	__be32 *p;
+	struct nfs_client *clp;
 
 	p = reserve_space(xdr, 4);
 	switch(arg->open_flags & O_EXCL) {
@@ -1162,8 +1164,23 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 		encode_attrs(xdr, arg->u.attrs, arg->server);
 		break;
 	default:
-		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
-		encode_nfs4_verifier(xdr, &arg->u.verifier);
+		clp = arg->server->nfs_client;
+		if (clp->cl_minorversion > 0) {
+			if (nfs4_has_persistent_session(clp)) {
+				*p = cpu_to_be32(NFS4_CREATE_GUARDED);
+				encode_attrs(xdr, arg->u.attrs, arg->server);
+			} else {
+				struct iattr dummy;
+
+				*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
+				encode_nfs4_verifier(xdr, &arg->u.verifier);
+				dummy.ia_valid = 0;
+				encode_attrs(xdr, &dummy, arg->server);
+			}
+		} else {
+			*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
+			encode_nfs4_verifier(xdr, &arg->u.verifier);
+		}
 	}
 }
 
-- 
1.6.2.5

