From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: RE: NFS root lockups with -next 20110113
Date: Thu, 13 Jan 2011 19:11:42 +0530
Message-ID: <af7e0625d87b3596567f016e2694ffef@mail.gmail.com>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com>
 <8138.1294924927@jrobl> 676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:60698 "EHLO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756707Ab1AMNlq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 08:41:46 -0500
In-Reply-To: 676f5c24375e1cc2aa14fe6630ef1324-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(+ 'linux-arm' since same problem was getting discussed
 in another thread)

> -----Original Message-----
> From: Santosh Shilimkar [mailto:santosh.shilimkar@ti.com]
> Sent: Thursday, January 13, 2011 6:59 PM
> To: 'J. R. Okajima'; 'Mark Brown'
> Cc: 'Trond Myklebust'; 'Nick Piggin'; 'linux-nfs@vger.kernel.org';
> 'linux-kernel@vger.kernel.org'; 'linux-fsdevel@vger.kernel.org'
> Subject: RE: NFS root lockups with -next 20110113
>
> > -----Original Message-----
> > From: J. R. Okajima [mailto:hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org]
> > Sent: Thursday, January 13, 2011 6:52 PM
> > To: Mark Brown
> > Cc: Trond Myklebust; Santosh Shilimkar; Nick Piggin; linux-
> > nfs@vger.kernel.org; linux-kernel@vger.kernel.org; linux-
> > fsdevel@vger.kernel.org
> > Subject: Re: NFS root lockups with -next 20110113
> >
> >
> > Mark Brown:
> > > With -next 20110113 I'm experiencing lockups shortly after
> > userspace
> > > starts when booting with my root filesystem on NFS, log below.
> I
> > can
> > > boot into /bin/sh but running real userspace triggers this very
> > easily.
> > > This was introduced sometime this week.
> > >
> > > I've not bisected or otherwise investigated much yet, but I do
> > notice
> > > code added recently by Nick in "fs: rcu-walk for path lookup"
> > showing up
> > > in the backtrace so including him in the CCs.
> >
> > This and a report from Santosh Shilimkar look like the same
> problem
> > which I reported, and I am testing this patch. If you can, please
> > try it
> > too.
> > Note: Of course this is not offcial fix.
> >
>
> It works. My board booted with NFS with below patch
>
>
> >
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 5bb7588..51d052f 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -480,6 +480,7 @@ static int nameidata_dentry_drop_rcu(struct
> > nameidata *nd, struct dentry *dentry
> >  {
> >  	struct fs_struct *fs = current->fs;
> >  	struct dentry *parent = nd->path.dentry;
> > +	int isroot;
> >
> >  	BUG_ON(!(nd->flags & LOOKUP_RCU));
> >  	if (nd->root.mnt) {
> > @@ -489,18 +490,22 @@ static int nameidata_dentry_drop_rcu(struct
> > nameidata *nd, struct dentry *dentry
> >  			goto err_root;
> >  	}
> >  	spin_lock(&parent->d_lock);
> > -	spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
> > -	if (!__d_rcu_to_refcount(dentry, nd->seq))
> > -		goto err;
> > +	isroot = IS_ROOT(dentry);
> > +	if (!isroot) {
> > +		spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
> > +		if (!__d_rcu_to_refcount(dentry, nd->seq))
> > +			goto err;
> > +	}
> >  	/*
> >  	 * If the sequence check on the child dentry passed, then the
> > child has
> >  	 * not been removed from its parent. This means the parent
> > dentry must
> >  	 * be valid and able to take a reference at this point.
> >  	 */
> > -	BUG_ON(!IS_ROOT(dentry) && dentry->d_parent != parent);
> > +	BUG_ON(!isroot && dentry->d_parent != parent);
> >  	BUG_ON(!parent->d_count);
> >  	parent->d_count++;
> > -	spin_unlock(&dentry->d_lock);
> > +	if (!isroot)
> > +		spin_unlock(&dentry->d_lock);
> >  	spin_unlock(&parent->d_lock);
> >  	if (nd->root.mnt) {
> >  		path_get(&nd->root);
> > @@ -513,7 +518,8 @@ static int nameidata_dentry_drop_rcu(struct
> > nameidata *nd, struct dentry *dentry
> >  	nd->flags &= ~LOOKUP_RCU;
> >  	return 0;
> >  err:
> > -	spin_unlock(&dentry->d_lock);
> > +	if (!isroot)
> > +		spin_unlock(&dentry->d_lock);
> >  	spin_unlock(&parent->d_lock);
> >  err_root:
> >  	if (nd->root.mnt)
