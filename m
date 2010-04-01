From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/11] lockd: Keep my_name in nsm_handle
Date: Thu, 01 Apr 2010 15:03:42 -0400
Message-ID: <20100401190342.6395.88708.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:62450 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758681Ab0DATDo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:03:44 -0400
Received: by mail-qy0-f173.google.com with SMTP id 4so1698690qyk.24
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:03:44 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd assumes everywhere that my_name is always utsname->nodename.  If we
want to use multiple my_names (say, for multi-homed support) then we need
to get the my_name value from one place, and ensure that value is also
communicated consistently to statd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c         |    6 +++---
 fs/lockd/mon.c              |   20 ++++++++++++++++----
 fs/lockd/svclock.c          |    2 +-
 include/linux/lockd/lockd.h |    6 ++++++
 4 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index c81249f..2051515 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -12,7 +12,6 @@
 #include <linux/errno.h>
 #include <linux/fs.h>
 #include <linux/nfs_fs.h>
-#include <linux/utsname.h>
 #include <linux/freezer.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
@@ -125,14 +124,15 @@ static void nlmclnt_setlockargs(struct nlm_rqst *req, struct file_lock *fl)
 {
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_lock	*lock = &argp->lock;
+	char *my_name = nsm_my_name(req);
 
 	nlmclnt_next_cookie(&argp->cookie);
 	memcpy(&lock->fh, NFS_FH(fl->fl_file->f_path.dentry->d_inode), sizeof(struct nfs_fh));
-	lock->caller  = utsname()->nodename;
+	lock->caller  = my_name;
 	lock->oh.data = req->a_owner;
 	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
 				(unsigned int)fl->fl_u.nfs_fl.owner->pid,
-				utsname()->nodename);
+				my_name);
 	lock->svid = fl->fl_u.nfs_fl.owner->pid;
 	lock->fl.fl_start = fl->fl_start;
 	lock->fl.fl_end = fl->fl_end;
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 690c236..e470038 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -39,6 +39,7 @@ struct nsm_args {
 	u32			proc;
 
 	char			*mon_name;
+	char			*my_name;
 };
 
 struct nsm_res {
@@ -93,6 +94,8 @@ static void nsm_kobj_release(struct kobject *kobj)
 
 	dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
 			nsm->sm_name, nsm->sm_addrbuf);
+
+	kfree(nsm->sm_my_name);
 	kfree(nsm);
 }
 
@@ -115,7 +118,7 @@ static ssize_t mon_name_show(struct nsm_handle *nsm, char *buf)
 
 static ssize_t my_name_show(struct nsm_handle *nsm, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%s\n", utsname()->nodename);
+	return snprintf(buf, PAGE_SIZE, "%s\n", nsm->sm_my_name);
 }
 
 static ssize_t address_show(struct nsm_handle *nsm, char *buf)
@@ -236,6 +239,7 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 		.vers		= 3,
 		.proc		= NLMPROC_NSM_NOTIFY,
 		.mon_name	= nsm->sm_mon_name,
+		.my_name	= nsm->sm_my_name,
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
@@ -404,7 +408,8 @@ static void nsm_init_private(struct nsm_handle *nsm)
 static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 					    const size_t salen,
 					    const char *hostname,
-					    const size_t hostname_len)
+					    const size_t hostname_len,
+					    const char *my_name)
 {
 	char *p, buf[SM_PRIV_SIZE * 2 + 1];
 	struct nsm_handle *new;
@@ -415,6 +420,12 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 	if (unlikely(new == NULL))
 		return NULL;
 
+	new->sm_my_name = kstrdup(my_name, GFP_KERNEL);
+	if (unlikely(new->sm_my_name == NULL)) {
+		kfree(new);
+		return NULL;
+	}
+
 	atomic_set(&new->sm_count, 1);
 	new->sm_name = (char *)(new + 1);
 	memcpy(nsm_addr(new), sap, salen);
@@ -515,7 +526,8 @@ retry:
 
 	spin_unlock(&nsm_lock);
 
-	new = nsm_create_handle(sap, salen, hostname, hostname_len);
+	new = nsm_create_handle(sap, salen, hostname, hostname_len,
+						init_utsname()->nodename);
 	if (unlikely(new == NULL))
 		return NULL;
 	goto retry;
@@ -637,7 +649,7 @@ static int encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
 	int status;
 	__be32 *p;
 
-	status = encode_nsm_string(xdr, utsname()->nodename);
+	status = encode_nsm_string(xdr, argp->my_name);
 	if (unlikely(status != 0))
 		return status;
 	p = xdr_reserve_space(xdr, 3 * sizeof(u32));
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index d100179..938a9e4 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -304,7 +304,7 @@ static int nlmsvc_setgrantargs(struct nlm_rqst *call, struct nlm_lock *lock)
 {
 	locks_copy_lock(&call->a_args.lock.fl, &lock->fl);
 	memcpy(&call->a_args.lock.fh, &lock->fh, sizeof(call->a_args.lock.fh));
-	call->a_args.lock.caller = utsname()->nodename;
+	call->a_args.lock.caller = nsm_my_name(call);
 	call->a_args.lock.oh.len = lock->oh.len;
 
 	/* set default data area */
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 3c20114..9e5da26 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -82,6 +82,7 @@ struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
 	char			*sm_mon_name;
+	char			*sm_my_name;
 	char			*sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;
@@ -254,6 +255,11 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 void		  nsm_release(struct nsm_handle *nsm);
 
+static inline char *nsm_my_name(const struct nlm_rqst *req)
+{
+	return (char *)req->a_host->h_nsmhandle->sm_my_name;
+}
+
 /*
  * This is used in garbage collection and resource reclaim
  * A return value != 0 means destroy the lock/block/share

