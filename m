From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 12 of 12 - NFSv4: tweak nfsd_readdir() for NFSv4
Date: Thu, 22 Aug 2002 10:35:20 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwW-00051w-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwr-0000qx-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:41 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:31 +1000
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet


From:	"Kendrick M. Smith" <kmsmith@umich.edu>

This patch makes three small changes to nfsd_readdir().

First, the 'filldir' routine for NFSv4 may return an arbitrary error,
which should become the return value for nfsd_readdir().  I implemented
this by adding an 'nfserr' field to the 'struct readdir_cd'.

Second, in NFSv4 the caller of nfsd_readdir() will specify an attribute
bitmap, which must be communicated to the 'filldir' routine.  I implemented
this by adding a @bitmap parameter to nfsd_readdir() and a corresponding
field in the 'struct readdir_cd'.  (The bitmap is not interpreted in any
way by nfsd_readdir().)

Finally, NFSv4 defines a new error nfserr_readdir_nospc, which indicates
that there was not enough buffer space to encode a single entry.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c        |    4 ++--
 ./fs/nfsd/nfsproc.c         |    2 +-
 ./fs/nfsd/vfs.c             |   13 ++++++++++++-
 ./include/linux/nfsd/nfsd.h |    5 ++++-
 4 files changed, 19 insertions(+), 5 deletions(-)

--- ./include/linux/nfsd/nfsd.h	2002/08/21 23:26:20	1.4
+++ ./include/linux/nfsd/nfsd.h	2002/08/21 23:26:43	1.5
@@ -55,6 +55,8 @@ struct readdir_cd {
 	char			plus;		/* readdirplus */
 	char			eob;		/* end of buffer */
 	char			dotonly;
+	int			nfserr;		/* v4 only */
+	u32			bmval[2];	/* v4 only */
 };
 typedef int		(*encode_dent_fn)(struct readdir_cd *, const char *,
 						int, loff_t, ino_t, unsigned int);
@@ -119,7 +121,8 @@ int		nfsd_truncate(struct svc_rqst *, st
 				unsigned long size);
 int		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
 				loff_t, encode_dent_fn,
-				u32 *buffer, int *countp, u32 *verf);
+				u32 *buffer, int *countp, u32 *verf,
+				u32 *bmval);
 int		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 				struct statfs *);
 
--- ./fs/nfsd/vfs.c	2002/08/21 23:26:20	1.6
+++ ./fs/nfsd/vfs.c	2002/08/21 23:26:44	1.7
@@ -1381,7 +1381,7 @@ out_nfserr:
  */
 int
 nfsd_readdir(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset, 
-             encode_dent_fn func, u32 *buffer, int *countp, u32 *verf)
+             encode_dent_fn func, u32 *buffer, int *countp, u32 *verf, u32 *bmval)
 {
 	u32		*p;
 	int		oldlen, eof, err;
@@ -1402,6 +1402,10 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 	cd.buffer = buffer;
 	cd.buflen = *countp; /* count of words */
 	cd.dirfh  = fhp;
+	if (bmval) {
+		cd.bmval[0] = bmval[0];
+		cd.bmval[1] = bmval[1];
+	}
 
 	/*
 	 * Read the directory entries. This silly loop is necessary because
@@ -1417,8 +1421,15 @@ nfsd_readdir(struct svc_rqst *rqstp, str
 		if (err < 0)
 			goto out_nfserr;
 
+		err = cd.nfserr;
+		if (err)
+			goto out_close;
 	} while (oldlen != cd.buflen && !cd.eob);
 
+	err = nfserr_readdir_nospc;
+	if (rqstp->rq_vers == 4 && cd.eob && cd.buffer == buffer)
+		goto out_close;
+
 	/* If we didn't fill the buffer completely, we're at EOF */
 	eof = !cd.eob;
 
--- ./fs/nfsd/nfs3proc.c	2002/08/21 23:26:21	1.3
+++ ./fs/nfsd/nfs3proc.c	2002/08/21 23:26:44	1.4
@@ -460,7 +460,7 @@ nfsd3_proc_readdir(struct svc_rqst *rqst
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t) argp->cookie, 
 					nfs3svc_encode_entry,
-					buffer, &count, argp->verf);
+					buffer, &count, argp->verf, NULL);
 	memcpy(resp->verf, argp->verf, 8);
 	resp->count = count;
 
@@ -495,7 +495,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t) argp->cookie, 
 					nfs3svc_encode_entry_plus,
-					buffer, &count, argp->verf);
+					buffer, &count, argp->verf, NULL);
 	memcpy(resp->verf, argp->verf, 8);
 	resp->count = count;
 
--- ./fs/nfsd/nfsproc.c	2002/08/21 23:26:40	1.1
+++ ./fs/nfsd/nfsproc.c	2002/08/21 23:26:44	1.2
@@ -492,7 +492,7 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 	/* Read directory and encode entries on the fly */
 	nfserr = nfsd_readdir(rqstp, &argp->fh, (loff_t) argp->cookie, 
 			      nfssvc_encode_entry,
-			      buffer, &count, NULL);
+			      buffer, &count, NULL, NULL);
 	resp->count = count;
 
 	fh_put(&argp->fh);


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
