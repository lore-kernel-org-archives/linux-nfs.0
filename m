From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 39/85] nfs41: session recovery infrastructure
Date: Mon, 10 Nov 2008 22:25:03 +0200
Message-ID: <1226348703-8525-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48825 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbYKJUZK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:25:10 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

FIXME: review comment message.

NFSv4.1 session recovery.
Sessions are created in the "alloc" state and session recovery
is used to initiate session creation as well.

nfs41: Correctly use new session in exception handling

We will need to handle several layers of session recovery depending on the
error. As a last resort, we will need to use the big hammer; destroy
an existing session and create a new one.

The current code creates a new session without destroying the old one.
Destroy the existing session and initialize a new session before calling
nfs41_recover_session_sync.

nfs41: correctly expire and validate session

Do not expire session in session_reclaimer error case where the session could
be ok (create session succeeded) but nfs4_proc_get_lease_time failed. Leave
the session expiration (as well as new session initialization) to callers.

The session is valid as soon as the create session rpc completes successfully,
and is not dependant upon a successful nfs4_proc_get_lease_time rpc.
Move session validation from nfs4_proc_create_session to the success case of
_nfs4_proc_create_session.

nfs41: add nfs_client pointer to struct nfs4_session

The session is always associated with a struct nfs_client that holds
the exchange_id results. Add an nfs_client struct backpointer to the session
and refactor the session recovery routines to only require a struct
nfs4_sessions parameter.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Makefile                        |    1 +
 fs/nfs/client.c                        |    2 +-
 fs/nfs/nfs41_session_recovery.c        |  186 ++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c                      |   17 +++-
 include/linux/nfs41_session_recovery.h |   40 +++++++
 5 files changed, 242 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfs/nfs41_session_recovery.c
 create mode 100644 include/linux/nfs41_session_recovery.h

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index ac6170c..de5ea30 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -14,4 +14,5 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
+nfs-$(CONFIG_NFS_V4_1)	+= nfs41_session_recovery.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 62bdf31..560b10b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -38,7 +38,7 @@
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #if defined(CONFIG_NFS_V4_1)
-#include <linux/nfs4_session.h>
+#include <linux/nfs41_session_recovery.h>
 #endif /* CONFIG_NFS_V4_1 */
 
 #include <asm/system.h>
diff --git a/fs/nfs/nfs41_session_recovery.c b/fs/nfs/nfs41_session_recovery.c
new file mode 100644
index 0000000..39ad45f
--- /dev/null
+++ b/fs/nfs/nfs41_session_recovery.c
@@ -0,0 +1,186 @@
+/*
+ * NFSv4.1 session recovery code
+ *
+ * Author: Rahul Iyer <iyer@netapp.com>
+ *
+ * This code is released under GPL. For details see Documentation/COPYING
+ */
+
+#if defined(CONFIG_NFS_V4_1)
+
+#include <linux/module.h>
+#include <linux/kthread.h>
+#include <linux/in.h>
+#include <linux/fs.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/nfs3.h>
+#include <linux/nfs_xdr.h>
+#include <linux/nfs.h>
+#include <linux/nfs_fs.h>
+#include <linux/namei.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/nfs41_session_recovery.h>
+#include "nfs4_fs.h"
+#include "internal.h"
+
+#define NFSDBG_FACILITY		NFSDBG_PROC
+
+/*
+ * Set the session state == valid. Returns previous value of the session state
+ */
+int nfs41_set_session_valid(struct nfs4_session *session)
+{
+	int ret;
+	smp_mb__before_clear_bit();
+	ret = test_and_clear_bit(NFS41_SESSION_ALLOC,
+				&session->session_state);
+	smp_mb__after_clear_bit();
+
+	return ret;
+}
+
+static int nfs41_start_session_recovery(struct nfs4_session *session)
+{
+	int ret;
+	ret = test_and_set_bit(NFS41_SESSION_RECOVER, &session->session_state);
+
+	return ret;
+}
+
+struct reclaimer_arg {
+	struct nfs4_session *session;
+};
+
+static int nfs41_end_session_recovery(struct nfs4_session *session)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(NFS41_SESSION_RECOVER, &session->session_state);
+	smp_mb__after_clear_bit();
+
+	/*
+	 * Wake up sync tasks
+	 */
+	wake_up_bit(&session->session_state, NFS41_SESSION_RECOVER);
+	return 0;
+}
+
+static int nfs41_wait_session_recover_sync(struct nfs4_session *session)
+{
+	might_sleep();
+	return wait_on_bit(&session->session_state, NFS41_SESSION_RECOVER,
+			   nfs4_wait_bit_killable, TASK_KILLABLE);
+}
+
+static int session_reclaimer(void *arg)
+{
+	int ret;
+	struct reclaimer_arg *rec = (struct reclaimer_arg *)arg;
+
+	dprintk("--> %s\n", __func__);
+	allow_signal(SIGKILL);
+
+	ret = nfs4_proc_create_session(rec->session);
+	if (ret)
+		goto out_error;
+
+out:
+	nfs41_end_session_recovery(rec->session);
+	kfree(rec);
+	module_put_and_exit(0);
+	dprintk("<-- %s: status=%d\n", __func__, ret);
+	return ret;
+out_error:
+	printk(KERN_WARNING "Error: session recovery failed on "
+		"NFSv4.1 server with error %d\n", ret);
+
+	switch (ret) {
+	case -NFS4ERR_STALE_CLIENTID:
+	case -NFS4ERR_STALE_STATEID:
+	case -NFS4ERR_EXPIRED:
+		set_bit(NFS4CLNT_LEASE_EXPIRED, &rec->session->clp->cl_state);
+		break;
+	}
+	goto out;
+}
+
+static int nfs41_schedule_session_recovery(struct reclaimer_arg *rec)
+{
+	struct task_struct *task;
+
+	dprintk("--> %s: spawning session_reclaimer\n", __func__);
+	__module_get(THIS_MODULE);
+	task = kthread_run(session_reclaimer, rec, "%llx-session-reclaim",
+			   *(unsigned long long *)&rec->session->sess_id);
+
+	if (!IS_ERR(task)) {
+		dprintk("<-- %s\n", __func__);
+		return 0;
+	}
+
+	module_put(THIS_MODULE);
+	dprintk("--> %s: failed spawning session_reclaimer: error=%ld\n",
+		__func__, PTR_ERR(task));
+	return PTR_ERR(task);
+}
+
+/*
+ * Session recovery
+ * Called when an op receives a session related error
+ */
+int nfs41_recover_session(struct nfs4_session *session)
+{
+	struct reclaimer_arg *rec = NULL;
+	int ret;
+
+	dprintk("--> %s: clp=%p session=%p\n", __func__, session->clp, session);
+
+	ret = nfs41_start_session_recovery(session);
+
+	/*
+	 * If we get 1, it means some other thread beat us to us here, so we
+	 * just sit back and wait for completion of the recovery process
+	 */
+	if (ret) {
+		dprintk("%s: session_recovery already started\n", __func__);
+		ret = 0;
+		goto out;
+	}
+
+	ret = -ENOMEM;
+	rec = kmalloc(sizeof(*rec), GFP_KERNEL);
+	if (!rec)
+		goto err;
+	rec->session = session;
+
+	ret = nfs41_schedule_session_recovery(rec);
+	/*
+	 * We got an error creating the reclaiming thread, so end the recovery
+	 * and bail out
+	 */
+	if (ret)
+		goto err;
+out:
+	dprintk("<-- %s status=%d\n", __func__, ret);
+	return ret;
+err:
+	nfs41_end_session_recovery(session);
+	kfree(rec);
+	goto out;
+}
+
+int nfs41_recover_session_sync(struct nfs4_session *session)
+{
+	int ret;
+
+	dprintk("--> %s\n", __func__);
+
+	ret = nfs41_recover_session(session);
+	if (!ret)
+		ret = nfs41_wait_session_recover_sync(session);
+
+	dprintk("<-- %s: status=%d\n", __func__, ret);
+	return ret;
+}
+
+#endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 836f4f3..ede017c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -56,7 +56,7 @@
 #include "iostat.h"
 #if defined(CONFIG_NFS_V4_1)
 #include "callback.h"
-#include <linux/nfs4_session.h>
+#include <linux/nfs41_session_recovery.h>
 #endif /* CONFIG_NFS_V4_1 */
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
@@ -68,7 +68,7 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *);
-static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception);
+static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception);
 static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
@@ -3280,7 +3280,7 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 /* This is the error handling routine for processes that are allowed
  * to sleep.
  */
-static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
 	int ret = errorcode;
@@ -4420,6 +4420,8 @@ struct nfs4_session *nfs4_alloc_session(void)
 	if (!session)
 		return NULL;
 
+	nfs41_set_session_alloc(session);
+
 	atomic_set(&session->ref_count, 1);
 
 	nfs4_init_channel(&session->fore_channel);
@@ -4538,6 +4540,8 @@ static int _nfs4_proc_create_session(struct nfs4_session *session)
 					&session->fore_channel.chan_attrs);
 		nfs4_adjust_channel_attrs(&args.bc_attrs,
 					&session->back_channel.chan_attrs);
+		nfs41_set_session_valid(session);	/* Activate session */
+
 		/* Increment the clientid slot sequence id */
 		clp->cl_seqid++;
 	}
@@ -4603,6 +4607,10 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 
 	dprintk("--> nfs4_proc_destroy_session\n");
 
+	/* session is still being created */
+	if (nfs41_test_session_alloc(session))
+		return status;
+
 	msg.rpc_proc = nfs4_proc(session->clp, NFSPROC4_CLNT_DESTROY_SESSION);
 	msg.rpc_argp = session;
 	msg.rpc_resp = NULL;
@@ -4641,6 +4649,9 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 	server = list_entry(clp->cl_superblocks.next, struct nfs_server,
 				client_link);
 
+	if (nfs41_test_session_alloc(clp->cl_session))
+		return -NFS4ERR_STALE_CLIENTID;
+
 	args.sa_cache_this = 0;
 
 	status = _nfs4_call_sync(server, &msg, &args, &res, 0);
diff --git a/include/linux/nfs41_session_recovery.h b/include/linux/nfs41_session_recovery.h
new file mode 100644
index 0000000..2d91e80
--- /dev/null
+++ b/include/linux/nfs41_session_recovery.h
@@ -0,0 +1,40 @@
+/*
+ * Session Recovery header file
+ *
+ * Author: Rahul Iyer <iyer@netapp.com>
+ *
+ * This code is released under GPL. For details see Documentation/COPYING
+ */
+
+#ifndef __NFS41_SESSION_RECOVERY_H__
+#define __NFS41_SESSION_RECOVERY_H__
+
+#if defined(CONFIG_NFS_V4_1)
+
+/*
+ * Session state bits
+ */
+enum nfs41_session_state {
+	NFS41_SESSION_ALLOC = 0,
+	NFS41_SESSION_RECOVER,
+};
+
+/*
+ * Set the session state to alloc
+ */
+static inline int nfs41_set_session_alloc(struct nfs4_session *session)
+{
+	return test_and_set_bit(NFS41_SESSION_ALLOC, &session->session_state);
+}
+
+static inline int nfs41_test_session_alloc(struct nfs4_session *session)
+{
+	return test_bit(NFS41_SESSION_ALLOC, &session->session_state);
+}
+
+int nfs41_set_session_valid(struct nfs4_session *);
+int nfs41_recover_session(struct nfs4_session *);
+int nfs41_recover_session_sync(struct nfs4_session *);
+
+#endif	/* CONFIG_NFS_V4_1 */
+#endif	/* __NFS41_SESSION_RECOVERY_H__ */
-- 
1.6.0.2

