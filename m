From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [RFC] [PATCH 1/2] nfs: Fix i_size update in O_DIRECT write
Date: Wed, 03 Oct 2007 17:49:13 +0530
Message-ID: <1191413953.20470.52.camel@jays-ws.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id37Y-0006nN-3k
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 05:14:32 -0700
Received: from victor.provo.novell.com ([137.65.250.26])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id37d-0003Dc-2T
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 05:14:37 -0700
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

When a process writes with O_DIRECT and another process reads with a
buffered read on the same client, it gets an EOF. It seems that the
O_DIRECT write is not updating the i_size of the inode, so the pread()
thinks it is past EOF and returns NULL.

While doing Direct I/O write in nfs_file_direct_write(), we avoid
updating i_size. We expect the server to set the new i_size and the
client to read the updated size back from post-op attributes.
nfs_update_inode() is doing this. We seem to update the i_size only when
"data_stable" is set. "data_stable" will never be set if both data and
meta-data have changed. This leads to buffered read not seeing the
changes at all. The following patch tries to fix this.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>

---

 fs/nfs/inode.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 71a49c3..953a4ef 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -944,6 +944,7 @@ static int nfs_update_inode(struct inode
 	unsigned int	invalid = 0;
 	unsigned long now = jiffies;
 	int data_stable;
+	int attr_changed;
 
 	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
 			__FUNCTION__, inode->i_sb->s_id, inode->i_ino,
@@ -975,8 +976,9 @@ static int nfs_update_inode(struct inode
 		nfsi->cache_change_attribute = now - 600*HZ;
 
 	/* Are we racing with known updates of the metadata on the server? */
-	data_stable = nfs_verify_change_attribute(inode, fattr->time_start);
-	if (data_stable)
+	data_stable = !nfs_caches_unstable(inode);
+	attr_changed = (fattr->time_start != NFS_I(inode)->cache_change_attribute);
+	if (data_stable && !attr_changed)
 		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATIME);
 
 	/* Do atomic weak cache consistency updates */
@@ -989,11 +991,10 @@ static int nfs_update_inode(struct inode
 		/* Do we perhaps have any outstanding writes? */
 		if (nfsi->npages == 0) {
 			/* No, but did we race with nfs_end_data_update()? */
-			if (data_stable) {
+			if (!data_stable && attr_changed) {
 				inode->i_size = new_isize;
-				invalid |= NFS_INO_INVALID_DATA;
+				invalid |= NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATTR;
 			}
-			invalid |= NFS_INO_INVALID_ATTR;
 		} else if (new_isize > cur_isize) {
 			inode->i_size = new_isize;
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
@@ -1062,7 +1063,7 @@ static int nfs_update_inode(struct inode
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
 		invalid &= ~NFS_INO_INVALID_DATA;
-	if (data_stable)
+	if (data_stable && !attr_changed)
 		invalid &= ~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME|NFS_INO_REVAL_PAGECACHE);
 	if (!nfs_have_delegation(inode, FMODE_READ) ||
 			(nfsi->cache_validity & NFS_INO_REVAL_FORCED))





-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
