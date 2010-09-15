Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab0IONhZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:37:25 -0400
Date: Wed, 15 Sep 2010 09:37:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 8/8] nfs: make sillyrename an async operation
Message-ID: <20100915093721.45ed71b3@corrin.poochiereds.net>
In-Reply-To: <1284557041-4375-9-git-send-email-jlayton@redhat.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
	<1284557041-4375-9-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 15 Sep 2010 09:24:01 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> +/**
> + * nfs_async_rename - perform an asynchronous rename operation
> + * @old_dir: directory that currently holds the dentry to be renamed
> + * @new_dir: target directory for the rename
> + * @old_dentry: original dentry to be renamed
> + * @new_dentry: dentry to which the old_dentry should be renamed
> + */
> +static struct rpc_task *
> +nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
> +		 struct dentry *old_dentry, struct dentry *new_dentry)
> +{
> +	int error;
> +	struct nfs_renamedata *data;
> +	struct rpc_message msg = { };
> +	struct rpc_task_setup task_setup_data = {
> +		.rpc_message = &msg,
> +		.callback_ops = &nfs_rename_ops,
> +		.workqueue = nfsiod_workqueue,
> +		.rpc_client = NFS_CLIENT(old_dir),
> +		.flags = RPC_TASK_ASYNC,
> +	};
> +	struct rpc_task *task;
> +
> +	data = kzalloc(sizeof(*data), GFP_KERNEL);
> +	if (data == NULL)
> +		return ERR_PTR(-ENOMEM);
> +	task_setup_data.callback_data = data,
> +
> +	data->cred = rpc_lookup_cred();
> +	if (IS_ERR(data->cred)) {
> +		kfree(data);
> +		return (struct rpc_task *)data->cred;
> +	}
> +	msg.rpc_argp = &data->args,
> +	msg.rpc_resp = &data->res,
				^^^
Eek! Just noticed the commas at the EOL in this patch. Not quite sure
how this compiled, but I'll fix, retest and resend. Review of the rest
of the patch would be appreciated though.

-- 
Jeff Layton <jlayton@redhat.com>
