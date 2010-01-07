From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/4] nfs: handle NFSv3 -EKEYEXPIRED errors as we would
	-EJUKEBOX
Date: Thu,  7 Jan 2010 09:42:04 -0500
Message-ID: <1262875325-4488-4-git-send-email-jlayton@redhat.com>
References: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond.Myklebust@netapp.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1262875325-4488-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

We're using -EKEYEXPIRED to indicate that a krb5 credcache contains an
expired ticket and that we should have the NFS layer retry the RPC call
instead of returning an error back to the caller. Handle this as we
would an -EJUKEBOX error return.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs3proc.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 3f8881d..24992f0 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -22,14 +22,14 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
-/* A wrapper to handle the EJUKEBOX error message */
+/* A wrapper to handle the EJUKEBOX and EKEYEXPIRED error messages */
 static int
 nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 {
 	int res;
 	do {
 		res = rpc_call_sync(clnt, msg, flags);
-		if (res != -EJUKEBOX)
+		if (res != -EJUKEBOX && res != -EKEYEXPIRED)
 			break;
 		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
@@ -42,9 +42,10 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 static int
 nfs3_async_handle_jukebox(struct rpc_task *task, struct inode *inode)
 {
-	if (task->tk_status != -EJUKEBOX)
+	if (task->tk_status != -EJUKEBOX && task->tk_status != -EKEYEXPIRED)
 		return 0;
-	nfs_inc_stats(inode, NFSIOS_DELAY);
+	if (task->tk_status == -EJUKEBOX)
+		nfs_inc_stats(inode, NFSIOS_DELAY);
 	task->tk_status = 0;
 	rpc_restart_call(task);
 	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
-- 
1.6.5.2
