From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - knfsd - Reduce stack usage in some nfs syscall functions.
Date: Tue, 17 Dec 2002 13:09:44 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15870.34664.808856.732489@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O7B9-0005uQ-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 18:09:51 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.239] == wireless-239.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 17 Dec 2002 13:09:45 +1100
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



Some of the 'data' structures for receiving syscall
arguments are quite large.  This patch converts to
larger one to be kmalloced instead of automatic.

(Patch against 2.5.current)
 ----------- Diffstat output ------------
 ./fs/nfsd/nfsctl.c |   92 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 59 insertions(+), 33 deletions(-)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2002-12-09 15:47:56.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2002-12-09 15:47:56.000000000 +1100
@@ -205,27 +205,37 @@ static ssize_t write_del(struct file *fi
 
 static ssize_t write_export(struct file *file, const char *buf, size_t size)
 {
-	struct nfsctl_export data;
-	if (size < sizeof(data))
+	struct nfsctl_export *data;
+	ssize_t rv;
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return exp_export(&data);
+	if (!(data = kmalloc(sizeof(*data), GFP_KERNEL)))
+		return -ENOMEM;
+	rv = -EFAULT;
+	if (copy_from_user(data, buf, size) == 0)
+		rv = exp_export(data);
+	kfree(data);
+	return rv;
 }
 
 static ssize_t write_unexport(struct file *file, const char *buf, size_t size)
 {
-	struct nfsctl_export data;
-	if (size < sizeof(data))
+	struct nfsctl_export *data;
+	ssize_t rv;
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	return exp_unexport(&data);
+	if (!(data = kmalloc(sizeof(*data), GFP_KERNEL)))
+		return -ENOMEM;
+	rv = -EFAULT;
+	if (copy_from_user(data, buf, size) == 0)
+		rv = exp_unexport(data);
+	kfree(data);
+	return rv;
 }
 
 static ssize_t write_getfs(struct file *file, const char *buf, size_t size)
 {
-	struct nfsctl_fsparm data;
+	struct nfsctl_fsparm *data;
 	struct sockaddr_in *sin;
 	struct auth_domain *clp;
 	int err = 0;
@@ -233,24 +243,30 @@ static ssize_t write_getfs(struct file *
 
 	if (file->private_data)
 		return -EINVAL;
-	if (size < sizeof(data))
+	if (size < sizeof(*data))
 		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	if (data.gd_addr.sa_family != AF_INET)
-		return -EPROTONOSUPPORT;
-	sin = (struct sockaddr_in *)&data.gd_addr;
-	if (data.gd_maxlen > NFS3_FHSIZE)
-		data.gd_maxlen = NFS3_FHSIZE;
+	data = kmalloc(sizeof(*data), GFP_KERNEL);
+	if (!data) 
+		return -ENOMEM;
+	err = -EFAULT;
+	if (copy_from_user(data, buf, size))
+		goto out;
+	err = -EPROTONOSUPPORT;
+	if (data->gd_addr.sa_family != AF_INET)
+		goto out;
+	sin = (struct sockaddr_in *)&data->gd_addr;
+	if (data->gd_maxlen > NFS3_FHSIZE)
+		data->gd_maxlen = NFS3_FHSIZE;
+	err = -ENOMEM;
 	res = kmalloc(sizeof(struct knfsd_fh), GFP_KERNEL);
 	if (!res)
-		return -ENOMEM;
+		goto out;
 	memset(res, 0, sizeof(struct knfsd_fh));
 	exp_readlock();
 	if (!(clp = auth_unix_lookup(sin->sin_addr)))
 		err = -EPERM;
 	else {
-		err = exp_rootfh(clp, data.gd_path, res, data.gd_maxlen);
+		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
 		auth_domain_put(clp);
 	}
 	exp_readunlock();
@@ -263,16 +279,18 @@ static ssize_t write_getfs(struct file *
 	else {
 		file->f_dentry->d_inode->i_size = res->fh_size + (int)&((struct knfsd_fh*)0)->fh_base;
 		file->private_data = res;
-		err = sizeof(data);
+		err = sizeof(*data);
 	}
 	up(&file->f_dentry->d_inode->i_sem);
 
+ out:
+	kfree(data);
 	return err;
 }
 
 static ssize_t write_getfd(struct file *file, const char *buf, size_t size)
 {
-	struct nfsctl_fdparm data;
+	struct nfsctl_fdparm *data;
 	struct sockaddr_in *sin;
 	struct auth_domain *clp;
 	int err = 0;
@@ -281,23 +299,29 @@ static ssize_t write_getfd(struct file *
 
 	if (file->private_data)
 		return -EINVAL;
-	if (size < sizeof(data))
-		return -EINVAL;
-	if (copy_from_user(&data, buf, size))
-		return -EFAULT;
-	if (data.gd_addr.sa_family != AF_INET)
-		return -EPROTONOSUPPORT;
-	if (data.gd_version < 2 || data.gd_version > NFSSVC_MAXVERS)
+	if (size < sizeof(*data))
 		return -EINVAL;
+	if (!(data = kmalloc(sizeof(*data), GFP_KERNEL)))
+		return -ENOMEM;
+	err = -EFAULT;
+	if (copy_from_user(data, buf, size))
+		goto out;
+	err = -EPROTONOSUPPORT;
+	if (data->gd_addr.sa_family != AF_INET)
+		goto out;
+	err = -EINVAL;
+	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
+		goto out;
+	err = -ENOMEM;
 	res = kmalloc(NFS_FHSIZE, GFP_KERNEL);
 	if (!res)
-		return -ENOMEM;
-	sin = (struct sockaddr_in *)&data.gd_addr;
+		goto out;
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
@@ -318,6 +342,8 @@ static ssize_t write_getfd(struct file *
 	}
 	up(&file->f_dentry->d_inode->i_sem);
 
+ out:
+	kfree(data);
 	return err;
 }
 


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
