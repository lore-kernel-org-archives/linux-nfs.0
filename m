Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38208 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966101Ab2B2SjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 13:39:23 -0500
Message-ID: <4F4E70C5.9030608@parallels.com>
Date: Wed, 29 Feb 2012 22:39:01 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 5/5] nfsd: add the infrastructure to handle the cld
 upcall
References: <1330535757-24925-1-git-send-email-jlayton@redhat.com> <1330535757-24925-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1330535757-24925-6-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Jeff.
I'll try to explain, how all this namespaces-aware SUNRPC PipeFS works.
The main idea is, that today we have 2 types of independently created and 
destroyed but linked objects:
1) pipe data itself. This object is created whenever kernel requires (on mount, 
module install, whatever)
2) dentry/inode for this pipe. This object is created on PipeFS superblock creation.
This means, any kernel user of SUNRPC pipes have to provide two mechanisms:
1) Safe call (in per-net operations, if the object is global your case) for 
PipeFS dentry/inode pair. This is done this in nfsd4_init_cld_pipe().
2) Notifier callback for PipeFS mount/umount operations. Note: this callback is 
done from SUNRPC module (i.e. you have to get nfsd module); this callback is 
safe - i.e you can be sure, that superblock is valid.

Important: notifier callback have to be registered prior to per-net operations, 
because otherwise you have races like below:

CPU0						CPU1
----------------------------------		-------------------------------
per-net ops register (no PipeFS sb)
						PipeFS mount - event sent
notifier register (event lost)

Unregister have to be done in the same (not reversed!) sequence to prevent races 
as below:

CPU0						CPU1
----------------------------------		-------------------------------
per-net ops unregister (no PipeFS sb)
						PipeFS mount - dentry created
notifier unregister (stale dentry)

The best example for you is in fs/nfs/blocklayout/blocklayout.c.
Feel free to ask questions.
Also, have a look at my comments below.


29.02.2012 21:15, Jeff Layton пишет:
> ...and add a mechanism for switching between the "legacy" tracker and
> the new one. The decision is made by looking to see whether the
> v4recoverydir exists. If it does, then the legacy client tracker is
> used.
>
> If it's not, then the kernel will create a "cld" pipe in rpc_pipefs.
> That pipe is used to talk to a daemon for handling the upcall.
>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> ---
>   fs/nfsd/nfs4recover.c |  382 ++++++++++++++++++++++++++++++++++++++++++++++++-
>   1 files changed, 381 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index ccd9b97..34fc843 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -1,5 +1,6 @@
>   /*
>   *  Copyright (c) 2004 The Regents of the University of Michigan.
> +*  Copyright (c) 2012 Jeff Layton<jlayton@redhat.com>
>   *  All rights reserved.
>   *
>   *  Andy Adamson<andros@citi.umich.edu>
> @@ -36,6 +37,11 @@
>   #include<linux/namei.h>
>   #include<linux/crypto.h>
>   #include<linux/sched.h>
> +#include<linux/fs.h>
> +#include<net/net_namespace.h>
> +#include<linux/sunrpc/rpc_pipe_fs.h>
> +#include<linux/sunrpc/clnt.h>
> +#include<linux/nfsd/cld.h>
>
>   #include "nfsd.h"
>   #include "state.h"
> @@ -478,12 +484,386 @@ static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
>   	.grace_done	= nfsd4_recdir_purge_old,
>   };
>
> +/* Globals */
> +#define NFSD_PIPE_DIR		"nfsd"
> +#define NFSD_CLD_PIPE		"cld"
> +
> +static struct rpc_pipe *cld_pipe;
> +
> +/* list of cld_msg's that are currently in use */
> +static DEFINE_SPINLOCK(cld_lock);
> +static LIST_HEAD(cld_list);
> +static unsigned int cld_xid;
> +
> +struct cld_upcall {
> +	struct list_head	cu_list;
> +	struct task_struct	*cu_task;
> +	struct cld_msg	cu_msg;
> +};
> +
> +static int
> +__cld_pipe_upcall(struct cld_msg *cmsg)
> +{
> +	int ret;
> +	struct rpc_pipe_msg msg;
> +
> +	memset(&msg, 0, sizeof(msg));
> +	msg.data = cmsg;
> +	msg.len = sizeof(*cmsg);
> +
> +	/*
> +	 * Set task state before we queue the upcall. That prevents
> +	 * wake_up_process in the downcall from racing with schedule.
> +	 */
> +	set_current_state(TASK_UNINTERRUPTIBLE);
> +	ret = rpc_queue_upcall(cld_pipe,&msg);
> +	if (ret<  0) {
> +		set_current_state(TASK_RUNNING);
> +		goto out;
> +	}
> +
> +	schedule();
> +	set_current_state(TASK_RUNNING);
> +
> +	if (msg.errno<  0)
> +		ret = msg.errno;
> +out:
> +	return ret;
> +}
> +
> +static int
> +cld_pipe_upcall(struct cld_msg *cmsg)
> +{
> +	int ret;
> +
> +	/*
> +	 * -EAGAIN occurs when pipe is closed and reopened while there are
> +	 *  upcalls queued.
> +	 */
> +	do {
> +		ret = __cld_pipe_upcall(cmsg);
> +	} while (ret == -EAGAIN);
> +
> +	return ret;
> +}
> +
> +static ssize_t
> +cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> +{
> +	struct cld_upcall *tmp, *cup;
> +	struct cld_msg *cmsg = (struct cld_msg *)src;
> +	uint32_t xid;
> +
> +	if (mlen != sizeof(*cmsg)) {
> +		dprintk("%s: got %lu bytes, expected %lu\n", __func__, mlen,
> +			sizeof(*cmsg));
> +		return -EINVAL;
> +	}
> +
> +	/* copy just the xid so we can try to find that */
> +	if (copy_from_user(&xid,&cmsg->cm_xid, sizeof(xid)) != 0) {
> +		dprintk("%s: error when copying xid from userspace", __func__);
> +		return -EFAULT;
> +	}
> +
> +	/* walk the list and find corresponding xid */
> +	cup = NULL;
> +	spin_lock(&cld_lock);
> +	list_for_each_entry(tmp,&cld_list, cu_list) {
> +		if (get_unaligned(&tmp->cu_msg.cm_xid) == xid) {
> +			cup = tmp;
> +			list_del_init(&cup->cu_list);
> +			break;
> +		}
> +	}
> +	spin_unlock(&cld_lock);
> +
> +	/* couldn't find upcall? */
> +	if (!cup) {
> +		dprintk("%s: couldn't find upcall -- xid=%u\n", __func__,
> +			cup->cu_msg.cm_xid);
> +		return -EINVAL;
> +	}
> +
> +	if (copy_from_user(&cup->cu_msg, src, mlen) != 0)
> +		return -EFAULT;
> +
> +	wake_up_process(cup->cu_task);
> +	return mlen;
> +}
> +
> +static void
> +cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
> +{
> +	struct cld_msg *cmsg = msg->data;
> +	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall,
> +						 cu_msg);
> +
> +	/* errno>= 0 means we got a downcall */
> +	if (msg->errno>= 0)
> +		return;
> +
> +	wake_up_process(cup->cu_task);
> +}
> +
> +static const struct rpc_pipe_ops cld_upcall_ops = {
> +	.upcall		= rpc_pipe_generic_upcall,
> +	.downcall	= cld_pipe_downcall,
> +	.destroy_msg	= cld_pipe_destroy_msg,
> +};
> +
> +/* Initialize rpc_pipefs pipe for communication with client tracking daemon */
> +static int
> +nfsd4_init_cld_pipe(void)
> +{

1) Please, pass network context to the function instead of hard-coding init_net 
in it's body.
2) please move dentry creation to separated function and split this new function 
into unsafe one (for nofier callback) and safe one, which covers unsafe with 
rpc_get_sb_net() and rpc_get_sb_net().

> +	int ret;
> +	struct dentry *dir, *dentry;
> +	struct super_block *sb;
> +
> +	if (cld_pipe)F
> +		return 0;
> +
> +	cld_pipe = rpc_mkpipe_data(&cld_upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
> +	if (IS_ERR(cld_pipe)) {
> +		ret = PTR_ERR(cld_pipe);
> +		goto err;
> +	}
> +
> +	/* since this is a global thing for now, hang it off init_net ns */
> +	sb = rpc_get_sb_net(&init_net);
> +	if (!sb) {
> +		ret = -ENOMEM;
> +		goto err_destroy_data;

You don't need to fail here and destroy but have to implement notifier callback 
for PipeFS MOUNT/UMOUNT operations.
Don't worry about this dentry - this is not a NFSd problem.

> +	}
> +
> +	dir = rpc_d_lookup_sb(sb, NFSD_PIPE_DIR);
> +	rpc_put_sb_net(&init_net);

You can't release PipeFS SB here - it will be dereferenced in 
rpc_mkpipe_dentry() and you are not protected against umount.

> +	if (!dir) {
> +		ret = -ENOENT;
> +		goto err_destroy_data;
> +	}
> +
> +	dentry = rpc_mkpipe_dentry(dir, NFSD_CLD_PIPE, NULL, cld_pipe);
> +	dput(dir);
> +	if (IS_ERR(dentry)) {
> +		ret = PTR_ERR(dentry);
> +		goto err_destroy_data;
> +	}
> +
> +	cld_pipe->dentry = dentry;
> +	return 0;
> +
> +err_destroy_data:
> +	rpc_destroy_pipe_data(cld_pipe);
> +err:
> +	cld_pipe = NULL;
> +	printk(KERN_ERR "NFSD: unable to create nfsdcld upcall pipe (%d)\n",
> +			ret);
> +	return ret;
> +}
> +
> +static void
> +nfsd4_remove_cld_pipe(void)
> +{
> +	int ret;
> +
> +	ret = rpc_unlink(cld_pipe->dentry);

You have to unlink cld_pipe->dentry only if it's non-NULL

> +	if (ret)
> +		printk(KERN_ERR "NFSD: error removing cld pipe: %d\n", ret);
> +	cld_pipe = NULL;
> +}
> +
> +static struct cld_upcall *
> +alloc_cld_upcall(void)
> +{
> +	struct cld_upcall *new, *tmp;
> +
> +	new = kzalloc(sizeof(*new), GFP_KERNEL);
> +	if (!new)
> +		return new;
> +
> +	/* FIXME: hard cap on number in flight? */
> +restart_search:
> +	spin_lock(&cld_lock);
> +	list_for_each_entry(tmp,&cld_list, cu_list) {
> +		if (tmp->cu_msg.cm_xid == cld_xid) {
> +			cld_xid++;
> +			spin_unlock(&cld_lock);
> +			goto restart_search;
> +		}
> +	}
> +	new->cu_task = current;
> +	new->cu_msg.cm_vers = CLD_UPCALL_VERSION;
> +	put_unaligned(cld_xid++,&new->cu_msg.cm_xid);
> +	list_add(&new->cu_list,&cld_list);
> +	spin_unlock(&cld_lock);
> +
> +	dprintk("%s: allocated xid %u\n", __func__, new->cu_msg.cm_xid);
> +
> +	return new;
> +}
> +
> +static void
> +free_cld_upcall(struct cld_upcall *victim)
> +{
> +	spin_lock(&cld_lock);
> +	list_del(&victim->cu_list);
> +	spin_unlock(&cld_lock);
> +	kfree(victim);
> +}
> +
> +/* Ask daemon to create a new record */
> +static void
> +nfsd4_cld_create(struct nfs4_client *clp)
> +{
> +	int ret;
> +	struct cld_upcall *cup;
> +
> +	/* Don't upcall if it's already stored */
> +	if (test_bit(NFSD4_CLIENT_STABLE,&clp->cl_flags))
> +		return;
> +
> +	cup = alloc_cld_upcall();
> +	if (!cup) {
> +		ret = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	cup->cu_msg.cm_cmd = Cld_Create;
> +	cup->cu_msg.cm_u.cm_name.cn_len = clp->cl_name.len;
> +	memcpy(cup->cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
> +			clp->cl_name.len);
> +
> +	ret = cld_pipe_upcall(&cup->cu_msg);
> +	if (!ret) {
> +		ret = cup->cu_msg.cm_status;
> +		set_bit(NFSD4_CLIENT_STABLE,&clp->cl_flags);
> +	}
> +
> +	free_cld_upcall(cup);
> +out_err:
> +	if (ret)
> +		printk(KERN_ERR "NFSD: Unable to create client "
> +				"record on stable storage: %d\n", ret);
> +}
> +
> +/* Ask daemon to create a new record */
> +static void
> +nfsd4_cld_remove(struct nfs4_client *clp)
> +{
> +	int ret;
> +	struct cld_upcall *cup;
> +
> +	/* Don't upcall if it's already removed */
> +	if (!test_bit(NFSD4_CLIENT_STABLE,&clp->cl_flags))
> +		return;
> +
> +	cup = alloc_cld_upcall();
> +	if (!cup) {
> +		ret = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	cup->cu_msg.cm_cmd = Cld_Remove;
> +	cup->cu_msg.cm_u.cm_name.cn_len = clp->cl_name.len;
> +	memcpy(cup->cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
> +			clp->cl_name.len);
> +
> +	ret = cld_pipe_upcall(&cup->cu_msg);
> +	if (!ret) {
> +		ret = cup->cu_msg.cm_status;
> +		clear_bit(NFSD4_CLIENT_STABLE,&clp->cl_flags);
> +	}
> +
> +	free_cld_upcall(cup);
> +out_err:
> +	if (ret)
> +		printk(KERN_ERR "NFSD: Unable to remove client "
> +				"record from stable storage: %d\n", ret);
> +}
> +
> +/* Check for presence of a record, and update its timestamp */
> +static int
> +nfsd4_cld_check(struct nfs4_client *clp)
> +{
> +	int ret;
> +	struct cld_upcall *cup;
> +
> +	/* Don't upcall if one was already stored during this grace pd */
> +	if (test_bit(NFSD4_CLIENT_STABLE,&clp->cl_flags))
> +		return 0;
> +
> +	cup = alloc_cld_upcall();
> +	if (!cup) {
> +		printk(KERN_ERR "NFSD: Unable to check client record on "
> +				"stable storage: %d\n", -ENOMEM);
> +		return -ENOMEM;
> +	}
> +
> +	cup->cu_msg.cm_cmd = Cld_Check;
> +	cup->cu_msg.cm_u.cm_name.cn_len = clp->cl_name.len;
> +	memcpy(cup->cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
> +			clp->cl_name.len);
> +
> +	ret = cld_pipe_upcall(&cup->cu_msg);
> +	if (!ret) {
> +		ret = cup->cu_msg.cm_status;
> +		set_bit(NFSD4_CLIENT_STABLE,&clp->cl_flags);
> +	}
> +
> +	free_cld_upcall(cup);
> +	return ret;
> +}
> +
> +static void
> +nfsd4_cld_grace_done(time_t boot_time)
> +{
> +	int ret;
> +	struct cld_upcall *cup;
> +
> +	cup = alloc_cld_upcall();
> +	if (!cup) {
> +		ret = -ENOMEM;
> +		goto out_err;
> +	}
> +
> +	cup->cu_msg.cm_cmd = Cld_GraceDone;
> +	cup->cu_msg.cm_u.cm_gracetime = (int64_t)boot_time;
> +	ret = cld_pipe_upcall(&cup->cu_msg);
> +	if (!ret)
> +		ret = cup->cu_msg.cm_status;
> +
> +	free_cld_upcall(cup);
> +out_err:
> +	if (ret)
> +		printk(KERN_ERR "NFSD: Unable to end grace period: %d\n", ret);
> +}
> +
> +static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
> +	.init		= nfsd4_init_cld_pipe,
> +	.exit		= nfsd4_remove_cld_pipe,
> +	.create		= nfsd4_cld_create,
> +	.remove		= nfsd4_cld_remove,
> +	.check		= nfsd4_cld_check,
> +	.grace_done	= nfsd4_cld_grace_done,
> +};
> +
>   int
>   nfsd4_client_tracking_init(void)
>   {
>   	int status;
> +	struct path path;
>
> -	client_tracking_ops =&nfsd4_legacy_tracking_ops;
> +	if (!client_tracking_ops) {
> +		client_tracking_ops =&nfsd4_cld_tracking_ops;
> +		status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW,&path);
> +		if (!status) {
> +			if (S_ISDIR(path.dentry->d_inode->i_mode))
> +				client_tracking_ops =
> +						&nfsd4_legacy_tracking_ops;
> +			path_put(&path);
> +		}
> +	}
>
>   	status = client_tracking_ops->init();
>   	if (status) {


-- 
Best regards,
Stanislav Kinsbursky
