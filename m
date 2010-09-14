Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33768 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab0INNCJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 09:02:09 -0400
Subject: Re: [RFC][PATCH] rpc_pipe_msg should be protected by inode->i_lock
 when purge it.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C8F3971.1050306@cn.fujitsu.com>
References: <4C8F3971.1050306@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 14 Sep 2010 08:58:59 -0400
Message-ID: <1284469139.10782.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-14 at 16:59 +0800, Bian Naimeng wrote:
> Maybe rpc_pipe_msg should be protected by inode->i_lock when purge the free_list.
> 
> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> 
> ---
>  net/sunrpc/rpc_pipe.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 8d63f8f..24b2714 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -47,8 +47,10 @@ static void rpc_purge_list(struct rpc_inode *rpci, struct list_head *head,
>  		return;
>  	do {
>  		msg = list_entry(head->next, struct rpc_pipe_msg, list);
> +		spin_lock(&rpci->vfs_inode->i_lock);
>  		list_del(&msg->list);
>  		msg->errno = err;
> +		spin_unlock(&rpci->vfs_inode->i_lock);
>  		destroy_msg(msg);
>  	} while (!list_empty(head));
>  	wake_up(&rpci->waitq);
> -- 
> 1.6.5.2
> 
> 
> 

No, we don't need to protect the list 'head'.

Trond
