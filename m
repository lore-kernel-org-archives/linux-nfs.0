From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 15 - Fixes for nfsd filesystem files
Date: Mon, 06 Jan 2003 11:05:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlM-0002Xq-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKli-0002Xz-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:06 +1100
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

The transaction files in the 'nfsd' filesystem
stores the per-transaction response size in the per-inode
i_size, which is wrong.
With this patch a page is allocated for holding size and
request and response, so routines don't need to
copy_fromuser.

Also, some routines were allocating rather large (>1024 bytes) 
stuctures on the stack for copy_fromuser into, which was not
nice and is now not needed.

Also, writeonly and write_read methods are unified in a single
transaction style interface.
Write then read performs and action and returns a response.
Write without read just performs the action and ignores response.
Read without write triggers an empty transaction which can still have
a response.  That functionality will be used in a later patch.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsctl.c |  262 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 139 insertions(+), 123 deletions(-)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-01-06 10:16:36.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2003-01-06 10:16:36.000000000 +1100
@@ -51,15 +51,15 @@ enum {
 /*
  * write() for these nodes.
  */
-static ssize_t write_svc(struct file *file, const char *buf, size_t size);
-static ssize_t write_add(struct file *file, const char *buf, size_t size);
-static ssize_t write_del(struct file *file, const char *buf, size_t size);
-static ssize_t write_export(struct file *file, const char *buf, size_t size);
-static ssize_t write_unexport(struct file *file, const char *buf, size_t size);
-static ssize_t write_getfd(struct file *file, const char *buf, size_t size);
-static ssize_t write_getfs(struct file *file, const char *buf, size_t size);
+static ssize_t write_svc(struct file *file, char *buf, size_t size);
+static ssize_t write_add(struct file *file, char *buf, size_t size);
+static ssize_t write_del(struct file *file, char *buf, size_t size);
+static ssize_t write_export(struct file *file, char *buf, size_t size);
+static ssize_t write_unexport(struct file *file, char *buf, size_t size);
+static ssize_t write_getfd(struct file *file, char *buf, size_t size);
+static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 
-static ssize_t (*write_op[])(struct file *, const char *, size_t) = {
+static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
 	[NFSD_Del] = write_del,
@@ -69,30 +69,77 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 };
 
-static ssize_t fs_write(struct file *file, const char *buf, size_t size, loff_t *pos)
+/* an argresp is stored in an allocated page and holds the 
+ * size of the argument or response, along with it's content
+ */
+struct argresp {
+	ssize_t size;
+	char data[0];
+};
+
+/*
+ * transaction based IO methods.
+ * The file expects a single write which triggers the transaction, and then
+ * possibly a read which collects the result - which is stored in a 
+ * file-local buffer.
+ */
+static ssize_t TA_write(struct file *file, const char *buf, size_t size, loff_t *pos)
 {
 	ino_t ino =  file->f_dentry->d_inode->i_ino;
+	struct argresp *ar;
+	ssize_t rv = 0;
+
 	if (ino >= sizeof(write_op)/sizeof(write_op[0]) || !write_op[ino])
 		return -EINVAL;
-	return write_op[ino](file, buf, size);
+	if (file->private_data) 
+		return -EINVAL; /* only one write allowed per open */
+	if (size > PAGE_SIZE - sizeof(struct argresp))
+		return -EFBIG;
+
+	ar = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!ar)
+		return -ENOMEM;
+	ar->size = 0;
+	down(&file->f_dentry->d_inode->i_sem);
+	if (file->private_data)
+		rv = -EINVAL;
+	else
+		file->private_data = ar;
+	up(&file->f_dentry->d_inode->i_sem);
+	if (rv) {
+		kfree(ar);
+		return rv;
+	}
+	if (copy_from_user(ar->data, buf, size))
+		return -EFAULT;
+	
+	rv =  write_op[ino](file, ar->data, size);
+	if (rv>0) {
+		ar->size = rv;
+		rv = size;
+	}
+	return rv;
 }
 
-/*
- * read(), open() and release() for getfs and getfd (read/write ones).
- * IO on these is a simple transaction - you open() the file, write() to it
- * and that generates a (stored) response.  After that read() will simply
- * access that response.
- */
 
 static ssize_t TA_read(struct file *file, char *buf, size_t size, loff_t *pos)
 {
-	if (!file->private_data)
+	struct argresp *ar;
+	ssize_t rv = 0;
+	
+	if (file->private_data == NULL)
+		rv = TA_write(file, buf, 0, pos);
+	if (rv < 0)
+		return rv;
+
+	ar = file->private_data;
+	if (!ar)
 		return 0;
-	if (*pos >= file->f_dentry->d_inode->i_size)
+	if (*pos >= ar->size)
 		return 0;
-	if (*pos + size > file->f_dentry->d_inode->i_size)
-		size = file->f_dentry->d_inode->i_size - *pos;
-	if (copy_to_user(buf, file->private_data + *pos, size))
+	if (*pos + size > ar->size)
+		size = ar->size - *pos;
+	if (copy_to_user(buf, ar->data + *pos, size))
 		return -EFAULT;
 	*pos += size;
 	return size;
@@ -112,12 +159,8 @@ static int TA_release(struct inode *inod
 	return 0;
 }
 
-static struct file_operations writer_ops = {
-	.write	= fs_write,
-};
-
-static struct file_operations reader_ops = {
-	.write		= fs_write,
+static struct file_operations transaction_ops = {
+	.write		= TA_write,
 	.read		= TA_read,
 	.open		= TA_open,
 	.release	= TA_release,
@@ -158,166 +201,139 @@ static struct file_operations exports_op
  *	Description of fs contents.
  */
 static struct { char *name; struct file_operations *ops; int mode; } files[] = {
-	[NFSD_Svc] = {"svc", &writer_ops, S_IWUSR},
-	[NFSD_Add] = {"add", &writer_ops, S_IWUSR},
-	[NFSD_Del] = {"del", &writer_ops, S_IWUSR},
-	[NFSD_Export] = {"export", &writer_ops, S_IWUSR},
-	[NFSD_Unexport] = {"unexport", &writer_ops, S_IWUSR},
-	[NFSD_Getfd] = {"getfd", &reader_ops, S_IWUSR|S_IRUSR},
-	[NFSD_Getfs] = {"getfs", &reader_ops, S_IWUSR|S_IRUSR},
+	[NFSD_Svc] = {"svc", &transaction_ops, S_IWUSR},
+	[NFSD_Add] = {"add", &transaction_ops, S_IWUSR},
+	[NFSD_Del] = {"del", &transaction_ops, S_IWUSR},
+	[NFSD_Export] = {"export", &transaction_ops, S_IWUSR},
+	[NFSD_Unexport] = {"unexport", &transaction_ops, S_IWUSR},
+	[NFSD_Getfd] = {"getfd", &transaction_ops, S_IWUSR|S_IRUSR},
+	[NFSD_Getfs] = {"getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 	[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 };
 
 /*----------------------------------------------------------------------------*/
 /*
  * payload - write methods
+ * If the method has a response, the response should be put in buf,
+ * and the length returned.  Otherwise return 0 or and -error.
  */
 
-static ssize_t write_svc(struct file *file, const char *buf, size_t size)
+static ssize_t write_svc(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_svc data;
-	if (size < sizeof(data))
+	struct nfsctl_svc *data;
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return nfsd_svc(data.svc_port, data.svc_nthreads);
+	data = (struct nfsctl_svc*) buf;
+	return nfsd_svc(data->svc_port, data->svc_nthreads);
 }
 
-static ssize_t write_add(struct file *file, const char *buf, size_t size)
+static ssize_t write_add(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_client data;
-	if (size < sizeof(data))
+	struct nfsctl_client *data;
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return exp_addclient(&data);
+	data = (struct nfsctl_client *)buf;
+	return exp_addclient(data);
 }
 
-static ssize_t write_del(struct file *file, const char *buf, size_t size)
+static ssize_t write_del(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_client data;
-	if (size < sizeof(data))
+	struct nfsctl_client *data;
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return exp_delclient(&data);
+	data = (struct nfsctl_client *)buf;
+	return exp_delclient(data);
 }
 
-static ssize_t write_export(struct file *file, const char *buf, size_t size)
+static ssize_t write_export(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_export data;
-	if (size < sizeof(data))
+	struct nfsctl_export *data;
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return exp_export(&data);
+	data = (struct nfsctl_export*)buf;
+	return exp_export(data);
 }
 
-static ssize_t write_unexport(struct file *file, const char *buf, size_t size)
+static ssize_t write_unexport(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_export data;
-	if (size < sizeof(data))
+	struct nfsctl_export *data;
+
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return exp_unexport(&data);
+	data = (struct nfsctl_export*)buf;
+	return exp_unexport(data);
 }
 
-static ssize_t write_getfs(struct file *file, const char *buf, size_t size)
+static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_fsparm data;
+	struct nfsctl_fsparm *data;
 	struct sockaddr_in *sin;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
 
-	if (file->private_data)
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (size < sizeof(data))
-		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	if (data.gd_addr.sa_family != AF_INET)
-		return -EPROTONOSUPPORT;
-	sin = (struct sockaddr_in *)&data.gd_addr;
-	if (data.gd_maxlen > NFS3_FHSIZE)
-		data.gd_maxlen = NFS3_FHSIZE;
-	res = kmalloc(sizeof(struct knfsd_fh), GFP_KERNEL);
-	if (!res)
-		return -ENOMEM;
-	memset(res, 0, sizeof(struct knfsd_fh));
+	data = (struct nfsctl_fsparm*)buf;
+	err = -EPROTONOSUPPORT;
+	if (data->gd_addr.sa_family != AF_INET)
+		goto out;
+	sin = (struct sockaddr_in *)&data->gd_addr;
+	if (data->gd_maxlen > NFS3_FHSIZE)
+		data->gd_maxlen = NFS3_FHSIZE;
+
+	res = (struct knfsd_fh*)buf;
+
 	exp_readlock();
 	if (!(clp = auth_unix_lookup(sin->sin_addr)))
 		err = -EPERM;
 	else {
-		err = exp_rootfh(clp, data.gd_path, res, data.gd_maxlen);
+		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
 		auth_domain_put(clp);
 	}
 	exp_readunlock();
-
-	down(&file->f_dentry->d_inode->i_sem);
-	if (file->private_data)
-		err = -EINVAL;
-	if (err)
-		kfree(res);
-	else {
-		file->f_dentry->d_inode->i_size = res->fh_size + (int)&((struct knfsd_fh*)0)->fh_base;
-		file->private_data = res;
-		err = sizeof(data);
-	}
-	up(&file->f_dentry->d_inode->i_sem);
-
+	if (err == 0)
+		err = res->fh_size + (int)&((struct knfsd_fh*)0)->fh_base;
+ out:
 	return err;
 }
 
-static ssize_t write_getfd(struct file *file, const char *buf, size_t size)
+static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
-	struct nfsctl_fdparm data;
+	struct nfsctl_fdparm *data;
 	struct sockaddr_in *sin;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh fh;
 	char *res;
 
-	if (file->private_data)
-		return -EINVAL;
-	if (size < sizeof(data))
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	if (data.gd_addr.sa_family != AF_INET)
-		return -EPROTONOSUPPORT;
-	if (data.gd_version < 2 || data.gd_version > NFSSVC_MAXVERS)
-		return -EINVAL;
-	res = kmalloc(NFS_FHSIZE, GFP_KERNEL);
-	if (!res)
-		return -ENOMEM;
-	sin = (struct sockaddr_in *)&data.gd_addr;
+	data = (struct nfsctl_fdparm*)buf;
+	err = -EPROTONOSUPPORT;
+	if (data->gd_addr.sa_family != AF_INET)
+		goto out;
+	err = -EINVAL;
+	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
+		goto out;
+
+	res = buf;
+	sin = (struct sockaddr_in *)&data->gd_addr;
 	exp_readlock();
 	if (!(clp = auth_unix_lookup(sin->sin_addr)))
 		err = -EPERM;
 	else {
-		err = exp_rootfh(clp, data.gd_path, &fh, NFS_FHSIZE);
+		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
 		auth_domain_put(clp);
 	}
 	exp_readunlock();
 
-	down(&file->f_dentry->d_inode->i_sem);
-	if (file->private_data)
-		err = -EINVAL;
-	if (!err && fh.fh_size > NFS_FHSIZE)
-		err = -EINVAL;
-	if (err)
-		kfree(res);
-	else {
+	if (err == 0) {
 		memset(res,0, NFS_FHSIZE);
 		memcpy(res, &fh.fh_base, fh.fh_size);
-		file->f_dentry->d_inode->i_size = NFS_FHSIZE;
-		file->private_data = res;
-		err = sizeof(data);
+		err = NFS_FHSIZE;
 	}
-	up(&file->f_dentry->d_inode->i_sem);
-
+ out:
 	return err;
 }
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
