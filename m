Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:40951 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbeC0VML (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 17:12:11 -0400
Received: by mail-io0-f195.google.com with SMTP id e79so953747ioi.7
        for <linux-nfs@vger.kernel.org>; Tue, 27 Mar 2018 14:12:11 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix exclusive create
Date: Tue, 27 Mar 2018 17:11:37 -0400
Message-Id: <20180327211137.44171-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we use EXCLUSIVE4_1 mode, the server returns an attribute mask where
all the bits indicate which attributes were set, and where the verifier
was stored. In order to figure out which attribute we have to resend,
we need to clear out the attributes that are set in exclcreat_bitmask.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
Should this be a stable patch?

 fs/nfs/nfs4proc.c | 46 ++++++++++++++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6933109fa30f..f73587f0fc57 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2750,27 +2750,37 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
  * fields corresponding to attributes that were used to store the verifier.
  * Make sure we clobber those fields in the later setattr call
  */
-static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
+static unsigned nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
 				struct iattr *sattr, struct nfs4_label **label)
 {
-	const u32 *attrset = opendata->o_res.attrset;
+	const __u32 *bitmask = opendata->o_arg.server->exclcreat_bitmask;
+	__u32 attrset[3];
+	unsigned ret = 0;
+	unsigned i;
 
-	if ((attrset[1] & FATTR4_WORD1_TIME_ACCESS) &&
-	    !(sattr->ia_valid & ATTR_ATIME_SET))
-		sattr->ia_valid |= ATTR_ATIME;
+	for (i = 0; i < ARRAY_SIZE(attrset); i++) {
+		attrset[i] = opendata->o_res.attrset[i];
+		if (opendata->o_arg.createmode == NFS4_CREATE_EXCLUSIVE4_1)
+			attrset[i] &= ~bitmask[i];
+	}
 
-	if ((attrset[1] & FATTR4_WORD1_TIME_MODIFY) &&
-	    !(sattr->ia_valid & ATTR_MTIME_SET))
-		sattr->ia_valid |= ATTR_MTIME;
+	if ((attrset[1] & (FATTR4_WORD1_TIME_ACCESS|FATTR4_WORD1_TIME_ACCESS_SET))) {
+		if (sattr->ia_valid & ATTR_ATIME_SET)
+			ret |= ATTR_ATIME_SET;
+		else
+			ret |= ATTR_ATIME;
+	}
 
-	/* Except MODE, it seems harmless of setting twice. */
-	if (opendata->o_arg.createmode != NFS4_CREATE_EXCLUSIVE &&
-		(attrset[1] & FATTR4_WORD1_MODE ||
-		 attrset[2] & FATTR4_WORD2_MODE_UMASK))
-		sattr->ia_valid &= ~ATTR_MODE;
+	if ((attrset[1] & (FATTR4_WORD1_TIME_MODIFY|FATTR4_WORD1_TIME_MODIFY_SET))) {
+		if (sattr->ia_valid & ATTR_MTIME_SET)
+			ret |= ATTR_MTIME_SET;
+		else
+			ret |= ATTR_MTIME;
+	}
 
-	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
+	if (!(attrset[2] & FATTR4_WORD2_SECURITY_LABEL))
 		*label = NULL;
+	return ret;
 }
 
 static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
@@ -2899,12 +2909,15 @@ static int _nfs4_do_open(struct inode *dir,
 
 	if ((opendata->o_arg.open_flags & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL) &&
 	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
-		nfs4_exclusive_attrset(opendata, sattr, &label);
+		unsigned attrs = nfs4_exclusive_attrset(opendata, sattr, &label);
 		/*
 		 * send create attributes which was not set by open
 		 * with an extra setattr.
 		 */
-		if (sattr->ia_valid & NFS4_VALID_ATTRS) {
+		if (attrs || label) {
+			unsigned ia_old = sattr->ia_valid;
+
+			sattr->ia_valid = attrs;
 			nfs_fattr_init(opendata->o_res.f_attr);
 			status = nfs4_do_setattr(state->inode, cred,
 					opendata->o_res.f_attr, sattr,
@@ -2914,6 +2927,7 @@ static int _nfs4_do_open(struct inode *dir,
 						opendata->o_res.f_attr);
 				nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
 			}
+			sattr->ia_valid = ia_old;
 		}
 	}
 	if (opened && opendata->file_created)
-- 
2.14.3

