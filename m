From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 18/38: CLIENT: put nfs_async_handle_jukebox() in
 fs/nfs/nfs3proc.c
Date: Wed, 14 Aug 2002 16:45:27 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141645020.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f51G-0005eV-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:45:30 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Now that all calls to nfs_async_handle_jukebox() have been moved to
fs/nfs/nfs3proc.c, we clean up by moving the nfs_async_jukebox() routine
itself there.  We also rename it nfs3_async_handle_jukebox(), to be
consistent with the naming conventions of that file.

--- old/fs/nfs/nfs3proc.c	Sun Aug 11 22:19:39 2002
+++ new/fs/nfs/nfs3proc.c	Sun Aug 11 22:22:43 2002
@@ -54,6 +54,17 @@ nfs3_rpc_call_wrapper(struct rpc_clnt *c
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
@@ -398,7 +409,7 @@ nfs3_proc_unlink_done(struct dentry *dir
 	struct rpc_message *msg = &task->tk_msg;
 	struct nfs_fattr	*dir_attr;

-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return 1;
 	if (msg->rpc_argp) {
 		dir_attr = (struct nfs_fattr*)msg->rpc_resp;
@@ -656,7 +667,7 @@ nfs3_read_done(struct rpc_task *task)
 {
 	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;

-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return;
 	nfs_readpage_result(task, data->u.v3.res.count);
 }
@@ -701,7 +712,7 @@ nfs3_write_done(struct rpc_task *task)
 {
 	struct nfs_write_data *data = (struct nfs_write_data *) task->tk_calldata;

-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return;
 	nfs_writeback_done(task, data->u.v3.args.stable,
 			   data->u.v3.args.count, data->u.v3.res.count);
@@ -755,7 +766,7 @@ nfs3_proc_write_setup(struct nfs_write_d
 static void
 nfs3_commit_done(struct rpc_task *task)
 {
-	if (nfs_async_handle_jukebox(task))
+	if (nfs3_async_handle_jukebox(task))
 		return;
 	nfs_commit_done(task);
 }
--- old/include/linux/nfs_fs.h	Sun Aug 11 22:20:29 2002
+++ new/include/linux/nfs_fs.h	Sun Aug 11 22:22:43 2002
@@ -462,28 +462,7 @@ extern void * nfs_root_data(void);
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

 #ifdef CONFIG_NFS_V4




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
