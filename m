From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Thu, 06 May 2004 13:39:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <409A7845.8090607@RedHat.com>
References: <40892507.2030004@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000405070904040309080304"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLmpX-0001ey-4r
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 10:38:43 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLmpW-0003Kx-LF
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 10:38:42 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.10/8.12.10) with ESMTP id i46Hca8c012721
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 13:38:36 -0400
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i46Hcav10331
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 13:38:36 -0400
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i46HcZl00795
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 13:38:35 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <40892507.2030004@RedHat.com>
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

This is a multi-part message in MIME format.
--------------000405070904040309080304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Here is a proper way of reinstantiating stale inodes....

SteveD.


--------------000405070904040309080304
Content-Type: text/plain;
 name="linux-2.4.21-nfs-estale4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-estale4.patch"

--- linux/fs/nfs/inode.c.orig	2004-05-06 11:31:23.000000000 -0400
+++ linux/fs/nfs/inode.c	2004-05-06 13:03:27.000000000 -0400
@@ -958,8 +958,17 @@ nfs_wait_on_inode(struct inode *inode, i
 int
 nfs_revalidate(struct dentry *dentry)
 {
+	int error;
 	struct inode *inode = dentry->d_inode;
-	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (error == -ESTALE) {
+		struct inode *dir = dentry->d_parent->d_inode;
+		nfs_zap_caches(dir);	
+		d_drop(dentry);
+	}
+
+	return error;
 }
 
 /*
--- linux/fs/stat.c.orig	2004-05-06 11:31:23.000000000 -0400
+++ linux/fs/stat.c	2004-05-06 13:03:27.000000000 -0400
@@ -143,8 +143,9 @@ static int cp_new_stat(struct inode * in
 asmlinkage long sys_stat(char * filename, struct __old_kernel_stat * statbuf)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -152,6 +153,10 @@ asmlinkage long sys_stat(char * filename
 			error = cp_old_stat(nd.dentry->d_inode, statbuf);
 		path_release(&nd);
 	}
+	if (error == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
 	return error;
 }
 #endif
@@ -159,8 +164,9 @@ asmlinkage long sys_stat(char * filename
 asmlinkage long sys_newstat(char * filename, struct stat * statbuf)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -168,6 +174,11 @@ asmlinkage long sys_newstat(char * filen
 			error = cp_new_stat(nd.dentry->d_inode, statbuf);
 		path_release(&nd);
 	}
+	if (error == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return error;
 }
 
@@ -180,8 +191,9 @@ asmlinkage long sys_newstat(char * filen
 asmlinkage long sys_lstat(char * filename, struct __old_kernel_stat * statbuf)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk_link(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -189,6 +201,11 @@ asmlinkage long sys_lstat(char * filenam
 			error = cp_old_stat(nd.dentry->d_inode, statbuf);
 		path_release(&nd);
 	}
+	if (error == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return error;
 }
 
@@ -197,8 +214,9 @@ asmlinkage long sys_lstat(char * filenam
 asmlinkage long sys_newlstat(char * filename, struct stat * statbuf)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk_link(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -206,6 +224,12 @@ asmlinkage long sys_newlstat(char * file
 			error = cp_new_stat(nd.dentry->d_inode, statbuf);
 		path_release(&nd);
 	}
+
+	if (error == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return error;
 }
 
@@ -218,8 +242,10 @@ asmlinkage long sys_newlstat(char * file
 asmlinkage long sys_fstat(unsigned int fd, struct __old_kernel_stat * statbuf)
 {
 	struct file * f;
-	int err = -EBADF;
+	int err, errcnt = 0;
 
+again:
+	err = -EBADF;
 	f = fget(fd);
 	if (f) {
 		struct dentry * dentry = f->f_dentry;
@@ -229,6 +255,11 @@ asmlinkage long sys_fstat(unsigned int f
 			err = cp_old_stat(dentry->d_inode, statbuf);
 		fput(f);
 	}
+	if (err == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return err;
 }
 
@@ -237,8 +268,10 @@ asmlinkage long sys_fstat(unsigned int f
 asmlinkage long sys_newfstat(unsigned int fd, struct stat * statbuf)
 {
 	struct file * f;
-	int err = -EBADF;
+	int err, errcnt = 0;
 
+again:
+	err = -EBADF;
 	f = fget(fd);
 	if (f) {
 		struct dentry * dentry = f->f_dentry;
@@ -248,6 +281,11 @@ asmlinkage long sys_newfstat(unsigned in
 			err = cp_new_stat(dentry->d_inode, statbuf);
 		fput(f);
 	}
+	if (err == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return err;
 }
 
@@ -340,8 +378,9 @@ static long cp_new_stat64(struct inode *
 asmlinkage long sys_stat64(char * filename, struct stat64 * statbuf, long flags)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -349,14 +388,20 @@ asmlinkage long sys_stat64(char * filena
 			error = cp_new_stat64(nd.dentry->d_inode, statbuf);
 		path_release(&nd);
 	}
+	if (error == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return error;
 }
 
 asmlinkage long sys_lstat64(char * filename, struct stat64 * statbuf, long flags)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt= 0;
 
+again:
 	error = user_path_walk_link(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -364,14 +409,21 @@ asmlinkage long sys_lstat64(char * filen
 			error = cp_new_stat64(nd.dentry->d_inode, statbuf);
 		path_release(&nd);
 	}
+	if (error == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
+
 	return error;
 }
 
 asmlinkage long sys_fstat64(unsigned long fd, struct stat64 * statbuf, long flags)
 {
 	struct file * f;
-	int err = -EBADF;
+	int err, errcnt = 0;
 
+again:
+	err = -EBADF;
 	f = fget(fd);
 	if (f) {
 		struct dentry * dentry = f->f_dentry;
@@ -381,6 +433,10 @@ asmlinkage long sys_fstat64(unsigned lon
 			err = cp_new_stat64(dentry->d_inode, statbuf);
 		fput(f);
 	}
+	if (err == -ESTALE && !errcnt) {
+		errcnt++;
+		goto again;
+	}
 	return err;
 }
 

--------------000405070904040309080304--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
