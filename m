Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752352Ab3HFUG0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 16:06:26 -0400
Message-ID: <52015739.4050702@redhat.com>
Date: Tue, 06 Aug 2013 13:06:17 -0700
From: Anand Avati <avati@redhat.com>
MIME-Version: 1.0
To: Miklos Szeredi <miklos@szeredi.hu>
CC: rwheeler@redhat.com, viro@ZenIV.linux.org.uk, bfoster@redhat.com,
        dhowells@redhat.com, eparis@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com, swhiteho@redhat.com, mszeredi@suse.cz
Subject: Re: [PATCH 4/4] fuse: drop dentry on failed revalidate
References: <1375799403-28544-1-git-send-email-miklos@szeredi.hu> <1375799403-28544-5-git-send-email-miklos@szeredi.hu>
In-Reply-To: <1375799403-28544-5-git-send-email-miklos@szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/6/13 7:30 AM, Miklos Szeredi wrote:
> From: Anand Avati <avati@redhat.com>
>
> Drop a subtree when we find that it has moved or been delated.  This can be
> done as long as there are no submounts under this location.
>
> If the directory was moved and we come across the same directory in a
> future lookup it will be reconnected by d_materialise_unique().
>
> Signed-off-by: Anand Avati <avati@redhat.com>
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
>   fs/fuse/dir.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
> index 131d14b..4ba5893 100644
> --- a/fs/fuse/dir.c
> +++ b/fs/fuse/dir.c
> @@ -226,8 +226,13 @@ static int fuse_dentry_revalidate(struct dentry *entry, unsigned int flags)
>   		if (!err) {
>   			struct fuse_inode *fi = get_fuse_inode(inode);
>   			if (outarg.nodeid != get_node_id(inode)) {
> +				int ret = 0;
> +
> +				if (check_submounts_and_drop(entry) != 0)
> +					ret = 1;
> +
>   				fuse_queue_forget(fc, forget, outarg.nodeid, 1);
> -				return 0;
> +				return ret;

If outarg.nodeid != get_node_id(inode), then we have to return 0 no 
matter what (whether we successfully dropped the entry or not), no? Or 
are you trying to forcefully keep the path to reach the submount alive? 
If so, we still fail in inode_permission() .. -> getattr() of the dir 
inode, no?

Avati

>   			}
>   			spin_lock(&fc->lock);
>   			fi->nlookup++;
>

