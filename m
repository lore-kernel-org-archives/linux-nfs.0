From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] NFSD: Path name length signage in nfsd request
	argument	structures
Date: Thu, 01 Nov 2007 16:57:25 -0400
Message-ID: <20071101205725.5503.56082.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh6g-0007iW-Is
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:38 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh6m-0005pM-5r
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:44 -0700
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

Clean up: For consistency, store the length of path name strings in nfsd
argument structures as unsigned integers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/nfsd/xdr.h  |    2 +-
 include/linux/nfsd/xdr3.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfsd/xdr.h b/include/linux/nfsd/xdr.h
index 49ddf79..a0132ef 100644
--- a/include/linux/nfsd/xdr.h
+++ b/include/linux/nfsd/xdr.h
@@ -73,7 +73,7 @@ struct nfsd_symlinkargs {
 	char *			fname;
 	unsigned int		flen;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 	struct iattr		attrs;
 };
 
diff --git a/include/linux/nfsd/xdr3.h b/include/linux/nfsd/xdr3.h
index 6fdb958..421eddd 100644
--- a/include/linux/nfsd/xdr3.h
+++ b/include/linux/nfsd/xdr3.h
@@ -89,7 +89,7 @@ struct nfsd3_symlinkargs {
 	char *			fname;
 	unsigned int		flen;
 	char *			tname;
-	int			tlen;
+	unsigned int		tlen;
 	struct iattr		attrs;
 };
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
