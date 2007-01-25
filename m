From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Fix type mismatch with filldir_t used by nfsd.
Date: Thu, 25 Jan 2007 15:18:52 +1100
Message-ID: <1070125041852.12337@suse.de>
References: <20070125151807.12305.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9w52-0002WN-8N
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 20:19:20 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9w53-0003Ci-91
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 20:19:22 -0800
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

Another nfsd patch suitable for 2.6.20...
Thanks,
NeilBrown


### Comments for Changeset

nfsd defines a type 'encode_dent_fn' which is much like 'filldir_t'
except that the first pointer is 'struct readdir_cd *' rather than
'void *'.  It then casts encode_dent_fn points to 'filldir_t' as
needed.  This hides any other type mismatches between the two such as
the fact that the 'ino' arg recently changed from ino_t to u64.

So: get rid of 'encode_dent_fn', get rid of the cast of the function
type, change the first arg of various functions from 'struct readdir_cd *'
to 'void *', and live with the fact that we have a little less type
checking on the calling of these functions now.  
Less internal (to nfsd) checking offset by more external checking, which
is more important.

Thanks to Gabriel Paubert <paubert@iram.es> for discovering this and
providing an initial patch.

Signed-off-by: Gabriel Paubert <paubert@iram.es>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs3xdr.c         |    9 +++++----
 ./fs/nfsd/nfs4xdr.c         |    5 +++--
 ./fs/nfsd/nfsxdr.c          |    5 +++--
 ./fs/nfsd/vfs.c             |    4 ++--
 ./include/linux/nfsd/nfsd.h |    4 +---
 ./include/linux/nfsd/xdr.h  |    4 ++--
 ./include/linux/nfsd/xdr3.h |    8 ++++----
 7 files changed, 20 insertions(+), 19 deletions(-)

diff .prev/fs/nfsd/nfs3xdr.c ./fs/nfsd/nfs3xdr.c
--- .prev/fs/nfsd/nfs3xdr.c	2007-01-24 18:38:49.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2007-01-24 18:45:40.000000000 +1100
@@ -990,15 +990,16 @@ encode_entry(struct readdir_cd *ccd, con
 }
 
 int
-nfs3svc_encode_entry(struct readdir_cd *cd, const char *name,
-		     int namlen, loff_t offset, ino_t ino, unsigned int d_type)
+nfs3svc_encode_entry(void *cd, const char *name,
+		     int namlen, loff_t offset, u64 ino, unsigned int d_type)
 {
 	return encode_entry(cd, name, namlen, offset, ino, d_type, 0);
 }
 
 int
-nfs3svc_encode_entry_plus(struct readdir_cd *cd, const char *name,
-			  int namlen, loff_t offset, ino_t ino, unsigned int d_type)
+nfs3svc_encode_entry_plus(void *cd, const char *name,
+			  int namlen, loff_t offset, u64 ino,
+			  unsigned int d_type)
 {
 	return encode_entry(cd, name, namlen, offset, ino, d_type, 1);
 }

diff .prev/fs/nfsd/nfs4xdr.c ./fs/nfsd/nfs4xdr.c
--- .prev/fs/nfsd/nfs4xdr.c	2007-01-22 09:08:18.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2007-01-24 18:44:19.000000000 +1100
@@ -1880,9 +1880,10 @@ nfsd4_encode_rdattr_error(__be32 *p, int
 }
 
 static int
-nfsd4_encode_dirent(struct readdir_cd *ccd, const char *name, int namlen,
-		    loff_t offset, ino_t ino, unsigned int d_type)
+nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
+		    loff_t offset, u64 ino, unsigned int d_type)
 {
+	struct readdir_cd *ccd = ccdv;
 	struct nfsd4_readdir *cd = container_of(ccd, struct nfsd4_readdir, common);
 	int buflen;
 	__be32 *p = cd->buffer;

diff .prev/fs/nfsd/nfsxdr.c ./fs/nfsd/nfsxdr.c
--- .prev/fs/nfsd/nfsxdr.c	2007-01-24 18:33:50.000000000 +1100
+++ ./fs/nfsd/nfsxdr.c	2007-01-24 18:37:33.000000000 +1100
@@ -462,9 +462,10 @@ nfssvc_encode_statfsres(struct svc_rqst 
 }
 
 int
-nfssvc_encode_entry(struct readdir_cd *ccd, const char *name,
-		    int namlen, loff_t offset, ino_t ino, unsigned int d_type)
+nfssvc_encode_entry(void *ccdv, const char *name,
+		    int namlen, loff_t offset, u64 ino, unsigned int d_type)
 {
+	struct readdir_cd *ccd = ccdv;
 	struct nfsd_readdirres *cd = container_of(ccd, struct nfsd_readdirres, common);
 	__be32	*p = cd->buffer;
 	int	buflen, slen;

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-01-23 11:15:06.000000000 +1100
+++ ./fs/nfsd/vfs.c	2007-01-24 18:32:10.000000000 +1100
@@ -1720,7 +1720,7 @@ out:
  */
 __be32
 nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t *offsetp, 
-	     struct readdir_cd *cdp, encode_dent_fn func)
+	     struct readdir_cd *cdp, filldir_t func)
 {
 	__be32		err;
 	int 		host_err;
@@ -1745,7 +1745,7 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 
 	do {
 		cdp->err = nfserr_eof; /* will be cleared on successful read */
-		host_err = vfs_readdir(file, (filldir_t) func, cdp);
+		host_err = vfs_readdir(file, func, cdp);
 	} while (host_err >=0 && cdp->err == nfs_ok);
 	if (host_err)
 		err = nfserrno(host_err);

diff .prev/include/linux/nfsd/nfsd.h ./include/linux/nfsd/nfsd.h
--- .prev/include/linux/nfsd/nfsd.h	2007-01-22 09:08:17.000000000 +1100
+++ ./include/linux/nfsd/nfsd.h	2007-01-25 10:31:56.000000000 +1100
@@ -52,8 +52,6 @@
 struct readdir_cd {
 	__be32			err;	/* 0, nfserr, or nfserr_eof */
 };
-typedef int		(*encode_dent_fn)(struct readdir_cd *, const char *,
-						int, loff_t, ino_t, unsigned int);
 typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
 
 extern struct svc_program	nfsd_program;
@@ -117,7 +115,7 @@ __be32		nfsd_unlink(struct svc_rqst *, s
 int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
 				unsigned long size);
 __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
-			     loff_t *, struct readdir_cd *, encode_dent_fn);
+			     loff_t *, struct readdir_cd *, filldir_t);
 __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 				struct kstatfs *);
 

diff .prev/include/linux/nfsd/xdr3.h ./include/linux/nfsd/xdr3.h
--- .prev/include/linux/nfsd/xdr3.h	2007-01-24 18:40:06.000000000 +1100
+++ ./include/linux/nfsd/xdr3.h	2007-01-24 18:41:45.000000000 +1100
@@ -331,11 +331,11 @@ int nfs3svc_release_fhandle(struct svc_r
 				struct nfsd3_attrstat *);
 int nfs3svc_release_fhandle2(struct svc_rqst *, __be32 *,
 				struct nfsd3_fhandle_pair *);
-int nfs3svc_encode_entry(struct readdir_cd *, const char *name,
-				int namlen, loff_t offset, ino_t ino,
+int nfs3svc_encode_entry(void *, const char *name,
+				int namlen, loff_t offset, u64 ino,
 				unsigned int);
-int nfs3svc_encode_entry_plus(struct readdir_cd *, const char *name,
-				int namlen, loff_t offset, ino_t ino,
+int nfs3svc_encode_entry_plus(void *, const char *name,
+				int namlen, loff_t offset, u64 ino,
 				unsigned int);
 /* Helper functions for NFSv3 ACL code */
 __be32 *nfs3svc_encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p,

diff .prev/include/linux/nfsd/xdr.h ./include/linux/nfsd/xdr.h
--- .prev/include/linux/nfsd/xdr.h	2007-01-24 18:34:11.000000000 +1100
+++ ./include/linux/nfsd/xdr.h	2007-01-24 18:45:54.000000000 +1100
@@ -165,8 +165,8 @@ int nfssvc_encode_readres(struct svc_rqs
 int nfssvc_encode_statfsres(struct svc_rqst *, __be32 *, struct nfsd_statfsres *);
 int nfssvc_encode_readdirres(struct svc_rqst *, __be32 *, struct nfsd_readdirres *);
 
-int nfssvc_encode_entry(struct readdir_cd *, const char *name,
-				int namlen, loff_t offset, ino_t ino, unsigned int);
+int nfssvc_encode_entry(void *, const char *name,
+			int namlen, loff_t offset, u64 ino, unsigned int);
 
 int nfssvc_release_fhandle(struct svc_rqst *, __be32 *, struct nfsd_fhandle *);
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
