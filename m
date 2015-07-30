Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36189 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbG3NqD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:46:03 -0400
Received: by pdjr16 with SMTP id r16so25428824pdj.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:46:02 -0700 (PDT)
Message-ID: <55BA2A8C.3000904@gmail.com>
Date: Thu, 30 Jul 2015 21:45:48 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 7/7 v2] NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1
References: <55BA290B.2020704@gmail.com>
In-Reply-To: <55BA290B.2020704@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Client sends a SETATTR request after OPEN for updating attributes.
For create file with S_ISGID is set, the S_ISGID in SETATTR will be
ignored at nfs server as chmod of no PERMISSION.

v2, base on suppattr_exclcreat.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c       | 18 ++++++++++++++----
 fs/nfs/nfs4xdr.c        | 26 ++++++++++++++++++--------
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2a888cb..74ef70c3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2294,15 +2294,25 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
  * fields corresponding to attributes that were used to store the verifier.
  * Make sure we clobber those fields in the later setattr call
  */
-static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct iattr *sattr)
+static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
+				struct iattr *sattr, struct nfs4_label **label)
 {
-	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_ACCESS) &&
+	const u32 *attrset = opendata->o_res.attrset;
+
+	if ((attrset[1] & FATTR4_WORD1_TIME_ACCESS) &&
 	    !(sattr->ia_valid & ATTR_ATIME_SET))
 		sattr->ia_valid |= ATTR_ATIME;
 
-	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_MODIFY) &&
+	if ((attrset[1] & FATTR4_WORD1_TIME_MODIFY) &&
 	    !(sattr->ia_valid & ATTR_MTIME_SET))
 		sattr->ia_valid |= ATTR_MTIME;
+
+	/* Except MODE, it seems harmless of setting twice. */
+	if ((attrset[1] & FATTR4_WORD1_MODE))
+		sattr->ia_valid &= ~ATTR_MODE;
+
+	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
+		*label = NULL;
 }
 
 static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
@@ -2427,7 +2437,7 @@ static int _nfs4_do_open(struct inode *dir,
 
 	if ((opendata->o_arg.open_flags & O_EXCL) &&
 	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
-		nfs4_exclusive_attrset(opendata, sattr);
+		nfs4_exclusive_attrset(opendata, sattr, &label);
 
 		nfs_fattr_init(opendata->o_res.f_attr);
 		status = nfs4_do_setattr(state->inode, cred,
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc88fcf..7dfeff4 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1001,7 +1001,8 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
 
 static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 				const struct nfs4_label *label,
-				const struct nfs_server *server)
+				const struct nfs_server *server,
+				bool excl_check)
 {
 	char owner_name[IDMAP_NAMESZ];
 	char owner_group[IDMAP_NAMESZ];
@@ -1067,6 +1068,17 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 		bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
 		len += 4;
 	}
+
+	if (excl_check) {
+		const u32 *excl_bmval = server->exclcreat_bitmask;
+		bmval[0] &= excl_bmval[0];
+		bmval[1] &= excl_bmval[1];
+		bmval[2] &= excl_bmval[2];
+
+		if (!(excl_bmval[2] & FATTR4_WORD2_SECURITY_LABEL))
+			label = NULL;
+	}
+
 	if (label) {
 		len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
 		bmval[2] |= FATTR4_WORD2_SECURITY_LABEL;
@@ -1168,7 +1180,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	}
 
 	encode_string(xdr, create->name->len, create->name->name);
-	encode_attrs(xdr, create->attrs, create->label, create->server);
+	encode_attrs(xdr, create->attrs, create->label, create->server, false);
 }
 
 static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
@@ -1382,18 +1394,17 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 {
-	struct iattr dummy;
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
 	switch(arg->createmode) {
 	case NFS4_CREATE_UNCHECKED:
 		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
-		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false);
 		break;
 	case NFS4_CREATE_GUARDED:
 		*p = cpu_to_be32(NFS4_CREATE_GUARDED);
-		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false);
 		break;
 	case NFS4_CREATE_EXCLUSIVE:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
@@ -1402,8 +1413,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	case NFS4_CREATE_EXCLUSIVE4_1:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
-		dummy.ia_valid = 0;
-		encode_attrs(xdr, &dummy, arg->label, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, true);
 	}
 }
 
@@ -1659,7 +1669,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 {
 	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &arg->stateid);
-	encode_attrs(xdr, arg->iap, arg->label, server);
+	encode_attrs(xdr, arg->iap, arg->label, server, false);
 }
 
 static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index aac795b..ba28126 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -379,7 +379,7 @@ struct nfs_openargs {
 	struct stateowner_id	id;
 	union {
 		struct {
-			struct iattr *  attrs;    /* UNCHECKED, GUARDED */
+			struct iattr *  attrs;    /* UNCHECKED, GUARDED, EXCLUSIVE4_1 */
 			nfs4_verifier   verifier; /* EXCLUSIVE */
 		};
 		nfs4_stateid	delegation;		/* CLAIM_DELEGATE_CUR */
-- 
2.4.3

