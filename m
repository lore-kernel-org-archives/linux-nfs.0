From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 12 of 54] nfsd4: use existing open instead of reopening on read and write
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-00017Z-Vs@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrr-000284-Ea
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrp-0007tW-Mn
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:55 -0800
To: Andrew Morton <akpm@osdl.org>
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


Use the struct file * obtained in nfsd4_open for nfsd_read and nfsd_write
when available.

To do this we add a struct file * argument to nfsd_read and nfsd_write.  If a
struct file is passed in, nfsd_read and nfsd_write will use it, doing just an
access check instead of an open and close.  If the new argument is NULL, they
will fall back on the old behaviour.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs3proc.c         |    4 -
 ./fs/nfsd/nfs4proc.c         |   18 ++++---
 ./fs/nfsd/nfs4state.c        |    8 ++-
 ./fs/nfsd/nfs4xdr.c          |    8 +--
 ./fs/nfsd/nfsproc.c          |    4 -
 ./fs/nfsd/vfs.c              |  103 +++++++++++++++++++++++++++++--------------
 ./include/linux/nfsd/nfsd.h  |    6 +-
 ./include/linux/nfsd/state.h |    2 
 ./include/linux/nfsd/xdr4.h  |    1 
 9 files changed, 100 insertions(+), 54 deletions(-)

diff ./fs/nfsd/nfs3proc.c~current~ ./fs/nfsd/nfs3proc.c
--- ./fs/nfsd/nfs3proc.c~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./fs/nfsd/nfs3proc.c	2005-03-07 11:35:11.000000000 +1100
@@ -172,7 +172,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, 
 	svc_reserve(rqstp, ((1 + NFS3_POST_OP_ATTR_WORDS + 3)<<2) + resp->count +4);
 
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = nfsd_read(rqstp, &resp->fh,
+	nfserr = nfsd_read(rqstp, &resp->fh, NULL,
 				  argp->offset,
 			   	  argp->vec, argp->vlen,
 				  &resp->count);
@@ -202,7 +202,7 @@ nfsd3_proc_write(struct svc_rqst *rqstp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->committed = argp->stable;
-	nfserr = nfsd_write(rqstp, &resp->fh,
+	nfserr = nfsd_write(rqstp, &resp->fh, NULL,
 				   argp->offset,
 				   argp->vec, argp->vlen,
 				   argp->len,

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2005-03-07 11:35:11.000000000 +1100
@@ -464,6 +464,7 @@ static inline int
 nfsd4_read(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_read *read)
 {
 	int status;
+	struct file *filp = NULL;
 
 	/* no need to check permission - this will be done in nfsd_read() */
 
@@ -472,8 +473,8 @@ nfsd4_read(struct svc_rqst *rqstp, struc
 
 	nfs4_lock_state();
 	/* check stateid */
-	if ((status = nfs4_preprocess_stateid_op(current_fh, &read->rd_stateid, 
-					CHECK_FH | RD_STATE))) {
+	if ((status = nfs4_preprocess_stateid_op(current_fh, &read->rd_stateid,
+					CHECK_FH | RD_STATE, &filp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -482,6 +483,7 @@ out:
 	nfs4_unlock_state();
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = current_fh;
+	read->rd_filp = filp;
 	return status;
 }
 
@@ -574,7 +576,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, st
 		nfs4_lock_state();
 		if ((status = nfs4_preprocess_stateid_op(current_fh, 
 						&setattr->sa_stateid, 
-						CHECK_FH | WR_STATE))) {
+						CHECK_FH | WR_STATE, NULL))) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			goto out_unlock;
 		}
@@ -598,6 +600,7 @@ static inline int
 nfsd4_write(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_write *write)
 {
 	stateid_t *stateid = &write->wr_stateid;
+	struct file *filp = NULL;
 	u32 *p;
 	int status = nfs_ok;
 
@@ -608,7 +611,7 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 
 	nfs4_lock_state();
 	if ((status = nfs4_preprocess_stateid_op(current_fh, stateid, 
-					CHECK_FH | WR_STATE))) {
+					CHECK_FH | WR_STATE, &filp))) {
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		goto out;
 	}
@@ -620,9 +623,10 @@ nfsd4_write(struct svc_rqst *rqstp, stru
 	*p++ = nfssvc_boot.tv_sec;
 	*p++ = nfssvc_boot.tv_usec;
 
-	status =  nfsd_write(rqstp, current_fh, write->wr_offset,
-			  write->wr_vec, write->wr_vlen, write->wr_buflen,
-			  &write->wr_how_written);
+	status =  nfsd_write(rqstp, current_fh, filp, write->wr_offset,
+			write->wr_vec, write->wr_vlen, write->wr_buflen,
+			&write->wr_how_written);
+
 	if (status == nfserr_symlink)
 		status = nfserr_inval;
 	return status;

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:11.000000000 +1100
@@ -2042,7 +2042,7 @@ io_during_grace_disallowed(struct inode 
 * Checks for stateid operations
 */
 int
-nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int flags)
+nfs4_preprocess_stateid_op(struct svc_fh *current_fh, stateid_t *stateid, int flags, struct file **filpp)
 {
 	struct nfs4_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
@@ -2053,6 +2053,8 @@ nfs4_preprocess_stateid_op(struct svc_fh
 	dprintk("NFSD: preprocess_stateid_op: stateid = (%08x/%08x/%08x/%08x)\n",
 		stateid->si_boot, stateid->si_stateownerid, 
 		stateid->si_fileid, stateid->si_generation); 
+	if (filpp)
+		*filpp = NULL;
 
 	if (io_during_grace_disallowed(ino, flags))
 		return nfserr_grace;
@@ -2099,6 +2101,8 @@ nfs4_preprocess_stateid_op(struct svc_fh
 		if ((status = nfs4_check_openmode(stp,flags)))
 			goto out;
 		renew_client(stp->st_stateowner->so_client);
+		if (filpp)
+			*filpp = stp->st_vfs_file;
 	} else if (dp) {
 		if ((status = nfs4_check_delegmode(dp, flags)))
 			goto out;
@@ -2405,7 +2409,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp
 		goto out;
 
 	nfs4_lock_state();
-	status = nfs4_preprocess_stateid_op(current_fh, &dr->dr_stateid, DELEG_RET);
+	status = nfs4_preprocess_stateid_op(current_fh, &dr->dr_stateid, DELEG_RET, NULL);
 	nfs4_unlock_state();
 out:
 	return status;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-03-07 11:35:08.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2005-03-07 11:35:11.000000000 +1100
@@ -2068,10 +2068,10 @@ nfsd4_encode_read(struct nfsd4_compoundr
 	}
 	read->rd_vlen = v;
 
-	nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp,
-			   read->rd_offset,
-			   read->rd_iov, read->rd_vlen,
-			   &maxcount);
+	nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp, read->rd_filp,
+			read->rd_offset, read->rd_iov, read->rd_vlen,
+			&maxcount);
+
 	if (nfserr == nfserr_symlink)
 		nfserr = nfserr_inval;
 	if (nfserr)

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2005-03-07 11:32:36.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2005-03-07 11:35:11.000000000 +1100
@@ -137,7 +137,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 	svc_reserve(rqstp, (19<<2) + argp->count + 4);
 
 	resp->count = argp->count;
-	nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh),
+	nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
 				  argp->offset,
 			   	  argp->vec, argp->vlen,
 				  &resp->count);
@@ -160,7 +160,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, 
 		SVCFH_fmt(&argp->fh),
 		argp->len, argp->offset);
 
-	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
+	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
 				   argp->offset,
 				   argp->vec, argp->vlen,
 				   argp->len,

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-03-07 11:33:41.000000000 +1100
+++ ./fs/nfsd/vfs.c	2005-03-07 11:35:11.000000000 +1100
@@ -812,30 +812,21 @@ nfsd_read_actor(read_descriptor_t *desc,
 	return size;
 }
 
-/*
- * Read data from a file. count must contain the requested read count
- * on entry. On return, *count contains the number of bytes actually read.
- * N.B. After this call fhp needs an fh_put
- */
-int
-nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
-          struct kvec *vec, int vlen, unsigned long *count)
+static inline int
+nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
+              loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
+	struct inode *inode;
 	struct raparms	*ra;
 	mm_segment_t	oldfs;
 	int		err;
-	struct file	*file;
-	struct inode	*inode;
 
-	err = nfsd_open(rqstp, fhp, S_IFREG, MAY_READ, &file);
-	if (err)
-		goto out;
 	err = nfserr_perm;
 	inode = file->f_dentry->d_inode;
 #ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 		(!lock_may_read(inode, offset, *count)))
-		goto out_close;
+		goto out;
 #endif
 
 	/* Get readahead parameters */
@@ -871,41 +862,28 @@ nfsd_read(struct svc_rqst *rqstp, struct
 		dnotify_parent(file->f_dentry, DN_ACCESS);
 	} else 
 		err = nfserrno(err);
-out_close:
-	nfsd_close(file);
 out:
 	return err;
 }
 
-/*
- * Write data to a file.
- * The stable flag requests synchronous writes.
- * N.B. After this call fhp needs an fh_put
- */
-int
-nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
-				struct kvec *vec, int vlen,
+static inline int
+nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
+				loff_t offset, struct kvec *vec, int vlen,
 	   			unsigned long cnt, int *stablep)
 {
 	struct svc_export	*exp;
-	struct file		*file;
 	struct dentry		*dentry;
 	struct inode		*inode;
 	mm_segment_t		oldfs;
 	int			err = 0;
 	int			stable = *stablep;
 
-	err = nfsd_open(rqstp, fhp, S_IFREG, MAY_WRITE, &file);
-	if (err)
-		goto out;
-	if (!cnt)
-		goto out_close;
 	err = nfserr_perm;
 
 #ifdef MSNFS
 	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 		(!lock_may_write(file->f_dentry->d_inode, offset, cnt)))
-		goto out_close;
+		goto out;
 #endif
 
 	dentry = file->f_dentry;
@@ -991,12 +969,71 @@ nfsd_write(struct svc_rqst *rqstp, struc
 		err = 0;
 	else 
 		err = nfserrno(err);
-out_close:
-	nfsd_close(file);
 out:
 	return err;
 }
 
+/*
+ * Read data from a file. count must contain the requested read count
+ * on entry. On return, *count contains the number of bytes actually read.
+ * N.B. After this call fhp needs an fh_put
+ */
+int
+nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
+		loff_t offset, struct kvec *vec, int vlen,
+		unsigned long *count)
+{
+	int		err;
+
+	if (file) {
+		err = nfsd_permission(fhp->fh_export, fhp->fh_dentry,
+				MAY_READ|MAY_OWNER_OVERRIDE);
+		if (err)
+			goto out;
+		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
+	} else {
+		err = nfsd_open(rqstp, fhp, S_IFREG, MAY_READ, &file);
+		if (err)
+			goto out;
+		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
+		nfsd_close(file);
+	}
+out:
+	return err;
+}
+
+/*
+ * Write data to a file.
+ * The stable flag requests synchronous writes.
+ * N.B. After this call fhp needs an fh_put
+ */
+int
+nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
+		loff_t offset, struct kvec *vec, int vlen, unsigned long cnt,
+		int *stablep)
+{
+	int			err = 0;
+
+	if (file) {
+		err = nfsd_permission(fhp->fh_export, fhp->fh_dentry,
+				MAY_WRITE|MAY_OWNER_OVERRIDE);
+		if (err)
+			goto out;
+		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
+				stablep);
+	} else {
+		err = nfsd_open(rqstp, fhp, S_IFREG, MAY_WRITE, &file);
+		if (err)
+			goto out;
+
+		if (cnt)
+			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, 
+					     cnt, stablep);
+		nfsd_close(file);
+	}
+out:
+	return err;
+}
 
 #ifdef CONFIG_NFSD_V3
 /*

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-03-07 11:35:09.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2005-03-07 11:35:11.000000000 +1100
@@ -99,9 +99,9 @@ int		nfsd_commit(struct svc_rqst *, stru
 int		nfsd_open(struct svc_rqst *, struct svc_fh *, int,
 				int, struct file **);
 void		nfsd_close(struct file *);
-int		nfsd_read(struct svc_rqst *, struct svc_fh *,
-				loff_t, struct kvec *,int, unsigned long *);
-int		nfsd_write(struct svc_rqst *, struct svc_fh *,
+int 		nfsd_read(struct svc_rqst *, struct svc_fh *, struct file *,
+				loff_t, struct kvec *, int, unsigned long *);
+int 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
 				loff_t, struct kvec *,int, unsigned long, int *);
 int		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-03-07 11:35:10.000000000 +1100
+++ ./include/linux/nfsd/state.h	2005-03-07 11:35:11.000000000 +1100
@@ -279,7 +279,7 @@ struct nfs4_stateid {
 extern time_t nfs4_laundromat(void);
 extern int nfsd4_renew(clientid_t *clid);
 extern int nfs4_preprocess_stateid_op(struct svc_fh *current_fh, 
-		stateid_t *stateid, int flags);
+		stateid_t *stateid, int flags, struct file **filp);
 extern int nfs4_share_conflict(struct svc_fh *current_fh, 
 		unsigned int deny_type);
 extern void nfs4_lock_state(void);

diff ./include/linux/nfsd/xdr4.h~current~ ./include/linux/nfsd/xdr4.h
--- ./include/linux/nfsd/xdr4.h~current~	2005-03-07 11:35:11.000000000 +1100
+++ ./include/linux/nfsd/xdr4.h	2005-03-07 11:35:11.000000000 +1100
@@ -241,6 +241,7 @@ struct nfsd4_read {
 	u32		rd_length;          /* request */
 	struct kvec	rd_iov[RPCSVC_MAXPAGES];
 	int		rd_vlen;
+	struct file     *rd_filp;
 	
 	struct svc_rqst *rd_rqstp;          /* response */
 	struct svc_fh * rd_fhp;             /* response */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
