Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f54.google.com ([74.125.83.54]:35282 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219Ab3LJQYt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Dec 2013 11:24:49 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so2290834eek.27
        for <linux-nfs@vger.kernel.org>; Tue, 10 Dec 2013 08:24:48 -0800 (PST)
Message-ID: <1386692682.2879.0.camel@leira.trondhjem.org>
Subject: Re: [PATCH 1/2] nfs/nfsd: return err directly while malloc failing
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Rui Xiang <rui.xiang@huawei.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 10 Dec 2013 18:24:42 +0200
In-Reply-To: <52A5B894.8020209@huawei.com>
References: <1386322217-27436-1-git-send-email-rui.xiang@huawei.com>
	 <52A5B894.8020209@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-12-09 at 20:33 +0800, Rui Xiang wrote:
> On 2013/12/6 17:30, Rui Xiang wrote:
> > while nthreads malloc fails, return err value directory
> > without kfree.
> > 
> > And the same issue arises in nfs_lookup, so return res
> > directly without freeing fh and fattr.
> > 
> > Signed-off-by: Rui Xiang <rui.xiang@huawei.com>
> > ---
> >  fs/nfs/dir.c     | 4 ++--
> >  fs/nfsd/nfsctl.c | 7 ++++---
> >  2 files changed, 6 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 812154a..2518865 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1278,7 +1278,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
> >  
> >  	res = ERR_PTR(-ENAMETOOLONG);
> >  	if (dentry->d_name.len > NFS_SERVER(dir)->namelen)
> > -		goto out;
> > +		return res;
> >  
> >  	/*
> >  	 * If we're doing an exclusive create, optimize away the lookup
> > @@ -1287,7 +1287,7 @@ struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, unsigned in
> >  	if (nfs_is_exclusive_create(dir, flags)) {
> >  		d_instantiate(dentry, NULL);
> >  		res = NULL;
> > -		goto out;
> > +		return res;
> >  	}
> >  
> >  	res = ERR_PTR(-ENOMEM);
> Trond,  and what's your opinion on the chunk above?

It's a minor optimisation but certainly not something that needs to be
pushed in before the next merge window.

Cheers
  Trond

