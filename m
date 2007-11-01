From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] NFSD: Fix mixed sign comparison
	in	nfs3svc_decode_symlinkargs
Date: Thu, 01 Nov 2007 16:57:20 -0400
Message-ID: <20071101205720.5503.61021.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh71-0007in-GO
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:59 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh76-0002Fg-2s
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:05 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs3xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 6fed3f9..9aefa95 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -449,8 +449,7 @@ int
 nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_symlinkargs *args)
 {
-	unsigned int len;
-	int avail;
+	unsigned int len, avail;
 	char *old, *new;
 	struct kvec *vec;
 
@@ -483,7 +482,8 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 	/* now copy next page if there is one */
 	if (len && !avail && rqstp->rq_arg.page_len) {
 		avail = rqstp->rq_arg.page_len;
-		if (avail > PAGE_SIZE) avail = PAGE_SIZE;
+		if (avail > PAGE_SIZE)
+			avail = PAGE_SIZE;
 		old = page_address(rqstp->rq_arg.pages[0]);
 	}
 	while (len && avail && *old) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
