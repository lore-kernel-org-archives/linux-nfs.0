Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab2KZOkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 8/8] nfsd4: return badname on use "." or "..", or "/"
Date: Mon, 26 Nov 2012 09:39:59 -0500
Message-Id: <1353940799-11763-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The spec requires badname, not inval, in these cases.

Some callers want us to return enoent, but I can see no justification
for that.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 09204f5..250171c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -65,17 +65,17 @@
 #define NFS4_REFERRAL_FSID_MINOR	0x8000000ULL
 
 static __be32
-check_filename(char *str, int len, __be32 err)
+check_filename(char *str, int len)
 {
 	int i;
 
 	if (len == 0)
 		return nfserr_inval;
 	if (isdotent(str, len))
-		return err;
+		return nfserr_badname;
 	for (i = 0; i < len; i++)
 		if (str[i] == '/')
-			return err;
+			return nfserr_badname;
 	return 0;
 }
 
@@ -570,7 +570,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 	READ32(create->cr_namelen);
 	READ_BUF(create->cr_namelen);
 	SAVEMEM(create->cr_name, create->cr_namelen);
-	if ((status = check_filename(create->cr_name, create->cr_namelen, nfserr_inval)))
+	if ((status = check_filename(create->cr_name, create->cr_namelen)))
 		return status;
 
 	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
@@ -602,7 +602,7 @@ nfsd4_decode_link(struct nfsd4_compoundargs *argp, struct nfsd4_link *link)
 	READ32(link->li_namelen);
 	READ_BUF(link->li_namelen);
 	SAVEMEM(link->li_name, link->li_namelen);
-	if ((status = check_filename(link->li_name, link->li_namelen, nfserr_inval)))
+	if ((status = check_filename(link->li_name, link->li_namelen)))
 		return status;
 
 	DECODE_TAIL;
@@ -696,7 +696,7 @@ nfsd4_decode_lookup(struct nfsd4_compoundargs *argp, struct nfsd4_lookup *lookup
 	READ32(lookup->lo_len);
 	READ_BUF(lookup->lo_len);
 	SAVEMEM(lookup->lo_name, lookup->lo_len);
-	if ((status = check_filename(lookup->lo_name, lookup->lo_len, nfserr_noent)))
+	if ((status = check_filename(lookup->lo_name, lookup->lo_len)))
 		return status;
 
 	DECODE_TAIL;
@@ -860,7 +860,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		READ32(open->op_fname.len);
 		READ_BUF(open->op_fname.len);
 		SAVEMEM(open->op_fname.data, open->op_fname.len);
-		if ((status = check_filename(open->op_fname.data, open->op_fname.len, nfserr_inval)))
+		if ((status = check_filename(open->op_fname.data, open->op_fname.len)))
 			return status;
 		break;
 	case NFS4_OPEN_CLAIM_PREVIOUS:
@@ -875,7 +875,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		READ32(open->op_fname.len);
 		READ_BUF(open->op_fname.len);
 		SAVEMEM(open->op_fname.data, open->op_fname.len);
-		if ((status = check_filename(open->op_fname.data, open->op_fname.len, nfserr_inval)))
+		if ((status = check_filename(open->op_fname.data, open->op_fname.len)))
 			return status;
 		break;
 	case NFS4_OPEN_CLAIM_FH:
@@ -987,7 +987,7 @@ nfsd4_decode_remove(struct nfsd4_compoundargs *argp, struct nfsd4_remove *remove
 	READ32(remove->rm_namelen);
 	READ_BUF(remove->rm_namelen);
 	SAVEMEM(remove->rm_name, remove->rm_namelen);
-	if ((status = check_filename(remove->rm_name, remove->rm_namelen, nfserr_noent)))
+	if ((status = check_filename(remove->rm_name, remove->rm_namelen)))
 		return status;
 
 	DECODE_TAIL;
@@ -1005,9 +1005,9 @@ nfsd4_decode_rename(struct nfsd4_compoundargs *argp, struct nfsd4_rename *rename
 	READ32(rename->rn_tnamelen);
 	READ_BUF(rename->rn_tnamelen);
 	SAVEMEM(rename->rn_tname, rename->rn_tnamelen);
-	if ((status = check_filename(rename->rn_sname, rename->rn_snamelen, nfserr_noent)))
+	if ((status = check_filename(rename->rn_sname, rename->rn_snamelen)))
 		return status;
-	if ((status = check_filename(rename->rn_tname, rename->rn_tnamelen, nfserr_inval)))
+	if ((status = check_filename(rename->rn_tname, rename->rn_tnamelen)))
 		return status;
 
 	DECODE_TAIL;
@@ -1034,8 +1034,7 @@ nfsd4_decode_secinfo(struct nfsd4_compoundargs *argp,
 	READ32(secinfo->si_namelen);
 	READ_BUF(secinfo->si_namelen);
 	SAVEMEM(secinfo->si_name, secinfo->si_namelen);
-	status = check_filename(secinfo->si_name, secinfo->si_namelen,
-								nfserr_noent);
+	status = check_filename(secinfo->si_name, secinfo->si_namelen);
 	if (status)
 		return status;
 	DECODE_TAIL;
-- 
1.7.9.5

