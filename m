From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 2] Claim i_alloc_sem while changing file size in nfsd
Date: Wed, 01 Jun 2005 11:20:26 +1000
Message-ID: <E1DdHuE-0001BB-FH@notabene.cse.unsw.edu.au>
References: <20050601111730.4494.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdHuQ-0004KH-DC
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 18:20:38 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DdHuN-0002PJ-BO
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 18:20:37 -0700
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
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


nfsd should hold i_alloc_sem while calling notify_change
with ATTR_SIZE set, just like do_truncate does.

From: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-06-01 10:36:09.000000000 +1000
+++ ./fs/nfsd/vfs.c	2005-06-01 11:16:13.000000000 +1000
@@ -301,6 +301,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	iap->ia_valid |= ATTR_CTIME;
 
 	if (iap->ia_valid & ATTR_SIZE) {
+		down_write(&inode->i_alloc_sem);
 		fh_lock(fhp);
 		size_change = 1;
 	}
@@ -311,6 +312,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	}
 	if (size_change) {
 		fh_unlock(fhp);
+		up_write(&inode->i_alloc_sem);
 		put_write_access(inode);
 	}
 	if (!err)

### Diffstat output
 ./fs/nfsd/vfs.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-06-01 10:36:09.000000000 +1000
+++ ./fs/nfsd/vfs.c	2005-06-01 11:16:13.000000000 +1000
@@ -301,6 +301,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	iap->ia_valid |= ATTR_CTIME;
 
 	if (iap->ia_valid & ATTR_SIZE) {
+		down_write(&inode->i_alloc_sem);
 		fh_lock(fhp);
 		size_change = 1;
 	}
@@ -311,6 +312,7 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	}
 	if (size_change) {
 		fh_unlock(fhp);
+		up_write(&inode->i_alloc_sem);
 		put_write_access(inode);
 	}
 	if (!err)


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
