From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/5] VFS: Allow caller to determine if BSD or posix
	locks were actually freed
Date: Mon, 26 Jun 2006 19:30:04 -0400
Message-ID: <20060626233004.6059.27511.stgit@lade.trondhjem.org>
References: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv0Wq-0001pS-Nn
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:04 -0700
Received: from dh134.citi.umich.edu ([141.211.133.134] helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fv0Wq-0003JH-MR
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 16:30:05 -0700
To: linux-kernel@vger.kernel.org
In-Reply-To: <20060626232936.6059.50399.stgit@lade.trondhjem.org>
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Change posix_lock_file_conf(), and flock_lock_file() so that if called
with an F_UNLCK argument, and the FL_EXISTS flag they will indicate
whether or not any locks were actually freed by returning 0 or -ENOENT.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/locks.c         |   18 ++++++++++++++++--
 include/linux/fs.h |    1 +
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 1ad29c9..50cb0a2 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -725,6 +725,10 @@ next_task:
 /* Try to create a FLOCK lock on filp. We always insert new FLOCK locks
  * at the head of the list, but that's secret knowledge known only to
  * flock_lock_file and posix_lock_file.
+ *
+ * Note that if called with an FL_EXISTS argument, the caller may determine
+ * whether or not a lock was successfully freed by testing the return
+ * value for -ENOENT.
  */
 static int flock_lock_file(struct file *filp, struct file_lock *request)
 {
@@ -750,8 +754,11 @@ static int flock_lock_file(struct file *
 		break;
 	}
 
-	if (request->fl_type == F_UNLCK)
+	if (request->fl_type == F_UNLCK) {
+		if ((request->fl_flags & FL_EXISTS) && !found)
+			error = -ENOENT;
 		goto out;
+	}
 
 	error = -ENOMEM;
 	new_fl = locks_alloc_lock();
@@ -948,8 +955,11 @@ static int __posix_lock_file_conf(struct
 
 	error = 0;
 	if (!added) {
-		if (request->fl_type == F_UNLCK)
+		if (request->fl_type == F_UNLCK) {
+			if (request->fl_flags & FL_EXISTS)
+				error = -ENOENT;
 			goto out;
+		}
 
 		if (!new_fl) {
 			error = -ENOLCK;
@@ -996,6 +1006,10 @@ static int __posix_lock_file_conf(struct
  * Add a POSIX style lock to a file.
  * We merge adjacent & overlapping locks whenever possible.
  * POSIX locks are sorted by owner task, then by starting address
+ *
+ * Note that if called with an FL_EXISTS argument, the caller may determine
+ * whether or not a lock was successfully freed by testing the return
+ * value for -ENOENT.
  */
 int posix_lock_file(struct file *filp, struct file_lock *fl)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2d8b348..31b1f6f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -682,6 +682,7 @@ #endif
 #define FL_POSIX	1
 #define FL_FLOCK	2
 #define FL_ACCESS	8	/* not trying to lock, just looking */
+#define FL_EXISTS	16	/* when unlocking, test for existence */
 #define FL_LEASE	32	/* lease held on this file */
 #define FL_CLOSE	64	/* unlock on close */
 #define FL_SLEEP	128	/* A blocking lock */

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
