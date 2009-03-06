From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
Date: Fri, 06 Mar 2009 15:22:17 -0500
Message-ID: <1236370937.7244.52.camel@heimdal.trondhjem.org>
References: <49760685.4030409@redhat.com>
	 <1232475301.7055.14.camel@heimdal.trondhjem.org>
	 <alpine.LFD.1.10.0903050829420.3949@w-kevinr.beaverton.ibm.com>
	 <1236279188.13361.30.camel@heimdal.trondhjem.org>
	 <alpine.LFD.1.10.0903051135040.3949@w-kevinr.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-v4vb7abcBxnOlL8v7pWb"
Cc: linux-nfs@vger.kernel.org
To: "Kevin W. Rudd" <solgato@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:38233 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888AbZCFUWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Mar 2009 15:22:25 -0500
In-Reply-To: <alpine.LFD.1.10.0903051135040.3949-mupu0Q0mUPfkOmf+N4b0O9FgqiXiwxn+0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-v4vb7abcBxnOlL8v7pWb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2009-03-05 at 11:49 -0800, Kevin W. Rudd wrote:
> On Thu, 5 Mar 2009, Trond Myklebust wrote:
> 
> > Going over that particular procedure reveals a number of bugs that all
> > should be fixed.
> 
> So true ;-)
> 
> > Trying to estimate how many bytes are free in the header is _WRONG_.
> > That memory is allocated with certain assumptions, which are set in the
> > definition of ACL3_setaclargs_sz. In this case, the assumptions appear
> > to be that we will fit a maximum of 5 ACEs in the header.
> > IOW: the real fix for your corruption problem is simply to set
> > len_in_head to 2*(2+5*3). Currently, the patch supplied by Sachin will
> > always set it to zero.
> 
> Does setting len_in_head to 2*(2+5*3) take into account the
> header space already consumed?  The initial patch was just a
> quick-n-dirty way of making sure we didn't overwrite the initial
> buffer, and a mechanism for generating some discussion around the
> other deficiencies in this procedure.  I'll take the blame for
> it being a quick hack to simply take the heat off for a critical
> customer situation :)
> 
> > Secondly, doing page allocation in the XDR routine is _WRONG_. For one
> > thing, look at the major memory leak which happens if the client needs
> > to resend the request (which can happen every now and again due to a
> > dropped tcp connection, or all the time due to UDP retransmits).
> > Those pages should have been allocated in nfs3_proc_getacl(), and indeed
> > that is where the wretched things are freed.
> 
> That's an issue I hadn't noticed, but this isn't really my area of
> expertice.  Thanks for taking a closer look at this area of code.

Does the attached patch help?

Trond


--=-v4vb7abcBxnOlL8v7pWb
Content-Description: 
Content-Type: application/x-dif
Content-Disposition: inline; filename="linux-2.6.28-003-fix_nfsv3_acls.dif"
Content-Transfer-Encoding: 7bit

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 5 Mar 2009 17:27:38 -0500
NFSv3: Fix posix ACL code

Fix a memory leak due to allocation in the XDR layer. In cases where the
RPC call needs to be retransmitted, we end up allocating new pages without
clearing the old ones. Fix this by moving the allocation into
nfs3_proc_setacls().

Also fix an issue discovered by Kevin Rudd, whereby the amount of memory
reserved for the acls in the xdr_buf->head was miscalculated, and causing
corruption.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs3acl.c        |   27 +++++++++++++++++++++------
 fs/nfs/nfs3xdr.c        |   34 +++++++++++++---------------------
 include/linux/nfs_xdr.h |    2 ++
 include/linux/nfsacl.h  |    3 +++
 4 files changed, 39 insertions(+), 27 deletions(-)


diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index cef6255..9f0849c 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -292,7 +292,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_fattr fattr;
-	struct page *pages[NFSACL_MAXPAGES] = { };
+	struct page *pages[NFSACL_MAXPAGES];
 	struct nfs3_setaclargs args = {
 		.inode = inode,
 		.mask = NFS_ACL,
@@ -303,7 +303,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		.rpc_argp	= &args,
 		.rpc_resp	= &fattr,
 	};
-	int status, count;
+	int status;
 
 	status = -EOPNOTSUPP;
 	if (!nfs_server_capable(inode, NFS_CAP_ACLS))
@@ -319,6 +319,20 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	if (S_ISDIR(inode->i_mode)) {
 		args.mask |= NFS_DFACL;
 		args.acl_default = dfacl;
+		args.len = nfsacl_size(acl, dfacl);
+	} else
+		args.len = nfsacl_size(acl, NULL);
+
+	status = -ENOMEM;
+	if (args.len > NFS_ACL_INLINE_BUFSIZE) {
+		unsigned int npages = 1 + ((args.len - 1) >> PAGE_SHIFT);
+
+		do {
+			args.pages[args.npages] = alloc_page(GFP_KERNEL);
+			if (!args.pages[args.npages])
+				goto out_freepages;
+			args.npages++;
+		} while (args.npages < npages);
 	}
 
 	dprintk("NFS call setacl\n");
@@ -329,10 +343,6 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 	nfs_zap_acl_cache(inode);
 	dprintk("NFS reply setacl: %d\n", status);
 
-	/* pages may have been allocated at the xdr layer. */
-	for (count = 0; count < NFSACL_MAXPAGES && args.pages[count]; count++)
-		__free_page(args.pages[count]);
-
 	switch (status) {
 		case 0:
 			status = nfs_refresh_inode(inode, &fattr);
@@ -346,6 +356,11 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 	}
+out_freepages:
+	while (args.npages > 0) {
+		args.npages--;
+		__free_page(args.pages[args.npages]);
+	}
 out:
 	return status;
 }
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 11cddde..6cdeacf 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -82,8 +82,10 @@
 #define NFS3_commitres_sz	(1+NFS3_wcc_data_sz+2)
 
 #define ACL3_getaclargs_sz	(NFS3_fh_sz+1)
-#define ACL3_setaclargs_sz	(NFS3_fh_sz+1+2*(2+5*3))
-#define ACL3_getaclres_sz	(1+NFS3_post_op_attr_sz+1+2*(2+5*3))
+#define ACL3_setaclargs_sz	(NFS3_fh_sz+1+ \
+				XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
+#define ACL3_getaclres_sz	(1+NFS3_post_op_attr_sz+1+ \
+				XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
 #define ACL3_setaclres_sz	(1+NFS3_post_op_attr_sz)
 
 /*
@@ -703,28 +705,18 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
                    struct nfs3_setaclargs *args)
 {
 	struct xdr_buf *buf = &req->rq_snd_buf;
-	unsigned int base, len_in_head, len = nfsacl_size(
-		(args->mask & NFS_ACL)   ? args->acl_access  : NULL,
-		(args->mask & NFS_DFACL) ? args->acl_default : NULL);
-	int count, err;
+	unsigned int base;
+	int err;
 
 	p = xdr_encode_fhandle(p, NFS_FH(args->inode));
 	*p++ = htonl(args->mask);
-	base = (char *)p - (char *)buf->head->iov_base;
-	/* put as much of the acls into head as possible. */
-	len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
-	len -= len_in_head;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2));
-
-	for (count = 0; (count << PAGE_SHIFT) < len; count++) {
-		args->pages[count] = alloc_page(GFP_KERNEL);
-		if (!args->pages[count]) {
-			while (count)
-				__free_page(args->pages[--count]);
-			return -ENOMEM;
-		}
-	}
-	xdr_encode_pages(buf, args->pages, 0, len);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	base = req->rq_slen;
+
+	if (args->npages != 0)
+		xdr_encode_pages(buf, args->pages, 0, args->len);
+	else
+		req->rq_slen += args->len;
 
 	err = nfsacl_encode(buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a550b52..2e5f000 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -406,6 +406,8 @@ struct nfs3_setaclargs {
 	int			mask;
 	struct posix_acl *	acl_access;
 	struct posix_acl *	acl_default;
+	size_t			len;
+	unsigned int		npages;
 	struct page **		pages;
 };
 
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 54487a9..43011b6 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -37,6 +37,9 @@
 #define NFSACL_MAXPAGES		((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
 				 >> PAGE_SHIFT)
 
+#define NFS_ACL_MAX_ENTRIES_INLINE	(5)
+#define NFS_ACL_INLINE_BUFSIZE	((2*(2+3*NFS_ACL_MAX_ENTRIES_INLINE)) << 2)
+
 static inline unsigned int
 nfsacl_size(struct posix_acl *acl_access, struct posix_acl *acl_default)
 {

--=-v4vb7abcBxnOlL8v7pWb--

