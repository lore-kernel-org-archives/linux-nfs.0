From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 9] knfsd: nfsd4: acls: simplify
	nfs4_acl_nfsv4_to_posix interface
Date: Tue, 5 Sep 2006 09:16:03 +1000
Message-ID: <1060904231603.23150@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfn-0000SO-3e
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:16:11 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfp-0004I8-O9
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:16:15 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: J.Bruce Fields <bfields@fieldses.org>

There's no need to handle the case where the caller passes in null for pacl
or dpacl; no caller does that, because it would be a dumb thing to do.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   48 +++++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 27 deletions(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2006-09-04 17:26:00.000000000 +1000
+++ ./fs/nfsd/nfs4acl.c	2006-09-04 17:27:48.000000000 +1000
@@ -360,39 +360,33 @@ nfs4_acl_nfsv4_to_posix(struct nfs4_acl 
 	if (error < 0)
 		goto out_acl;
 
-	if (pacl != NULL) {
-		if (acl->naces == 0) {
-			error = -ENODATA;
-			goto try_dpacl;
-		}
-
-		*pacl = _nfsv4_to_posix_one(acl, flags);
-		if (IS_ERR(*pacl)) {
-			error = PTR_ERR(*pacl);
-			*pacl = NULL;
-			goto out_acl;
-		}
+	if (acl->naces == 0) {
+		error = -ENODATA;
+		goto try_dpacl;
 	}
 
+	*pacl = _nfsv4_to_posix_one(acl, flags);
+	if (IS_ERR(*pacl)) {
+		error = PTR_ERR(*pacl);
+		*pacl = NULL;
+		goto out_acl;
+	}
 try_dpacl:
-	if (dpacl != NULL) {
-		if (dacl->naces == 0) {
-			if (pacl == NULL || *pacl == NULL)
-				error = -ENODATA;
-			goto out_acl;
-		}
-
-		error = 0;
-		*dpacl = _nfsv4_to_posix_one(dacl, flags);
-		if (IS_ERR(*dpacl)) {
-			error = PTR_ERR(*dpacl);
-			*dpacl = NULL;
-			goto out_acl;
-		}
+	if (dacl->naces == 0) {
+		if (pacl == NULL || *pacl == NULL)
+			error = -ENODATA;
+		goto out_acl;
 	}
 
+	error = 0;
+	*dpacl = _nfsv4_to_posix_one(dacl, flags);
+	if (IS_ERR(*dpacl)) {
+		error = PTR_ERR(*dpacl);
+		*dpacl = NULL;
+		goto out_acl;
+	}
 out_acl:
-	if (error && pacl) {
+	if (error) {
 		posix_acl_release(*pacl);
 		*pacl = NULL;
 	}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
