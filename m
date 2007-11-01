From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] NFSD: File name length signage in nfsd request
	argument	structures
Date: Thu, 01 Nov 2007 16:57:04 -0400
Message-ID: <20071101205704.5503.40356.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh6P-0007hx-J8
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:21 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh6S-0005iN-3F
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:24 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clean up: For consistency, store the length of file name strings in nfsd
argument structures as unsigned integers.  This matches the XDR routines
and client argument structures for the same operation types.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
