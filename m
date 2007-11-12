From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd4: recheck for secure ports in fh_verify
Date: Mon, 12 Nov 2007 16:05:03 -0500
Message-ID: <1194901503-23105-3-git-send-email-bfields@citi.umich.edu>
References: <1194901503-23105-1-git-send-email-bfields@citi.umich.edu>
	<1194901503-23105-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrgSr-0004Wu-VZ
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 13:05:03 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IrgSx-0008P3-Dy
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 13:05:07 -0800
In-Reply-To: <1194901503-23105-2-git-send-email-bfields@citi.umich.edu>
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

As with

	7fc90ec93a5eb71f4b08... "call nfsd_setuser() on fh_compose()..."

this is a case where we need to redo a security check in fh_verify()
even though the filehandle already has an associated dentry--if the
filehandle was created by fh_compose() in an earlier operation of the
nfsv4 compound, then we may not have done these checks yet.

Without this fix it is possible, for example, to traverse from an export
without the secure ports requirement to one with it in a single
compound, and bypass the secure port check on the new export.

While we're here, fix up some minor style problems and change a printk()
to a dprintk(), to make it harder for random unprivileged users to spam
the logs.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsfh.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 4f712e9..468f17a 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -95,6 +95,22 @@ nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
 	return 0;
 }
 
+static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
+					  struct svc_export *exp)
+{
+	/* Check if the request originated from a secure port. */
+	if (!rqstp->rq_secure && EX_SECURE(exp)) {
+		char buf[RPC_MAX_ADDRBUFLEN];
+		dprintk(KERN_WARNING
+		       "nfsd: request from insecure port %s!\n",
+		       svc_print_addr(rqstp, buf, sizeof(buf)));
+		return nfserr_perm;
+	}
+
+	/* Set user creds for this exportpoint */
+	return nfserrno(nfsd_setuser(rqstp, exp));
+}
+
 /*
  * Perform sanity checks on the dentry in a client's file handle.
  *
@@ -167,18 +183,7 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
 			goto out;
 		}
 
-		/* Check if the request originated from a secure port. */
-		error = nfserr_perm;
-		if (!rqstp->rq_secure && EX_SECURE(exp)) {
-			char buf[RPC_MAX_ADDRBUFLEN];
-			printk(KERN_WARNING
-			       "nfsd: request from insecure port %s!\n",
-			       svc_print_addr(rqstp, buf, sizeof(buf)));
-			goto out;
-		}
-
-		/* Set user creds for this exportpoint */
-		error = nfserrno(nfsd_setuser(rqstp, exp));
+		error = nfsd_setuser_and_check_port(rqstp, exp);
 		if (error)
 			goto out;
 
@@ -227,18 +232,22 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
 		fhp->fh_export = exp;
 		nfsd_nr_verified++;
 	} else {
-		/* just rechecking permissions
-		 * (e.g. nfsproc_create calls fh_verify, then nfsd_create does as well)
+		/*
+		 * just rechecking permissions
+		 * (e.g. nfsproc_create calls fh_verify, then nfsd_create
+		 * does as well)
 		 */
 		dprintk("nfsd: fh_verify - just checking\n");
 		dentry = fhp->fh_dentry;
 		exp = fhp->fh_export;
-		/* Set user creds for this exportpoint; necessary even
+		/*
+		 * Set user creds for this exportpoint; necessary even
 		 * in the "just checking" case because this may be a
 		 * filehandle that was created by fh_compose, and that
 		 * is about to be used in another nfsv4 compound
-		 * operation */
-		error = nfserrno(nfsd_setuser(rqstp, exp));
+		 * operation.
+		 */
+		error = nfsd_setuser_and_check_port(rqstp, exp);
 		if (error)
 			goto out;
 	}
-- 
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
