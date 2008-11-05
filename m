From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/13] NFSD: Add documenting comments for nfsctl interface
Date: Wed, 05 Nov 2008 12:28:37 -0500
Message-ID: <20081105172835.7330.92485.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42076 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbYKERaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:13 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Document the NFSD interface between user space and the kernel laid out in
fs/nfsd/nfsctl.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |  479 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 451 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e3f9783..5c75f8a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -84,6 +84,8 @@ static ssize_t write_unexport(struct file *file, char *buf, size_t size);
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
+static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size);
+static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
@@ -94,9 +96,6 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
-static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
-static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
-
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -106,8 +105,8 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
-	[NFSD_FO_UnlockIP] = failover_unlock_ip,
-	[NFSD_FO_UnlockFS] = failover_unlock_fs,
+	[NFSD_FO_UnlockIP] = write_unlock_ip,
+	[NFSD_FO_UnlockFS] = write_unlock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -176,10 +175,24 @@ static const struct file_operations exports_operations = {
 /*----------------------------------------------------------------------------*/
 /*
  * payload - write methods
- * If the method has a response, the response should be put in buf,
- * and the length returned.  Otherwise return 0 or and -error.
  */
 
+/**
+ * write_svc - Start kernel's NFSD server
+ *
+ * Deprecated.  /proc/fs/nfsd/threads is preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_svc
+ *				svc_port:	port number of this
+ *						server's listener
+ *				svc_nthreads:	number of threads to start
+ *			size:	size in bytes of passed in nfsctl_svc
+ * Output:
+ *	On success:	returns zero
+ *	On error:	return code is negative errno value
+ */
 static ssize_t write_svc(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_svc *data;
@@ -189,6 +202,30 @@ static ssize_t write_svc(struct file *file, char *buf, size_t size)
 	return nfsd_svc(data->svc_port, data->svc_nthreads);
 }
 
+/**
+ * write_add - Add or modify client entry in auth unix cache
+ *
+ * Deprecated.  /proc/net/rpc/auth.unix.ip is preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_client
+ *				cl_ident:	'\0'-terminated C string
+ *						containing domain name
+ *						of client
+ *				cl_naddr:	no. of items in cl_addrlist
+ *				cl_addrlist:	array of client addresses
+ *				cl_fhkeytype:	ignored
+ *				cl_fhkeylen:	ignored
+ *				cl_fhkey:	ignored
+ *			size:	size in bytes of passed in nfsctl_client
+ * Output:
+ *	On success:	returns zero
+ *	On error:	return code is negative errno value
+ *
+ * Note: Only AF_INET client addresses are passed in, since
+ * nfsctl_client.cl_addrlist contains only in_addr fields for addresses.
+ */
 static ssize_t write_add(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_client *data;
@@ -198,6 +235,30 @@ static ssize_t write_add(struct file *file, char *buf, size_t size)
 	return exp_addclient(data);
 }
 
+/**
+ * write_del - Remove client from auth unix cache
+ *
+ * Deprecated.  /proc/net/rpc/auth.unix.ip is preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_client
+ *				cl_ident:	'\0'-terminated C string
+ *						containing domain name
+ *						of client
+ *				cl_naddr:	ignored
+ *				cl_addrlist:	ignored
+ *				cl_fhkeytype:	ignored
+ *				cl_fhkeylen:	ignored
+ *				cl_fhkey:	ignored
+ *			size:	size in bytes of passed in nfsctl_client
+ * Output:
+ *	On success:	returns zero
+ *	On error:	return code is negative errno value
+ *
+ * Note: Only AF_INET client addresses are passed in, since
+ * nfsctl_client.cl_addrlist contains only in_addr fields for addresses.
+ */
 static ssize_t write_del(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_client *data;
@@ -207,6 +268,33 @@ static ssize_t write_del(struct file *file, char *buf, size_t size)
 	return exp_delclient(data);
 }
 
+/**
+ * write_export - Export part or all of a local file system
+ *
+ * Deprecated.  /proc/net/rpc/{nfsd.export,nfsd.fh} are preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_export
+ *				ex_client:	'\0'-terminated C string
+ *						containing domain name
+ *						of client allowed to access
+ *						this export
+ *				ex_path:	'\0'-terminated C string
+ *						containing pathname of
+ *						directory in local file system
+ *				ex_dev:		fsid to use for this export
+ *				ex_ino:		ignored
+ *				ex_flags:	export flags for this export
+ *				ex_anon_uid:	UID to use for anonymous
+ *						requests
+ *				ex_anon_gid:	GID to use for anonymous
+ *						requests
+ *			size:	size in bytes of passed in nfsctl_export
+ * Output:
+ *	On success:	returns zero
+ *	On error:	return code is negative errno value
+ */
 static ssize_t write_export(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_export *data;
@@ -216,6 +304,31 @@ static ssize_t write_export(struct file *file, char *buf, size_t size)
 	return exp_export(data);
 }
 
+/**
+ * write_unexport - Unexport a previously exported file system
+ *
+ * Deprecated.  /proc/net/rpc/{nfsd.export,nfsd.fh} are preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_export
+ *				ex_client:	'\0'-terminated C string
+ *						containing domain name
+ *						of client no longer allowed
+ *						to access this export
+ *				ex_path:	'\0'-terminated C string
+ *						containing pathname of
+ *						directory in local file system
+ *				ex_dev:		ignored
+ *				ex_ino:		ignored
+ *				ex_flags:	ignored
+ *				ex_anon_uid:	ignored
+ *				ex_anon_gid:	ignored
+ *			size:	size in bytes of passed in nfsctl_export
+ * Output:
+ *	On success:	returns zero
+ *	On error:	return code is negative errno value
+ */
 static ssize_t write_unexport(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_export *data;
@@ -226,6 +339,30 @@ static ssize_t write_unexport(struct file *file, char *buf, size_t size)
 	return exp_unexport(data);
 }
 
+/**
+ * write_getfs - Get a variable-length NFS file handle by path
+ *
+ * Deprecated.  /proc/fs/nfsd/filehandle is preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_fsparm
+ *				gd_addr:	socket address of client
+ *				gd_path:	'\0'-terminated C string
+ *						containing pathname of
+ *						directory in local file system
+ *				gd_maxlen:	maximum size of returned file
+ *						handle
+ *			size:	size in bytes of passed in nfsctl_fsparm
+ * Output:
+ *	On success:	passed-in buffer filled with a knfsd_fh structure
+ *			(a variable-length raw NFS file handle);
+ *			return code is the size in bytes of the file handle
+ *	On error:	return code is negative errno value
+ *
+ * Note: Only AF_INET client addresses are passed in, since gd_addr
+ * is the same size as a struct sockaddr_in.
+ */
 static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fsparm *data;
@@ -265,6 +402,29 @@ static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 	return err;
 }
 
+/**
+ * write_getfd - Get a fixed-length NFS file handle by path (used by mountd)
+ *
+ * Deprecated.  /proc/fs/nfsd/filehandle is preferred.
+ * Function remains to support old versions of nfs-utils.
+ *
+ * Input:
+ *			buf:	struct nfsctl_fdparm
+ *				gd_addr:	socket address of client
+ *				gd_path:	'\0'-terminated C string
+ *						containing pathname of
+ *						directory in local file system
+ *				gd_version:	fdparm structure version
+ *			size:	size in bytes of passed in nfsctl_fdparm
+ * Output:
+ *	On success:	passed-in buffer filled with nfsctl_res
+ *			(a fixed-length raw NFS file handle);
+ *			return code is the size in bytes of the file handle
+ *	On error:	return code is negative errno value
+ *
+ * Note: Only AF_INET client addresses are passed in, since gd_addr
+ * is the same size as a struct sockaddr_in.
+ */
 static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fdparm *data;
@@ -309,7 +469,23 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 	return err;
 }
 
-static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
+/**
+ * write_unlock_ip - Release all locks used by a client
+ *
+ * Experimental.
+ *
+ * Input:
+ *			buf:	'\n'-terminated C string containing a
+ *				presentation format IPv4 address
+ *			size:	length of C string in @buf
+ * Output:
+ *	On success:	returns zero if all specified locks were released;
+ *			returns one if one or more locks were not released
+ *	On error:	return code is negative errno value
+ *
+ * Note: Only AF_INET client addresses are passed in
+ */
+static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 {
 	struct sockaddr_in sin = {
 		.sin_family	= AF_INET,
@@ -339,7 +515,21 @@ static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
 	return nlmsvc_unlock_all_by_ip((struct sockaddr *)&sin);
 }
 
-static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
+/**
+ * write_unlock_fs - Release all locks on a local file system
+ *
+ * Experimental.
+ *
+ * Input:
+ *			buf:	'\n'-terminated C string containing the
+ *				absolute pathname of a local file system
+ *			size:	length of C string in @buf
+ * Output:
+ *	On success:	returns zero if all specified locks were released;
+ *			returns one if one or more locks were not released
+ *	On error:	return code is negative errno value
+ */
+static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size)
 {
 	struct path path;
 	char *fo_path;
@@ -360,21 +550,44 @@ static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
 	if (error)
 		return error;
 
+	/*
+	 * XXX: Needs better sanity checking.  Otherwise we could end up
+	 * releasing locks on the wrong file system.
+	 *
+	 * For example:
+	 * 1.  Does the path refer to a directory?
+	 * 2.  Is that directory a mount point, or
+	 * 3.  Is that directory the root of an exported file system?
+	 */
 	error = nlmsvc_unlock_all_by_sb(path.mnt->mnt_sb);
 
 	path_put(&path);
 	return error;
 }
 
+/**
+ * write_filehandle - Get a variable-length NFS file handle by path
+ *
+ * On input, the buffer contains a '\n'-terminated C string comprised of
+ * three alphanumeric words separated by whitespace.  The string may
+ * contain escape sequences.
+ *
+ * Input:
+ *			buf:
+ *				domain:		client domain name
+ *				path:		export pathname
+ *				maxsize:	numeric maximum size of
+ *						@buf
+ *			size:	length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C
+ *			string containing a ASCII hex text version
+ *			of the NFS file handle;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is negative errno value
+ */
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 {
-	/* request is:
-	 *   domain path maxsize
-	 * response is
-	 *   filehandle
-	 *
-	 * qword quoting is used, so filehandle will be \x....
-	 */
 	char *dname, *path;
 	int uninitialized_var(maxsize);
 	char *mesg = buf;
@@ -391,11 +604,13 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 
 	dname = mesg;
 	len = qword_get(&mesg, dname, size);
-	if (len <= 0) return -EINVAL;
+	if (len <= 0)
+		return -EINVAL;
 	
 	path = dname+len+1;
 	len = qword_get(&mesg, path, size);
-	if (len <= 0) return -EINVAL;
+	if (len <= 0)
+		return -EINVAL;
 
 	len = get_int(&mesg, &maxsize);
 	if (len)
@@ -419,17 +634,43 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 	if (len)
 		return len;
 	
-	mesg = buf; len = SIMPLE_TRANSACTION_LIMIT;
+	mesg = buf;
+	len = SIMPLE_TRANSACTION_LIMIT;
 	qword_addhex(&mesg, &len, (char*)&fh.fh_base, fh.fh_size);
 	mesg[-1] = '\n';
 	return mesg - buf;	
 }
 
+/**
+ * write_threads - Start NFSD, or report the current number of running threads
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C
+ *			string numeric value representing the number of
+ *			running NFSD threads;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing an unsigned
+ *					integer value representing the
+ *					number of NFSD threads to start
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	NFS service is started;
+ *			passed-in buffer filled with '\n'-terminated C
+ *			string numeric value representing the number of
+ *			running NFSD threads;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
 {
-	/* if size > 0, look for a number of threads and call nfsd_svc
-	 * then write out number of threads as reply
-	 */
 	char *mesg = buf;
 	int rv;
 	if (size > 0) {
@@ -437,9 +678,9 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 		rv = get_int(&mesg, &newthreads);
 		if (rv)
 			return rv;
-		if (newthreads <0)
+		if (newthreads < 0)
 			return -EINVAL;
-		rv = nfsd_svc(2049, newthreads);
+		rv = nfsd_svc(NFS_PORT, newthreads);
 		if (rv)
 			return rv;
 	}
@@ -447,6 +688,28 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 	return strlen(buf);
 }
 
+/**
+ * write_pool_threads - Set or report the current number of threads per pool
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ *
+ * OR
+ *
+ * Input:
+ * 			buf:		C string containing whitespace-
+ * 					separated unsigned integer values
+ *					representing the number of NFSD
+ *					threads to start in each pool
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C
+ *			string containing integer values representing the
+ *			number of NFSD threads in each pool;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 {
 	/* if size > 0, look for an array of number of threads per node
@@ -517,10 +780,6 @@ out_free:
 
 static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
-	/*
-	 * Format:
-	 *   [-/+]vers [-/+]vers ...
-	 */
 	char *mesg = buf;
 	char *vers, sign;
 	int len, num;
@@ -578,6 +837,38 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	return len;
 }
 
+/**
+ * write_versions - Set or report the available NFS protocol versions
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C
+ *			string containing positive or negative integer
+ *			values representing the current status of each
+ *			protocol version;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ *
+ * OR
+ *
+ * Input:
+ * 			buf:		C string containing whitespace-
+ * 					separated positive or negative
+ * 					integer values representing NFS
+ * 					protocol versions to enable ("+n")
+ * 					or disable ("-n")
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	status of zero or more protocol versions has
+ *			been updated; passed-in buffer filled with
+ *			'\n'-terminated C string containing positive
+ *			or negative integer values representing the
+ *			current status of each protocol version;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
 static ssize_t write_versions(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
@@ -687,6 +978,75 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 	return -EINVAL;
 }
 
+/**
+ * write_ports - Pass a socket file descriptor or transport name to listen on
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ * Output:
+ *	On success:	passed-in buffer filled with a '\n'-terminated C
+ *			string containing a whitespace-separated list of
+ *			named NFSD listeners;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing an unsigned
+ *					integer value representing a bound
+ *					but unconnected socket that is to be
+ *					used as an NFSD listener
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	NFS service is started;
+ *			passed-in buffer filled with a '\n'-terminated C
+ *			string containing a unique alphanumeric name of
+ *			the listener;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is a negative errno value
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing a "-" followed
+ *					by an integer value representing a
+ *					previously passed in socket file
+ *					descriptor
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	NFS service no longer listens on that socket;
+ *			passed-in buffer filled with a '\n'-terminated C
+ *			string containing a unique name of the listener;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is a negative errno value
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing a transport
+ *					name and an unsigned integer value
+ *					representing the port to listen on,
+ *					separated by whitespace
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	returns zero; NFS service is started
+ *	On error:	return code is a negative errno value
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing a "-" followed
+ *					by a transport name and an unsigned
+ *					integer value representing the port
+ *					to listen on, separated by whitespace
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	returns zero; NFS service no longer listens
+ *			on that transport
+ *	On error:	return code is a negative errno value
+ */
 static ssize_t write_ports(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
@@ -700,6 +1060,27 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 
 int nfsd_max_blksize;
 
+/**
+ * write_maxblksize - Set or report the current NFS blksize
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ *
+ * OR
+ *
+ * Input:
+ * 			buf:		C string containing an unsigned
+ * 					integer value representing the new
+ * 					NFS blksize
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C string
+ *			containing numeric value of the current NFS blksize
+ *			setting;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
@@ -752,6 +1133,27 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 	return strlen(buf);
 }
 
+/**
+ * write_leasetime - Set or report the current NFSv4 lease time
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing an unsigned
+ *					integer value representing the new
+ *					NFSv4 lease expiry time
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C
+ *			string containing unsigned integer value of the
+ *			current lease expiry time;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
@@ -788,6 +1190,27 @@ static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 	return strlen(buf);
 }
 
+/**
+ * write_recoverydir - Set or report the pathname of the recovery directory
+ *
+ * Input:
+ *			buf:		ignored
+ *			size:		zero
+ *
+ * OR
+ *
+ * Input:
+ *			buf:		C string containing the pathname
+ *					of the directory on a local file
+ *					system containing permanent NFSv4
+ *					recovery data
+ *			size:		non-zero length of C string in @buf
+ * Output:
+ *	On success:	passed-in buffer filled with '\n'-terminated C string
+ *			containing the current recovery pathname setting;
+ *			return code is the size in bytes of the string
+ *	On error:	return code is zero or a negative errno value
+ */
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;

