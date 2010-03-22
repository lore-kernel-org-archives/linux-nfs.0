Return-Path: <nfsv4-bounces@linux-nfs.org>
Subject: Re: [PATCH 1/2] use negative cache for Kerberos credentials
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
In-Reply-To: <20100322094731.GO18907@ics.muni.cz>
References: <20100316115439.GX19154@ics.muni.cz>
	<1268745962.3155.25.camel@localhost.localdomain>
	<20100316162738.GD19154@ics.muni.cz>
	<1268758702.3098.8.camel@localhost.localdomain>
	<20100322094731.GO18907@ics.muni.cz>
Date: Mon, 22 Mar 2010 11:18:44 -0400
Message-ID: <1269271124.3496.4.camel@localhost.localdomain>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-22 at 10:47 +0100, Lukas Hejtmanek wrote: 
> Hi,
> 
> On Tue, Mar 16, 2010 at 12:58:22PM -0400, Trond Myklebust wrote:
> > Yes. I'll draft a patch of what I'm proposing later today. What I
> > basically want to do is to add a flag to the gss_cred that marks it as
> > expired, and add a timestamp.
> 
> is there draft of the patch anywhere? Is my kernel part patch completely
> wrong?
> 

Hi Lukas,

We already have code in nfs4proc.c for handling EKEYEXPIRED, and that
delays the request before allowing it to retry. What I was proposing was
negative caching, so that if some other process comes along and tries to
do an upcall, the RPC code just immediately returns EKEYEXPIRED instead
of asking gssd again.

Something like the following (still untested) patch.

Cheers
   Trond
---------------------------------------------------------------------------------------- 
SUNRPC: Don't spam gssd with upcall requests when the kerberos key expired
From: Trond Myklebust <Trond.Myklebust@netapp.com>

Now that the rpc.gssd daemon can explicitly tell us that the key expired,
we should cache that information to avoid spamming gssd.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/auth.h     |    1 +
 include/linux/sunrpc/auth_gss.h |    1 +
 net/sunrpc/auth_gss/auth_gss.c  |   65 ++++++++++++++++++++++++++++++++-------
 3 files changed, 55 insertions(+), 12 deletions(-)


diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 996df4d..87d7ec0 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -54,6 +54,7 @@ struct rpc_cred {
 #define RPCAUTH_CRED_NEW	0
 #define RPCAUTH_CRED_UPTODATE	1
 #define RPCAUTH_CRED_HASHED	2
+#define RPCAUTH_CRED_NEGATIVE	3
 
 #define RPCAUTH_CRED_MAGIC	0x0f4aa4f0
 
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index d48d4e6..671538d 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -82,6 +82,7 @@ struct gss_cred {
 	enum rpc_gss_svc	gc_service;
 	struct gss_cl_ctx	*gc_ctx;
 	struct gss_upcall_msg	*gc_upcall;
+	unsigned long		gc_upcall_timestamp;
 	unsigned char		gc_machine_cred : 1;
 };
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index c389ccf..ec620c3 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -57,6 +57,9 @@ static const struct rpc_authops authgss_ops;
 static const struct rpc_credops gss_credops;
 static const struct rpc_credops gss_nullops;
 
+#define GSS_RETRY_EXPIRED 5
+static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
+
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
@@ -350,6 +353,24 @@ gss_unhash_msg(struct gss_upcall_msg *gss_msg)
 }
 
 static void
+gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss_msg)
+{
+	switch (gss_msg->msg.errno) {
+	case 0:
+		if (gss_msg->ctx == NULL)
+			break;
+		clear_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
+		gss_cred_set_ctx(&gss_cred->gc_base, gss_msg->ctx);
+		break;
+	case -EKEYEXPIRED:
+		set_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
+	}
+	gss_cred->gc_upcall_timestamp = jiffies;
+	gss_cred->gc_upcall = NULL;
+	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+}
+
+static void
 gss_upcall_callback(struct rpc_task *task)
 {
 	struct gss_cred *gss_cred = container_of(task->tk_msg.rpc_cred,
@@ -358,13 +379,9 @@ gss_upcall_callback(struct rpc_task *task)
 	struct inode *inode = &gss_msg->inode->vfs_inode;
 
 	spin_lock(&inode->i_lock);
-	if (gss_msg->ctx)
-		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
-	else
-		task->tk_status = gss_msg->msg.errno;
-	gss_cred->gc_upcall = NULL;
-	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
+	gss_handle_downcall_result(gss_cred, gss_msg);
 	spin_unlock(&inode->i_lock);
+	task->tk_status = gss_msg->msg.errno;
 	gss_release_msg(gss_msg);
 }
 
@@ -507,18 +524,16 @@ gss_refresh_upcall(struct rpc_task *task)
 	spin_lock(&inode->i_lock);
 	if (gss_cred->gc_upcall != NULL)
 		rpc_sleep_on(&gss_cred->gc_upcall->rpc_waitqueue, task, NULL);
-	else if (gss_msg->ctx != NULL) {
-		gss_cred_set_ctx(task->tk_msg.rpc_cred, gss_msg->ctx);
-		gss_cred->gc_upcall = NULL;
-		rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
-	} else if (gss_msg->msg.errno >= 0) {
+	else if (gss_msg->ctx == NULL && gss_msg->msg.errno >= 0) {
 		task->tk_timeout = 0;
 		gss_cred->gc_upcall = gss_msg;
 		/* gss_upcall_callback will release the reference to gss_upcall_msg */
 		atomic_inc(&gss_msg->count);
 		rpc_sleep_on(&gss_msg->rpc_waitqueue, task, gss_upcall_callback);
-	} else
+	} else {
+		gss_handle_downcall_result(gss_cred, gss_msg);
 		err = gss_msg->msg.errno;
+	}
 	spin_unlock(&inode->i_lock);
 	gss_release_msg(gss_msg);
 out:
@@ -1117,6 +1132,23 @@ static int gss_renew_cred(struct rpc_task *task)
 	return 0;
 }
 
+static int gss_cred_is_negative_entry(struct rpc_cred *cred)
+{
+	if (test_bit(RPCAUTH_CRED_NEGATIVE, &cred->cr_flags)) {
+		unsigned long now = jiffies;
+		unsigned long begin, expire;
+		struct gss_cred *gss_cred; 
+
+		gss_cred = container_of(cred, struct gss_cred, gc_base);
+		begin = gss_cred->gc_upcall_timestamp;
+		expire = begin + gss_expired_cred_retry_delay * HZ;
+
+		if (time_in_range_open(now, begin, expire))
+			return 1;
+	}
+	return 0;
+}
+
 /*
 * Refresh credentials. XXX - finish
 */
@@ -1126,6 +1158,9 @@ gss_refresh(struct rpc_task *task)
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
 	int ret = 0;
 
+	if (gss_cred_is_negative_entry(cred))
+		return -EKEYEXPIRED;
+
 	if (!test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags) &&
 			!test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags)) {
 		ret = gss_renew_cred(task);
@@ -1573,5 +1608,11 @@ static void __exit exit_rpcsec_gss(void)
 }
 
 MODULE_LICENSE("GPL");
+module_param_named(expired_cred_retry_delay,
+		   gss_expired_cred_retry_delay,
+		   uint, 0644);
+MODULE_PARM_DESC(expired_cred_retry_delay, "Timeout (in seconds) until "
+		"the RPC engine retries an expired credential");
+
 module_init(init_rpcsec_gss)
 module_exit(exit_rpcsec_gss)


_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
