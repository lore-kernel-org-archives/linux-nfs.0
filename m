Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:38627 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbaBWQWX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Feb 2014 11:22:23 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 9AE032807BB
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 17:22:21 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 8FC0613E9C
	for <linux-nfs@vger.kernel.org>; Sun, 23 Feb 2014 17:22:21 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tb16c2da43983a96160fd8@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Sun, 23 Feb 2014 17:22:21 +0100
From: tigran.mkrtchyan@desy.de
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs4: EXCLUSIVE4_1 should send file attrs with OPEN
Date: Sun, 23 Feb 2014 17:22:15 +0100
Message-Id: <1393172535-4617-2-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1393172535-4617-1-git-send-email-tigran.mkrtchyan@desy.de>
References: <1393172535-4617-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

to avoid extra SETATTR RPC call.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/nfs4proc.c | 2 +-
 fs/nfs/nfs4xdr.c  | 4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2da6a69..f22a72d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2259,7 +2259,7 @@ static int _nfs4_do_open(struct inode *dir,
 	state = ctx->state;
 
 	if ((opendata->o_arg.open_flags & O_EXCL) &&
-	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
+	    (opendata->o_arg.createmode == NFS4_CREATE_EXCLUSIVE)) {
 		nfs4_exclusive_attrset(opendata, sattr);
 
 		nfs_fattr_init(opendata->o_res.f_attr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 72f3bf1..cb4dc01 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1399,7 +1399,6 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 {
-	struct iattr dummy;
 	__be32 *p;
 
 	p = reserve_space(xdr, 4);
@@ -1419,8 +1418,7 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	case NFS4_CREATE_EXCLUSIVE4_1:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
-		dummy.ia_valid = 0;
-		encode_attrs(xdr, &dummy, arg->label, arg->server);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server);
 	}
 }
 
-- 
1.8.5.3

