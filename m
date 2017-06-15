Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37042 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdFOKOn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 06:14:43 -0400
Date: Thu, 15 Jun 2017 11:14:42 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 16/27] proc: Add fs_context support to procfs [ver #5]
Message-ID: <20170615101441.GI31671@ZenIV.linux.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745346349.10897.1390410969617844911.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149745346349.10897.1390410969617844911.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 04:17:43PM +0100, David Howells wrote:

>  int pid_ns_prepare_proc(struct pid_namespace *ns)
>  {
> +	struct proc_fs_context *ctx;
> +	struct fs_context *fc;
>  	struct vfsmount *mnt;
> +	int ret;
> +
> +	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0, FS_CONTEXT_FOR_NEW);
> +	if (IS_ERR(fc))
> +		return PTR_ERR(fc);
> +
> +	ctx = container_of(fc, struct proc_fs_context, fc);
> +	if (ctx->pid_ns != ns) {
> +		put_pid_ns(ctx->pid_ns);
> +		get_pid_ns(ns);
> +		ctx->pid_ns = ns;
> +	}
> +
> +	ret = vfs_get_tree(fc);
> +	if (ret < 0) {
> +		put_fs_context(fc);
> +		return ret;
> +	}
>  
> -	mnt = kern_mount_data(&proc_fs_type, ns);
> +	mnt = kern_mount_data_fc(fc);
> +	put_fs_context(fc);

Same as with ipc; do you need to go through dynamic allocation,
container_of, patching it up, etc.?
