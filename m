From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] nfs4: on a O_EXCL OPEN make sure the SETATTR
 sets the fields holding the verifier
Date: Tue, 5 Jun 2007 14:49:03 -0400
Message-ID: <20070605144903.f1b65dbd.jlayton@redhat.com>
References: <20070605135659.8f9c2715.jlayton@redhat.com>
	<1181067182.7033.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HveZ8-0000F3-1h
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 12:19:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HveZA-0007CI-Rc
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 12:19:41 -0700
In-Reply-To: <1181067182.7033.25.camel@heimdal.trondhjem.org>
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

Thanks for the comments, Trond. Here's a new patch. It builds but I haven't
done any thorough testing of it. If this looks reasonable, I'll do some more
thorough testing with it to make sure it fixes the testcase.

Also, do you have any suggestions of other attrs I should be checking in
nfs4_exclusive_attrset?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8e46e3e..6f76869 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -955,6 +955,22 @@ static struct nfs4_state *nfs4_open_delegated(struct inode *inode, int flags, st
 }
 
 /*
+ * on an EXCLUSIVE create, the server should send back a bitmask with FATTR4-*
+ * fields corresponding to attributes that were used to store the verifier.
+ * Make sure we clobber those fields in the later setattr call
+ */
+static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct iattr *sattr)
+{
+	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_ACCESS) &&
+	    !(sattr->ia_valid & ATTR_ATIME_SET))
+		sattr->ia_valid |= ATTR_ATIME;
+
+	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_MODIFY) &&
+	    !(sattr->ia_valid & ATTR_MTIME_SET))
+		sattr->ia_valid |= ATTR_MTIME;
+}
+
+/*
  * Returns a referenced nfs4_state
  */
 static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, int flags, struct iattr *sattr, struct rpc_cred *cred, struct nfs4_state **res)
@@ -985,6 +1001,9 @@ static int _nfs4_do_open(struct inode *dir, struct dentry *dentry, int flags, st
 	if (status != 0)
 		goto err_opendata_free;
 
+	if (opendata->o_arg.open_flags & O_EXCL)
+		nfs4_exclusive_attrset(opendata, sattr);
+
 	status = -ENOMEM;
 	state = nfs4_opendata_to_nfs4_state(opendata);
 	if (state == NULL)
@@ -1787,6 +1806,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = nfs4_do_setattr(state->inode, &fattr, sattr, state);
 		if (status == 0)
 			nfs_setattr_update_inode(state->inode, sattr);
+		nfs_post_op_update_inode(state->inode, &fattr);
 	}
 	if (status == 0 && nd != NULL && (nd->flags & LOOKUP_OPEN))
 		status = nfs4_intent_set_file(nd, dentry, state);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4eb8a59..29f3c0b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3313,7 +3313,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 {
         __be32 *p;
-        uint32_t bmlen;
+        uint32_t savewords, bmlen, i;
         int status;
 
         status = decode_op_hdr(xdr, OP_OPEN);
@@ -3331,7 +3331,12 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
                 goto xdr_error;
 
         READ_BUF(bmlen << 2);
-        p += bmlen;
+	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
+	for (i = 0; i < savewords; ++i) 
+		READ32(res->attrset[i]);
+
+	p += (bmlen - savewords);
+
 	return decode_delegation(xdr, res);
 xdr_error:
 	dprintk("%s: Bitmap too large! Length = %u\n", __FUNCTION__, bmlen);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 16116b8..4257719 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -15,6 +15,7 @@
 
 #include <linux/types.h>
 
+#define NFS4_BITMAP_SIZE	2
 #define NFS4_VERIFIER_SIZE	8
 #define NFS4_STATEID_SIZE	16
 #define NFS4_FHSIZE		128
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index f8c55e5..690481f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -145,6 +145,7 @@ struct nfs_openres {
 	nfs4_stateid		delegation;
 	__u32			do_recall;
 	__u64			maxsize;
+	__u32			attrset[NFS4_BITMAP_SIZE];
 };
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
