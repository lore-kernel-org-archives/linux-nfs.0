Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39549 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932479AbaLJSbN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 13:31:13 -0500
Date: Wed, 10 Dec 2014 13:31:12 -0500
To: Trond Myklebust <trondmy@gmail.com>, linux-nfs@vger.kernel.org
Subject: NFSv4 ACLs and umasks
Message-ID: <20141210183112.GE20235@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've gotten complaints that the effect of NFSv4 ACL inheritance is
often overridden by common umask settings.

Options:
    
	- Do nothing, make sure the behavior's documented.  I don't
	  think this will make people happy, but I haven't tried to
	  figure out exactly what any of them are trying to do.

	- Do as in NFSv3 and teach the client to skip the umask in the
	  case the parent directory has inheritable ACEs.  The following
	  patch is a proof-of-concept with some bugs.  It requires
	  documenting what we mean by "parent directory has interitable
	  ACEs"--I'm taking it to mean that the ACL has some ACE with
	  inheritance bits set, as that's simple to explain.  Drawbacks
	  include: requires fetching and caching an ACL on create;
	  there's a race between checking and creating; creates may fail
	  just because reading the ACL fails.
    
	- New protocol: e.g. add a new attribute representing the
	  un-umasked mode, send both that and the regular mode on
	  create, let the server sort it out.

	- Something else??: adopt some convention that uses redundant
	  information in a compound (multiple SETATTRs?) to communicate
	  umask to "in the know" servers without changing behavior on
	  existing servers.  Provide an "ignore the umask" mount option.
	  Maybe I'm missing a clever trick.

Any ideas?

--b.
    
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 6e62155abf26..e3b4b6250693 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1503,7 +1503,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 
 	if (open_flags & O_CREAT) {
 		attr.ia_valid |= ATTR_MODE;
-		attr.ia_mode = mode & ~current_umask();
+		attr.ia_mode = mode;
 	}
 	if (open_flags & O_TRUNC) {
 		attr.ia_valid |= ATTR_SIZE;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 69dc20a743f9..efa2589f9242 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2793,6 +2793,81 @@ out:
 	return status;
 }
 
+static bool nfs4_ace_inheritable(u32 flags)
+{
+	return flags & (NFS4_ACE_FILE_INHERIT_ACE |
+			NFS4_ACE_DIRECTORY_INHERIT_ACE);
+
+}
+
+/* XXX: one-off by-hand xdr parsing: */
+static int nfs4_acl_has_inheritable_aces(void *buf, int len)
+{
+	__be32 *p = buf;
+	int naces, i;
+	u32 word;
+
+	if (len < 4)
+		goto overflow;
+	len -= 4;
+	naces = be32_to_cpup(p++);
+	for (i=0; i < naces; i++) {
+		if (len < 4*4)
+			goto overflow;
+		len -= 4 * 4;
+		p++; /* skip type */
+		word = be32_to_cpup(p++); /* flags */
+		if (nfs4_ace_inheritable(word))
+			return 1;
+		p++; /* skip access mask; */
+		/* skip name: */
+		word = be32_to_cpup(p++);
+		if (len < (XDR_QUADLEN(word) << 2))
+			goto overflow;
+		len -= XDR_QUADLEN(word) << 2;
+		p += XDR_QUADLEN(word);
+	}
+	return 0;
+overflow:
+	/* XXX: what should we do with too-long ACLs? */
+	return -EIO;
+}
+
+static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen);
+
+/*
+ * Apply the umask iff the directory lacks inheritable ACLs.
+ *
+ * XXX: Callers are ignoring the error cases.
+ */
+static int nfs4_apply_umask(struct inode *dir, unsigned short *mode)
+{
+	struct page *page;
+	void *buf;
+	int ret;
+
+	/* XXX: We probably need to handle longer ACLs: */
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+	buf = page_address(page);
+
+	ret = nfs4_proc_get_acl(dir, buf, PAGE_SIZE);
+	if (ret < 0)
+		goto out_free;
+	ret = nfs4_acl_has_inheritable_aces(buf, PAGE_SIZE);
+	if (ret < 0)
+		goto out_free;
+	if (ret) {
+		ret = 0;
+		goto out_free;
+	}
+	*mode &= ~current_umask();
+out_free:
+	__free_page(page);
+	return ret;
+}
+
 static struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx,
 		int open_flags, struct iattr *attr, int *opened)
@@ -2800,6 +2875,9 @@ nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx,
 	struct nfs4_state *state;
 	struct nfs4_label l = {0, 0, 0, NULL}, *label = NULL;
 
+	if (open_flags & O_CREAT)
+		nfs4_apply_umask(dir, &attr->ia_mode);
+
 	label = nfs4_label_init_security(dir, ctx->dentry, attr, &l);
 
 	/* Protect against concurrent sillydeletes */
@@ -3507,7 +3585,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 
 	ilabel = nfs4_label_init_security(dir, dentry, sattr, &l);
 
-	sattr->ia_mode &= ~current_umask();
+	nfs4_apply_umask(dir, &sattr->ia_mode);
 	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, &opened);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
@@ -3818,7 +3896,7 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 
 	label = nfs4_label_init_security(dir, dentry, sattr, &l);
 
-	sattr->ia_mode &= ~current_umask();
+	nfs4_apply_umask(dir, &sattr->ia_mode);
 	do {
 		err = _nfs4_proc_mkdir(dir, dentry, sattr, label);
 		trace_nfs4_mkdir(dir, &dentry->d_name, err);
@@ -3927,7 +4005,7 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 
 	label = nfs4_label_init_security(dir, dentry, sattr, &l);
 
-	sattr->ia_mode &= ~current_umask();
+	nfs4_apply_umask(dir, &sattr->ia_mode);
 	do {
 		err = _nfs4_proc_mknod(dir, dentry, sattr, label, rdev);
 		trace_nfs4_mknod(dir, &dentry->d_name, err);
