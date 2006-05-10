From: Lin Feng Shen <shenlinf@cn.ibm.com>
Subject: [PATCH 1/1] NFS: fix error handling on access_ok in compat_sys_nfsservctl
Date: Thu, 11 May 2006 00:44:54 +0800
Message-ID: <44621886.7060606@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/html; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdroW-0005nn-Mb
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 09:45:28 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FdroW-0004Fm-Ls
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 09:45:28 -0700
Received: from ausmtp04.au.ibm.com ([202.81.18.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FdroT-00032d-QE
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 09:45:28 -0700
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k4AGttci218568
	for <nfs@lists.sourceforge.net>; Thu, 11 May 2006 02:55:55 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4AGmLhX244350
	for <nfs@lists.sourceforge.net>; Thu, 11 May 2006 02:48:26 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11/8.13.3) with ESMTP id k4AGj1QU007451
	for <nfs@lists.sourceforge.net>; Thu, 11 May 2006 02:45:01 +1000
To: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
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

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
<pre>From: Lin Feng Shen <a class="moz-txt-link-rfc2396E" href="mailto:shenlinf@cn.ibm.com">&lt;shenlinf@cn.ibm.com&gt;</a>

Functions compat_nfs_svc_trans, compat_nfs_clnt_trans, compat_nfs_exp_trans,
compat_nfs_getfd_trans and compat_nfs_getfs_trans, which are called by
compat_sys_nfsservctl(fs/compat.c), don't handle the return value of
access_ok properly. access_ok return 1 when the addr is valid, and 0
when it's not, but these functions have the reversed understanding. When the
address is valid, they always return -EFAULT to compat_sys_nfsservctl.

An example is to run /usr/sbin/rpc.nfsd(32bit program on Power5). It doesn't
function as expected. strace showes that nfsservctl returns -EFAULT.

The patch fixes this by correcting the error handling on the return value of
access_ok in the five functions. It is created against linux-2.6.17-rc3-git16.

Signed-off-by: Lin Feng Shen <a class="moz-txt-link-rfc2396E" href="mailto:shenlinf@cn.ibm.com">&lt;shenlinf@cn.ibm.com&gt;</a>
--- 

--- linux-2.6.17-rc3-git16/fs/compat.c.orig	2006-05-09 09:07:38.000000000 -0500
+++ linux-2.6.17-rc3-git16/fs/compat.c	2006-05-09 09:21:00.000000000 -0500
@@ -2032,101 +2032,96 @@ union compat_nfsctl_res {
 
 static int compat_nfs_svc_trans(struct nfsctl_arg *karg, struct compat_nfsctl_arg __user *arg)
 {
-	int err;
-
-	err = access_ok(VERIFY_READ, &amp;arg-&gt;ca32_svc, sizeof(arg-&gt;ca32_svc));
-	err |= get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version);
-	err |= __get_user(karg-&gt;ca_svc.svc_port, &amp;arg-&gt;ca32_svc.svc32_port);
-	err |= __get_user(karg-&gt;ca_svc.svc_nthreads, &amp;arg-&gt;ca32_svc.svc32_nthreads);
-	return (err) ? -EFAULT : 0;
+	if(!access_ok(VERIFY_READ, &amp;arg-&gt;ca32_svc, sizeof(arg-&gt;ca32_svc)) ||
+	    get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version) ||
+	    __get_user(karg-&gt;ca_svc.svc_port, &amp;arg-&gt;ca32_svc.svc32_port) ||
+	    __get_user(karg-&gt;ca_svc.svc_nthreads, &amp;arg-&gt;ca32_svc.svc32_nthreads))
+		return -EFAULT;
+	return 0;
 }
 
 static int compat_nfs_clnt_trans(struct nfsctl_arg *karg, struct compat_nfsctl_arg __user *arg)
 {
-	int err;
-
-	err = access_ok(VERIFY_READ, &amp;arg-&gt;ca32_client, sizeof(arg-&gt;ca32_client));
-	err |= get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version);
-	err |= __copy_from_user(&amp;karg-&gt;ca_client.cl_ident[0],
+	if(!access_ok(VERIFY_READ, &amp;arg-&gt;ca32_client, sizeof(arg-&gt;ca32_client)) ||
+	    get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version) ||
+	    __copy_from_user(&amp;karg-&gt;ca_client.cl_ident[0],
 			  &amp;arg-&gt;ca32_client.cl32_ident[0],
-			  NFSCLNT_IDMAX);
-	err |= __get_user(karg-&gt;ca_client.cl_naddr, &amp;arg-&gt;ca32_client.cl32_naddr);
-	err |= __copy_from_user(&amp;karg-&gt;ca_client.cl_addrlist[0],
+			  NFSCLNT_IDMAX) ||
+	    __get_user(karg-&gt;ca_client.cl_naddr, &amp;arg-&gt;ca32_client.cl32_naddr) ||
+	    __copy_from_user(&amp;karg-&gt;ca_client.cl_addrlist[0],
 			  &amp;arg-&gt;ca32_client.cl32_addrlist[0],
-			  (sizeof(struct in_addr) * NFSCLNT_ADDRMAX));
-	err |= __get_user(karg-&gt;ca_client.cl_fhkeytype,
-		      &amp;arg-&gt;ca32_client.cl32_fhkeytype);
-	err |= __get_user(karg-&gt;ca_client.cl_fhkeylen,
-		      &amp;arg-&gt;ca32_client.cl32_fhkeylen);
-	err |= __copy_from_user(&amp;karg-&gt;ca_client.cl_fhkey[0],
+			  (sizeof(struct in_addr) * NFSCLNT_ADDRMAX)) ||
+	    __get_user(karg-&gt;ca_client.cl_fhkeytype,
+		      &amp;arg-&gt;ca32_client.cl32_fhkeytype) ||
+	    __get_user(karg-&gt;ca_client.cl_fhkeylen,
+		      &amp;arg-&gt;ca32_client.cl32_fhkeylen) ||
+	    __copy_from_user(&amp;karg-&gt;ca_client.cl_fhkey[0],
 			  &amp;arg-&gt;ca32_client.cl32_fhkey[0],
-			  NFSCLNT_KEYMAX);
+			  NFSCLNT_KEYMAX))
+		return -EFAULT;
 
-	return (err) ? -EFAULT : 0;
+	return 0;
 }
 
 static int compat_nfs_exp_trans(struct nfsctl_arg *karg, struct compat_nfsctl_arg __user *arg)
 {
-	int err;
-
-	err = access_ok(VERIFY_READ, &amp;arg-&gt;ca32_export, sizeof(arg-&gt;ca32_export));
-	err |= get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version);
-	err |= __copy_from_user(&amp;karg-&gt;ca_export.ex_client[0],
+	if(!access_ok(VERIFY_READ, &amp;arg-&gt;ca32_export, sizeof(arg-&gt;ca32_export)) ||
+	    get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version) ||
+	    __copy_from_user(&amp;karg-&gt;ca_export.ex_client[0],
 			  &amp;arg-&gt;ca32_export.ex32_client[0],
-			  NFSCLNT_IDMAX);
-	err |= __copy_from_user(&amp;karg-&gt;ca_export.ex_path[0],
+			  NFSCLNT_IDMAX) ||
+	    __copy_from_user(&amp;karg-&gt;ca_export.ex_path[0],
 			  &amp;arg-&gt;ca32_export.ex32_path[0],
-			  NFS_MAXPATHLEN);
-	err |= __get_user(karg-&gt;ca_export.ex_dev,
-		      &amp;arg-&gt;ca32_export.ex32_dev);
-	err |= __get_user(karg-&gt;ca_export.ex_ino,
-		      &amp;arg-&gt;ca32_export.ex32_ino);
-	err |= __get_user(karg-&gt;ca_export.ex_flags,
-		      &amp;arg-&gt;ca32_export.ex32_flags);
-	err |= __get_user(karg-&gt;ca_export.ex_anon_uid,
-		      &amp;arg-&gt;ca32_export.ex32_anon_uid);
-	err |= __get_user(karg-&gt;ca_export.ex_anon_gid,
-		      &amp;arg-&gt;ca32_export.ex32_anon_gid);
+			  NFS_MAXPATHLEN) ||
+	    __get_user(karg-&gt;ca_export.ex_dev,
+		      &amp;arg-&gt;ca32_export.ex32_dev) ||
+	    __get_user(karg-&gt;ca_export.ex_ino,
+		      &amp;arg-&gt;ca32_export.ex32_ino) ||
+	    __get_user(karg-&gt;ca_export.ex_flags,
+		      &amp;arg-&gt;ca32_export.ex32_flags) ||
+	    __get_user(karg-&gt;ca_export.ex_anon_uid,
+		      &amp;arg-&gt;ca32_export.ex32_anon_uid) ||
+	    __get_user(karg-&gt;ca_export.ex_anon_gid,
+		      &amp;arg-&gt;ca32_export.ex32_anon_gid))
+		return -EFAULT;
 	SET_UID(karg-&gt;ca_export.ex_anon_uid, karg-&gt;ca_export.ex_anon_uid);
 	SET_GID(karg-&gt;ca_export.ex_anon_gid, karg-&gt;ca_export.ex_anon_gid);
 
-	return (err) ? -EFAULT : 0;
+	return 0;
 }
 
 static int compat_nfs_getfd_trans(struct nfsctl_arg *karg, struct compat_nfsctl_arg __user *arg)
 {
-	int err;
-
-	err = access_ok(VERIFY_READ, &amp;arg-&gt;ca32_getfd, sizeof(arg-&gt;ca32_getfd));
-	err |= get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version);
-	err |= __copy_from_user(&amp;karg-&gt;ca_getfd.gd_addr,
+	if(!access_ok(VERIFY_READ, &amp;arg-&gt;ca32_getfd, sizeof(arg-&gt;ca32_getfd)) ||
+	    get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version) ||
+	    __copy_from_user(&amp;karg-&gt;ca_getfd.gd_addr,
 			  &amp;arg-&gt;ca32_getfd.gd32_addr,
-			  (sizeof(struct sockaddr)));
-	err |= __copy_from_user(&amp;karg-&gt;ca_getfd.gd_path,
+			  (sizeof(struct sockaddr))) ||
+	    __copy_from_user(&amp;karg-&gt;ca_getfd.gd_path,
 			  &amp;arg-&gt;ca32_getfd.gd32_path,
-			  (NFS_MAXPATHLEN+1));
-	err |= __get_user(karg-&gt;ca_getfd.gd_version,
-		      &amp;arg-&gt;ca32_getfd.gd32_version);
+			  (NFS_MAXPATHLEN+1)) ||
+	    __get_user(karg-&gt;ca_getfd.gd_version,
+		      &amp;arg-&gt;ca32_getfd.gd32_version))
+		return -EFAULT;
 
-	return (err) ? -EFAULT : 0;
+	return 0;
 }
 
 static int compat_nfs_getfs_trans(struct nfsctl_arg *karg, struct compat_nfsctl_arg __user *arg)
 {
-	int err;
-
-	err = access_ok(VERIFY_READ, &amp;arg-&gt;ca32_getfs, sizeof(arg-&gt;ca32_getfs));
-	err |= get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version);
-	err |= __copy_from_user(&amp;karg-&gt;ca_getfs.gd_addr,
+	if(!access_ok(VERIFY_READ, &amp;arg-&gt;ca32_getfs, sizeof(arg-&gt;ca32_getfs)) ||
+	    get_user(karg-&gt;ca_version, &amp;arg-&gt;ca32_version) ||
+	    __copy_from_user(&amp;karg-&gt;ca_getfs.gd_addr,
 			  &amp;arg-&gt;ca32_getfs.gd32_addr,
-			  (sizeof(struct sockaddr)));
-	err |= __copy_from_user(&amp;karg-&gt;ca_getfs.gd_path,
+			  (sizeof(struct sockaddr))) ||
+	    __copy_from_user(&amp;karg-&gt;ca_getfs.gd_path,
 			  &amp;arg-&gt;ca32_getfs.gd32_path,
-			  (NFS_MAXPATHLEN+1));
-	err |= __get_user(karg-&gt;ca_getfs.gd_maxlen,
-		      &amp;arg-&gt;ca32_getfs.gd32_maxlen);
+			  (NFS_MAXPATHLEN+1)) ||
+	    __get_user(karg-&gt;ca_getfs.gd_maxlen,
+		      &amp;arg-&gt;ca32_getfs.gd32_maxlen))
+		return -EFAULT;
 
-	return (err) ? -EFAULT : 0;
+	return 0;
 }
 
 /* This really doesn't need translations, we are only passing</pre>
</body>
</html>



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
