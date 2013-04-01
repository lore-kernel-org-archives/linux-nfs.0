Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758633Ab3DALlx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 07:41:53 -0400
Date: Mon, 1 Apr 2013 07:41:49 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: remove support for nfsdcld
Message-ID: <20130401074149.51a4b4f2@tlielax.poochiereds.net>
In-Reply-To: <51593D11.5070702@parallels.com>
References: <1363957031-10579-1-git-send-email-jlayton@redhat.com>
	<51593D11.5070702@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 1 Apr 2013 11:53:53 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 22.03.2013 16:57, Jeff Layton пишет:
> > ...as advertised for 3.10.
> >
> 
> It looks like UMH should be containerised as fast as possible, doesn't it?
> Bruce, don't you know, how much time left before 3.10 merge window?
> 

Yes, that would be ideal. I'd estimate that we have about a month or so?

Just from a quick look it doesn't look too hard to do this:

Use call_usermodehelper_fns with an "init" function that changes the
namespace(s) of the process before the do_execve call. The namespace
info could be passed in via the "data" parm to call_usermodehelper_fns.
Alternately, I guess you could add some namespace fields to struct
subprocess_info...

That said, I'm not clear on how you have to go about changing the
namespace once the new process has been spawned...


> > Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >   fs/nfsd/nfs4recover.c          | 492 +----------------------------------------
> >   fs/nfsd/nfsctl.c               |   8 +-
> >   fs/nfsd/nfsd.h                 |   5 -
> >   include/uapi/linux/nfsd/Kbuild |   1 -
> >   include/uapi/linux/nfsd/cld.h  |  56 -----
> >   5 files changed, 6 insertions(+), 556 deletions(-)
> >   delete mode 100644 include/uapi/linux/nfsd/cld.h
> >
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index 899ca26..4e7f47e 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -42,7 +42,6 @@
> >   #include <net/net_namespace.h>
> >   #include <linux/sunrpc/rpc_pipe_fs.h>
> >   #include <linux/sunrpc/clnt.h>
> > -#include <linux/nfsd/cld.h>
> >
> >   #include "nfsd.h"
> >   #include "state.h"
> > @@ -625,426 +624,6 @@ static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
> >   	.grace_done	= nfsd4_recdir_purge_old,
> >   };
> >
> > -/* Globals */
> > -#define NFSD_PIPE_DIR		"nfsd"
> > -#define NFSD_CLD_PIPE		"cld"
> > -
> > -/* per-net-ns structure for holding cld upcall info */
> > -struct cld_net {
> > -	struct rpc_pipe		*cn_pipe;
> > -	spinlock_t		 cn_lock;
> > -	struct list_head	 cn_list;
> > -	unsigned int		 cn_xid;
> > -};
> > -
> > -struct cld_upcall {
> > -	struct list_head	 cu_list;
> > -	struct cld_net		*cu_net;
> > -	struct task_struct	*cu_task;
> > -	struct cld_msg		 cu_msg;
> > -};
> > -
> > -static int
> > -__cld_pipe_upcall(struct rpc_pipe *pipe, struct cld_msg *cmsg)
> > -{
> > -	int ret;
> > -	struct rpc_pipe_msg msg;
> > -
> > -	memset(&msg, 0, sizeof(msg));
> > -	msg.data = cmsg;
> > -	msg.len = sizeof(*cmsg);
> > -
> > -	/*
> > -	 * Set task state before we queue the upcall. That prevents
> > -	 * wake_up_process in the downcall from racing with schedule.
> > -	 */
> > -	set_current_state(TASK_UNINTERRUPTIBLE);
> > -	ret = rpc_queue_upcall(pipe, &msg);
> > -	if (ret < 0) {
> > -		set_current_state(TASK_RUNNING);
> > -		goto out;
> > -	}
> > -
> > -	schedule();
> > -	set_current_state(TASK_RUNNING);
> > -
> > -	if (msg.errno < 0)
> > -		ret = msg.errno;
> > -out:
> > -	return ret;
> > -}
> > -
> > -static int
> > -cld_pipe_upcall(struct rpc_pipe *pipe, struct cld_msg *cmsg)
> > -{
> > -	int ret;
> > -
> > -	/*
> > -	 * -EAGAIN occurs when pipe is closed and reopened while there are
> > -	 *  upcalls queued.
> > -	 */
> > -	do {
> > -		ret = __cld_pipe_upcall(pipe, cmsg);
> > -	} while (ret == -EAGAIN);
> > -
> > -	return ret;
> > -}
> > -
> > -static ssize_t
> > -cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> > -{
> > -	struct cld_upcall *tmp, *cup;
> > -	struct cld_msg __user *cmsg = (struct cld_msg __user *)src;
> > -	uint32_t xid;
> > -	struct nfsd_net *nn = net_generic(filp->f_dentry->d_sb->s_fs_info,
> > -						nfsd_net_id);
> > -	struct cld_net *cn = nn->cld_net;
> > -
> > -	if (mlen != sizeof(*cmsg)) {
> > -		dprintk("%s: got %zu bytes, expected %zu\n", __func__, mlen,
> > -			sizeof(*cmsg));
> > -		return -EINVAL;
> > -	}
> > -
> > -	/* copy just the xid so we can try to find that */
> > -	if (copy_from_user(&xid, &cmsg->cm_xid, sizeof(xid)) != 0) {
> > -		dprintk("%s: error when copying xid from userspace", __func__);
> > -		return -EFAULT;
> > -	}
> > -
> > -	/* walk the list and find corresponding xid */
> > -	cup = NULL;
> > -	spin_lock(&cn->cn_lock);
> > -	list_for_each_entry(tmp, &cn->cn_list, cu_list) {
> > -		if (get_unaligned(&tmp->cu_msg.cm_xid) == xid) {
> > -			cup = tmp;
> > -			list_del_init(&cup->cu_list);
> > -			break;
> > -		}
> > -	}
> > -	spin_unlock(&cn->cn_lock);
> > -
> > -	/* couldn't find upcall? */
> > -	if (!cup) {
> > -		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__, xid);
> > -		return -EINVAL;
> > -	}
> > -
> > -	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
> > -		return -EFAULT;
> > -
> > -	wake_up_process(cup->cu_task);
> > -	return mlen;
> > -}
> > -
> > -static void
> > -cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
> > -{
> > -	struct cld_msg *cmsg = msg->data;
> > -	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall,
> > -						 cu_msg);
> > -
> > -	/* errno >= 0 means we got a downcall */
> > -	if (msg->errno >= 0)
> > -		return;
> > -
> > -	wake_up_process(cup->cu_task);
> > -}
> > -
> > -static const struct rpc_pipe_ops cld_upcall_ops = {
> > -	.upcall		= rpc_pipe_generic_upcall,
> > -	.downcall	= cld_pipe_downcall,
> > -	.destroy_msg	= cld_pipe_destroy_msg,
> > -};
> > -
> > -static struct dentry *
> > -nfsd4_cld_register_sb(struct super_block *sb, struct rpc_pipe *pipe)
> > -{
> > -	struct dentry *dir, *dentry;
> > -
> > -	dir = rpc_d_lookup_sb(sb, NFSD_PIPE_DIR);
> > -	if (dir == NULL)
> > -		return ERR_PTR(-ENOENT);
> > -	dentry = rpc_mkpipe_dentry(dir, NFSD_CLD_PIPE, NULL, pipe);
> > -	dput(dir);
> > -	return dentry;
> > -}
> > -
> > -static void
> > -nfsd4_cld_unregister_sb(struct rpc_pipe *pipe)
> > -{
> > -	if (pipe->dentry)
> > -		rpc_unlink(pipe->dentry);
> > -}
> > -
> > -static struct dentry *
> > -nfsd4_cld_register_net(struct net *net, struct rpc_pipe *pipe)
> > -{
> > -	struct super_block *sb;
> > -	struct dentry *dentry;
> > -
> > -	sb = rpc_get_sb_net(net);
> > -	if (!sb)
> > -		return NULL;
> > -	dentry = nfsd4_cld_register_sb(sb, pipe);
> > -	rpc_put_sb_net(net);
> > -	return dentry;
> > -}
> > -
> > -static void
> > -nfsd4_cld_unregister_net(struct net *net, struct rpc_pipe *pipe)
> > -{
> > -	struct super_block *sb;
> > -
> > -	sb = rpc_get_sb_net(net);
> > -	if (sb) {
> > -		nfsd4_cld_unregister_sb(pipe);
> > -		rpc_put_sb_net(net);
> > -	}
> > -}
> > -
> > -/* Initialize rpc_pipefs pipe for communication with client tracking daemon */
> > -static int
> > -nfsd4_init_cld_pipe(struct net *net)
> > -{
> > -	int ret;
> > -	struct dentry *dentry;
> > -	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> > -	struct cld_net *cn;
> > -
> > -	if (nn->cld_net)
> > -		return 0;
> > -
> > -	cn = kzalloc(sizeof(*cn), GFP_KERNEL);
> > -	if (!cn) {
> > -		ret = -ENOMEM;
> > -		goto err;
> > -	}
> > -
> > -	cn->cn_pipe = rpc_mkpipe_data(&cld_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
> > -	if (IS_ERR(cn->cn_pipe)) {
> > -		ret = PTR_ERR(cn->cn_pipe);
> > -		goto err;
> > -	}
> > -	spin_lock_init(&cn->cn_lock);
> > -	INIT_LIST_HEAD(&cn->cn_list);
> > -
> > -	dentry = nfsd4_cld_register_net(net, cn->cn_pipe);
> > -	if (IS_ERR(dentry)) {
> > -		ret = PTR_ERR(dentry);
> > -		goto err_destroy_data;
> > -	}
> > -
> > -	cn->cn_pipe->dentry = dentry;
> > -	nn->cld_net = cn;
> > -	return 0;
> > -
> > -err_destroy_data:
> > -	rpc_destroy_pipe_data(cn->cn_pipe);
> > -err:
> > -	kfree(cn);
> > -	printk(KERN_ERR "NFSD: unable to create nfsdcld upcall pipe (%d)\n",
> > -			ret);
> > -	return ret;
> > -}
> > -
> > -static void
> > -nfsd4_remove_cld_pipe(struct net *net)
> > -{
> > -	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> > -	struct cld_net *cn = nn->cld_net;
> > -
> > -	nfsd4_cld_unregister_net(net, cn->cn_pipe);
> > -	rpc_destroy_pipe_data(cn->cn_pipe);
> > -	kfree(nn->cld_net);
> > -	nn->cld_net = NULL;
> > -}
> > -
> > -static struct cld_upcall *
> > -alloc_cld_upcall(struct cld_net *cn)
> > -{
> > -	struct cld_upcall *new, *tmp;
> > -
> > -	new = kzalloc(sizeof(*new), GFP_KERNEL);
> > -	if (!new)
> > -		return new;
> > -
> > -	/* FIXME: hard cap on number in flight? */
> > -restart_search:
> > -	spin_lock(&cn->cn_lock);
> > -	list_for_each_entry(tmp, &cn->cn_list, cu_list) {
> > -		if (tmp->cu_msg.cm_xid == cn->cn_xid) {
> > -			cn->cn_xid++;
> > -			spin_unlock(&cn->cn_lock);
> > -			goto restart_search;
> > -		}
> > -	}
> > -	new->cu_task = current;
> > -	new->cu_msg.cm_vers = CLD_UPCALL_VERSION;
> > -	put_unaligned(cn->cn_xid++, &new->cu_msg.cm_xid);
> > -	new->cu_net = cn;
> > -	list_add(&new->cu_list, &cn->cn_list);
> > -	spin_unlock(&cn->cn_lock);
> > -
> > -	dprintk("%s: allocated xid %u\n", __func__, new->cu_msg.cm_xid);
> > -
> > -	return new;
> > -}
> > -
> > -static void
> > -free_cld_upcall(struct cld_upcall *victim)
> > -{
> > -	struct cld_net *cn = victim->cu_net;
> > -
> > -	spin_lock(&cn->cn_lock);
> > -	list_del(&victim->cu_list);
> > -	spin_unlock(&cn->cn_lock);
> > -	kfree(victim);
> > -}
> > -
> > -/* Ask daemon to create a new record */
> > -static void
> > -nfsd4_cld_create(struct nfs4_client *clp)
> > -{
> > -	int ret;
> > -	struct cld_upcall *cup;
> > -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > -	struct cld_net *cn = nn->cld_net;
> > -
> > -	/* Don't upcall if it's already stored */
> > -	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
> > -		return;
> > -
> > -	cup = alloc_cld_upcall(cn);
> > -	if (!cup) {
> > -		ret = -ENOMEM;
> > -		goto out_err;
> > -	}
> > -
> > -	cup->cu_msg.cm_cmd = Cld_Create;
> > -	cup->cu_msg.cm_u.cm_name.cn_len = clp->cl_name.len;
> > -	memcpy(cup->cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
> > -			clp->cl_name.len);
> > -
> > -	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
> > -	if (!ret) {
> > -		ret = cup->cu_msg.cm_status;
> > -		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> > -	}
> > -
> > -	free_cld_upcall(cup);
> > -out_err:
> > -	if (ret)
> > -		printk(KERN_ERR "NFSD: Unable to create client "
> > -				"record on stable storage: %d\n", ret);
> > -}
> > -
> > -/* Ask daemon to create a new record */
> > -static void
> > -nfsd4_cld_remove(struct nfs4_client *clp)
> > -{
> > -	int ret;
> > -	struct cld_upcall *cup;
> > -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > -	struct cld_net *cn = nn->cld_net;
> > -
> > -	/* Don't upcall if it's already removed */
> > -	if (!test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
> > -		return;
> > -
> > -	cup = alloc_cld_upcall(cn);
> > -	if (!cup) {
> > -		ret = -ENOMEM;
> > -		goto out_err;
> > -	}
> > -
> > -	cup->cu_msg.cm_cmd = Cld_Remove;
> > -	cup->cu_msg.cm_u.cm_name.cn_len = clp->cl_name.len;
> > -	memcpy(cup->cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
> > -			clp->cl_name.len);
> > -
> > -	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
> > -	if (!ret) {
> > -		ret = cup->cu_msg.cm_status;
> > -		clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> > -	}
> > -
> > -	free_cld_upcall(cup);
> > -out_err:
> > -	if (ret)
> > -		printk(KERN_ERR "NFSD: Unable to remove client "
> > -				"record from stable storage: %d\n", ret);
> > -}
> > -
> > -/* Check for presence of a record, and update its timestamp */
> > -static int
> > -nfsd4_cld_check(struct nfs4_client *clp)
> > -{
> > -	int ret;
> > -	struct cld_upcall *cup;
> > -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > -	struct cld_net *cn = nn->cld_net;
> > -
> > -	/* Don't upcall if one was already stored during this grace pd */
> > -	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
> > -		return 0;
> > -
> > -	cup = alloc_cld_upcall(cn);
> > -	if (!cup) {
> > -		printk(KERN_ERR "NFSD: Unable to check client record on "
> > -				"stable storage: %d\n", -ENOMEM);
> > -		return -ENOMEM;
> > -	}
> > -
> > -	cup->cu_msg.cm_cmd = Cld_Check;
> > -	cup->cu_msg.cm_u.cm_name.cn_len = clp->cl_name.len;
> > -	memcpy(cup->cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
> > -			clp->cl_name.len);
> > -
> > -	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
> > -	if (!ret) {
> > -		ret = cup->cu_msg.cm_status;
> > -		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> > -	}
> > -
> > -	free_cld_upcall(cup);
> > -	return ret;
> > -}
> > -
> > -static void
> > -nfsd4_cld_grace_done(struct nfsd_net *nn, time_t boot_time)
> > -{
> > -	int ret;
> > -	struct cld_upcall *cup;
> > -	struct cld_net *cn = nn->cld_net;
> > -
> > -	cup = alloc_cld_upcall(cn);
> > -	if (!cup) {
> > -		ret = -ENOMEM;
> > -		goto out_err;
> > -	}
> > -
> > -	cup->cu_msg.cm_cmd = Cld_GraceDone;
> > -	cup->cu_msg.cm_u.cm_gracetime = (int64_t)boot_time;
> > -	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
> > -	if (!ret)
> > -		ret = cup->cu_msg.cm_status;
> > -
> > -	free_cld_upcall(cup);
> > -out_err:
> > -	if (ret)
> > -		printk(KERN_ERR "NFSD: Unable to end grace period: %d\n", ret);
> > -}
> > -
> > -static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
> > -	.init		= nfsd4_init_cld_pipe,
> > -	.exit		= nfsd4_remove_cld_pipe,
> > -	.create		= nfsd4_cld_create,
> > -	.remove		= nfsd4_cld_remove,
> > -	.check		= nfsd4_cld_check,
> > -	.grace_done	= nfsd4_cld_grace_done,
> > -};
> > -
> >   /* upcall via usermodehelper */
> >   static char cltrack_prog[PATH_MAX] = "/sbin/nfsdcltrack";
> >   module_param_string(cltrack_prog, cltrack_prog, sizeof(cltrack_prog),
> > @@ -1287,21 +866,14 @@ nfsd4_client_tracking_init(struct net *net)
> >   	 * then use the legacy ops.
> >   	 */
> >   	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;
> > -	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
> > -	if (!status) {
> > -		status = S_ISDIR(path.dentry->d_inode->i_mode);
> > -		path_put(&path);
> > -		if (status)
> > -			goto do_init;
> > -	}
> > +	status = kern_path(nfs4_recoverydir(),
> > +				LOOKUP_FOLLOW|LOOKUP_DIRECTORY, &path);
> > +	if (status)
> > +		goto out_err;
> >
> > -	/* Finally, try to use nfsdcld */
> > -	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
> > -	printk(KERN_WARNING "NFSD: the nfsdcld client tracking upcall will be "
> > -			"removed in 3.10. Please transition to using "
> > -			"nfsdcltrack.\n");
> >   do_init:
> >   	status = nn->client_tracking_ops->init(net);
> > +out_err:
> >   	if (status) {
> >   		printk(KERN_WARNING "NFSD: Unable to initialize client "
> >   				    "recovery tracking! (%d)\n", status);
> > @@ -1358,57 +930,3 @@ nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time)
> >   		nn->client_tracking_ops->grace_done(nn, boot_time);
> >   }
> >
> > -static int
> > -rpc_pipefs_event(struct notifier_block *nb, unsigned long event, void *ptr)
> > -{
> > -	struct super_block *sb = ptr;
> > -	struct net *net = sb->s_fs_info;
> > -	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> > -	struct cld_net *cn = nn->cld_net;
> > -	struct dentry *dentry;
> > -	int ret = 0;
> > -
> > -	if (!try_module_get(THIS_MODULE))
> > -		return 0;
> > -
> > -	if (!cn) {
> > -		module_put(THIS_MODULE);
> > -		return 0;
> > -	}
> > -
> > -	switch (event) {
> > -	case RPC_PIPEFS_MOUNT:
> > -		dentry = nfsd4_cld_register_sb(sb, cn->cn_pipe);
> > -		if (IS_ERR(dentry)) {
> > -			ret = PTR_ERR(dentry);
> > -			break;
> > -		}
> > -		cn->cn_pipe->dentry = dentry;
> > -		break;
> > -	case RPC_PIPEFS_UMOUNT:
> > -		if (cn->cn_pipe->dentry)
> > -			nfsd4_cld_unregister_sb(cn->cn_pipe);
> > -		break;
> > -	default:
> > -		ret = -ENOTSUPP;
> > -		break;
> > -	}
> > -	module_put(THIS_MODULE);
> > -	return ret;
> > -}
> > -
> > -static struct notifier_block nfsd4_cld_block = {
> > -	.notifier_call = rpc_pipefs_event,
> > -};
> > -
> > -int
> > -register_cld_notifier(void)
> > -{
> > -	return rpc_pipefs_notifier_register(&nfsd4_cld_block);
> > -}
> > -
> > -void
> > -unregister_cld_notifier(void)
> > -{
> > -	rpc_pipefs_notifier_unregister(&nfsd4_cld_block);
> > -}
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index a830f33..f0aeb93 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -1163,12 +1163,9 @@ static int __init init_nfsd(void)
> >   	int retval;
> >   	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
> >
> > -	retval = register_cld_notifier();
> > -	if (retval)
> > -		return retval;
> >   	retval = register_pernet_subsys(&nfsd_net_ops);
> >   	if (retval < 0)
> > -		goto out_unregister_notifier;
> > +		return retval;
> >   	retval = nfsd4_init_slabs();
> >   	if (retval)
> >   		goto out_unregister_pernet;
> > @@ -1201,8 +1198,6 @@ out_free_slabs:
> >   	nfsd4_free_slabs();
> >   out_unregister_pernet:
> >   	unregister_pernet_subsys(&nfsd_net_ops);
> > -out_unregister_notifier:
> > -	unregister_cld_notifier();
> >   	return retval;
> >   }
> >
> > @@ -1217,7 +1212,6 @@ static void __exit exit_nfsd(void)
> >   	nfsd_fault_inject_cleanup();
> >   	unregister_filesystem(&nfsd_fs_type);
> >   	unregister_pernet_subsys(&nfsd_net_ops);
> > -	unregister_cld_notifier();
> >   }
> >
> >   MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
> > diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> > index 07a473f..8eb2aac 100644
> > --- a/fs/nfsd/nfsd.h
> > +++ b/fs/nfsd/nfsd.h
> > @@ -365,17 +365,12 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
> >   	NFSD_WRITEABLE_ATTRS_WORD2
> >
> >   extern int nfsd4_is_junction(struct dentry *dentry);
> > -extern int register_cld_notifier(void);
> > -extern void unregister_cld_notifier(void);
> >   #else /* CONFIG_NFSD_V4 */
> >   static inline int nfsd4_is_junction(struct dentry *dentry)
> >   {
> >   	return 0;
> >   }
> >
> > -#define register_cld_notifier() 0
> > -#define unregister_cld_notifier() do { } while(0)
> > -
> >   #endif /* CONFIG_NFSD_V4 */
> >
> >   #endif /* LINUX_NFSD_NFSD_H */
> > diff --git a/include/uapi/linux/nfsd/Kbuild b/include/uapi/linux/nfsd/Kbuild
> > index c11bc40..88589ac 100644
> > --- a/include/uapi/linux/nfsd/Kbuild
> > +++ b/include/uapi/linux/nfsd/Kbuild
> > @@ -1,5 +1,4 @@
> >   # UAPI Header export list
> > -header-y += cld.h
> >   header-y += debug.h
> >   header-y += export.h
> >   header-y += nfsfh.h
> > diff --git a/include/uapi/linux/nfsd/cld.h b/include/uapi/linux/nfsd/cld.h
> > deleted file mode 100644
> > index f14a9ab..0000000
> > --- a/include/uapi/linux/nfsd/cld.h
> > +++ /dev/null
> > @@ -1,56 +0,0 @@
> > -/*
> > - * Upcall description for nfsdcld communication
> > - *
> > - * Copyright (c) 2012 Red Hat, Inc.
> > - * Author(s): Jeff Layton <jlayton@redhat.com>
> > - *
> > - *  This program is free software; you can redistribute it and/or modify
> > - *  it under the terms of the GNU General Public License as published by
> > - *  the Free Software Foundation; either version 2 of the License, or
> > - *  (at your option) any later version.
> > - *
> > - *  This program is distributed in the hope that it will be useful,
> > - *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> > - *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > - *  GNU General Public License for more details.
> > - *
> > - *  You should have received a copy of the GNU General Public License
> > - *  along with this program; if not, write to the Free Software
> > - *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> > - */
> > -
> > -#ifndef _NFSD_CLD_H
> > -#define _NFSD_CLD_H
> > -
> > -/* latest upcall version available */
> > -#define CLD_UPCALL_VERSION 1
> > -
> > -/* defined by RFC3530 */
> > -#define NFS4_OPAQUE_LIMIT 1024
> > -
> > -enum cld_command {
> > -	Cld_Create,		/* create a record for this cm_id */
> > -	Cld_Remove,		/* remove record of this cm_id */
> > -	Cld_Check,		/* is this cm_id allowed? */
> > -	Cld_GraceDone,		/* grace period is complete */
> > -};
> > -
> > -/* representation of long-form NFSv4 client ID */
> > -struct cld_name {
> > -	uint16_t	cn_len;				/* length of cm_id */
> > -	unsigned char	cn_id[NFS4_OPAQUE_LIMIT];	/* client-provided */
> > -} __attribute__((packed));
> > -
> > -/* message struct for communication with userspace */
> > -struct cld_msg {
> > -	uint8_t		cm_vers;		/* upcall version */
> > -	uint8_t		cm_cmd;			/* upcall command */
> > -	int16_t		cm_status;		/* return code */
> > -	uint32_t	cm_xid;			/* transaction id */
> > -	union {
> > -		int64_t		cm_gracetime;	/* grace period start time */
> > -		struct cld_name	cm_name;
> > -	} __attribute__((packed)) cm_u;
> > -} __attribute__((packed));
> > -
> > -#endif /* !_NFSD_CLD_H */
> >
> 
> 


-- 
Jeff Layton <jlayton@redhat.com>
