Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:36334 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751609Ab3KCAqz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 20:46:55 -0400
Message-ID: <52759CFD.5070804@davequigley.com>
Date: Sat, 02 Nov 2013 20:46:53 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, trond.myklebust@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: set security label when revalidating inode
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/2/2013 6:57 AM, Jeff Layton wrote:
> Currently, we fetch the security label when revalidating an inode's
> attributes, but don't apply it. This is in contrast to the readdir()
> codepath where we do apply label changes.
>
> Cc: Dave Quigley <dpquigl@davequigley.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>   fs/nfs/inode.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 4bc7538..6ae6160 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -923,6 +923,8 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
>   	if (nfsi->cache_validity & NFS_INO_INVALID_ACL)
>   		nfs_zap_acl_cache(inode);
>
> +	nfs_setsecurity(inode, fattr, label);
> +
>   	dfprintk(PAGECACHE, "NFS: (%s/%Ld) revalidation complete\n",
>   		inode->i_sb->s_id,
>   		(long long)NFS_FILEID(inode));
>


I'm pretty sure (almost 100000%) that this was originally in the patch 
set and it got lost somewhere. So You have an ACK from me on it.

Dave
