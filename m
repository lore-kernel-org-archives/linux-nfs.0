From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 003 of 3] Provide missing NFSv2 part of patch for checking vfs_getattr.
Date: Fri, 13 Jan 2006 14:14:28 +1100
Message-ID: <1060113031428.4672@cse.unsw.edu.au>
References: <20060113141059.4573.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExFOe-0001ro-9W
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 19:14:36 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExFOd-0007nj-MD
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 19:14:36 -0800
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


From: David Shaw <dshaw@jabberwocky.com>

A recent patch which checked the return status of vfs_getattr in nfsd,
completely missed the nfsproc.c (NFSv2) part.  Here is it.

This patch moved the call to vfs_getattr from the xdr encoding (at
which point it is too late to return an error) to the call handling.
This means several calls to vfs_getattr are needed in nfsproc.c.  Many
are encapsulated in nfsd_return_attrs and nfsd_return_dirop.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsproc.c |   37 ++++++++++++++++++++++++++++++-------
 1 file changed, 30 insertions(+), 7 deletions(-)

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2006-01-13 13:42:09.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2006-01-13 13:42:14.000000000 +1100
@@ -36,6 +36,22 @@ nfsd_proc_null(struct svc_rqst *rqstp, v
 	return nfs_ok;
 }
 
+static int
+nfsd_return_attrs(int err, struct nfsd_attrstat *resp)
+{
+	if (err) return err;
+	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_mnt,
+				    resp->fh.fh_dentry,
+				    &resp->stat));
+}
+static int
+nfsd_return_dirop(int err, struct nfsd_diropres *resp)
+{
+	if (err) return err;
+	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_mnt,
+				    resp->fh.fh_dentry,
+				    &resp->stat));
+}
 /*
  * Get a file's attributes
  * N.B. After this call resp->fh needs an fh_put
@@ -44,10 +60,12 @@ static int
 nfsd_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 					  struct nfsd_attrstat *resp)
 {
+	int nfserr;
 	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
 
 	fh_copy(&resp->fh, &argp->fh);
-	return fh_verify(rqstp, &resp->fh, 0, MAY_NOP);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, MAY_NOP);
+	return nfsd_return_attrs(nfserr, resp);
 }
 
 /*
@@ -58,12 +76,14 @@ static int
 nfsd_proc_setattr(struct svc_rqst *rqstp, struct nfsd_sattrargs *argp,
 					  struct nfsd_attrstat  *resp)
 {
+	int nfserr;
 	dprintk("nfsd: SETATTR  %s, valid=%x, size=%ld\n",
 		SVCFH_fmt(&argp->fh),
 		argp->attrs.ia_valid, (long) argp->attrs.ia_size);
 
 	fh_copy(&resp->fh, &argp->fh);
-	return nfsd_setattr(rqstp, &resp->fh, &argp->attrs,0, (time_t)0);
+	nfserr = nfsd_setattr(rqstp, &resp->fh, &argp->attrs,0, (time_t)0);
+	return nfsd_return_attrs(nfserr, resp);
 }
 
 /*
@@ -86,7 +106,7 @@ nfsd_proc_lookup(struct svc_rqst *rqstp,
 				 &resp->fh);
 
 	fh_put(&argp->fh);
-	return nfserr;
+	return nfsd_return_dirop(nfserr, resp);
 }
 
 /*
@@ -142,7 +162,10 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 			   	  argp->vec, argp->vlen,
 				  &resp->count);
 
-	return nfserr;
+	if (nfserr) return nfserr;
+	return nfserrno(vfs_getattr(resp->fh.fh_export->ex_mnt,
+				    resp->fh.fh_dentry,
+				    &resp->stat));
 }
 
 /*
@@ -165,7 +188,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, 
 				   argp->vec, argp->vlen,
 				   argp->len,
 				   &stable);
-	return nfserr;
+	return nfsd_return_attrs(nfserr, resp);
 }
 
 /*
@@ -322,7 +345,7 @@ out_unlock:
 
 done:
 	fh_put(dirfhp);
-	return nfserr;
+	return nfsd_return_dirop(nfserr, resp);
 }
 
 static int
@@ -425,7 +448,7 @@ nfsd_proc_mkdir(struct svc_rqst *rqstp, 
 	nfserr = nfsd_create(rqstp, &argp->fh, argp->name, argp->len,
 				    &argp->attrs, S_IFDIR, 0, &resp->fh);
 	fh_put(&argp->fh);
-	return nfserr;
+	return nfsd_return_dirop(nfserr, resp);
 }
 
 /*


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
