From: Neil Brown <neilb@suse.de>
Subject: PATCH/RFC Add support for using UUID to identify filesystem
 in filehandle
Date: Fri, 2 Feb 2007 21:15:17 +1100
Message-ID: <17859.3893.523905.884732@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCvSQ-0006Ji-Qx
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 02:15:51 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCvSQ-0004su-Sv
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 02:15:52 -0800
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 6EDB3218EC
	for <nfs@lists.sourceforge.net>; Fri,  2 Feb 2007 11:15:46 +0100 (CET)
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


If anyone wants to review these patches, or comment on the design, I'd
appreciate it....

The way nfsd has identified filesystems has bothered me for a while.

The default mechanism is to use the major/minor device number of the
block device that holds the filesystem.  This doesn't work for
filesystems without a block device, and has problems if the
major/minor number changes, as can happen with hardware changes and
kernel upgrades.

The alternate introduced some time ago is to explicitly give a number
to identify each filesystem with fsid=XXX in /etc/exports.  This
overcomes the above problems but requires manually assigning numbers
which isn't always ideal.

What this patch set does is allow you to use a UUID extracted from the
filesystem with libblkid.

UUIDs are 16 bytes long and there is not enough room to store that in
an NFSv2 filehandle (along with identification of the file).
So for NFSv2 we hash the UUID down to 8 or 4 bytes (using simple xor).
If the exportpoint is the root of a filesystem, we use an 8 byte
hash.  If it is lower in the filesystem we use a 4 byte hash and a 4
byte inode number.

NFSv3 (and v4) filehandles have lots more room, so there we use the
full 16byte uuid and an optional 64bit inode number.

Note that with lots of filesystems exported with NFSv2 there is an
increased chance of uuid collision.  Don't do that.  Use v3.

You currently specify the uuid by putting
   fsuuid
in the export flags (and you can give an explicit uuid if you want
to).
I wonder if I should just over-load fsid, and have
   fsid=uuid
(exactly that) to mean use a libblkid uuid, and
   fsid=xxxxxxxx:xxxxxxxx:xxxxxxxx:xxxxxxxx
(hex digits for the 'x's) for an explicit uuid.
I would want to be able to specify both an old fsid and a new uuid (for a
transition period, to avoid clients suddenly having their file
handles rejected) so maybe you can just specify "fsid=" twice.

What do people think?

It would be nice to be able to call-out to a support program if a given
uuid didn't match any mounted filesystem.  It could then mount the
filesystem (maybe from a media-changer) and export it.  I haven't
implemented that yet.

Maybe even a call-out the get the uuid of a filesystem that libblkid
doesn't understand??  Would that be useful?

Maybe 'fsuuid' should be a default.  If the kernel supports
uuid-filehandles, mounted should always provide a uuid to the kernel
and hand out uuid filehandles whenever appropriate.... Or maybe it
should only default on v3, as on v2 there is a small chance that you
can break a working setup.

Thought? comments? Testing?  Review?

Thanks,
NeilBrown

Below are two patches to the kernel - against latest -mm -followed by
an nfs-utils patch against latest git... I made up the changes to
configure.in.  If anyone understands recommended practice for that
file and can comment :-)

-----------------------------------------------

Tidy up choice of filesystem-identifier when creating a filehandle.

If we are using the same version/fsid as a current filehandle, then
there is no need to verify the the numbers are valid for this
export, and they must be (we used them to find this export).

This allows us to simplify the fsid selection code.

Also change "ref_fh_version" and "ref_fh_fsid_type" to "version" and
"fsid_type", as the important thing isn't that they are the
version/type of the reference filehandle, but they are the chosen type
for the new filehandle.

And tidy up some indenting.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |  124 ++++++++++++++++++++++++++----------------------------
 1 file changed, 60 insertions(+), 64 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-02-02 15:48:20.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2007-02-02 15:49:01.000000000 +1100
@@ -211,7 +211,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 				fileid_type = 2;
 		} else
 			fileid_type = fh->fh_fileid_type;
-		
+
 		if (fileid_type == 0)
 			dentry = dget(exp->ex_dentry);
 		else {
@@ -291,7 +291,7 @@ static inline int _fh_update(struct dent
 			     __u32 *datap, int *maxsize)
 {
 	struct export_operations *nop = exp->ex_mnt->mnt_sb->s_export_op;
-	
+
 	if (dentry == exp->ex_dentry) {
 		*maxsize = 0;
 		return 0;
@@ -316,7 +316,8 @@ static inline void _fh_update_old(struct
 }
 
 __be32
-fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry, struct svc_fh *ref_fh)
+fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
+	   struct svc_fh *ref_fh)
 {
 	/* ref_fh is a reference file handle.
 	 * if it is non-null and for the same filesystem, then we should compose
@@ -326,8 +327,8 @@ fh_compose(struct svc_fh *fhp, struct sv
 	 *
 	 */
 
-	u8 ref_fh_version = 0;
-	u8 ref_fh_fsid_type = 0;
+	u8 version = 1;
+	u8 fsid_type = 0;
 	struct inode * inode = dentry->d_inode;
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
@@ -339,57 +340,52 @@ fh_compose(struct svc_fh *fhp, struct sv
 		parent->d_name.name, dentry->d_name.name,
 		(inode ? inode->i_ino : 0));
 
+	/* Choose filehandle version and fsid type based on
+	 * the reference filehandle (if it is in the same export)
+	 * or the export options.
+	 */
 	if (ref_fh && ref_fh->fh_export == exp) {
-		ref_fh_version = ref_fh->fh_handle.fh_version;
-		if (ref_fh_version == 0xca)
-			ref_fh_fsid_type = 0;
+		version = ref_fh->fh_handle.fh_version;
+		if (version == 0xca)
+			fsid_type = 0;
 		else
-			ref_fh_fsid_type = ref_fh->fh_handle.fh_fsid_type;
-		if (ref_fh_fsid_type > 3)
-			ref_fh_fsid_type = 0;
-
-		/* make sure ref_fh type works for given export */
-		if (ref_fh_fsid_type == 1 &&
-		    !(exp->ex_flags & NFSEXP_FSID)) {
-			/* if we don't have an fsid, we cannot provide one... */
-			ref_fh_fsid_type = 0;
-		}
+			fsid_type = ref_fh->fh_handle.fh_fsid_type;
+		/* We know this version/type works for this export
+		 * so there is no need for further checks.
+		 */
 	} else if (exp->ex_flags & NFSEXP_FSID)
-		ref_fh_fsid_type = 1;
-
-	if (!old_valid_dev(ex_dev) && ref_fh_fsid_type == 0) {
+		fsid_type = 1;
+	else if (!old_valid_dev(ex_dev))
 		/* for newer device numbers, we must use a newer fsid format */
-		ref_fh_version = 1;
-		ref_fh_fsid_type = 3;
-	}
-	if (old_valid_dev(ex_dev) &&
-	    (ref_fh_fsid_type == 2 || ref_fh_fsid_type == 3))
-		/* must use type1 for smaller device numbers */
-		ref_fh_fsid_type = 0;
+		fsid_type = 3;
+	else
+		fsid_type = 0;
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
 
 	if (fhp->fh_locked || fhp->fh_dentry) {
 		printk(KERN_ERR "fh_compose: fh %s/%s not initialized!\n",
-			parent->d_name.name, dentry->d_name.name);
+		       parent->d_name.name, dentry->d_name.name);
 	}
 	if (fhp->fh_maxsize < NFS_FHSIZE)
 		printk(KERN_ERR "fh_compose: called with maxsize %d! %s/%s\n",
-		       fhp->fh_maxsize, parent->d_name.name, dentry->d_name.name);
+		       fhp->fh_maxsize,
+		       parent->d_name.name, dentry->d_name.name);
 
 	fhp->fh_dentry = dget(dentry); /* our internal copy */
 	fhp->fh_export = exp;
 	cache_get(&exp->h);
 
-	if (ref_fh_version == 0xca) {
+	if (version == 0xca) {
 		/* old style filehandle please */
 		memset(&fhp->fh_handle.fh_base, 0, NFS_FHSIZE);
 		fhp->fh_handle.fh_size = NFS_FHSIZE;
 		fhp->fh_handle.ofh_dcookie = 0xfeebbaca;
 		fhp->fh_handle.ofh_dev =  old_encode_dev(ex_dev);
 		fhp->fh_handle.ofh_xdev = fhp->fh_handle.ofh_dev;
-		fhp->fh_handle.ofh_xino = ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
+		fhp->fh_handle.ofh_xino =
+			ino_t_to_u32(exp->ex_dentry->d_inode->i_ino);
 		fhp->fh_handle.ofh_dirino = ino_t_to_u32(parent_ino(dentry));
 		if (inode)
 			_fh_update_old(dentry, exp, &fhp->fh_handle);
@@ -398,38 +394,38 @@ fh_compose(struct svc_fh *fhp, struct sv
 		fhp->fh_handle.fh_version = 1;
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
-		fhp->fh_handle.fh_fsid_type = ref_fh_fsid_type;
-		switch (ref_fh_fsid_type) {
-			case 0:
-				/*
-				 * fsid_type 0:
-				 * 2byte major, 2byte minor, 4byte inode
-				 */
-				mk_fsid_v0(datap, ex_dev,
-					exp->ex_dentry->d_inode->i_ino);
-				break;
-			case 1:
-				/* fsid_type 1 == 4 bytes filesystem id */
-				mk_fsid_v1(datap, exp->ex_fsid);
-				break;
-			case 2:
-				/*
-				 * fsid_type 2:
-				 * 4byte major, 4byte minor, 4byte inode
-				 */
-				mk_fsid_v2(datap, ex_dev,
-					exp->ex_dentry->d_inode->i_ino);
-				break;
-			case 3:
-				/*
-				 * fsid_type 3:
-				 * 4byte devicenumber, 4byte inode
-				 */
-				mk_fsid_v3(datap, ex_dev,
-					exp->ex_dentry->d_inode->i_ino);
-				break;
+		fhp->fh_handle.fh_fsid_type = fsid_type;
+		switch (fsid_type) {
+		case 0:
+			/*
+			 * fsid_type 0:
+			 * 2byte major, 2byte minor, 4byte inode
+			 */
+			mk_fsid_v0(datap, ex_dev,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
+		case 1:
+			/* fsid_type 1 == 4 bytes filesystem id */
+			mk_fsid_v1(datap, exp->ex_fsid);
+			break;
+		case 2:
+			/*
+			 * fsid_type 2:
+			 * 4byte major, 4byte minor, 4byte inode
+			 */
+			mk_fsid_v2(datap, ex_dev,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
+		case 3:
+			/*
+			 * fsid_type 3:
+			 * 4byte devicenumber, 4byte inode
+			 */
+			mk_fsid_v3(datap, ex_dev,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
 		}
-		len = key_len(ref_fh_fsid_type);
+		len = key_len(fsid_type);
 		datap += len/4;
 		fhp->fh_handle.fh_size = 4 + len;
 
@@ -456,7 +452,7 @@ fh_update(struct svc_fh *fhp)
 {
 	struct dentry *dentry;
 	__u32 *datap;
-	
+
 	if (!fhp->fh_dentry)
 		goto out_bad;
 
------------------------------------------------------------------------

Add some new fsid types.

Add support for 8 and 16 byte fsid types, so that
filesystem uuids can be used.
Larger ones will only be used for NFSv3+

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c            |   67 +++++++++++++++++++++++++++++++-----------
 ./fs/nfsd/nfsfh.c             |   27 ++++++++++++++++
 ./include/linux/nfsd/export.h |    7 ++--
 ./include/linux/nfsd/nfsfh.h  |   31 +++++++++++++++++++
 4 files changed, 112 insertions(+), 20 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-02-02 15:57:30.000000000 +1100
+++ ./fs/nfsd/export.c	2007-02-02 15:49:02.000000000 +1100
@@ -231,9 +231,8 @@ static inline void expkey_init(struct ca
 	kref_get(&item->ek_client->ref);
 	new->ek_client = item->ek_client;
 	new->ek_fsidtype = item->ek_fsidtype;
-	new->ek_fsid[0] = item->ek_fsid[0];
-	new->ek_fsid[1] = item->ek_fsid[1];
-	new->ek_fsid[2] = item->ek_fsid[2];
+
+	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
 }
 
 static inline void expkey_update(struct cache_head *cnew,
@@ -362,7 +361,7 @@ static struct svc_export *svc_export_upd
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
 
-static int check_export(struct inode *inode, int flags)
+static int check_export(struct inode *inode, int flags, unsigned char *uuid)
 {
 
 	/* We currently export only dirs and regular files.
@@ -375,12 +374,13 @@ static int check_export(struct inode *in
 	/* There are two requirements on a filesystem to be exportable.
 	 * 1:  We must be able to identify the filesystem from a number.
 	 *       either a device number (so FS_REQUIRES_DEV needed)
-	 *       or an FSID number (so NFSEXP_FSID needed).
+	 *       or an FSID number (so NFSEXP_FSID or ->uuid is needed).
 	 * 2:  We must be able to find an inode from a filehandle.
 	 *       This means that s_export_op must be set.
 	 */
 	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
-	    !(flags & NFSEXP_FSID)) {
+	    !(flags & NFSEXP_FSID) &&
+	    uuid == NULL) {
 		dprintk("exp_export: export of non-dev fs without fsid\n");
 		return -EINVAL;
 	}
@@ -405,10 +405,6 @@ fsloc_parse(char **mesg, char *buf, stru
 	int len;
 	int migrated, i, err;
 
-	len = qword_get(mesg, buf, PAGE_SIZE);
-	if (len != 5 || memcmp(buf, "fsloc", 5))
-		return 0;
-
 	/* listsize */
 	err = get_int(mesg, &fsloc->locations_count);
 	if (err)
@@ -519,6 +515,8 @@ static int svc_export_parse(struct cache
 	exp.ex_fslocs.locations_count = 0;
 	exp.ex_fslocs.migrated = 0;
 
+	exp.ex_uuid = NULL;
+
 	/* flags */
 	err = get_int(&mesg, &an_int);
 	if (err == -ENOENT)
@@ -542,12 +540,33 @@ static int svc_export_parse(struct cache
 		if (err) goto out;
 		exp.ex_fsid = an_int;
 
-		err = check_export(nd.dentry->d_inode, exp.ex_flags);
-		if (err) goto out;
+		while ((len = qword_get(&mesg, buf, PAGE_SIZE)) > 0) {
+			if (strcmp(buf, "fsloc") == 0)
+				err = fsloc_parse(&mesg, buf, &exp.ex_fslocs);
+			else if (strcmp(buf, "uuid") == 0) {
+				/* expect a 16 byte uuid encoded as \xXXXX... */
+				len = qword_get(&mesg, buf, PAGE_SIZE);
+				if (len != 16)
+					err  = -EINVAL;
+				else {
+					exp.ex_uuid =
+						kmemdup(buf, 16, GFP_KERNEL);
+					if (exp.ex_uuid == NULL)
+						err = -ENOMEM;
+				}
+			} else
+				/* quietly ignore unknown words and anything
+				 * following. Newer user-space can try to set
+				 * new values, then see what the result was.
+				 */
+				break;
+			if (err)
+				goto out;
+		}
 
-		err = fsloc_parse(&mesg, buf, &exp.ex_fslocs);
-		if (err)
-			goto out;
+		err = check_export(nd.dentry->d_inode, exp.ex_flags,
+				   exp.ex_uuid);
+		if (err) goto out;
 	}
 
 	expp = svc_export_lookup(&exp);
@@ -561,6 +580,8 @@ static int svc_export_parse(struct cache
 	else
 		exp_put(expp);
  out:
+	nfsd4_fslocs_free(&exp.ex_fslocs);
+	kfree(exp.ex_uuid);
  	kfree(exp.ex_path);
 	if (nd.dentry)
 		path_release(&nd);
@@ -590,9 +611,19 @@ static int svc_export_show(struct seq_fi
 	seq_escape(m, exp->ex_client->name, " \t\n\\");
 	seq_putc(m, '(');
 	if (test_bit(CACHE_VALID, &h->flags) && 
-	    !test_bit(CACHE_NEGATIVE, &h->flags))
+	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
 		exp_flags(m, exp->ex_flags, exp->ex_fsid,
 			  exp->ex_anon_uid, exp->ex_anon_gid, &exp->ex_fslocs);
+		if (exp->ex_uuid) {
+			int i;
+			seq_puts(m, ",uuid=");
+			for (i=0; i<16; i++) {
+				if ((i&3) == 0 && i)
+					seq_putc(m, ':');
+				seq_printf(m, "%02x", exp->ex_uuid[i]);
+			}
+		}
+	}
 	seq_puts(m, ")\n");
 	return 0;
 }
@@ -629,6 +660,8 @@ static void export_update(struct cache_h
 	new->ex_anon_uid = item->ex_anon_uid;
 	new->ex_anon_gid = item->ex_anon_gid;
 	new->ex_fsid = item->ex_fsid;
+	new->ex_uuid = item->ex_uuid;
+	item->ex_uuid = NULL;
 	new->ex_path = item->ex_path;
 	item->ex_path = NULL;
 	new->ex_fslocs.locations = item->ex_fslocs.locations;
@@ -976,7 +1009,7 @@ exp_export(struct nfsctl_export *nxp)
 		goto finish;
 	}
 
-	err = check_export(nd.dentry->d_inode, nxp->ex_flags);
+	err = check_export(nd.dentry->d_inode, nxp->ex_flags, NULL);
 	if (err) goto finish;
 
 	err = -ENOMEM;

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-02-02 15:57:30.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2007-02-02 15:49:02.000000000 +1100
@@ -333,6 +333,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
 	dev_t ex_dev = exp->ex_dentry->d_inode->i_sb->s_dev;
+	int root_export = (exp->ex_dentry == exp->ex_dentry->d_sb->s_root);
 
 	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %s/%s, ino=%ld)\n",
 		MAJOR(ex_dev), MINOR(ex_dev),
@@ -353,6 +354,18 @@ fh_compose(struct svc_fh *fhp, struct sv
 		/* We know this version/type works for this export
 		 * so there is no need for further checks.
 		 */
+	} else if (exp->ex_uuid) {
+		if (fhp->fh_maxsize >= 64) {
+			if (root_export)
+				fsid_type = 6;
+			else
+				fsid_type = 7;
+		} else {
+			if (root_export)
+				fsid_type = 5;
+			else
+				fsid_type = 4;
+		}
 	} else if (exp->ex_flags & NFSEXP_FSID)
 		fsid_type = 1;
 	else if (!old_valid_dev(ex_dev))
@@ -424,6 +437,20 @@ fh_compose(struct svc_fh *fhp, struct sv
 			mk_fsid_v3(datap, ex_dev,
 				   exp->ex_dentry->d_inode->i_ino);
 			break;
+		case 4:
+			mk_fsid_v4(datap, exp->ex_uuid,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
+		case 5:
+			mk_fsid_v5(datap, exp->ex_uuid);
+			break;
+		case 6:
+			mk_fsid_v6(datap, exp->ex_uuid);
+			break;
+		case 7:
+			mk_fsid_v7(datap, exp->ex_uuid,
+				   exp->ex_dentry->d_inode->i_ino);
+			break;
 		}
 		len = key_len(fsid_type);
 		datap += len/4;

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2007-02-02 15:57:30.000000000 +1100
+++ ./include/linux/nfsd/export.h	2007-02-02 15:49:02.000000000 +1100
@@ -74,19 +74,20 @@ struct svc_export {
 	uid_t			ex_anon_uid;
 	gid_t			ex_anon_gid;
 	int			ex_fsid;
+	unsigned char *		ex_uuid; /* 16 byte fsid */
 	struct nfsd4_fs_locations ex_fslocs;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
- * svc_export for a given client.  There can be two per export, one
- * for type 0 (dev/ino), one for type 1 (fsid)
+ * svc_export for a given client.  There can be several per export,
+ * for the different fsid types.
  */
 struct svc_expkey {
 	struct cache_head	h;
 
 	struct auth_domain *	ek_client;
 	int			ek_fsidtype;
-	u32			ek_fsid[3];
+	u32			ek_fsid[6];
 
 	struct vfsmount *	ek_mnt;
 	struct dentry *		ek_dentry;

diff .prev/include/linux/nfsd/nfsfh.h ./include/linux/nfsd/nfsfh.h
--- .prev/include/linux/nfsd/nfsfh.h	2007-02-02 15:57:30.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2007-02-02 15:49:02.000000000 +1100
@@ -190,6 +190,33 @@ static inline void mk_fsid_v3(u32 *fsidv
 	fsidv[1] = ino_t_to_u32(ino);
 }
 
+static inline void mk_fsid_v4(u32 *fsidv, unsigned char *uuid, ino_t ino)
+{
+	/* 4 byte fsid and inode number */
+	u32 *up = (u32*)uuid;
+	fsidv[0] = ino_t_to_u32(ino);
+	fsidv[1] = up[0] ^ up[1] ^ up[2] ^ up[3];
+}
+
+static inline void mk_fsid_v5(u32 *fsidv, unsigned char *uuid)
+{
+	/* 8 byte fsid  */
+	u32 *up = (u32*)uuid;
+	fsidv[0] = up[0] ^ up[2];
+	fsidv[1] = up[1] ^ up[3];
+}
+static inline void mk_fsid_v6(u32 *fsidv, unsigned char *uuid)
+{
+	/* 16 byte fsid - NFSv3+ only */
+	memcpy(fsidv, uuid, 16);
+}
+static inline void mk_fsid_v7(u32 *fsidv, unsigned char *uuid, ino_t ino)
+{
+	/* 8 byte inode and 16 byte fsid */
+	*(u64*)fsidv = (u64)ino;
+	memcpy(fsidv+2, uuid, 16);
+}
+
 static inline int key_len(int type)
 {
 	switch(type) {
@@ -197,6 +224,10 @@ static inline int key_len(int type)
 	case 1: return 4;
 	case 2: return 12;
 	case 3: return 8;
+	case 4: return 8;
+	case 5: return 8;
+	case 6: return 16;
+	case 7: return 24;
 	default: return 0;
 	}
 }

---------------------------------------------------------------
diff --git a/configure.in b/configure.in
index 7cec002..279e260 100644
--- a/configure.in
+++ b/configure.in
@@ -174,9 +174,12 @@ fi
 if test "$knfsd_cv_glibc2" = no; then
     AC_CHECK_LIB(bsd, daemon, [LIBBSD="-lbsd"])
 fi
+AC_CHECK_LIB(blkid, blkid_get_cache, [LIBBLKID="-lblkid"], AC_MSG_ERROR([libblkid needed]))
+AC_CHECK_HEADER(blkid/blkid.h, , AC_MSG_ERROR([Cannot file libblkid header file blkid/blkid.h]))
 AC_SUBST(LIBSOCKET)
 AC_SUBST(LIBCRYPT)
 AC_SUBST(LIBBSD)
+AC_SUBST(LIBBLKID)
 
 if test "$enable_gss" = yes; then
   dnl 'gss' also depends on nfsidmap.h - at least for svcgssd_proc.c
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index aba37c2..13a89da 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -80,6 +80,7 @@ struct exportent {
 	int		e_nsqgids;
 	int		e_fsid;
 	char *		e_mountpoint;
+	char *		e_uuid;
 };
 
 struct rmtabent {
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 36473cf..407da93 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -247,8 +247,9 @@ cache_flush(int force)
 	int c;
 	char stime[20];
 	char path[200];
+	time_t now;
 	/* Note: the order of these caches is important.
-	 * The need to be flushed in dependancy order. So
+	 * They need to be flushed in dependancy order. So
 	 * a cache that references items in another cache,
 	 * as nfsd.fh entries reference items in nfsd.export,
 	 * must be flushed before the cache that it references.
@@ -259,9 +260,11 @@ cache_flush(int force)
 		"nfsd.export",
 		NULL
 	};
+	now = time(0);
 	if (force ||
-	    stat(_PATH_ETAB, &stb) != 0)
-		stb.st_mtime = time(0);
+	    stat(_PATH_ETAB, &stb) != 0 ||
+		stb.st_mtime > now)
+		stb.st_mtime = now;
 	
 	sprintf(stime, "%ld\n", stb.st_mtime);
 	for (c=0; cachelist[c]; c++) {
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 2d31781..c3a3154 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -96,6 +96,7 @@ getexportent(int fromkernel, int fromexports)
 	ee.e_mountpoint = NULL;
 	ee.e_nsquids = 0;
 	ee.e_nsqgids = 0;
+	ee.e_uuid = NULL;
 
 	if (first || (ok = getexport(exp, sizeof(exp))) == 0) {
 		ok = getpath(ee.e_path, sizeof(ee.e_path));
@@ -196,6 +197,11 @@ putexportent(struct exportent *ep)
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
+	if (ep->e_uuid == (char*)1)
+		fprintf(fp, "fsuuid,");
+	else if (ep->e_uuid)
+		fprintf(fp, "fsuuid=%s,", ep->e_uuid);
+
 	if (ep->e_mountpoint)
 		fprintf(fp, "mountpoint%s%s,",
 			ep->e_mountpoint[0]?"=":"", ep->e_mountpoint);
@@ -278,6 +284,7 @@ mkexportent(char *hname, char *path, char *options)
 	ee.e_mountpoint = NULL;
 	ee.e_nsquids = 0;
 	ee.e_nsqgids = 0;
+	ee.e_uuid = NULL;
 
 	if (strlen(hname) >= sizeof(ee.e_hostname)) {
 		xlog(L_WARNING, "client name %s too long", hname);
@@ -421,13 +428,21 @@ bad_option:
 			}
 		} else if (strncmp(opt, "fsid=", 5) == 0) {
 			char *oe;
-			ep->e_fsid = strtoul(opt+5, &oe, 0);
-			if (opt[5]=='\0' || *oe != '\0') {
-				xlog(L_ERROR, "%s: %d: bad fsid \"%s\"\n",
-				     flname, flline, opt);	
-				goto bad_option;
+			if (strcmp(opt+5, "root") == 0)
+				ep->e_fsid = 0;
+			else {
+				ep->e_fsid = strtoul(opt+5, &oe, 0);
+				if (opt[5]=='\0' || *oe != '\0') {
+					xlog(L_ERROR, "%s: %d: bad fsid \"%s\"\n",
+					     flname, flline, opt);	
+					goto bad_option;
+				}
 			}
 			ep->e_flags |= NFSEXP_FSID;
+		} else if (strcmp(opt, "fsuuid") == 0) {
+			ep->e_uuid = (char*)1;
+		} else if (strncmp(opt, "fsuuid=", 7) == 0) {
+			ep->e_uuid = strdup(opt+7);
 		} else if (strcmp(opt, "mountpoint")==0 ||
 			   strcmp(opt, "mp") == 0 ||
 			   strncmp(opt, "mountpoint=", 11)==0 ||
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index ef7d8e1..72ee48c 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -95,7 +95,7 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 		snprintf(buf, BUFSIZ,"%d\n", udpfd); 
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
 			syslog(LOG_ERR, 
-			       "nfssvc: writting fds to kernel failed: errno %d (%s)", 
+			       "nfssvc: writing fds to kernel failed: errno %d (%s)", 
 			       errno, strerror(errno));
 		}
 		close(fd);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index cd49a3b..06058ff 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -404,6 +404,10 @@ dump(int verbose)
 				c = dumpopt(c, "no_acl");
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
+			if (ep->e_uuid == (char*)1)
+				c = dumpopt(c, "fsuuid");
+			else if (ep->e_uuid)
+				c = dumpopt(c, "fsuuid=%s", ep->e_uuid);
 			if (ep->e_mountpoint)
 				c = dumpopt(c, "mountpoint%s%s", 
 					    ep->e_mountpoint[0]?"=":"", 
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index d57b8b4..960c5bd 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -301,7 +301,7 @@ then the nominated path must be a mountpoint for the exportpoint to be
 exported.
 
 .TP
-.IR fsid= num
+.IR fsid= num|root
 This option forces the filesystem identification portion of the file
 handle and file attributes used on the wire to be
 .I num
@@ -322,6 +322,28 @@ The value  0 has a special meaning when use with NFSv4.  NFSv4 has a
 concept of a root of the overall exported filesystem. The export point
 exported with fsid=0 will be used as this root.
 
+.TP
+.IR fsuuid
+.TP
+.IR fsuuid= uuid
+This is an alternate to
+.IR fsid .
+If a uuid is given (32 hex digits with arbitrary punctuation), it
+behaves very like
+.I fsid
+except that the filesystem identifier can contain more bits, so
+creating a unique uuid is easier.
+
+If no
+.I uuid
+is given, the UUID of the filesystem being exported is used if such is
+available.  This is extracted using
+.IR libblkid .
+This allows filesystems to be safely exported without concern for the
+device number changing, and without needing to manually assign device
+numbers.
+
+
 .SS User ID Mapping
 .PP
 .I nfsd
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index dd400fd..c8500cb 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -12,7 +12,7 @@ mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
 mountd_LDADD = ../../support/export/libexport.a \
 	       ../../support/nfs/libnfs.a \
 	       ../../support/misc/libmisc.a \
-	       $(LIBBSD) $(LIBWRAP) $(LIBNSL)
+	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID)
 mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
 		  -I$(top_builddir)/support/include \
 		  -I$(top_srcdir)/support/export
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index dcb5dac..cb4b62c 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -27,6 +27,7 @@
 #include "mountd.h"
 #include "xmalloc.h"
 
+#include "blkid/blkid.h"
 /*
  * Support routines for text-based upcalls.
  * Fields are separated by spaces.
@@ -87,6 +88,72 @@ void auth_unix_ip(FILE *f)
 	
 }
 
+int get_uuid(char *path, char *uuid, int uuidlen, char *u)
+{
+	/* extract hex digits from uuidstr and compose a uuid
+	 * of the given length (max 16), xoring bytes to make
+	 * a smaller uuid.  Then compare with uuid
+	 */
+	int i = 0;
+	const char *val;
+
+	if (path) {
+		static blkid_cache cache = NULL;
+		struct stat stb;
+		char *devname;
+		blkid_tag_iterate iter;
+		blkid_dev dev;
+		const char *type;
+		if (cache == NULL)
+			blkid_get_cache(&cache, NULL);
+
+		blkid_probe_all_new(cache);
+
+		if (stat(path, &stb) != 0)
+			return 0;
+		devname = blkid_devno_to_devname(stb.st_dev);
+		if (!devname)
+			return 0;
+		dev = blkid_get_dev(cache, devname, BLKID_DEV_NORMAL);
+		free(devname);
+		if (!dev)
+			return 0;
+		iter = blkid_tag_iterate_begin(dev);
+		if (!iter)
+			return 0;
+		while (blkid_tag_next(iter, &type, &val) == 0)
+			if (strcmp(type, "UUID") == 0)
+				break;
+		blkid_tag_iterate_end(iter);
+		if (!type)
+			return 0;
+	} else {
+		val = uuid;
+	}
+	
+	memset(u, 0, uuidlen);
+	for ( ; *val ; val++) {
+		char c = *val;
+		if (!isxdigit(c))
+			continue;
+		if (isalpha(c)) {
+			if (isupper(c))
+				c = c - 'A' + 10;
+			else
+				c = c - 'a' + 10;
+		} else
+			c = c - '0' + 0;
+		if ((i&1) == 0)
+			c <<= 4;
+		u[i/2] ^= c;
+		i++;
+		if (i == uuidlen*2)
+			i = 0;
+	}
+	return 1;
+}
+	
+
 void nfsd_fh(FILE *f)
 {
 	/* request are:
@@ -100,12 +167,15 @@ void nfsd_fh(FILE *f)
 	int fsidlen;
 	unsigned int dev, major=0, minor=0;
 	unsigned int inode=0;
+	unsigned long long inode64;
 	unsigned int fsidnum=0;
 	char fsid[32];
 	struct exportent *found = NULL;
 	nfs_export *exp;
 	int i;
 	int dev_missing = 0;
+	int uuidlen = 0;
+	char *fhuuid = NULL;
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
@@ -119,7 +189,7 @@ void nfsd_fh(FILE *f)
 		goto out;
 	if (qword_get_int(&cp, &fsidtype) != 0)
 		goto out;
-	if (fsidtype < 0 || fsidtype > 3)
+	if (fsidtype < 0 || fsidtype > 7)
 		goto out; /* unknown type */
 	if ((fsidlen = qword_get(&cp, fsid, 32)) <= 0)
 		goto out;
@@ -162,6 +232,33 @@ void nfsd_fh(FILE *f)
 		minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
 		break;
 
+	case 4: /* 4 byte inode number and 4 byte uuid */
+		if (fsidlen != 8)
+			goto out;
+		memcpy(&inode, fsid, 4);
+		uuidlen = 4;
+		fhuuid = fsid+4;
+		break;
+	case 5: /* 8 byte uuid */
+		if (fsidlen != 8)
+			goto out;
+		uuidlen = 8;
+		fhuuid = fsid;
+		break;
+	case 6: /* 16 byte uuid */
+		if (fsidlen != 16)
+			goto out;
+		uuidlen = 16;
+		fhuuid = fsid;
+		break;
+	case 7: /* 8 byte inode number and 16 byte uuid */
+		if (fsidlen != 24)
+			goto out;
+		memcpy(&inode64, fsid, 8);
+		inode = inode64;
+		uuidlen = 16;
+		fhuuid = fsid+8;
+		break;
 	}
 
 	auth_reload();
@@ -170,6 +267,7 @@ void nfsd_fh(FILE *f)
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
 			struct stat stb;
+			char u[16];			
 
 			if (!client_member(dom, exp->m_client->m_hostname))
 				continue;
@@ -180,16 +278,43 @@ void nfsd_fh(FILE *f)
 				dev_missing ++;
 			if (stat(exp->m_export.e_path, &stb) != 0)
 				continue;
-			if (fsidtype == 1 &&
-			    ((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
-			     exp->m_export.e_fsid != fsidnum))
-				continue;
-			if (fsidtype != 1) {
+			switch(fsidtype){
+			case 0:
+			case 2:
+			case 3:
 				if (stb.st_ino != inode)
 					continue;
 				if (major != major(stb.st_dev) ||
 				    minor != minor(stb.st_dev))
 					continue;
+				break;
+			case 1:
+				if (((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
+				     exp->m_export.e_fsid != fsidnum))
+					continue;
+				break;
+			case 4:
+			case 7:
+				if (stb.st_ino != inode)
+					continue;
+				goto check_uuid;
+			case 5:
+			case 6:
+				if (!is_mountpoint(exp->m_export.e_path))
+					continue;
+			check_uuid:
+				if (exp->m_export.e_uuid == NULL)
+					continue;
+				if (exp->m_export.e_uuid != (char *)1)
+					get_uuid(NULL, exp->m_export.e_uuid,
+						 uuidlen, u);
+				else if (get_uuid(exp->m_export.e_path, NULL,
+						  uuidlen, u) == 0)
+					continue;
+
+				if (memcmp(u, fhuuid, uuidlen) != 0)
+					continue;
+				break;
 			}
 			/* It's a match !! */
 			if (!found)
@@ -292,6 +417,16 @@ void nfsd_export(FILE *f)
 		qword_printint(f, found->m_export.e_anonuid);
 		qword_printint(f, found->m_export.e_anongid);
 		qword_printint(f, found->m_export.e_fsid);
+		if (found->m_export.e_uuid == (char*)1) {
+			char u[16];
+			if (get_uuid(exp->m_export.e_path, NULL, 16, u)) {
+				qword_print(f, "uuid");
+				qword_printhex(f, u, 16);
+			}
+		} else if (found->m_export.e_uuid) {
+			qword_print(f, "uuid");
+			qword_printhex(f, found->m_export.e_uuid, 16);
+		}
 	}
 	qword_eol(f);
  out:
@@ -366,6 +501,16 @@ int cache_export_ent(char *domain, struct exportent *exp)
 	qword_printint(f, exp->e_anonuid);
 	qword_printint(f, exp->e_anongid);
 	qword_printint(f, exp->e_fsid);
+	if (exp->e_uuid == (char*)1) {
+		char u[16];
+		if (get_uuid(exp->e_path, NULL, 16, u)) {
+			qword_print(f, "uuid");
+			qword_printhex(f, u, 16);
+		}
+	} else if (exp->e_uuid) {
+		qword_print(f, "uuid");
+		qword_printhex(f, exp->e_uuid, 16);
+	}
 	err = qword_eol(f);
 
 	fclose(f);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
