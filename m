From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: append-only attribute support
Date: Mon, 24 Jan 2005 15:27:36 +1100
Message-ID: <16884.31032.977260.817339@cse.unsw.edu.au>
References: <8381054C-6B13-11D9-BFA6-000D933B35AA@bdi.com>
	<1106318654.3200.38.camel@tribesman.namesys.com>
	<1106322787.30627.5.camel@lade.trondhjem.org>
	<41F12C75.5040007@bdi.com>
	<1106327280.9849.32.camel@lade.trondhjem.org>
	<41F1423F.3080800@bdi.com>
	<1106330559.9849.73.camel@lade.trondhjem.org>
	<41F14618.70500@bdi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CsvpR-0008Fv-Vn
	for nfs@lists.sourceforge.net; Sun, 23 Jan 2005 20:27:53 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CsvpQ-0000cS-GA
	for nfs@lists.sourceforge.net; Sun, 23 Jan 2005 20:27:53 -0800
To: "Aaron D. Ball" <adb@bdi.com>
In-Reply-To: message from Aaron D. Ball on Friday January 21
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday January 21, adb@bdi.com wrote:
> Trond Myklebust wrote:
> 
> > Don't you mean
> >
> >	if ((IS_APPEND(inode) && (access & MAY_WRITE)) || IS_ISMNDLK(inode))
> >
> >;-)
> >  
> >
> Yep, I retyped it without my brain engaged.  Guess 1 PM is past my bedtime.
> 
> It'll be a few hours before I can try this out.  Does anything else 
> suggest itself in the mean time?

Sounds sensible. I'll forward the following patch off in due course.

NeilBrown


 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-01-24 15:25:31.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-01-24 15:26:39.000000000 +1100
@@ -656,12 +656,15 @@ nfsd_open(struct svc_rqst *rqstp, struct
 	dentry = fhp->fh_dentry;
 	inode = dentry->d_inode;
 
-	/* Disallow access to files with the append-only bit set or
-	 * with mandatory locking enabled
+	/* Disallow write access to files with the append-only bit set
+	 * or any access when mandatory locking enabled
 	 */
 	err = nfserr_perm;
-	if (IS_APPEND(inode) || IS_ISMNDLK(inode))
+	if (IS_APPEND(inode) && (access & MAY_WRITE))
 		goto out;
+	if (IS_ISMNDLK(inode))
+		goto out;
+
 	if (!inode->i_fop)
 		goto out;
 


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
