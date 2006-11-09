From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: fix spurious error return from nfsd_create in
	async case
Date: Wed, 8 Nov 2006 19:49:09 -0500
Message-ID: <20061109004909.GA30367@fieldses.org>
References: <20061101021647.GA4203@schwan.zoo>
	<20061108234515.GD16390@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, aime.le-rouzic@bull.net,
	nfs@lists.sourceforge.net, Al Viro <viro@zeniv.linux.org.uk>,
	Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ghy6c-00072K-MA
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 16:49:22 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ghy6Z-0000QZ-Jt
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 16:49:23 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061108234515.GD16390@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Commit 6264d69d7df654ca64f625e9409189a0e50734e9 modified the
nfsd_create() error handling in such a way that nfsd_create will usually
return nfserr_perm even when succesful, if the export has the async
export option.
    
This introduced a regression that could cause mkdir() to always return a
permissions error, even though the directory in question was actually
succesfully created.
    
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1a7ad8c..bb4d926 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1177,7 +1177,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
 	/*
 	 * Get the dir op function pointer.
 	 */
-	err = nfserr_perm;
+	err = 0;
 	switch (type) {
 	case S_IFREG:
 		host_err = vfs_create(dirp, dchild, iap->ia_mode, NULL);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
