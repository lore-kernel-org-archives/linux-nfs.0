Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18577 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756239Ab1EKVIr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2011 17:08:47 -0400
Subject: Re: [PATCH] nfs: check a crash in nfs_lookup_revalidate
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Huang <shawn.p.huang@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <1305147805-5756-1-git-send-email-shawn.p.huang@gmail.com>
References: <1305147805-5756-1-git-send-email-shawn.p.huang@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 May 2011 17:08:45 -0400
Message-ID: <1305148125.21868.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-05-11 at 17:03 -0400, Peng Huang wrote:
> lookup_one_len() may call nfs_loopup_revalidate() with nd == NULL
> indirectly, that causes the kernel crash.
> 
> RIP: 0010:[<ffffffffa0ba3b41>]  [<ffffffffa0ba3b41>]
> nfs_lookup_revalidate+0x21/0x4a0 [nfs]
> RSP: 0018:ffff88018f00fae8  EFLAGS: 00010286
> 
> Call Trace:
>  [<ffffffff81164a17>] do_revalidate+0x17/0x60
>  [<ffffffff81164e9b>] __lookup_hash+0xcb/0x140
>  [<ffffffff811653c4>] lookup_one_len+0x94/0xe0
>  [<ffffffff81241ef1>] ecryptfs_lookup+0x91/0x1d0
>  [<ffffffff81164d85>] d_alloc_and_lookup+0x45/0x90
>  [<ffffffff8116f7b5>] ? d_lookup+0x35/0x60
>  [<ffffffff811669b2>] do_lookup+0x192/0x2d0
>  [<ffffffff811763be>] ? vfsmount_lock_local_unlock+0x1e/0x30
>  [<ffffffff8126d09c>] ? security_inode_permission+0x1c/0x30
>  [<ffffffff81167d67>] link_path_walk+0x597/0xae0
>  [<ffffffff8117638e>] ? vfsmount_lock_local_lock+0x1e/0x30
>  [<ffffffff81165905>] ? path_init_rcu+0xa5/0x210
>  [<ffffffff8116858b>] do_path_lookup+0x5b/0x140
>  [<ffffffff811692f7>] user_path_at+0x57/0xa0
>  [<ffffffff8159fd08>] ? do_page_fault+0x1e8/0x4e0
>  [<ffffffff8115eb86>] vfs_fstatat+0x46/0x80
>  [<ffffffff8116b990>] ? filldir+0x0/0xe0
>  [<ffffffff8115ec2e>] vfs_lstat+0x1e/0x20
>  [<ffffffff8115ec54>] sys_newlstat+0x24/0x50
>  [<ffffffff8159c995>] ? page_fault+0x25/0x30
>  [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
> 
> Signed-off-by: Peng Huang <shawn.p.huang@gmail.com>
> ---
>  fs/nfs/dir.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 2c3eb33..9452aa5 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1028,7 +1028,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_fattr *fattr = NULL;
>  	int error;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd != NULL && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	parent = dget_parent(dentry);

That's exactly what Tyler Hicks proposed last week and which was NACKed.
We simply won't support layered filesystems that don't do intents.

IOW: Feel free to change the above to.

if (nd == NULL)
     return -EIO;




-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

