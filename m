Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34332 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489AbbG1LNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:13:22 -0400
Received: by pdbbh15 with SMTP id bh15so69255721pdb.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:13:22 -0700 (PDT)
Message-ID: <55B763C8.1050408@gmail.com>
Date: Tue, 28 Jul 2015 19:13:12 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 4/5] NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Client sends a SETATTR request after OPEN for updating attributes.
For create file with S_ISGID is set, the SETATTR will be not set S_ISGID
as chmod of no PERMISSION.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 fs/nfs/nfs4xdr.c  | 4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8bee934..801f5f4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2413,7 +2413,7 @@ static int _nfs4_do_open(struct inode *dir,
 	state = ctx->state;
 
 	if ((opendata->o_arg.open_flags & O_EXCL) &&
-	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
+	    (opendata->o_arg.createmode == NFS4_CREATE_EXCLUSIVE)) {
 		nfs4_exclusive_attrset(opendata, sattr);
 
 		nfs_fattr_init(opendata->o_res.f_attr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 558cd65d..b5147bc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1382,7 +1382,6 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 {
-	struct iattr dummy;
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
@@ -1402,8 +1401,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	case NFS4_CREATE_EXCLUSIVE4_1:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
-		dummy.ia_valid = 0;
-		encode_attrs(xdr, &dummy, arg->label, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
 	}
 }
 
-- 
2.4.3

