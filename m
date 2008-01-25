From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 009/100] NFSD: File name length signage in nfsd request argument structures
Date: Fri, 25 Jan 2008 18:15:49 -0500
Message-ID: <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47318 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762032AbYAYXRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:25 -0500
In-Reply-To: <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: For consistency, store the length of file name strings in nfsd
argument structures as unsigned integers.  This matches the XDR routines
and client argument structures for the same operation types.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/nfsd/xdr.h  |   12 ++++++------
 include/linux/nfsd/xdr3.h |   14 +++++++-------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/nfsd/xdr.h b/include/linux/nfsd/xdr.h
index 67885d5..49ddf79 100644
--- a/include/linux/nfsd/xdr.h
+++ b/include/linux/nfsd/xdr.h
@@ -23,7 +23,7 @@ struct nfsd_sattrargs {
 struct nfsd_diropargs {
 	struct svc_fh		fh;
 	char *			name;
-	int			len;
+	unsigned int		len;
 };
 
 struct nfsd_readargs {
@@ -43,17 +43,17 @@ struct nfsd_writeargs {
 struct nfsd_createargs {
 	struct svc_fh		fh;
 	char *			name;
-	int			len;
+	unsigned int		len;
 	struct iattr		attrs;
 };
 
 struct nfsd_renameargs {
 	struct svc_fh		ffh;
 	char *			fname;
-	int			flen;
+	unsigned int		flen;
 	struct svc_fh		tfh;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 };
 
 struct nfsd_readlinkargs {
@@ -65,13 +65,13 @@ struct nfsd_linkargs {
 	struct svc_fh		ffh;
 	struct svc_fh		tfh;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 };
 
 struct nfsd_symlinkargs {
 	struct svc_fh		ffh;
 	char *			fname;
-	int			flen;
+	unsigned int		flen;
 	char *			tname;
 	int			tlen;
 	struct iattr		attrs;
diff --git a/include/linux/nfsd/xdr3.h b/include/linux/nfsd/xdr3.h
index 89d9d60..6fdb958 100644
--- a/include/linux/nfsd/xdr3.h
+++ b/include/linux/nfsd/xdr3.h
@@ -21,7 +21,7 @@ struct nfsd3_sattrargs {
 struct nfsd3_diropargs {
 	struct svc_fh		fh;
 	char *			name;
-	int			len;
+	unsigned int		len;
 };
 
 struct nfsd3_accessargs {
@@ -48,7 +48,7 @@ struct nfsd3_writeargs {
 struct nfsd3_createargs {
 	struct svc_fh		fh;
 	char *			name;
-	int			len;
+	unsigned int		len;
 	int			createmode;
 	struct iattr		attrs;
 	__be32 *		verf;
@@ -57,7 +57,7 @@ struct nfsd3_createargs {
 struct nfsd3_mknodargs {
 	struct svc_fh		fh;
 	char *			name;
-	int			len;
+	unsigned int		len;
 	__u32			ftype;
 	__u32			major, minor;
 	struct iattr		attrs;
@@ -66,10 +66,10 @@ struct nfsd3_mknodargs {
 struct nfsd3_renameargs {
 	struct svc_fh		ffh;
 	char *			fname;
-	int			flen;
+	unsigned int		flen;
 	struct svc_fh		tfh;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 };
 
 struct nfsd3_readlinkargs {
@@ -81,13 +81,13 @@ struct nfsd3_linkargs {
 	struct svc_fh		ffh;
 	struct svc_fh		tfh;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 };
 
 struct nfsd3_symlinkargs {
 	struct svc_fh		ffh;
 	char *			fname;
-	int			flen;
+	unsigned int		flen;
 	char *			tname;
 	int			tlen;
 	struct iattr		attrs;
-- 
1.5.4.rc2.60.gb2e62

