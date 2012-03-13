Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:36140 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758657Ab2CMR0T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 13:26:19 -0400
Message-ID: <4F5F8324.30608@parallels.com>
Date: Tue, 13 Mar 2012 21:25:56 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        Weston Andros Adamson <dros@netapp.com>, Peng Tao <peng_tao@emc.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [patch] NFS: null dereference in dev_remove()
References: <20120313171848.GA31808@elgon.mountain>
In-Reply-To: <20120313171848.GA31808@elgon.mountain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

13.03.2012 21:18, Dan Carpenter пишет:
> In commit 5ffaf85541 "NFS: replace global bl_wq with per-net one" we
> made "msg" a pointer instead of a struct stored in stack memory.  But we
> forgot to change the memset() here so we're still clearing stack memory
> instead clearing the struct like we intended.  It will lead to a kernel
> crash.
>
> Signed-off-by: Dan Carpenter<dan.carpenter@oracle.com>
>
> diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
> index 30fc22a..737d839 100644
> --- a/fs/nfs/blocklayout/blocklayoutdm.c
> +++ b/fs/nfs/blocklayout/blocklayoutdm.c
> @@ -54,7 +54,7 @@ static void dev_remove(struct net *net, dev_t dev)
>   	dprintk("Entering %s\n", __func__);
>
>   	bl_pipe_msg.bl_wq =&nn->bl_wq;
> -	memset(&msg, 0, sizeof(*msg));
> +	memset(msg, 0, sizeof(*msg));
>   	msg->data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
>   	if (!msg->data)
>   		goto out;

Thanks, Dan!

-- 
Best regards,
Stanislav Kinsbursky
