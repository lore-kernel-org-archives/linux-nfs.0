From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 2] Don't drop setuid on directories when ownership changed by NFSd
Date: Wed, 01 Jun 2005 11:20:26 +1000
Message-ID: <E1DdHuE-0001B7-8A@notabene.cse.unsw.edu.au>
References: <20050601111730.4494.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdHuQ-0004KJ-DV
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 18:20:38 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DdHuN-0002PL-DB
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


..as setuid means something totally different on directories.


Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/vfs.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-06-01 10:36:09.000000000 +1000
+++ ./fs/nfsd/vfs.c	2005-06-01 10:36:09.000000000 +1000
@@ -280,13 +280,17 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	}
 
 	/* Revoke setuid/setgid bit on chown/chgrp */
-	if ((iap->ia_valid & ATTR_UID) && (imode & S_ISUID)
-	 && iap->ia_uid != inode->i_uid) {
+	if ((iap->ia_valid & ATTR_UID)
+	    && (imode & S_ISUID)
+	    && !S_ISDIR(imode)
+	    && iap->ia_uid != inode->i_uid) {
 		iap->ia_valid |= ATTR_MODE;
 		iap->ia_mode = imode &= ~S_ISUID;
 	}
-	if ((iap->ia_valid & ATTR_GID) && (imode & S_ISGID)
-	 && iap->ia_gid != inode->i_gid) {
+	if ((iap->ia_valid & ATTR_GID)
+	    && (imode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)
+	    && !S_ISDIR(imode)
+	    && iap->ia_gid != inode->i_gid) {
 		iap->ia_valid |= ATTR_MODE;
 		iap->ia_mode = imode &= ~S_ISGID;
 	}


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
