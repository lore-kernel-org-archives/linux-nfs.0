From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 17 - decode symlink inplace to avoid modifying request
Date: Fri, 11 Oct 2002 15:27:45 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKv-0003bZ-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zsi1-0004mO-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:51:37 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:51:27 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

Rather than possibly modifying a request (as 
xdr_decode_string can) we use xdr_decode_string_inplace
to symlink contents.  This string may not be nul terminated
(though it often is) so in the 'unlikely' event that is isn't
nul terminated, we copy it into a kmalloced space first.

It might be nice if vfs_symlink took a length, but then every
filesystem would have to as well....


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |    2 +-
 ./fs/nfsd/nfsxdr.c  |    2 +-
 ./fs/nfsd/vfs.c     |   14 +++++++++++++-
 3 files changed, 15 insertions(+), 3 deletions(-)

--- ./fs/nfsd/vfs.c	2002/10/11 01:41:42	1.3
+++ ./fs/nfsd/vfs.c	2002/10/11 01:56:31	1.4
@@ -1128,7 +1128,19 @@ nfsd_symlink(struct svc_rqst *rqstp, str
 	if (IS_ERR(dnew))
 		goto out_nfserr;
 
-	err = vfs_symlink(dentry->d_inode, dnew, path);
+	if (unlikely(path[plen] != 0)) {
+		char *path_alloced = kmalloc(plen+1, GFP_KERNEL);
+		if (path_alloced == NULL)
+			err = -ENOMEM;
+		else {
+			strncpy(path_alloced, path, plen);
+			path_alloced[plen] = 0;
+			err = vfs_symlink(dentry->d_inode, dnew, path_alloced);
+			kfree(path_alloced);
+		}
+	} else
+		err = vfs_symlink(dentry->d_inode, dnew, path);
+
 	if (!err) {
 		if (EX_ISSYNC(fhp->fh_export))
 			nfsd_sync_dir(dentry);
--- ./fs/nfsd/nfsxdr.c	2002/10/11 01:52:54	1.1
+++ ./fs/nfsd/nfsxdr.c	2002/10/11 01:56:32	1.2
@@ -81,7 +81,7 @@ decode_pathname(u32 *p, char **namp, int
 	char		*name;
 	int		i;
 
-	if ((p = xdr_decode_string(p, namp, lenp, NFS_MAXPATHLEN)) != NULL) {
+	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS_MAXPATHLEN)) != NULL) {
 		for (i = 0, name = *namp; i < *lenp; i++, name++) {
 			if (*name == '\0')
 				return NULL;
--- ./fs/nfsd/nfs3xdr.c	2002/10/11 01:52:54	1.1
+++ ./fs/nfsd/nfs3xdr.c	2002/10/11 01:56:32	1.2
@@ -103,7 +103,7 @@ decode_pathname(u32 *p, char **namp, int
 	char		*name;
 	int		i;
 
-	if ((p = xdr_decode_string(p, namp, lenp, NFS3_MAXPATHLEN)) != NULL) {
+	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS3_MAXPATHLEN)) != NULL) {
 		for (i = 0, name = *namp; i < *lenp; i++, name++) {
 			if (*name == '\0')
 				return NULL;


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
