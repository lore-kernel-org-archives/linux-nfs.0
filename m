Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5.framestore.com ([193.203.83.15]:36751 "EHLO
	mx5.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480Ab2HNQcw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 12:32:52 -0400
Subject: Re: Your comments, guidance, advice please :)
From: Jim Vanns <james.vanns@framestore.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Vanns <james.vanns@framestore.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA939D69C@SACEXCMBX04-PRD.hq.netapp.com>
References: <1344869728.8400.46.camel@sys367.ldn.framestore.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA939D69C@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: multipart/mixed; boundary="=-h2yZ5fl1NOE/jjl1RfKC"
Date: Tue, 14 Aug 2012 17:32:39 +0100
Message-ID: <1344961959.8801.3.camel@sys367.ldn.framestore.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-h2yZ5fl1NOE/jjl1RfKC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-08-13 at 16:40 +0000, Myklebust, Trond wrote:
> On Mon, 2012-08-13 at 15:55 +0100, Jim Vanns wrote:
> > Hello NFS hackers. First off, fear not - the attached patch is not
> > something I wish to submit to the mainline kernel! However, it is
> > important for me that you pass judgement or comment on it. It is smal=
l.
> >=20
> > Basically, I've written the patch solely to workaround a Bluearc bug
> > where it duplicates fileids within an fsid and therefore we're not ab=
le
> > to rely on the fsid+fileid to identify distinct files in an NFS
> > filesystem. Some of our storage indexing and reporting software relie=
s
> > on this and works happily with other, more RFC-adherent
> > implementations ;)
> >=20
> > The functional change is one that modified the received fileid to a h=
ash
> > of the file handle as that, thankfully, is still unique. As with a
> > fileid I need this hash to remain consistent for the lifetime of a fi=
le.
> > It is used as a unique identifier in a database.
> >=20
> > I'd really appreciate it if you could let me know of any problems you
> > see with it - whether it'll break some client-side code, hash table u=
se
> > or worse still send back bad data to the server.
> >=20
> > I've modified what I can see as the least amount of code possible - a=
nd
> > my test VM is working happily as a client with this patch. It is
> > intended that the patch modifies only client-side code once the Bluea=
rc
> > RPCs are pulled off the wire. I never want to send back these modifie=
d
> > fileids to the server.
>=20
> READDIR and READDIRPLUS will continue to return the fileid from the
> server, so the getdents() and readdir() syscalls will be broken. Since
> READDIRPLUS does return the filehandle, you might be able to fix that
> up, but plain READDIR would appear to be unfixable.

To this end then, I've modified my patch so that within
nfs_refresh_inode() itself I do the following:

fattr->fileid =3D nfs_fh_hash(NFS_FH(inode));

Before the spin lock is taken. Full patch attached again for context.

Thanks again,

Jim

> Otherwise, your strategy should in principle be OK, but with the caveat
> that a hash does not suffice to completely prevent collisions even if i=
t
> is well chosen.
> IOW: All you are doing is tweaking the probability of a collision.
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20
> NrybX=C7=A7v^)=DE=BA{.n+{"^nrz=1Ah&=1EGh=03(=E9=9A=8E=DD=A2j"=1A=1Bmz=DE=
=96fh~m

--=20
Jim Vanns
Systems Programmer
Framestore

--=-h2yZ5fl1NOE/jjl1RfKC
Content-Disposition: attachment; filename="fscfc-nfs-fileid-hash-2.patch"
Content-Type: text/x-patch; name="fscfc-nfs-fileid-hash-2.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

--- linux-2.6.32/fs/nfs/inode.c.orig	2012-08-13 11:24:41.902452726 +0100
+++ linux-2.6.32/fs/nfs/inode.c	2012-08-14 14:04:37.905712353 +0100
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
@@ -907,7 +974,6 @@ static int nfs_check_inode_attributes(st
 	loff_t cur_size, new_isize;
 	unsigned long invalid = 0;
 
-
 	/* Has the inode gone and changed behind our back? */
 	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid != fattr->fileid)
 		return -EIO;
@@ -1036,6 +1102,12 @@ int nfs_refresh_inode(struct inode *inod
 
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
+
+    /*
+     * FSCFC: Compare against the hashed file handle, not the fileid
+     */
+    fattr->fileid = nfs_fh_hash(NFS_FH(inode)); // JV alternate code
+
 	spin_lock(&inode->i_lock);
 	status = nfs_refresh_inode_locked(inode, fattr);
 	spin_unlock(&inode->i_lock);

--=-h2yZ5fl1NOE/jjl1RfKC--

