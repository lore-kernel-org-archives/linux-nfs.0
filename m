Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799AbaFZBsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/8] nfsd4: rename cr_linkname->cr_data
Date: Wed, 25 Jun 2014 21:48:04 -0400
Message-Id: <1403747288-21590-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The name of a link is currently stored in cr_name and cr_namelen, and
the content in cr_linkname and cr_linklen.  That's confusing.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 fs/nfsd/nfs4xdr.c  |   15 +++++++--------
 fs/nfsd/xdr4.h     |    8 ++++----
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7aa83bf..b57c882 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -623,7 +623,7 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	case NF4LNK:
 		status = nfsd_symlink(rqstp, &cstate->current_fh,
 				      create->cr_name, create->cr_namelen,
-				      create->cr_linkname,
+				      create->cr_data,
 				      &resfh, &create->cr_iattr);
 		break;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a1c48b4..3d07496 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -598,20 +598,19 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 	switch (create->cr_type) {
 	case NF4LNK:
 		READ_BUF(4);
-		create->cr_linklen = be32_to_cpup(p++);
-		READ_BUF(create->cr_linklen);
+		create->cr_datalen = be32_to_cpup(p++);
+		READ_BUF(create->cr_datalen);
 		/*
 		 * The VFS will want a null-terminated string, and
 		 * null-terminating in place isn't safe since this might
 		 * end on a page boundary:
 		 */
-		create->cr_linkname =
-				kmalloc(create->cr_linklen + 1, GFP_KERNEL);
-		if (!create->cr_linkname)
+		create->cr_data = kmalloc(create->cr_datalen + 1, GFP_KERNEL);
+		if (!create->cr_data)
 			return nfserr_jukebox;
-		memcpy(create->cr_linkname, p, create->cr_linklen);
-		create->cr_linkname[create->cr_linklen] = '\0';
-		defer_free(argp, kfree, create->cr_linkname);
+		memcpy(create->cr_data, p, create->cr_datalen);
+		create->cr_data[create->cr_datalen] = '\0';
+		defer_free(argp, kfree, create->cr_data);
 		break;
 	case NF4BLK:
 	case NF4CHR:
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 18cbb6d..b8bf63a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -107,8 +107,8 @@ struct nfsd4_create {
 	u32		cr_type;            /* request */
 	union {                             /* request */
 		struct {
-			u32 namelen;
-			char *name;
+			u32 datalen;
+			char *data;
 		} link;   /* NF4LNK */
 		struct {
 			u32 specdata1;
@@ -121,8 +121,8 @@ struct nfsd4_create {
 	struct nfs4_acl *cr_acl;
 	struct xdr_netobj cr_label;
 };
-#define cr_linklen	u.link.namelen
-#define cr_linkname	u.link.name
+#define cr_datalen	u.link.datalen
+#define cr_data		u.link.data
 #define cr_specdata1	u.dev.specdata1
 #define cr_specdata2	u.dev.specdata2
 
-- 
1.7.9.5

