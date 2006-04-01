From: Jeff Layton <jtlayton@poochiereds.net>
Subject: [PATCH] lockd: add procfs control to cue lockd to release all
 locks on a device
Date: Sat, 01 Apr 2006 09:17:15 -0500
Message-ID: <1143901035.13560.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPguq-0008Jv-SB
	for nfs@lists.sourceforge.net; Sat, 01 Apr 2006 06:17:24 -0800
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FPgup-0001j7-WA
	for nfs@lists.sourceforge.net; Sat, 01 Apr 2006 06:17:24 -0800
Received: from ibm63aec.bellsouth.net ([72.148.41.34])
          by imf21aec.mail.bellsouth.net with ESMTP
          id <20060401141717.RMFJ22697.imf21aec.mail.bellsouth.net@ibm63aec.bellsouth.net>
          for <nfs@lists.sourceforge.net>; Sat, 1 Apr 2006 09:17:17 -0500
Received: from mail.poochiereds.net ([72.148.41.34])
          by ibm63aec.bellsouth.net with ESMTP
          id <20060401141713.QUMS26828.ibm63aec.bellsouth.net@mail.poochiereds.net>
          for <nfs@lists.sourceforge.net>; Sat, 1 Apr 2006 09:17:13 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.poochiereds.net (Postfix) with ESMTP id 53DC53C1D2
	for <nfs@lists.sourceforge.net>; Sat,  1 Apr 2006 09:17:16 -0500 (EST)
Received: from mail.poochiereds.net ([127.0.0.1])
	by localhost (salusa [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 02284-07 for <nfs@lists.sourceforge.net>;
	Sat, 1 Apr 2006 09:17:16 -0500 (EST)
Received: from tleilax.poochiereds.net (tleilax.poochiereds.net [192.168.1.3])
	by mail.poochiereds.net (Postfix) with ESMTP id 0BD9D3C1D1
	for <nfs@lists.sourceforge.net>; Sat,  1 Apr 2006 09:17:16 -0500 (EST)
To: nfs@lists.sourceforge.net
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

There's been a long standing problem with Linux NFS implementation. If a
client has active POSIX locks on a filesystem, it cannot be unmounted
even if you have unexported it and killed any userspace processes that
are actively working in it. This is especially a problem in clustered
NFS setups, as it can prevent a successful failover from occurring.

There is an existing workaround, which is to send a SIGKILL to lockd.
Unfortunately, that makes it drop all of its locks -- even ones on
filesystems that aren't failing over. This is bad in a cluster with
multiple NFS services that fail over independently, or on hosts with a
mix of clustered and non-clustered NFS shares.

This patch attempts to remedy this by adding a new procfs file
(/proc/fs/lockd/release_device). Echoing the dev_t value of the block
device with the underlying filesystem will tell lockd to drop all locks
on that device. I considered implementing this via sysfs or configfs,
but it wasn't clear to me how this would fall into the heirarchy of
either.

I've tested this and it works correctly. Comments and suggestions are
certainly welcome.

Thanks,
Jeff


diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -34,11 +34,15 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/lockd.h>
 #include <linux/nfs.h>
+#include <asm/uaccess.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
 #define LOCKD_BUFSIZE		(1024 + NLMSVC_XDRSIZE)
 #define ALLOWED_SIGS		(sigmask(SIGKILL))
 
+/* string representation of dev_t shouldn't be larger than this */
+#define DEV_T_STRLEN		13
+
 static struct svc_program	nlmsvc_program;
 
 struct nlmsvc_binding *		nlmsvc_ops;
@@ -71,6 +75,7 @@ static const unsigned long	nlm_timeout_m
 static const int		nlm_port_min = 0, nlm_port_max = 65535;
 
 static struct ctl_table_header * nlm_sysctl_table;
+static struct proc_dir_entry *lockd_dir,*release_device_file;
 
 static unsigned long set_grace_period(void)
 {
@@ -391,6 +396,33 @@ static ctl_table nlm_sysctl_root[] = {
 	{ .ctl_name = 0 }
 };
 
+/* function for release_device procfs control */
+static int proc_write_release_device(struct file *file, const char *buffer,
+				     unsigned long count, void *data)
+{
+	int len;
+	dev_t device;
+	char kdev_str[DEV_T_STRLEN];
+
+	if(count > DEV_T_STRLEN)
+		len = DEV_T_STRLEN;
+	else
+		len = count;
+
+	if (copy_from_user(&kdev_str, buffer, len))
+		return -EFAULT;
+
+	kdev_str[len] = '\0';
+	device = (dev_t)(simple_strtoul((const char *) &kdev_str, NULL, 0));
+
+	if (device) {
+		dprintk("lockd: releasing all locks on 0x%x\n",device);	
+		nlmsvc_release_device(device);
+	}
+
+	return len;
+}
+
 /*
  * Module (and driverfs) parameters.
  */
@@ -463,14 +495,46 @@ module_param_call(nlm_tcpport, param_set
 
 static int __init init_nlm(void)
 {
+	int rv = 0;
+
 	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root, 0);
-	return nlm_sysctl_table ? 0 : -ENOMEM;
+	if (! nlm_sysctl_table) {
+		rv = -ENOMEM;
+		goto out;
+	}
+
+	lockd_dir = proc_mkdir("fs/lockd",NULL);
+	if (! lockd_dir) {
+		rv = -ENOMEM;
+		goto no_lockd_dir;
+	}
+	lockd_dir->owner=THIS_MODULE;
+
+	release_device_file = create_proc_entry("release_device", 0200,
+						lockd_dir);
+	if (!release_device_file) {
+		rv = -ENOMEM;
+		goto no_release_device_file;
+	}
+
+	release_device_file->write_proc = proc_write_release_device;
+	release_device_file->owner = THIS_MODULE;
+	goto out;
+
+no_release_device_file:
+	remove_proc_entry("fs/lockd", NULL);
+no_lockd_dir:
+	unregister_sysctl_table(nlm_sysctl_table);
+out:
+	return rv;
 }
 
 static void __exit exit_nlm(void)
 {
 	/* FIXME: delete all NLM clients */
 	nlm_shutdown_hosts();
+	remove_proc_entry("release_device",lockd_dir);
+	remove_proc_entry("fs/lockd", NULL);
 	unregister_sysctl_table(nlm_sysctl_table);
 }
 
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -235,7 +235,7 @@ nlm_inspect_file(struct nlm_host *host, 
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(struct nlm_host *host, int action)
+nlm_traverse_files(struct nlm_host *host, dev_t device, int action)
 {
 	struct nlm_file	*file, **fp;
 	int		i;
@@ -244,6 +244,13 @@ nlm_traverse_files(struct nlm_host *host
 	for (i = 0; i < FILE_NRHASH; i++) {
 		fp = nlm_files + i;
 		while ((file = *fp) != NULL) {
+
+			if (device &&
+			    nlmsvc_file_inode(file)->i_sb->s_dev != device) {
+				fp = &file->f_next;
+				continue;
+			}
+
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
 			if (nlm_inspect_file(host, file, action)) {
@@ -301,7 +308,7 @@ nlmsvc_mark_resources(void)
 {
 	dprintk("lockd: nlmsvc_mark_resources\n");
 
-	nlm_traverse_files(NULL, NLM_ACT_MARK);
+	nlm_traverse_files(NULL, 0, NLM_ACT_MARK);
 }
 
 /*
@@ -312,7 +319,7 @@ nlmsvc_free_host_resources(struct nlm_ho
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, NLM_ACT_UNLOCK))
+	if (nlm_traverse_files(host, 0, NLM_ACT_UNLOCK))
 		printk(KERN_WARNING
 			"lockd: couldn't remove all locks held by %s",
 			host->h_name);
@@ -332,3 +339,16 @@ nlmsvc_invalidate_all(void)
 		nlm_release_host(host);
 	}
 }
+
+/*
+ * release all locks on the given device
+ */
+void
+nlmsvc_release_device(dev_t device)
+{
+	dprintk("lockd: nlmsvc_release_device\n");
+	if (nlm_traverse_files(NULL, device, NLM_ACT_UNLOCK))
+		printk(KERN_WARNING
+			"lockd: couldn't remove all locks on device %x\n",
+			device);
+}
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -30,6 +30,7 @@ extern struct nlmsvc_binding *	nlmsvc_op
  * Functions exported by the lockd module
  */
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
+extern void	nlmsvc_release_device(dev_t device);
 extern int	lockd_up(void);
 extern void	lockd_down(void);
 




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
