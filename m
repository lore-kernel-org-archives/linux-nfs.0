From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 5 of 8 - Add server-side support for the nfsv4 mounted_on_fileid attribute.
Date: Thu, 25 Mar 2004 12:06:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKf-0007Dn-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKs-0006bf-7G
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:06 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKr-0002Zo-Ji
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:05 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:07:00 +1100
To: Andrew Morton <akpm@osdl.org>
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c         |   11 +++++++++++
 ./include/linux/nfs4.h      |    1 +
 ./include/linux/nfsd/nfsd.h |    2 +-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-03-25 11:43:35.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-03-25 11:43:35.000000000 +1100
@@ -1588,7 +1588,18 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		WRITE32(stat.mtime.tv_sec);
 		WRITE32(stat.mtime.tv_nsec);
 	}
+	if (bmval1 & FATTR4_WORD1_MOUNTED_ON_FILEID) {
+		struct dentry *mnt_pnt, *mnt_root;
 
+		if ((buflen -= 8) < 0)
+                	goto out_resource; 
+		mnt_root = exp->ex_mnt->mnt_root;
+		if (mnt_root->d_inode == dentry->d_inode) {
+			mnt_pnt = exp->ex_mnt->mnt_mountpoint;
+			WRITE64((u64) mnt_pnt->d_inode->i_ino);
+		} else
+                	WRITE64((u64) stat.ino);
+	}
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	*countp = p - buffer;
 	status = nfs_ok;

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2004-03-25 11:43:35.000000000 +1100
+++ ./include/linux/nfs4.h	2004-03-25 11:43:35.000000000 +1100
@@ -274,6 +274,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_METADATA      (1 << 20)
 #define FATTR4_WORD1_TIME_MODIFY        (1 << 21)
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1 << 22)
+#define FATTR4_WORD1_MOUNTED_ON_FILEID  (1 << 23)
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-03-25 11:43:24.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2004-03-25 11:43:35.000000000 +1100
@@ -279,7 +279,7 @@ static inline int is_fsid(struct svc_fh 
  | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
  | FATTR4_WORD1_SPACE_USED      | FATTR4_WORD1_TIME_ACCESS  | FATTR4_WORD1_TIME_ACCESS_SET  \
  | FATTR4_WORD1_TIME_CREATE     | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
- | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET)
+ | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
 
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
 #define NFSD_WRITEONLY_ATTRS_WORD1							    \


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
