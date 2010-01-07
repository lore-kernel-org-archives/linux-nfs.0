From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/4] nfs4: handle -EKEYEXPIRED errors from RPC layer
Date: Thu,  7 Jan 2010 09:42:03 -0500
Message-ID: <1262875325-4488-3-git-send-email-jlayton@redhat.com>
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

If a KRB5 TGT ticket expires, we don't want to return an error
immediatel. If someone has a long running job and just forgets to run
"kinit" in time then this will make it fail.

Instead, we want to treat this situation as we would NFS4ERR_DELAY and
retry the upcall after delaying a bit with an exponential backoff.

This patch just makes any place that would handle NFS4ERR_DELAY also
handle -EKEYEXPIRED the same way. In the future, we may want to be more
sophisticated however and handle hard vs. soft mounts differently, or
specify some upper limit on how long we'll wait for a new TGT to be
acquired.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c  |   11 +++++++++--
 fs/nfs/nfs4state.c |    1 +
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 198d51d..2e2dda2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -285,6 +285,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
+		case -EKEYEXPIRED:
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
@@ -1161,7 +1162,7 @@ static int nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 	int err;
 	do {
 		err = _nfs4_do_open_reclaim(ctx, state);
-		if (err != -NFS4ERR_DELAY)
+		if (err != -NFS4ERR_DELAY && err != -EKEYEXPIRED)
 			break;
 		nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
@@ -1580,6 +1581,7 @@ static int nfs4_do_open_expired(struct nfs_open_context *ctx, struct nfs4_state
 			goto out;
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
+		case -EKEYEXPIRED:
 			nfs4_handle_exception(server, err, &exception);
 			err = 0;
 		}
@@ -3449,6 +3451,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (server)
 				nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
+		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
@@ -3554,6 +3557,7 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp, struct rpc_cred *cred)
 			case -NFS4ERR_RESOURCE:
 				/* The IBM lawyers misread another document! */
 			case -NFS4ERR_DELAY:
+			case -EKEYEXPIRED:
 				err = nfs4_delay(clp->cl_rpcclient, &timeout);
 		}
 	} while (err == 0);
@@ -4144,7 +4148,7 @@ static int nfs4_lock_reclaim(struct nfs4_state *state, struct file_lock *request
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
 		err = _nfs4_do_setlk(state, F_SETLK, request, NFS_LOCK_RECLAIM);
-		if (err != -NFS4ERR_DELAY)
+		if (err != -NFS4ERR_DELAY && err != -EKEYEXPIRED)
 			break;
 		nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
@@ -4169,6 +4173,7 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 			goto out;
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
+		case -EKEYEXPIRED:
 			nfs4_handle_exception(server, err, &exception);
 			err = 0;
 		}
@@ -4317,6 +4322,7 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 				err = 0;
 				goto out;
 			case -NFS4ERR_DELAY:
+			case -EKEYEXPIRED:
 				break;
 		}
 		err = nfs4_handle_exception(server, err, &exception);
@@ -4516,6 +4522,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case -NFS4ERR_DELAY:
 	case -NFS4ERR_GRACE:
+	case -EKEYEXPIRED:
 		dprintk("%s Retry: tk_status %d\n", __func__, task->tk_status);
 		rpc_delay(task, NFS4_POLL_RETRY_MIN);
 		task->tk_status = 0;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6d263ed..423a4aa 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1314,6 +1314,7 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
 		case -NFS4ERR_DELAY:
 		case -NFS4ERR_CLID_INUSE:
 		case -EAGAIN:
+		case -EKEYEXPIRED:
 			break;
 
 		case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
-- 
1.6.5.2
