Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41936 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759562Ab0G3ScG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 14:32:06 -0400
Date: Fri, 30 Jul 2010 14:30:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/5] nfsd: bypass readahead cache when have struct file
Message-ID: <20100730183052.GD21729@fieldses.org>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com>
 <1280442084-17867-2-git-send-email-bfields@redhat.com>
 <20100730081041.GA4126@infradead.org>
 <20100730154128.GA21729@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100730154128.GA21729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 30, 2010 at 11:41:28AM -0400, bfields wrote:
> On Fri, Jul 30, 2010 at 04:10:42AM -0400, Christoph Hellwig wrote:
> > The callers of nfsd_read are:
> > 
> > fs/nfsd/nfs3proc.c:     nfserr = nfsd_read(rqstp, &resp->fh, NULL,
> > fs/nfsd/nfs4proc.c:     /* no need to check permission - this will be done in nfsd_read() */
> > fs/nfsd/nfs4xdr.c:      nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp, read->rd_filp,
> > fs/nfsd/nfsproc.c:      nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
> > 
> > which suggests that we're better off just calling nfsd_open_read
> > (possible with a better name) directly from fs/nfsd/nfs3proc.c and
> > fs/nfsd/nfsproc.c and nfsd_vfs_read directly from fs/nfsd/nfs4proc.c
> > and fs/nfsd/nfs4xdr.c instead of doing this conditional.
> 
> So, something like this.--b.

No, I forgot the parameter the v4 caller passes can sometimes be NULL
(v4 allows use of a "special stateid" not associated with any open), so
we still need the condition in that case.

Still probably an improvement.

--b.

commit 039a87ca536a85bc169ce092e44bd57adfa1f563
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jul 30 11:33:32 2010 -0400

    nfsd: minor nfsd read api cleanup
    
    Christoph points that the NFSv2/v3 callers know which case they want
    here, so we may as well just call the file=NULL case directly instead of
    making this conditional.
    
    Cc: Christoph Hellwig <hch@infradead.org>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 9ae9331..5b7e302 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -168,7 +168,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
 	svc_reserve_auth(rqstp, ((1 + NFS3_POST_OP_ATTR_WORDS + 3)<<2) + resp->count +4);
 
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = nfsd_read(rqstp, &resp->fh, NULL,
+	nfserr = nfsd_read(rqstp, &resp->fh,
 				  argp->offset,
 			   	  rqstp->rq_vec, argp->vlen,
 				  &resp->count);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 835924f..f8931ac 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2630,7 +2630,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	}
 	read->rd_vlen = v;
 
-	nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp, read->rd_filp,
+	nfserr = nfsd_read_file(read->rd_rqstp, read->rd_fhp, read->rd_filp,
 			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
 			&maxcount);
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 1edb78b..08e1726 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -144,7 +144,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
 	svc_reserve_auth(rqstp, (19<<2) + argp->count + 4);
 
 	resp->count = argp->count;
-	nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
+	nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh),
 				  argp->offset,
 			   	  rqstp->rq_vec, argp->vlen,
 				  &resp->count);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 3458a8f..1709138 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1065,7 +1065,12 @@ out:
 	return err;
 }
 
-static __be32 nfsd_open_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
+/*
+ * Read data from a file. count must contain the requested read count
+ * on entry. On return, *count contains the number of bytes actually read.
+ * N.B. After this call fhp needs an fh_put
+ */
+__be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
 	struct file *file;
@@ -1101,13 +1106,9 @@ static __be32 nfsd_open_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return err;
 }
 
-/*
- * Read data from a file. count must contain the requested read count
- * on entry. On return, *count contains the number of bytes actually read.
- * N.B. After this call fhp needs an fh_put
- */
+/* As above, but use the provided file descriptor. */
 __be32
-nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
+nfsd_read_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		loff_t offset, struct kvec *vec, int vlen,
 		unsigned long *count)
 {
@@ -1119,8 +1120,8 @@ nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 		if (err)
 			goto out;
 		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
-	} else
-		err = nfsd_open_read(rqstp, fhp, offset, vec, vlen, count);
+	} else /* Note file may still be NULL in NFSv4 special stateid case: */
+		err = nfsd_read(rqstp, fhp, offset, vec, vlen, count);
 out:
 	return err;
 }
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 217a62c..9a370a5 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -64,7 +64,9 @@ __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, int,
 				int, struct file **);
 void		nfsd_close(struct file *);
-__be32 		nfsd_read(struct svc_rqst *, struct svc_fh *, struct file *,
+__be32 		nfsd_read(struct svc_rqst *, struct svc_fh *,
+				loff_t, struct kvec *, int, unsigned long *);
+__be32 		nfsd_read_file(struct svc_rqst *, struct svc_fh *, struct file *,
 				loff_t, struct kvec *, int, unsigned long *);
 __be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
 				loff_t, struct kvec *,int, unsigned long *, int *);
