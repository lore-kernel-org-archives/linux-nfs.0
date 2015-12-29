Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:41474 "EHLO mx1.molgen.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541AbbL2TvD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Dec 2015 14:51:03 -0500
Subject: Re: [PATCH] NFS: Ensure we revalidate attributes before using
 execute_ok()
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <CAHQdGtTOSw9gDFWo6nwfr=bSo9aXAHVHeRX0XMdeDGkfvzqQjw@mail.gmail.com>
 <1451349629-47744-1-git-send-email-trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
From: Donald Buczek <buczek@molgen.mpg.de>
Message-ID: <5682E424.8070606@molgen.mpg.de>
Date: Tue, 29 Dec 2015 20:51:00 +0100
MIME-Version: 1.0
In-Reply-To: <1451349629-47744-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29.12.2015 01:40, Trond Myklebust wrote:
> Donald Buczek reports that NFS clients can also report incorrect
> results for access() due to lack of revalidation of attributes
> before calling execute_ok().
> Looking closely, it seems chdir() is afflicted with the same problem.
>
> Fix is to ensure we call nfs_revalidate_inode_rcu() or
> nfs_revalidate_inode() as appropriate before deciding to trust
> execute_ok().
>
> Reported-by: Donald Buczek <buczek@molgen.mpg.de>
> Link: http://lkml.kernel.org/r/1451331530-3748-1-git-send-email-buczek@molgen.mpg.de
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>   fs/nfs/dir.c | 18 ++++++++++++++++--
>   1 file changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 44e519c21e18..5bd2f5bfaf57 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2432,6 +2432,20 @@ int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
>   }
>   EXPORT_SYMBOL_GPL(nfs_may_open);
>   
> +static int nfs_execute_ok(struct inode *inode, int mask)
> +{
> +	struct nfs_server *server = NFS_SERVER(inode);
> +	int ret;
> +
> +	if (mask & MAY_NOT_BLOCK)
> +		ret = nfs_revalidate_inode_rcu(server, inode);
> +	else
> +		ret = nfs_revalidate_inode(server, inode);
> +	if (ret == 0 && !execute_ok(inode))
> +		ret = -EACCES;
> +	return ret;
> +}
> +
>   int nfs_permission(struct inode *inode, int mask)
>   {
>   	struct rpc_cred *cred;
> @@ -2484,8 +2498,8 @@ force_lookup:
>   			res = PTR_ERR(cred);
>   	}
>   out:
> -	if (!res && (mask & MAY_EXEC) && !execute_ok(inode))
> -		res = -EACCES;
> +	if (!res && (mask & MAY_EXEC))
> +		res = nfs_execute_ok(inode, mask);
>   
>   	dfprintk(VFS, "NFS: permission(%s/%lu), mask=0x%x, res=%d\n",
>   		inode->i_sb->s_id, inode->i_ino, mask, res);

This patch doesn't resolve the problem. The reason is, that there is a 
nfs_do_access() before this nfs_execute_ok() in the execution path of 
nfs_permission.  While nfs4_proc_acccess doesn't update the mode, it 
does update read_cache_jiffies. So the later nfs_revalidate_inode will 
be a noop, the cache was just made to look fresh.

If nfs_revalidate_inode would be called before the nfs_do_access it 
might work. I fact it would make some sense to move it before the switch 
based on inode->i_mode, because the mode might change on the server, too.

Regards
   Donald

PS: Sorry for my faulty patch! What a shame :(

