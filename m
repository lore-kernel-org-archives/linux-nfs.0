From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 4] knfsd: Add some new fsid types.
Date: Mon, 12 Feb 2007 16:49:52 +1100
Message-ID: <1070212054952.26808@suse.de>
References: <20070212164133.26352.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGU5B-0001sc-2U
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:33 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGU5A-0001qe-9b
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:35 -0800
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


Add support for using a filesystem UUID to identify and
export point in the filehandle.
For NFSv2, this UUID is xor-ed down to 4 or 8 bytes so
that it doesn't take up too much room.  For NFSv3+, we
use the full 16 bytes, and possibly also a 64bit inode number
for exports beneath the root of a filesystem.

When generating an fsid to return in 'stat' information,
use the UUID (hashed down to size) if it is available and 
a small 'fsid' was not specifically provided.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c            |  106 +++++++++++++++++++++++++++--------------
 ./fs/nfsd/nfs3xdr.c           |   31 +++++++++---
 ./fs/nfsd/nfs4xdr.c           |   10 +++
 ./fs/nfsd/nfsfh.c             |   88 ++++++++++++++++++----------------
 ./fs/nfsd/nfsxdr.c            |   19 ++++++-
 ./include/linux/nfsd/export.h |    7 +-
 ./include/linux/nfsd/nfsd.h   |   12 ----
 ./include/linux/nfsd/nfsfh.h  |  107 +++++++++++++++++++++++++++++++-----------
 8 files changed, 246 insertions(+), 134 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-02-12 16:34:14.000000000 +1100
+++ ./fs/nfsd/export.c	2007-02-12 16:39:45.000000000 +1100
@@ -189,18 +189,17 @@ static int expkey_show(struct seq_file *
 		       struct cache_head *h)
 {
 	struct svc_expkey *ek ;
+	int i;
 
 	if (h ==NULL) {
 		seq_puts(m, "#domain fsidtype fsid [path]\n");
 		return 0;
 	}
 	ek = container_of(h, struct svc_expkey, h);
-	seq_printf(m, "%s %d 0x%08x", ek->ek_client->name,
-		   ek->ek_fsidtype, ek->ek_fsid[0]);
-	if (ek->ek_fsidtype != 1)
-		seq_printf(m, "%08x", ek->ek_fsid[1]);
-	if (ek->ek_fsidtype == 2)
-		seq_printf(m, "%08x", ek->ek_fsid[2]);
+	seq_printf(m, "%s %d 0x", ek->ek_client->name,
+		   ek->ek_fsidtype);
+	for (i=0; i < key_len(ek->ek_fsidtype)/4; i++)
+		seq_printf(m, "%08x", ek->ek_fsid[i]);
 	if (test_bit(CACHE_VALID, &h->flags) && 
 	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
 		seq_printf(m, " ");
@@ -231,9 +230,8 @@ static inline void expkey_init(struct ca
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
@@ -362,7 +360,7 @@ static struct svc_export *svc_export_upd
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
 
-static int check_export(struct inode *inode, int flags)
+static int check_export(struct inode *inode, int flags, unsigned char *uuid)
 {
 
 	/* We currently export only dirs and regular files.
@@ -375,12 +373,13 @@ static int check_export(struct inode *in
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
@@ -405,10 +404,6 @@ fsloc_parse(char **mesg, char *buf, stru
 	int len;
 	int migrated, i, err;
 
-	len = qword_get(mesg, buf, PAGE_SIZE);
-	if (len != 5 || memcmp(buf, "fsloc", 5))
-		return 0;
-
 	/* listsize */
 	err = get_int(mesg, &fsloc->locations_count);
 	if (err)
@@ -519,6 +514,8 @@ static int svc_export_parse(struct cache
 	exp.ex_fslocs.locations_count = 0;
 	exp.ex_fslocs.migrated = 0;
 
+	exp.ex_uuid = NULL;
+
 	/* flags */
 	err = get_int(&mesg, &an_int);
 	if (err == -ENOENT)
@@ -542,12 +539,33 @@ static int svc_export_parse(struct cache
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
@@ -561,6 +579,8 @@ static int svc_export_parse(struct cache
 	else
 		exp_put(expp);
  out:
+	nfsd4_fslocs_free(&exp.ex_fslocs);
+	kfree(exp.ex_uuid);
  	kfree(exp.ex_path);
 	if (nd.dentry)
 		path_release(&nd);
@@ -590,9 +610,19 @@ static int svc_export_show(struct seq_fi
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
@@ -629,6 +659,8 @@ static void export_update(struct cache_h
 	new->ex_anon_uid = item->ex_anon_uid;
 	new->ex_anon_gid = item->ex_anon_gid;
 	new->ex_fsid = item->ex_fsid;
+	new->ex_uuid = item->ex_uuid;
+	item->ex_uuid = NULL;
 	new->ex_path = item->ex_path;
 	item->ex_path = NULL;
 	new->ex_fslocs.locations = item->ex_fslocs.locations;
@@ -751,11 +783,11 @@ exp_get_key(svc_client *clp, dev_t dev, 
 	u32 fsidv[3];
 	
 	if (old_valid_dev(dev)) {
-		mk_fsid_v0(fsidv, dev, ino);
-		return exp_find_key(clp, 0, fsidv, NULL);
+		mk_fsid(FSID_DEV, fsidv, dev, ino, 0, NULL);
+		return exp_find_key(clp, FSID_DEV, fsidv, NULL);
 	}
-	mk_fsid_v3(fsidv, dev, ino);
-	return exp_find_key(clp, 3, fsidv, NULL);
+	mk_fsid(FSID_ENCODE_DEV, fsidv, dev, ino, 0, NULL);
+	return exp_find_key(clp, FSID_ENCODE_DEV, fsidv, NULL);
 }
 
 /*
@@ -766,9 +798,9 @@ exp_get_fsid_key(svc_client *clp, int fs
 {
 	u32 fsidv[2];
 
-	mk_fsid_v1(fsidv, fsid);
+	mk_fsid(FSID_NUM, fsidv, 0, 0, fsid, NULL);
 
-	return exp_find_key(clp, 1, fsidv, NULL);
+	return exp_find_key(clp, FSID_NUM, fsidv, NULL);
 }
 
 svc_export *
@@ -882,8 +914,8 @@ static int exp_fsid_hash(svc_client *clp
 	if ((exp->ex_flags & NFSEXP_FSID) == 0)
 		return 0;
 
-	mk_fsid_v1(fsid, exp->ex_fsid);
-	return exp_set_key(clp, 1, fsid, exp);
+	mk_fsid(FSID_NUM, fsid, 0, 0, exp->ex_fsid, NULL);
+	return exp_set_key(clp, FSID_NUM, fsid, exp);
 }
 
 static int exp_hash(struct auth_domain *clp, struct svc_export *exp)
@@ -893,11 +925,11 @@ static int exp_hash(struct auth_domain *
 	dev_t dev = inode->i_sb->s_dev;
 
 	if (old_valid_dev(dev)) {
-		mk_fsid_v0(fsid, dev, inode->i_ino);
-		return exp_set_key(clp, 0, fsid, exp);
+		mk_fsid(FSID_DEV, fsid, dev, inode->i_ino, 0, NULL);
+		return exp_set_key(clp, FSID_DEV, fsid, exp);
 	}
-	mk_fsid_v3(fsid, dev, inode->i_ino);
-	return exp_set_key(clp, 3, fsid, exp);
+	mk_fsid(FSID_ENCODE_DEV, fsid, dev, inode->i_ino, 0, NULL);
+	return exp_set_key(clp, FSID_ENCODE_DEV, fsid, exp);
 }
 
 static void exp_unhash(struct svc_export *exp)
@@ -976,7 +1008,7 @@ exp_export(struct nfsctl_export *nxp)
 		goto finish;
 	}
 
-	err = check_export(nd.dentry->d_inode, nxp->ex_flags);
+	err = check_export(nd.dentry->d_inode, nxp->ex_flags, NULL);
 	if (err) goto finish;
 
 	err = -ENOMEM;
@@ -1169,9 +1201,9 @@ exp_pseudoroot(struct auth_domain *clp, 
 	__be32 rv;
 	u32 fsidv[2];
 
-	mk_fsid_v1(fsidv, 0);
+	mk_fsid(FSID_NUM, fsidv, 0, 0, 0, NULL);
 
-	exp = exp_find(clp, 1, fsidv, creq);
+	exp = exp_find(clp, FSID_NUM, fsidv, creq);
 	if (IS_ERR(exp))
 		return nfserrno(PTR_ERR(exp));
 	if (exp == NULL)

diff .prev/fs/nfsd/nfs3xdr.c ./fs/nfsd/nfs3xdr.c
--- .prev/fs/nfsd/nfs3xdr.c	2007-02-12 16:34:14.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2007-02-12 16:39:45.000000000 +1100
@@ -149,6 +149,27 @@ decode_sattr3(__be32 *p, struct iattr *i
 	return p;
 }
 
+static __be32 *encode_fsid(__be32 *p, struct svc_fh *fhp)
+{
+	u64 f;
+	switch(fsid_source(fhp)) {
+	default:
+	case FSIDSOURCE_DEV:
+		p = xdr_encode_hyper(p, (u64)huge_encode_dev
+				     (fhp->fh_dentry->d_inode->i_sb->s_dev));
+		break;
+	case FSIDSOURCE_FSID:
+		p = xdr_encode_hyper(p, (u64) fhp->fh_export->ex_fsid);
+		break;
+	case FSIDSOURCE_UUID:
+		f = ((u64*)fhp->fh_export->ex_uuid)[0];
+		f ^= ((u64*)fhp->fh_export->ex_uuid)[1];
+		p = xdr_encode_hyper(p, f);
+		break;
+	}
+	return p;
+}
+
 static __be32 *
 encode_fattr3(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	      struct kstat *stat)
@@ -169,10 +190,7 @@ encode_fattr3(struct svc_rqst *rqstp, __
 	p = xdr_encode_hyper(p, ((u64)stat->blocks) << 9);
 	*p++ = htonl((u32) MAJOR(stat->rdev));
 	*p++ = htonl((u32) MINOR(stat->rdev));
-	if (is_fsid(fhp, rqstp->rq_reffh))
-		p = xdr_encode_hyper(p, (u64) fhp->fh_export->ex_fsid);
-	else
-		p = xdr_encode_hyper(p, (u64) huge_encode_dev(stat->dev));
+	p = encode_fsid(p, fhp);
 	p = xdr_encode_hyper(p, (u64) stat->ino);
 	p = encode_time3(p, &stat->atime);
 	lease_get_mtime(dentry->d_inode, &time); 
@@ -203,10 +221,7 @@ encode_saved_post_attr(struct svc_rqst *
 	p = xdr_encode_hyper(p, ((u64)fhp->fh_post_blocks) << 9);
 	*p++ = fhp->fh_post_rdev[0];
 	*p++ = fhp->fh_post_rdev[1];
-	if (is_fsid(fhp, rqstp->rq_reffh))
-		p = xdr_encode_hyper(p, (u64) fhp->fh_export->ex_fsid);
-	else
-		p = xdr_encode_hyper(p, (u64)huge_encode_dev(inode->i_sb->s_dev));
+	p = encode_fsid(p, fhp);
 	p = xdr_encode_hyper(p, (u64) inode->i_ino);
 	p = encode_time3(p, &fhp->fh_post_atime);
 	p = encode_time3(p, &fhp->fh_post_mtime);

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-02-12 16:34:14.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2007-02-12 16:39:45.000000000 +1100
@@ -1563,14 +1563,20 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		if (exp->ex_fslocs.migrated) {
 			WRITE64(NFS4_REFERRAL_FSID_MAJOR);
 			WRITE64(NFS4_REFERRAL_FSID_MINOR);
-		} else if (is_fsid(fhp, rqstp->rq_reffh)) {
+		} else switch(fsid_source(fhp)) {
+		case FSIDSOURCE_FSID:
 			WRITE64((u64)exp->ex_fsid);
 			WRITE64((u64)0);
-		} else {
+			break;
+		case FSIDSOURCE_DEV:
 			WRITE32(0);
 			WRITE32(MAJOR(stat.dev));
 			WRITE32(0);
 			WRITE32(MINOR(stat.dev));
+			break;
+		case FSIDSOURCE_UUID:
+			WRITEMEM(exp->ex_uuid, 16);
+			break;
 		}
 	}
 	if (bmval0 & FATTR4_WORD0_UNIQUE_HANDLES) {

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-02-12 16:39:36.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2007-02-12 16:39:45.000000000 +1100
@@ -118,9 +118,6 @@ fh_verify(struct svc_rqst *rqstp, struct
 
 	dprintk("nfsd: fh_verify(%s)\n", SVCFH_fmt(fhp));
 
-	/* keep this filehandle for possible reference  when encoding attributes */
-	rqstp->rq_reffh = fh;
-
 	if (!fhp->fh_dentry) {
 		__u32 *datap=NULL;
 		__u32 tfh[3];		/* filehandle fragment for oldstyle filehandles */
@@ -145,10 +142,10 @@ fh_verify(struct svc_rqst *rqstp, struct
 			}
 			len = key_len(fh->fh_fsid_type) / 4;
 			if (len == 0) goto out;
-			if  (fh->fh_fsid_type == 2) {
+			if  (fh->fh_fsid_type == FSID_MAJOR_MINOR) {
 				/* deprecated, convert to type 3 */
-				len = 3;
-				fh->fh_fsid_type = 3;
+				len = key_len(FSID_ENCODE_DEV)/4;
+				fh->fh_fsid_type = FSID_ENCODE_DEV;
 				fh->fh_fsid[0] = new_encode_dev(MKDEV(ntohl(fh->fh_fsid[0]), ntohl(fh->fh_fsid[1])));
 				fh->fh_fsid[1] = fh->fh_fsid[2];
 			}
@@ -163,8 +160,9 @@ fh_verify(struct svc_rqst *rqstp, struct
 			/* assume old filehandle format */
 			xdev = old_decode_dev(fh->ofh_xdev);
 			xino = u32_to_ino_t(fh->ofh_xino);
-			mk_fsid_v0(tfh, xdev, xino);
-			exp = exp_find(rqstp->rq_client, 0, tfh, &rqstp->rq_chandle);
+			mk_fsid(FSID_DEV, tfh, xdev, xino, 0, NULL);
+			exp = exp_find(rqstp->rq_client, FSID_DEV, tfh,
+				       &rqstp->rq_chandle);
 		}
 
 		if (IS_ERR(exp) && (PTR_ERR(exp) == -EAGAIN
@@ -333,6 +331,7 @@ fh_compose(struct svc_fh *fhp, struct sv
 	struct dentry *parent = dentry->d_parent;
 	__u32 *datap;
 	dev_t ex_dev = exp->ex_dentry->d_inode->i_sb->s_dev;
+	int root_export = (exp->ex_dentry == exp->ex_dentry->d_sb->s_root);
 
 	dprintk("nfsd: fh_compose(exp %02x:%02x/%ld %s/%s, ino=%ld)\n",
 		MAJOR(ex_dev), MINOR(ex_dev),
@@ -347,19 +346,31 @@ fh_compose(struct svc_fh *fhp, struct sv
 	if (ref_fh && ref_fh->fh_export == exp) {
 		version = ref_fh->fh_handle.fh_version;
 		if (version == 0xca)
-			fsid_type = 0;
+			fsid_type = FSID_DEV;
 		else
 			fsid_type = ref_fh->fh_handle.fh_fsid_type;
 		/* We know this version/type works for this export
 		 * so there is no need for further checks.
 		 */
+	} else if (exp->ex_uuid) {
+		if (fhp->fh_maxsize >= 64) {
+			if (root_export)
+				fsid_type = FSID_UUID16;
+			else
+				fsid_type = FSID_UUID16_INUM;
+		} else {
+			if (root_export)
+				fsid_type = FSID_UUID8;
+			else
+				fsid_type = FSID_UUID4_INUM;
+		}
 	} else if (exp->ex_flags & NFSEXP_FSID)
-		fsid_type = 1;
+		fsid_type = FSID_NUM;
 	else if (!old_valid_dev(ex_dev))
 		/* for newer device numbers, we must use a newer fsid format */
-		fsid_type = 3;
+		fsid_type = FSID_ENCODE_DEV;
 	else
-		fsid_type = 0;
+		fsid_type = FSID_DEV;
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
@@ -395,36 +406,10 @@ fh_compose(struct svc_fh *fhp, struct sv
 		fhp->fh_handle.fh_auth_type = 0;
 		datap = fhp->fh_handle.fh_auth+0;
 		fhp->fh_handle.fh_fsid_type = fsid_type;
-		switch (fsid_type) {
-		case 0:
-			/*
-			 * fsid_type 0:
-			 * 2byte major, 2byte minor, 4byte inode
-			 */
-			mk_fsid_v0(datap, ex_dev,
-				   exp->ex_dentry->d_inode->i_ino);
-			break;
-		case 1:
-			/* fsid_type 1 == 4 bytes filesystem id */
-			mk_fsid_v1(datap, exp->ex_fsid);
-			break;
-		case 2:
-			/*
-			 * fsid_type 2:
-			 * 4byte major, 4byte minor, 4byte inode
-			 */
-			mk_fsid_v2(datap, ex_dev,
-				   exp->ex_dentry->d_inode->i_ino);
-			break;
-		case 3:
-			/*
-			 * fsid_type 3:
-			 * 4byte devicenumber, 4byte inode
-			 */
-			mk_fsid_v3(datap, ex_dev,
-				   exp->ex_dentry->d_inode->i_ino);
-			break;
-		}
+		mk_fsid(fsid_type, datap, ex_dev,
+			exp->ex_dentry->d_inode->i_ino,
+			exp->ex_fsid, exp->ex_uuid);
+
 		len = key_len(fsid_type);
 		datap += len/4;
 		fhp->fh_handle.fh_size = 4 + len;
@@ -529,3 +514,22 @@ char * SVCFH_fmt(struct svc_fh *fhp)
 		fh->fh_base.fh_pad[5]);
 	return buf;
 }
+
+enum fsid_source fsid_source(struct svc_fh *fhp)
+{
+	if (fhp->fh_handle.fh_version != 1)
+		return FSIDSOURCE_DEV;
+	switch(fhp->fh_handle.fh_fsid_type) {
+	case FSID_DEV:
+	case FSID_ENCODE_DEV:
+	case FSID_MAJOR_MINOR:
+		return FSIDSOURCE_DEV;
+	case FSID_NUM:
+		return FSIDSOURCE_FSID;
+	default:
+		if (fhp->fh_export->ex_flags & NFSEXP_FSID)
+			return FSIDSOURCE_FSID;
+		else
+			return FSIDSOURCE_UUID;
+	}
+}

diff .prev/fs/nfsd/nfsxdr.c ./fs/nfsd/nfsxdr.c
--- .prev/fs/nfsd/nfsxdr.c	2007-02-12 16:34:14.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2007-02-12 16:39:45.000000000 +1100
@@ -153,6 +153,7 @@ encode_fattr(struct svc_rqst *rqstp, __b
 	struct dentry	*dentry = fhp->fh_dentry;
 	int type;
 	struct timespec time;
+	u32 f;
 
 	type = (stat->mode & S_IFMT);
 
@@ -173,10 +174,22 @@ encode_fattr(struct svc_rqst *rqstp, __b
 	else
 		*p++ = htonl(0xffffffff);
 	*p++ = htonl((u32) stat->blocks);
-	if (is_fsid(fhp, rqstp->rq_reffh))
-		*p++ = htonl((u32) fhp->fh_export->ex_fsid);
-	else
+	switch (fsid_source(fhp)) {
+	default:
+	case FSIDSOURCE_DEV:
 		*p++ = htonl(new_encode_dev(stat->dev));
+		break;
+	case FSIDSOURCE_FSID:
+		*p++ = htonl((u32) fhp->fh_export->ex_fsid);
+		break;
+	case FSIDSOURCE_UUID:
+		f = ((u32*)fhp->fh_export->ex_uuid)[0];
+		f ^= ((u32*)fhp->fh_export->ex_uuid)[1];
+		f ^= ((u32*)fhp->fh_export->ex_uuid)[2];
+		f ^= ((u32*)fhp->fh_export->ex_uuid)[3];
+		*p++ = htonl(f);
+		break;
+	}
 	*p++ = htonl((u32) stat->ino);
 	*p++ = htonl((u32) stat->atime.tv_sec);
 	*p++ = htonl(stat->atime.tv_nsec ? stat->atime.tv_nsec / 1000 : 0);

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2007-02-12 16:34:14.000000000 +1100
+++ ./include/linux/nfsd/export.h	2007-02-12 16:39:45.000000000 +1100
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

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2007-02-12 16:34:14.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2007-02-12 16:39:45.000000000 +1100
@@ -254,18 +254,6 @@ void		nfsd_lockd_shutdown(void);
  */
 extern struct timeval	nfssvc_boot;
 
-static inline int is_fsid(struct svc_fh *fh, struct knfsd_fh *reffh)
-{
-	if (fh->fh_export->ex_flags & NFSEXP_FSID) {
-		struct vfsmount *mnt = fh->fh_export->ex_mnt;
-		if (!old_valid_dev(mnt->mnt_sb->s_dev) ||
-		    (reffh->fh_version == 1 && reffh->fh_fsid_type == 1))
-			return 1;
-	}
-	return 0;
-}
-
-
 #ifdef CONFIG_NFSD_V4
 
 /* before processing a COMPOUND operation, we have to check that there

diff .prev/include/linux/nfsd/nfsfh.h ./include/linux/nfsd/nfsfh.h
--- .prev/include/linux/nfsd/nfsfh.h	2007-02-12 16:34:14.000000000 +1100
+++ ./include/linux/nfsd/nfsfh.h	2007-02-12 16:39:45.000000000 +1100
@@ -165,38 +165,91 @@ typedef struct svc_fh {
 
 } svc_fh;
 
-static inline void mk_fsid_v0(u32 *fsidv, dev_t dev, ino_t ino)
-{
-	fsidv[0] = htonl((MAJOR(dev)<<16) |
-			MINOR(dev));
-	fsidv[1] = ino_t_to_u32(ino);
-}
-
-static inline void mk_fsid_v1(u32 *fsidv, u32 fsid)
-{
-	fsidv[0] = fsid;
-}
-
-static inline void mk_fsid_v2(u32 *fsidv, dev_t dev, ino_t ino)
-{
-	fsidv[0] = htonl(MAJOR(dev));
-	fsidv[1] = htonl(MINOR(dev));
-	fsidv[2] = ino_t_to_u32(ino);
-}
-
-static inline void mk_fsid_v3(u32 *fsidv, dev_t dev, ino_t ino)
-{
-	fsidv[0] = new_encode_dev(dev);
-	fsidv[1] = ino_t_to_u32(ino);
+enum nfsd_fsid {
+	FSID_DEV = 0,
+	FSID_NUM,
+	FSID_MAJOR_MINOR,
+	FSID_ENCODE_DEV,
+	FSID_UUID4_INUM,
+	FSID_UUID8,
+	FSID_UUID16,
+	FSID_UUID16_INUM,
+};
+
+enum fsid_source {
+	FSIDSOURCE_DEV,
+	FSIDSOURCE_FSID,
+	FSIDSOURCE_UUID,
+};
+extern enum fsid_source fsid_source(struct svc_fh *fhp);
+
+
+/* This might look a little large to "inline" but in all calls except
+ * one, 'vers' is constant so moste of the function disappears.
+ */
+static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
+			   u32 fsid, unsigned char *uuid)
+{
+	u32 *up;
+	switch(vers) {
+	case FSID_DEV:
+		fsidv[0] = htonl((MAJOR(dev)<<16) |
+				 MINOR(dev));
+		fsidv[1] = ino_t_to_u32(ino);
+		break;
+	case FSID_NUM:
+		fsidv[0] = fsid;
+		break;
+	case FSID_MAJOR_MINOR:
+		fsidv[0] = htonl(MAJOR(dev));
+		fsidv[1] = htonl(MINOR(dev));
+		fsidv[2] = ino_t_to_u32(ino);
+		break;
+
+	case FSID_ENCODE_DEV:
+		fsidv[0] = new_encode_dev(dev);
+		fsidv[1] = ino_t_to_u32(ino);
+		break;
+
+	case FSID_UUID4_INUM:
+		/* 4 byte fsid and inode number */
+		up = (u32*)uuid;
+		fsidv[0] = ino_t_to_u32(ino);
+		fsidv[1] = up[0] ^ up[1] ^ up[2] ^ up[3];
+		break;
+
+	case FSID_UUID8:
+		/* 8 byte fsid  */
+		up = (u32*)uuid;
+		fsidv[0] = up[0] ^ up[2];
+		fsidv[1] = up[1] ^ up[3];
+		break;
+
+	case FSID_UUID16:
+		/* 16 byte fsid - NFSv3+ only */
+		memcpy(fsidv, uuid, 16);
+		break;
+
+	case FSID_UUID16_INUM:
+		/* 8 byte inode and 16 byte fsid */
+		*(u64*)fsidv = (u64)ino;
+		memcpy(fsidv+2, uuid, 16);
+		break;
+	default: BUG();
+	}
 }
 
 static inline int key_len(int type)
 {
 	switch(type) {
-	case 0: return 8;
-	case 1: return 4;
-	case 2: return 12;
-	case 3: return 8;
+	case FSID_DEV:		return 8;
+	case FSID_NUM: 		return 4;
+	case FSID_MAJOR_MINOR:	return 12;
+	case FSID_ENCODE_DEV:	return 8;
+	case FSID_UUID4_INUM:	return 8;
+	case FSID_UUID8:	return 8;
+	case FSID_UUID16:	return 16;
+	case FSID_UUID16_INUM:	return 24;
 	default: return 0;
 	}
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
