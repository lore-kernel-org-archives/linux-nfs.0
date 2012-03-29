Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34197 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741Ab2C2TbG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 15:31:06 -0400
Date: Thu, 29 Mar 2012 15:31:00 -0400
From: Dr James Bruce Fields <bfields@fieldses.org>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
Message-ID: <20120329193100.GA20329@fieldses.org>
References: <loom.20120329T182500-467@post.gmane.org>
 <1333040091.5547.32.camel@lade.trondhjem.org>
 <4F749CCA.3000400@cora.nwra.com>
 <1333042863.5547.37.camel@lade.trondhjem.org>
 <4F74A4D5.1040802@cora.nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F74A4D5.1040802@cora.nwra.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2012 at 12:07:17PM -0600, Orion Poplawski wrote:
> On 03/29/2012 11:40 AM, Myklebust, Trond wrote:
> >>Going back to v4 on EL5.8 server: nfsv4el.log, nfsv4f18.log
> >>
> >>Both get NFS4ERR_EXIST in this case.
> >
> >Which is an obvious server bug: it should be sending NFS4ERR_SYMLINK in
> >reply to that OPEN.
> >
> >Bruce?
> >
> 
> I can reproduce with a 3.4.0-0.rc0.git1.2.fc18 server as well.

Hm.  So how about this?  (Untested.)

Probably there should be a pynfs test too.

I'm assuming it should still be ERR_EXIST in the exclusive,
exclusive4_1, and guarded cases.

--b.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7423d71..2bfcad4 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1457,9 +1457,12 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 		switch (createmode) {
 		case NFS3_CREATE_UNCHECKED:
-			if (! S_ISREG(dchild->d_inode->i_mode))
-				err = nfserr_exist;
-			else if (truncp) {
+			if (! S_ISREG(dchild->d_inode->i_mode)) {
+				if (rqstp->rq_vers == 4)
+					err = nfserr_symlink;
+				else
+					err = nfserr_exist;
+			} else if (truncp) {
 				/* in nfsv4, we need to treat this case a little
 				 * differently.  we don't want to truncate the
 				 * file now; this would be wrong if the OPEN
