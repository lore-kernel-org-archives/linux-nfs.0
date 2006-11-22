From: Daniel Phillips <phillips@google.com>
Subject: [RFC] Change filesystem mount without disconnecting clients
Date: Tue, 21 Nov 2006 19:19:00 -0800
Message-ID: <4563C1A4.5060608@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Robert Nelson <rlnelson@google.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gmidj-0003X8-7Z
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 19:19:11 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gmidk-0000G8-6o
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 19:19:12 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com
	[172.29.48.30]) by smtp-out.google.com with ESMTP id kAM3J6XS001765
	for <nfs@lists.sourceforge.net>; Tue, 21 Nov 2006 19:19:06 -0800
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,

This patch provides an interface to let us quietly change the block device
on which a filesystem is mounted, without disrupting client TCP connections.
Why would anybody want to do such a strange thing?  Answer: remote block
device replication.

Each replication cycle results in a new virtual block device containing a
new, consistent state of the filesystem.  We want clients to see the changed
filesystem transparently, without remounting, as if somebody had just gone
in and directly operated on the local filesystem, adding files, deleting
files, changing file contents, renaming and so on.  This should all just
work, even if clients have files open and are in the middle of operating on
them.  This can cause some file operations to error out, but will not crash
the client or server.  Operations on unchanged files should work as expected,
in spite of the underlying block device having been changed.Note: to avoid
state file handles we do need to take some care with the fsid, which is not
within the scope of this patch (we just specify a known fsid in the exports
file for the time being).

The interface works as follows:
    write anything to /proc/fs/nfsd/suspend ->
       flush nfsd export cache and suspend nfs transaction processing

    read anything from /proc/fs/nfsd/suspend ->
       resume nfs transaction processing

The suspend is accomplished by taking a write lock on the export cache's
hash_sem, which by fortuitous circumstance encloses all nfs transaction
processing.  We then flush the export cache, driving the underlying
filesystem mount count down to one, in which state it can be unmounted.
Holding the hash_sem prevents mountd from reloading the export cache.  To
resume, we just release the write lock.

This is used something like:

    echo foo >/proc/fs/nfsd/suspend
    umount /mnt/someexport
    mount /dev/somenewdev /mnt/someexport
    cat /proc/fs/nfsd/suspend

This works pretty well, but does have the deficiency of suspending all nfsd
activity, even for exports on a filesystem we are not touching.  So a finer
granularity lock would be nice, but first we are just interested in
correctness.

This interface is not supposed to be a keeper and we are not proposing this
feature for merging by any means.  We are interested in opinions on whether
the approach is correct.  For example, could the purge fail to drive the
filesystem mount count to one?  Is there any way past our locking to
accidentally attempt to reload the export cache while we are still fiddling
with the filesystem?  We certainly do not claim to be competent knfsd hackers
the moment, having looked at the code pretty much for the first time a week
or two ago.  We may well have missed something basic.

The code that goes with this to do remote block device replication will be
released pretty soon as an open source project, most likely in the next week
or two.  For today I will just claim that it works well and it does something
that some people may find quite useful: it allows remote users to access a
read-only copy of a filesystem, served from a local disk that is replicated
from a read-write volume some place far away.

Signed-off-by Robert Nelson <rlnelson@google.com>
Signed-off-by Daniel Phillips <phillips@google.com>

diff -urp 2.6.18.3.clean/fs/nfsd/export.c 2.6.18.3/fs/nfsd/export.c
--- 2.6.18.3.clean/fs/nfsd/export.c	2006-11-18 19:28:22.000000000 -0800
+++ 2.6.18.3/fs/nfsd/export.c	2006-11-21 17:03:02.000000000 -0800
@@ -735,7 +735,7 @@ exp_readlock(void)
  	down_read(&hash_sem);
  }

-static inline void
+void
  exp_writelock(void)
  {
  	down_write(&hash_sem);
@@ -747,7 +747,7 @@ exp_readunlock(void)
  	up_read(&hash_sem);
  }

-static inline void
+void
  exp_writeunlock(void)
  {
  	up_write(&hash_sem);
@@ -1290,6 +1290,17 @@ exp_verify_string(char *cp, int max)
  }

  /*
+ * Flush exports table without calling RW semaphore.
+ * The caller is required to lock and unlock the export table.
+ */
+void
+export_purge(void)
+{
+	cache_purge(&svc_expkey_cache);
+	cache_purge(&svc_export_cache);
+}
+
+/*
   * Initialize the exports module.
   */
  void
diff -urp 2.6.18.3.clean/fs/nfsd/nfsctl.c 2.6.18.3/fs/nfsd/nfsctl.c
--- 2.6.18.3.clean/fs/nfsd/nfsctl.c	2006-11-18 19:28:22.000000000 -0800
+++ 2.6.18.3/fs/nfsd/nfsctl.c	2006-11-21 16:44:50.000000000 -0800
@@ -38,7 +38,7 @@
  unsigned int nfsd_versbits = ~0;

  /*
- *	We have a single directory with 9 nodes in it.
+ *	We have a single directory with several nodes in it.
   */
  enum {
  	NFSD_Root = 1,
@@ -53,6 +53,7 @@ enum {
  	NFSD_Fh,
  	NFSD_Threads,
  	NFSD_Versions,
+	NFSD_Suspend,
  	/*
  	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
  	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
@@ -139,6 +140,26 @@ static const struct file_operations tran
  	.release	= simple_transaction_release,
  };

+static ssize_t nfsctl_suspend_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
+{
+	printk("Suspending NFS transactions!\n");
+	exp_writelock();
+	export_purge();
+	return size;
+}
+
+static ssize_t nfsctl_suspend_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
+{
+	printk("Resuming NFS transactions!\n");
+	exp_writeunlock();
+	return 0;
+}
+
+static struct file_operations suspend_ops = {
+	.write		= nfsctl_suspend_write,
+	.read		= nfsctl_suspend_read,
+};
+
  extern struct seq_operations nfs_exports_op;
  static int exports_open(struct inode *inode, struct file *file)
  {
@@ -484,6 +505,7 @@ static int nfsd_fill_super(struct super_
  		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
  		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
  		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Suspend] = {"suspend", &suspend_ops, S_IWUSR|S_IRUSR},
  #ifdef CONFIG_NFSD_V4
  		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
  		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
diff -urp 2.6.18.3.clean/include/linux/nfsd/export.h 2.6.18.3/include/linux/nfsd/export.h
--- 2.6.18.3.clean/include/linux/nfsd/export.h	2006-11-18 19:28:22.000000000 -0800
+++ 2.6.18.3/include/linux/nfsd/export.h	2006-11-21 17:01:55.000000000 -0800
@@ -84,6 +84,9 @@ struct svc_expkey {
  void			nfsd_export_init(void);
  void			nfsd_export_shutdown(void);
  void			nfsd_export_flush(void);
+void			export_purge(void);
+void			exp_writelock(void);
+void			exp_writeunlock(void);
  void			exp_readlock(void);
  void			exp_readunlock(void);
  struct svc_export *	exp_get_by_name(struct auth_domain *clp,

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
