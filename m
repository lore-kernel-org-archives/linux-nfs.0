Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60044 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab3CTT1V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 15:27:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: fanchaoting <fanchaoting@cn.fujitsu.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-block: removing DM device maybe cause oops when
 call dev_remove
Date: Wed, 20 Mar 2013 19:27:19 +0000
Message-ID: <1363807637.4790.63.camel@leira.trondhjem.org>
References: <51496CC5.7040400@cn.fujitsu.com>
In-Reply-To: <51496CC5.7040400@cn.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-03-20 at 16:01 +0800, fanchaoting wrote:
> when pnfs block using device mapper,if umounting later,it maybe
> cause oops. we apply "1 + sizeof(bl_umount_request)" memory for
> msg->data, the memory maybe overflow when we do "memcpy(&dataptr
> [sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request))",
> because the size of bl_msg is more than 1 byte.
> 
>    Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
> 
> ---
>  fs/nfs/blocklayout/blocklayoutdm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
> index 737d839..8df9afa 100644
> --- a/fs/nfs/blocklayout/blocklayoutdm.c
> +++ b/fs/nfs/blocklayout/blocklayoutdm.c
> @@ -55,7 +55,7 @@ static void dev_remove(struct net *net, dev_t dev)
> 
>         bl_pipe_msg.bl_wq = &nn->bl_wq;
>         memset(msg, 0, sizeof(*msg));
> -       msg->data = kzalloc(1 + sizeof(bl_umount_request), GFP_NOFS);
> +       msg->data = kzalloc(sizeof(bl_msg) + sizeof(bl_umount_request), GFP_NOFS);
>         if (!msg->data)
>                 goto out;
> 

Why not just move the calculation of msg->len, and then use msg->len in
the above allocation?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
