Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5.framestore.com ([193.203.83.15]:41468 "EHLO
	mx5.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab2HMPbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 11:31:00 -0400
Received: from vm-zimbra.ldn.framestore.com ([172.16.73.68] helo=zimbra.framestore.com)
	by mx5.framestore.com with esmtp (Exim 4.72)
	(envelope-from <james.vanns@framestore.com>)
	id 1T0w3J-00072x-Q9
	for linux-nfs@vger.kernel.org; Mon, 13 Aug 2012 15:55:38 +0100
Received: from [172.16.84.176] (sys367.ldn.framestore.com [172.16.84.176])
	by zimbra.framestore.com (Postfix) with ESMTPA id 06DEC1EC0ACD
	for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 15:55:24 +0100 (BST)
Subject: Your comments, guidance, advice please :)
From: Jim Vanns <james.vanns@framestore.com>
To: linux-nfs@vger.kernel.org
Content-Type: multipart/mixed; boundary="=-mqFEVhwPpM2qxc8phaiS"
Date: Mon, 13 Aug 2012 15:55:28 +0100
Message-ID: <1344869728.8400.46.camel@sys367.ldn.framestore.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-mqFEVhwPpM2qxc8phaiS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hello NFS hackers. First off, fear not - the attached patch is not
something I wish to submit to the mainline kernel! However, it is
important for me that you pass judgement or comment on it. It is small.

Basically, I've written the patch solely to workaround a Bluearc bug
where it duplicates fileids within an fsid and therefore we're not able
to rely on the fsid+fileid to identify distinct files in an NFS
filesystem. Some of our storage indexing and reporting software relies
on this and works happily with other, more RFC-adherent
implementations ;)

The functional change is one that modified the received fileid to a hash
of the file handle as that, thankfully, is still unique. As with a
fileid I need this hash to remain consistent for the lifetime of a file.
It is used as a unique identifier in a database.

I'd really appreciate it if you could let me know of any problems you
see with it - whether it'll break some client-side code, hash table use
or worse still send back bad data to the server.

I've modified what I can see as the least amount of code possible - and
my test VM is working happily as a client with this patch. It is
intended that the patch modifies only client-side code once the Bluearc
RPCs are pulled off the wire. I never want to send back these modified
fileids to the server.

Kind regards and thanks for your help, 

Jim Vanns

PS. Sorry, I should mention of course that this patch is a diff from the
2.6.32 kernel as shipped with Fedora 12 - so not a recent kernel.

-- 
Jim Vanns
Systems Programmer
Framestore

--=-mqFEVhwPpM2qxc8phaiS
Content-Disposition: attachment; filename="fscfc-nfs-fileid-hash.patch"
Content-Type: text/x-patch; name="fscfc-nfs-fileid-hash.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- linux-2.6.32/fs/nfs/inode.c.orig	2012-08-13 11:24:41.902452726 +0100
+++ linux-2.6.32/fs/nfs/inode.c	2012-08-13 12:41:38.871454124 +0100
@@ -60,6 +60,52 @@ static int nfs_update_inode(struct inode
 
 static struct kmem_cache * nfs_inode_cachep;
 
+/*
+ * FSCFC:
+ *
+ * Implementations of FNV-1 hash function:
+ * http://isthe.com/chongo/tech/comp/fnv
+ * http://en.wikipedia.org/wiki/Fowler_Noll_Vo_hash#Notes
+ */
+static inline uint32_t
+nfs_fh_hash32(struct nfs_fh *fh)
+{
+    static const uint32_t seed = 2166136261U,
+                          prime = 16777619U;
+    uint32_t hash = seed, i = 0;
+
+    while (i < fh->size) {
+        hash = (hash * prime) ^ fh->data[i];
+        ++i;
+    }
+
+    return hash;
+}
+
+static inline uint64_t
+nfs_fh_hash64(struct nfs_fh *fh)
+{
+    static const uint64_t seed = 14695981039346656037U,
+                          prime = 1099511628211U;
+    uint64_t hash = seed, i = 0;
+
+    while (i < fh->size) {
+        hash = (hash * prime) ^ fh->data[i];
+        ++i;
+    }
+
+    return hash;
+}
+
+static inline unsigned long
+nfs_fh_hash(struct nfs_fh *fh)
+{
+    if (sizeof(unsigned long) == 4)
+        return nfs_fh_hash32(fh);
+
+    return nfs_fh_hash64(fh);
+}
+
 static inline unsigned long
 nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
 {
@@ -268,7 +314,28 @@ nfs_fhget(struct super_block *sb, struct
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
 		goto out_no_inode;
 
-	hash = nfs_fattr_to_ino_t(fattr);
+    /* 
+     * FSCFC:
+     *
+     * This patch exists solely to work around the Bluearc duplicate inode/NFS
+     * fileid bug. On Bluearc filesystems a distinct, non-hardlinked file or
+     * directory appears to share the same fsid + fileid with other completely
+     * unrelated files elsewhere in the hierarchy. This becomes a problem for
+     * any system dependent on the commonly accpepted notion of the NFSv3 fsid
+     * and fileid uniquely identifying a single file/directory within an NFS
+     * filesystem. Thankfully, the NFS file handle for any duplications are
+     * still unique :)
+     *
+     * We must update *both* the hash value (was the i_ino/fileid as returned
+     * by nfs_fattr_to_ino_t() above) and fileid here as it is used as the key
+     * in the inode cache maintained within iget5_locked() below.
+     *
+     * We set fattr->fileid to 'hash' to because NFS_FILEID and set_nfs_fileid()
+     * just copy/return 'fileid' from this structure which the server has
+     * already sent as the inode on it's filesystem as you'd expect. This is
+     * what we overwrite - client side only.
+     */
+    fattr->fileid = hash = nfs_fh_hash(fh); // JV alternate code
 
 	inode = iget5_locked(sb, hash, nfs_find_actor, nfs_init_locked, &desc);
 	if (inode == NULL) {
@@ -736,6 +803,7 @@ __nfs_revalidate_inode(struct nfs_server
 		goto out;
 	}
 
+    fattr.fileid = nfs_fh_hash(NFS_FH(inode)); // JV alternate code
 	status = nfs_refresh_inode(inode, &fattr);
 	if (status) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
@@ -903,13 +971,17 @@ static void nfs_wcc_update_inode(struct 
  */
 static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fattr)
 {
+    unsigned long hash = nfs_fh_hash(NFS_FH(inode)); // JV alternate code
 	struct nfs_inode *nfsi = NFS_I(inode);
 	loff_t cur_size, new_isize;
 	unsigned long invalid = 0;
 
+    /*
+     * FSCFC: Compare against the hashed file handle, not the fileid
+     */
 
 	/* Has the inode gone and changed behind our back? */
-	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != hash)
 		return -EIO;
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
 		return -EIO;
@@ -1150,12 +1222,16 @@ static int nfs_update_inode(struct inode
 	unsigned long invalid = 0;
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
+    unsigned long hash = nfs_fh_hash(NFS_FH(inode)); // JV alternate code
 
 	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
 			atomic_read(&inode->i_count), fattr->valid);
 
-	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
+    /*
+     * FSCFC: Compare against the hashed file handle, not the fileid
+     */
+	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != hash)
 		goto out_fileid;
 
 	/*

--=-mqFEVhwPpM2qxc8phaiS--

