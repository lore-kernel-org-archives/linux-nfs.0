Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:65016 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab3LJQ0R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 11:26:17 -0500
Received: by mail-ee0-f46.google.com with SMTP id d49so2299087eek.5
        for <linux-nfs@vger.kernel.org>; Tue, 10 Dec 2013 08:26:13 -0800 (PST)
Message-ID: <1386692771.2879.2.camel@leira.trondhjem.org>
Subject: Re: [PATCH 2/2] nfs: fix return err if inode exiting in
 nfs_instantiate
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Rui Xiang <rui.xiang@huawei.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 10 Dec 2013 18:26:11 +0200
In-Reply-To: <52A59EAB.20200@huawei.com>
References: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
	 <1386322217-27436-2-git-send-email-rui.xiang@huawei.com>
	 <E04FAC94-F109-4F37-8077-A39F3C386899@primarydata.com>
	 <52A59EAB.20200@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-12-09 at 18:42 +0800, Rui Xiang wrote:
> On 2013/12/6 21:46, Trond Myklebust wrote:
> > 
> > On Dec 6, 2013, at 4:30, Rui Xiang <rui.xiang@huawei.com> wrote:
> > 
> >> In common function nfs_instantiate to create, mkdir, and mknod,
> >> if dentry->d_inode exits, it should return -EEXIST instead of
> >> -EACCES.
> >>
> >> Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
> >> ---
> >> fs/nfs/dir.c | 2 +-
> >> 1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> >> index 2518865..e570b37 100644
> >> --- a/fs/nfs/dir.c
> >> +++ b/fs/nfs/dir.c
> >> @@ -1547,7 +1547,7 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
> >> 	struct dentry *parent = dget_parent(dentry);
> >> 	struct inode *dir = parent->d_inode;
> >> 	struct inode *inode;
> >> -	int error = -EACCES;
> >> +	int error = -EEXIST;
> >>
> >> 	d_drop(dentry);
> >>
> > 
> > That looks like it should rather be a WARN_ON(). If the caller has set the dentry's inode before creating the file, then something is really wrong.
> It can return -EEXIST to say that the file already exits, then will exit. But why does it need a WARN_ON(). Please give me some advise.
> 

If we ever hit that condition then it means that the caller is doing
something very wrong. That's what the WARN_ON (or WARN_ON_ONCE) would be
there to check.

Cheers
  Trond

