From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 14/19] A basic NFSv4 client for 2.5.x
Date: Sat, 12 Oct 2002 01:48:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15783.25418.28956.487634@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1809WK-0002X2-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 16:48:40 -0700
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Now that all calls to nfs_async_handle_jukebox() have been moved to
fs/nfs/nfs3proc.c, we clean up by moving the nfs_async_jukebox() routine
itself there.  We also rename it nfs3_async_handle_jukebox(), to be
consistent with the naming conventions of that file.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E13/fs/nfs/nfs3proc.c linux-2.5.41-nfsv4-E14/fs/nfs/nfs3proc.c
--- linux-2.5.41-nfsv4-E13/fs/nfs/nfs3proc.c	2002-10-11 18:22:12.000000000 -0400
+++ linux-2.5.41-nfsv4-E14/fs/nfs/nfs3proc.c	2002-10-11 18:22:38.000000000 -0400
@@ -54,6 +54,17 @@
 #define rpc_call_sync(clnt, msg, flags) \
 		nfs3_rpc_wrapper(clnt, msg, flags)
 
+static int
+nfs3_async_handle_jukebox(struct rpc_task *task)
+{
+	if (task->tk_status != -EJUKEBOX)
+		return 0;
+	task->tk_status = 0;
+	rpc_restart_call(task);
+	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
+	return 1;
+}
+
 /*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
@@ -398,7 +409,7 @@
 	struct rpc_message *msg = &task->tk_msg;
 	struct nfs_fattr	*dir_attr;
 
-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return 1;
 	if (msg->rpc_argp) {
 		dir_attr = (struct nfs_fattr*)msg->rpc_resp;
@@ -656,7 +667,7 @@
 {
 	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
 
-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return;
 	nfs_readpage_result(task, data->u.v3.res.count, data->u.v3.res.eof);
 }
@@ -701,7 +712,7 @@
 {
 	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;
 
-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return;
 	nfs_writeback_done(task, data->u.v3.args.stable,
 			   data->u.v3.args.count, data->u.v3.res.count);
@@ -755,7 +766,7 @@
 static void
 nfs3_commit_done(struct rpc_task *task)
 {
-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return;
 	nfs_commit_done(task);
 }
diff -u --recursive --new-file linux-2.5.41-nfsv4-E13/include/linux/nfs_fs.h linux-2.5.41-nfsv4-E14/include/linux/nfs_fs.h
--- linux-2.5.41-nfsv4-E13/include/linux/nfs_fs.h	2002-10-11 18:21:46.000000000 -0400
+++ linux-2.5.41-nfsv4-E14/include/linux/nfs_fs.h	2002-10-11 18:22:38.000000000 -0400
@@ -470,28 +470,7 @@
 	__retval;							\
 })
 
-#ifdef CONFIG_NFS_V3
-
 #define NFS_JUKEBOX_RETRY_TIME (5 * HZ)
-static inline int
-nfs_async_handle_jukebox(struct rpc_task *task)
-{
-	if (task->tk_status != -EJUKEBOX)
-		return 0;
-	task->tk_status = 0;
-	rpc_restart_call(task);
-	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
-	return 1;
-}
-
-#else
-
-static inline int
-nfs_async_handle_jukebox(struct rpc_task *task)
-{
-	return 0;
-}
-#endif /* CONFIG_NFS_V3 */
 
 #endif /* __KERNEL__ */
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
