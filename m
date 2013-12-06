Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:56122 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161800Ab3LFNqZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 08:46:25 -0500
Received: by mail-ie0-f172.google.com with SMTP id qd12so1217198ieb.3
        for <linux-nfs@vger.kernel.org>; Fri, 06 Dec 2013 05:46:25 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: [PATCH 2/2] nfs: fix return err if inode exiting in nfs_instantiate
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1386322217-27436-2-git-send-email-rui.xiang@huawei.com>
Date: Fri, 6 Dec 2013 08:46:23 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E04FAC94-F109-4F37-8077-A39F3C386899@primarydata.com>
References: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com> <1386322217-27436-2-git-send-email-rui.xiang@huawei.com>
To: Rui Xiang <rui.xiang@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 6, 2013, at 4:30, Rui Xiang <rui.xiang@huawei.com> wrote:

> In common function nfs_instantiate to create, mkdir, and mknod,
> if dentry->d_inode exits, it should return -EEXIST instead of
> -EACCES.
> 
> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
> ---
> fs/nfs/dir.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 2518865..e570b37 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1547,7 +1547,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
> 	struct dentry *parent = dget_parent(dentry);
> 	struct inode *dir = parent->d_inode;
> 	struct inode *inode;
> -	int error = -EACCES;
> +	int error = -EEXIST;
> 
> 	d_drop(sentry);
> 

That looks like it should rather be a WARN_ON(). If the caller has set the dentry's inode before creating the file, then something is really wrong.

Cheers
  Trond