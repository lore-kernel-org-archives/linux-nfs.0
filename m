From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 015/112] SUNRPC: Move exported declarations to the function
	declarations
Date: Fri, 25 Jan 2008 11:37:27 -0500
Message-ID: <20080125163727.31887.8912.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754617AbYAYQ7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:43 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdso010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:42 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do this for all RPC client related functions and XDR functions.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth.c        |    8 ++++++
 net/sunrpc/clnt.c        |   10 +++++++
 net/sunrpc/rpc_pipe.c    |    3 ++
 net/sunrpc/sched.c       |    9 ++++++
 net/sunrpc/stats.c       |    2 +
 net/sunrpc/sunrpc_syms.c |   66 ----------------------------------------------
 net/sunrpc/sysctl.c      |    7 +++++
 net/sunrpc/xdr.c         |   16 ++++++++++-
 net/sunrpc/xprt.c        |    1 +
 9 files changed, 55 insertions(+), 67 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 1ea2755..1025a0e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -51,6 +51,7 @@ rpcauth_register(const struct rpc_authops *ops)
 	spin_unlock(&rpc_authflavor_lock);
 	return ret;
 }
+EXPORT_SYMBOL(rpcauth_register);
 
 int
 rpcauth_unregister(const struct rpc_authops *ops)
@@ -68,6 +69,7 @@ rpcauth_unregister(const struct rpc_authops *ops)
 	spin_unlock(&rpc_authflavor_lock);
 	return ret;
 }
+EXPORT_SYMBOL(rpcauth_unregister);
 
 struct rpc_auth *
 rpcauth_create(rpc_authflavor_t pseudoflavor, struct rpc_clnt *clnt)
@@ -102,6 +104,7 @@ rpcauth_create(rpc_authflavor_t pseudoflavor, struct rpc_clnt *clnt)
 out:
 	return auth;
 }
+EXPORT_SYMBOL(rpcauth_create);
 
 void
 rpcauth_release(struct rpc_auth *auth)
@@ -151,6 +154,7 @@ rpcauth_init_credcache(struct rpc_auth *auth)
 	auth->au_credcache = new;
 	return 0;
 }
+EXPORT_SYMBOL(rpcauth_init_credcache);
 
 /*
  * Destroy a list of credentials
@@ -213,6 +217,7 @@ rpcauth_destroy_credcache(struct rpc_auth *auth)
 		kfree(cache);
 	}
 }
+EXPORT_SYMBOL(rpcauth_destroy_credcache);
 
 /*
  * Remove stale credentials. Avoid sleeping inside the loop.
@@ -332,6 +337,7 @@ found:
 out:
 	return cred;
 }
+EXPORT_SYMBOL(rpcauth_lookup_credcache);
 
 struct rpc_cred *
 rpcauth_lookupcred(struct rpc_auth *auth, int flags)
@@ -350,6 +356,7 @@ rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 	put_group_info(acred.group_info);
 	return ret;
 }
+EXPORT_SYMBOL(rpcauth_lookupcred);
 
 void
 rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
@@ -435,6 +442,7 @@ need_lock:
 out_destroy:
 	cred->cr_ops->crdestroy(cred);
 }
+EXPORT_SYMBOL(put_rpccred);
 
 void
 rpcauth_unbindcred(struct rpc_task *task)
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 046d8f6..5b561f9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -345,6 +345,7 @@ out_no_clnt:
 	dprintk("RPC:       %s: returned error %d\n", __FUNCTION__, err);
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL(rpc_clone_client);
 
 /*
  * Properly shut down an RPC client, terminating all outstanding
@@ -363,6 +364,7 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
 
 	rpc_release_client(clnt);
 }
+EXPORT_SYMBOL(rpc_shutdown_client);
 
 /*
  * Free an RPC client
@@ -467,6 +469,7 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 out:
 	return clnt;
 }
+EXPORT_SYMBOL(rpc_bind_new_program);
 
 /*
  * Default callback for async RPC calls
@@ -512,11 +515,13 @@ void rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset)
 {
 	rpc_save_sigmask(oldset, clnt->cl_intr);
 }
+EXPORT_SYMBOL(rpc_clnt_sigmask);
 
 void rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset)
 {
 	rpc_restore_sigmask(oldset);
 }
+EXPORT_SYMBOL(rpc_clnt_sigunmask);
 
 static
 struct rpc_task *rpc_do_run_task(struct rpc_clnt *clnt,
@@ -572,6 +577,7 @@ int rpc_call_sync(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 	rpc_put_task(task);
 	return status;
 }
+EXPORT_SYMBOL(rpc_call_sync);
 
 /**
  * rpc_call_async - Perform an asynchronous RPC call
@@ -593,6 +599,7 @@ rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg, int flags,
 	rpc_put_task(task);
 	return 0;
 }
+EXPORT_SYMBOL(rpc_call_async);
 
 /**
  * rpc_run_task - Allocate a new RPC task, then run rpc_execute against it
@@ -625,6 +632,7 @@ rpc_call_setup(struct rpc_task *task, struct rpc_message *msg, int flags)
 	else
 		task->tk_action = rpc_exit_task;
 }
+EXPORT_SYMBOL(rpc_call_setup);
 
 /**
  * rpc_peeraddr - extract remote peer address from clnt's xprt
@@ -671,6 +679,7 @@ rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize
 	if (xprt->ops->set_buffer_size)
 		xprt->ops->set_buffer_size(xprt, sndsize, rcvsize);
 }
+EXPORT_SYMBOL(rpc_setbufsize);
 
 /*
  * Return size of largest payload RPC client can support, in bytes
@@ -710,6 +719,7 @@ rpc_restart_call(struct rpc_task *task)
 
 	task->tk_action = call_start;
 }
+EXPORT_SYMBOL(rpc_restart_call);
 
 /*
  * 0.  Initial state
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 5364e2e..19b44e5 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -113,6 +113,7 @@ out:
 	wake_up(&rpci->waitq);
 	return res;
 }
+EXPORT_SYMBOL(rpc_queue_upcall);
 
 static inline void
 rpc_inode_setowner(struct inode *inode, void *private)
@@ -805,6 +806,7 @@ err_dput:
 			-ENOMEM);
 	goto out;
 }
+EXPORT_SYMBOL(rpc_mkpipe);
 
 /**
  * rpc_unlink - remove a pipe
@@ -835,6 +837,7 @@ rpc_unlink(struct dentry *dentry)
 	dput(parent);
 	return error;
 }
+EXPORT_SYMBOL(rpc_unlink);
 
 /*
  * populate the filesystem
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c98873f..44aa9d6 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -373,6 +373,7 @@ void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 	__rpc_sleep_on(q, task, action, timer);
 	spin_unlock_bh(&q->lock);
 }
+EXPORT_SYMBOL(rpc_sleep_on);
 
 /**
  * __rpc_do_wake_up_task - wake up a single rpc_task
@@ -444,6 +445,7 @@ void rpc_wake_up_task(struct rpc_task *task)
 	}
 	rcu_read_unlock_bh();
 }
+EXPORT_SYMBOL(rpc_wake_up_task);
 
 /*
  * Wake up the next task on a priority queue.
@@ -519,6 +521,7 @@ struct rpc_task * rpc_wake_up_next(struct rpc_wait_queue *queue)
 
 	return task;
 }
+EXPORT_SYMBOL(rpc_wake_up_next);
 
 /**
  * rpc_wake_up - wake up all rpc_tasks
@@ -544,6 +547,7 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
 	spin_unlock(&queue->lock);
 	rcu_read_unlock_bh();
 }
+EXPORT_SYMBOL(rpc_wake_up);
 
 /**
  * rpc_wake_up_status - wake up all rpc_tasks and set their status value.
@@ -572,6 +576,7 @@ void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
 	spin_unlock(&queue->lock);
 	rcu_read_unlock_bh();
 }
+EXPORT_SYMBOL(rpc_wake_up_status);
 
 static void __rpc_atrun(struct rpc_task *task)
 {
@@ -586,6 +591,7 @@ void rpc_delay(struct rpc_task *task, unsigned long delay)
 	task->tk_timeout = delay;
 	rpc_sleep_on(&delay_queue, task, NULL, __rpc_atrun);
 }
+EXPORT_SYMBOL(rpc_delay);
 
 /*
  * Helper to call task->tk_ops->rpc_call_prepare
@@ -731,6 +737,7 @@ void rpc_execute(struct rpc_task *task)
 	rpc_set_running(task);
 	__rpc_execute(task);
 }
+EXPORT_SYMBOL(rpc_execute);
 
 static void rpc_async_schedule(struct work_struct *work)
 {
@@ -849,6 +856,7 @@ void rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt, int flags, cons
 	dprintk("RPC:       new task initialized, procpid %u\n",
 				task_pid_nr(current));
 }
+EXPORT_SYMBOL(rpc_init_task);
 
 static struct rpc_task *
 rpc_alloc_task(void)
@@ -960,6 +968,7 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 	}
 	spin_unlock(&clnt->cl_lock);
 }
+EXPORT_SYMBOL(rpc_killall_tasks);
 
 int rpciod_up(void)
 {
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 4d4f373..fd97a49 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -241,12 +241,14 @@ rpc_proc_register(struct rpc_stat *statp)
 {
 	return do_register(statp->program->name, statp, &rpc_proc_fops);
 }
+EXPORT_SYMBOL(rpc_proc_register);
 
 void
 rpc_proc_unregister(const char *name)
 {
 	remove_proc_entry(name, proc_net_rpc);
 }
+EXPORT_SYMBOL(rpc_proc_unregister);
 
 struct proc_dir_entry *
 svc_proc_register(struct svc_stat *statp, const struct file_operations *fops)
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 33d89e8..1a7e309 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -22,45 +22,6 @@
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/xprtsock.h>
 
-/* RPC scheduler */
-EXPORT_SYMBOL(rpc_execute);
-EXPORT_SYMBOL(rpc_init_task);
-EXPORT_SYMBOL(rpc_sleep_on);
-EXPORT_SYMBOL(rpc_wake_up_next);
-EXPORT_SYMBOL(rpc_wake_up_task);
-EXPORT_SYMBOL(rpc_wake_up_status);
-
-/* RPC client functions */
-EXPORT_SYMBOL(rpc_clone_client);
-EXPORT_SYMBOL(rpc_bind_new_program);
-EXPORT_SYMBOL(rpc_shutdown_client);
-EXPORT_SYMBOL(rpc_killall_tasks);
-EXPORT_SYMBOL(rpc_call_sync);
-EXPORT_SYMBOL(rpc_call_async);
-EXPORT_SYMBOL(rpc_call_setup);
-EXPORT_SYMBOL(rpc_clnt_sigmask);
-EXPORT_SYMBOL(rpc_clnt_sigunmask);
-EXPORT_SYMBOL(rpc_delay);
-EXPORT_SYMBOL(rpc_restart_call);
-EXPORT_SYMBOL(rpc_setbufsize);
-EXPORT_SYMBOL(rpc_unlink);
-EXPORT_SYMBOL(rpc_wake_up);
-EXPORT_SYMBOL(rpc_queue_upcall);
-EXPORT_SYMBOL(rpc_mkpipe);
-
-/* Client transport */
-EXPORT_SYMBOL(xprt_set_timeout);
-
-/* Client credential cache */
-EXPORT_SYMBOL(rpcauth_register);
-EXPORT_SYMBOL(rpcauth_unregister);
-EXPORT_SYMBOL(rpcauth_create);
-EXPORT_SYMBOL(rpcauth_lookupcred);
-EXPORT_SYMBOL(rpcauth_lookup_credcache);
-EXPORT_SYMBOL(rpcauth_destroy_credcache);
-EXPORT_SYMBOL(rpcauth_init_credcache);
-EXPORT_SYMBOL(put_rpccred);
-
 /* RPC server stuff */
 EXPORT_SYMBOL(svc_create);
 EXPORT_SYMBOL(svc_create_thread);
@@ -81,8 +42,6 @@ EXPORT_SYMBOL(svc_set_client);
 
 /* RPC statistics */
 #ifdef CONFIG_PROC_FS
-EXPORT_SYMBOL(rpc_proc_register);
-EXPORT_SYMBOL(rpc_proc_unregister);
 EXPORT_SYMBOL(svc_proc_register);
 EXPORT_SYMBOL(svc_proc_unregister);
 EXPORT_SYMBOL(svc_seq_show);
@@ -105,31 +64,6 @@ EXPORT_SYMBOL(qword_get);
 EXPORT_SYMBOL(svcauth_unix_purge);
 EXPORT_SYMBOL(unix_domain_find);
 
-/* Generic XDR */
-EXPORT_SYMBOL(xdr_encode_string);
-EXPORT_SYMBOL(xdr_decode_string_inplace);
-EXPORT_SYMBOL(xdr_decode_netobj);
-EXPORT_SYMBOL(xdr_encode_netobj);
-EXPORT_SYMBOL(xdr_encode_pages);
-EXPORT_SYMBOL(xdr_inline_pages);
-EXPORT_SYMBOL(xdr_shift_buf);
-EXPORT_SYMBOL(xdr_encode_word);
-EXPORT_SYMBOL(xdr_decode_word);
-EXPORT_SYMBOL(xdr_encode_array2);
-EXPORT_SYMBOL(xdr_decode_array2);
-EXPORT_SYMBOL(xdr_buf_from_iov);
-EXPORT_SYMBOL(xdr_buf_subsegment);
-EXPORT_SYMBOL(xdr_buf_read_netobj);
-EXPORT_SYMBOL(read_bytes_from_xdr_buf);
-
-/* Debugging symbols */
-#ifdef RPC_DEBUG
-EXPORT_SYMBOL(rpc_debug);
-EXPORT_SYMBOL(nfs_debug);
-EXPORT_SYMBOL(nfsd_debug);
-EXPORT_SYMBOL(nlm_debug);
-#endif
-
 extern struct cache_detail ip_map_cache, unix_gid_cache;
 
 static int __init
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 2be714e..c879732 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -23,9 +23,16 @@
  * Declare the debug flags here
  */
 unsigned int	rpc_debug;
+EXPORT_SYMBOL(rpc_debug);
+
 unsigned int	nfs_debug;
+EXPORT_SYMBOL(nfs_debug);
+
 unsigned int	nfsd_debug;
+EXPORT_SYMBOL(nfsd_debug);
+
 unsigned int	nlm_debug;
+EXPORT_SYMBOL(nlm_debug);
 
 #ifdef RPC_DEBUG
 
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index fdc5e6d..5426406 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -28,6 +28,7 @@ xdr_encode_netobj(__be32 *p, const struct xdr_netobj *obj)
 	memcpy(p, obj->data, obj->len);
 	return p + XDR_QUADLEN(obj->len);
 }
+EXPORT_SYMBOL(xdr_encode_netobj);
 
 __be32 *
 xdr_decode_netobj(__be32 *p, struct xdr_netobj *obj)
@@ -40,6 +41,7 @@ xdr_decode_netobj(__be32 *p, struct xdr_netobj *obj)
 	obj->data = (u8 *) p;
 	return p + XDR_QUADLEN(len);
 }
+EXPORT_SYMBOL(xdr_decode_netobj);
 
 /**
  * xdr_encode_opaque_fixed - Encode fixed length opaque data
@@ -91,6 +93,7 @@ xdr_encode_string(__be32 *p, const char *string)
 {
 	return xdr_encode_array(p, string, strlen(string));
 }
+EXPORT_SYMBOL(xdr_encode_string);
 
 __be32 *
 xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
@@ -103,6 +106,7 @@ xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
 	*sp = (char *) p;
 	return p + XDR_QUADLEN(len);
 }
+EXPORT_SYMBOL(xdr_decode_string_inplace);
 
 void
 xdr_encode_pages(struct xdr_buf *xdr, struct page **pages, unsigned int base,
@@ -130,6 +134,7 @@ xdr_encode_pages(struct xdr_buf *xdr, struct page **pages, unsigned int base,
 	xdr->buflen += len;
 	xdr->len += len;
 }
+EXPORT_SYMBOL(xdr_encode_pages);
 
 void
 xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
@@ -151,7 +156,7 @@ xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
 
 	xdr->buflen += len;
 }
-
+EXPORT_SYMBOL(xdr_inline_pages);
 
 /*
  * Helper routines for doing 'memmove' like operations on a struct xdr_buf
@@ -418,6 +423,7 @@ xdr_shift_buf(struct xdr_buf *buf, size_t len)
 {
 	xdr_shrink_bufhead(buf, len);
 }
+EXPORT_SYMBOL(xdr_shift_buf);
 
 /**
  * xdr_init_encode - Initialize a struct xdr_stream for sending data.
@@ -639,6 +645,7 @@ xdr_buf_from_iov(struct kvec *iov, struct xdr_buf *buf)
 	buf->page_len = 0;
 	buf->buflen = buf->len = iov->iov_len;
 }
+EXPORT_SYMBOL(xdr_buf_from_iov);
 
 /* Sets subbuf to the portion of buf of length len beginning base bytes
  * from the start of buf. Returns -1 if base of length are out of bounds. */
@@ -687,6 +694,7 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 		return -1;
 	return 0;
 }
+EXPORT_SYMBOL(xdr_buf_subsegment);
 
 static void __read_bytes_from_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned int len)
 {
@@ -717,6 +725,7 @@ int read_bytes_from_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, u
 	__read_bytes_from_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
+EXPORT_SYMBOL(read_bytes_from_xdr_buf);
 
 static void __write_bytes_to_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned int len)
 {
@@ -760,6 +769,7 @@ xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)
 	*obj = ntohl(raw);
 	return 0;
 }
+EXPORT_SYMBOL(xdr_decode_word);
 
 int
 xdr_encode_word(struct xdr_buf *buf, unsigned int base, u32 obj)
@@ -768,6 +778,7 @@ xdr_encode_word(struct xdr_buf *buf, unsigned int base, u32 obj)
 
 	return write_bytes_to_xdr_buf(buf, base, &raw, sizeof(obj));
 }
+EXPORT_SYMBOL(xdr_encode_word);
 
 /* If the netobj starting offset bytes from the start of xdr_buf is contained
  * entirely in the head or the tail, set object to point to it; otherwise
@@ -805,6 +816,7 @@ int xdr_buf_read_netobj(struct xdr_buf *buf, struct xdr_netobj *obj, unsigned in
 	__read_bytes_from_xdr_buf(&subbuf, obj->data, obj->len);
 	return 0;
 }
+EXPORT_SYMBOL(xdr_buf_read_netobj);
 
 /* Returns 0 on success, or else a negative error code. */
 static int
@@ -1010,6 +1022,7 @@ xdr_decode_array2(struct xdr_buf *buf, unsigned int base,
 
 	return xdr_xcode_array2(buf, base, desc, 0);
 }
+EXPORT_SYMBOL(xdr_decode_array2);
 
 int
 xdr_encode_array2(struct xdr_buf *buf, unsigned int base,
@@ -1021,6 +1034,7 @@ xdr_encode_array2(struct xdr_buf *buf, unsigned int base,
 
 	return xdr_xcode_array2(buf, base, desc, 1);
 }
+EXPORT_SYMBOL(xdr_encode_array2);
 
 int
 xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a9101d4..21ea94b 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -992,6 +992,7 @@ void xprt_set_timeout(struct rpc_timeout *to, unsigned int retr, unsigned long i
 	to->to_retries   = retr;
 	to->to_exponential = 0;
 }
+EXPORT_SYMBOL(xprt_set_timeout);
 
 /**
  * xprt_create_transport - create an RPC transport
