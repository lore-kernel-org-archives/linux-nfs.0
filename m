From: Neil Horman <nhorman@redhat.com>
Subject: Re: possible client stale filehandle bug?
Date: Wed, 26 Jan 2005 08:11:50 -0500
Message-ID: <41F79716.6020303@redhat.com>
References: <20050125173945.GU12269@polop.usc.edu> <1106719587.10014.4.camel@lade.trondhjem.org> <20050126063547.GS12269@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060805050701020606020608"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctmxd-0004wY-9t
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 05:11:53 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Ctmxc-0007EX-Ex
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 05:11:53 -0800
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20050126063547.GS12269@polop.usc.edu>
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

This is a multi-part message in MIME format.
--------------060805050701020606020608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Garrick Staples wrote:
> On Tue, Jan 25, 2005 at 10:06:27PM -0800, Trond Myklebust alleged:
> 
>>ty den 25.01.2005 Klokka 09:39 (-0800) skreiv Garrick Staples:
>>
>>>Hi all,
>>>   I have lots of storage in a large Solaris samfs environment that is NFS
>>>shared to a large number of Solaris and RHEL3 clients.  Under some conditions,
>>>linux apps have been getting stale filehandles during the normal course of
>>>their activity.  Various file handling syscalls like read() or open() might
>>>error.  Lots of renames and setattrs calls seem to trigger the problem.  
>>>'ci' and 'cvs commit' are particularly good at this.
>>
>>ESTALE is usually a sign that someone is deleting a file on the server
>>that is in use by the client. It is a sign that you are doing something
>>that violates the caching rules of NFS.
> 
> 
> Nothing of the kind is happening here.  I've tested this a thousand times over
> the last few days trying to find a solution.  In this case, Sun's samfs
> filesystem is definitely at fault and doing the wrong thing.  Backline
> engineers at Sun confirm this and are working on a fix.  
> 
> The reason for _this_ email isn't because of the ESTALEs, it's regarding the
> handling of the ESTALEs.  Right now I need the Solaris client behaviour to
> deal with this particular buggy server.
> 
> Incidentally, 2.6.10 never has a problem.  It's behaviour never creates ESTALEs in
> the first place.
> 
>  
> 
>>>It seems that the Solaris clients never report any such errors, only the Linux
>>>clients.  However, watching 'snoop' on the Solaris NFS server, I see that it IS
>>>returning stale file handles to both OSes, but Solaris clients seem to retry
>>>the request several times; and the Linux clients immediately pass the error up
>>>to the application.
>>>
>>>Is there some condition that the 2.4 kernel is handling incorrectly?
>>
>>I do not believe that Solaris redrives ESTALE on read, but they may do
>>it on open(). Linux does not redrive either case. See the many
>>discussions in the NFS list archives for why.
> 
> 
> Did you look at the 'snoop' bits in the previous email?  During that time, the
> process on the Solaris client is hanging in a write() call.
> 
> I'd be very happy to see any patches lieing around that might do this
> behaviour.  It would get me through the short term until Sun fixes this bug in
> samfs.
> 

The easiest, cleanest thing to do is retry the operation in the sys_* 
function.  Red Hat's latest kernel does this to prevent ESTALE.  I've 
attached the patch for your reference.  Mind you, due to the reasons 
you'll find in the list archives that Trond referenced, you'll not see 
this get into upstream kernels, so caveat emptor.

HTH
Neil


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/

--------------060805050701020606020608
Content-Type: text/plain;
 name="linux-2.4.21-nfs-estale.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-estale.patch"

diff -urNp linux-6090/fs/nfs/inode.c linux-6091/fs/nfs/inode.c
--- linux-6090/fs/nfs/inode.c
+++ linux-6091/fs/nfs/inode.c
@@ -1022,7 +1022,15 @@ int
 nfs_revalidate(struct dentry *dentry)
 {
 	struct inode *inode = dentry->d_inode;
-	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	int error;
+
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (error == -ESTALE) {
+		nfs_zap_caches(dentry->d_parent->d_inode);
+		d_drop(dentry);
+	}
+
+	return error;
 }
 
 /*
diff -urNp linux-6090/fs/nfs/xattr.c linux-6091/fs/nfs/xattr.c
--- linux-6090/fs/nfs/xattr.c
+++ linux-6091/fs/nfs/xattr.c
@@ -53,8 +53,13 @@ nfs_getxattr(struct dentry *dentry, cons
 	acl = ERR_PTR(-EOPNOTSUPP);
 	if (NFS_PROTO(inode)->version == 3 && NFS_PROTO(inode)->getacl)
 		acl = NFS_PROTO(inode)->getacl(inode, type);
-	if (IS_ERR(acl))
+	if (IS_ERR(acl)) {
+		if (PTR_ERR(acl) == -ESTALE) {
+			nfs_zap_caches(dentry->d_parent->d_inode);
+			d_drop(dentry);
+		}
 		return PTR_ERR(acl);
+	}
 	else if (acl) {
 		if (type == ACL_TYPE_ACCESS && acl->a_count == 0)
 			error = -ENODATA;
diff -urNp linux-6090/fs/open.c linux-6091/fs/open.c
--- linux-6090/fs/open.c
+++ linux-6091/fs/open.c
@@ -807,6 +807,30 @@ asmlinkage long sys_open(const char * fi
 		if (fd >= 0) {
 			struct file *f = filp_open(tmp, flags, mode);
 			error = PTR_ERR(f);
+
+			/*
+			 * ESTALE errors can be a pain.  On some
+			 * filesystems (e.g. NFS), ESTALE can often
+			 * be resolved by retry, as the ESTALE resulted
+			 * in a cache invalidation.  We perform this
+			 * retry here, once for every directory element
+			 * in the path to avoid the case where the removal
+			 * of the nth parent directory of the file we're
+			 * trying to open results in n ESTALE errors.
+			 */
+			if (error == -ESTALE) {
+				int nretries = 1;
+				char *cp;
+
+				for (cp = tmp; *cp; cp++) {
+					if (*cp == '/')
+						nretries++;
+				}
+				do {
+					f = filp_open(tmp, flags, mode);
+					error = PTR_ERR(f);
+				} while (error == -ESTALE && --nretries > 0);
+			}
 			if (IS_ERR(f))
 				goto out_error;
 			fd_install(fd, f);
diff -urNp linux-6090/fs/stat.c linux-6091/fs/stat.c
--- linux-6090/fs/stat.c
+++ linux-6091/fs/stat.c
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
 
@@ -340,8 +364,9 @@ static long cp_new_stat64(struct inode *
 asmlinkage long sys_stat64(char * filename, struct stat64 * statbuf, long flags)
 {
 	struct nameidata nd;
-	int error;
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -349,14 +374,20 @@ asmlinkage long sys_stat64(char * filena
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
+	int error, errcnt = 0;
 
+again:
 	error = user_path_walk_link(filename, &nd);
 	if (!error) {
 		error = do_revalidate(nd.dentry);
@@ -364,6 +395,11 @@ asmlinkage long sys_lstat64(char * filen
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
 

--------------060805050701020606020608--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
