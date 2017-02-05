Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34271 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdBEODq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 09:03:46 -0500
Received: by mail-it0-f68.google.com with SMTP id o185so5982770itb.1
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2017 06:03:46 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfsd/idmap: return nfserr_inval for zero length principals
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Message-ID: <25d503f0-c330-1401-2ed6-693c97fa8970@gmail.com>
Date: Sun, 5 Feb 2017 22:02:01 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tigran Mkrtchyan's pynfs testcase for zero length principals fail as,

SATT16   st_setattr.testEmptyPrincipal                            : FAILURE
           Setting empty owner should return NFS4ERR_INVAL,
           instead got NFS4ERR_BADOWNER
SATT17   st_setattr.testEmptyGroupPrincipal                       : FAILURE
           Setting empty owner_group should return NFS4ERR_INVAL,
           instead got NFS4ERR_BADOWNER

This patch checks the principal and return nfserr_inval directly.
It should be check after decoding in nfs4xdr.c, but it's simple before
process in nfsd_map_xxxx, so adds it in nfs4idmap.c.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4idmap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 5b20577..6b9b6cc 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -628,6 +628,10 @@ nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 {
 	__be32 status;
 	u32 id = -1;
+
+	if (name == NULL || namelen == 0)
+		return nfserr_inval;
+
 	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
 	*uid = make_kuid(&init_user_ns, id);
 	if (!uid_valid(*uid))
@@ -641,6 +645,10 @@ nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 {
 	__be32 status;
 	u32 id = -1;
+
+	if (name == NULL || namelen == 0)
+		return nfserr_inval;
+
 	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
 	*gid = make_kgid(&init_user_ns, id);
 	if (!gid_valid(*gid))
-- 
2.9.3

