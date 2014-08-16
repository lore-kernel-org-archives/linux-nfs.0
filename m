Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:42755 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaHPR46 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Aug 2014 13:56:58 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so3336110wgh.21
        for <linux-nfs@vger.kernel.org>; Sat, 16 Aug 2014 10:56:57 -0700 (PDT)
Date: Sat, 16 Aug 2014 20:56:53 +0300
From: Dan Aloni <dan@kernelim.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] nfs: fix kernel warning when removing proc entry
Message-ID: <20140816175653.GA3884@gmail.com>
References: <1408056579-25255-1-git-send-email-xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408056579-25255-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 14, 2014 at 03:49:39PM -0700, Cong Wang wrote:
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  fs/nfs/client.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 1c5ff6d..1c57202 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1429,7 +1429,7 @@ void nfs_fs_proc_net_exit(struct net *net)
>  
>  	remove_proc_entry("volumes", nn->proc_nfsfs);
>  	remove_proc_entry("servers", nn->proc_nfsfs);
> -	remove_proc_entry("fs/nfsfs", NULL);
> +	remove_proc_entry("nfsfs", net->proc_net);
>  }

nfs_fs_proc_net_init() has:

error_1:
        remove_proc_entry("fs/nfsfs", NULL);

I think this needs fixing too, for consistency.

-- 
Dan Aloni
