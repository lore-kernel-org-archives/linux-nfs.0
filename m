Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi11.ns.itscom.net ([219.110.2.181]:48871 "EHLO
	mtoichi11.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab1BMCTp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Feb 2011 21:19:45 -0500
From: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Subject: Re: vfs-scale, general questions (Re: NFS root lockups with -next 20110113)
To: Ian Kent <raven@themaw.net>
Cc: Nick Piggin <npiggin@gmail.com>,
        Santosh Shilimkar <santosh.shilimkar@ti.com>,
        Mark Brown <broonie@opensource.wolfsonmicro.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
In-Reply-To: <1297396169.3844.11.camel@perseus>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com> <8138.1294924927@jrobl> <676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com> <8482.1294926315@jrobl> <AANLkTim=VY7+fo6d_nUXVxs+iZ_f79qWu_eYMUjvhVJO@mail.gmail.com> <909.1295419383@jrobl> <1297396169.3844.11.camel@perseus>
Content-Type: text/plain; charset=us-ascii
Date: Sun, 13 Feb 2011 11:19:22 +0900
Message-ID: <7070.1297563562@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Ian Kent:
> > - what is the right order of dget() and mntget()?
> >   If I remember correctly, someone said "mntget() first and then
> >   dget(). when putting, do in reverse" in the discussion when
> >   path_{get,put}() were born. So it is called "the right order" in the
> >   commit log.
> >   It was many years ago. Is it still true? And should rcu-walk follow it
> >   too? The current implementation doesn't seem to care about this order.
>
> I didn't spot that, where did you see this?
>
> I'm not sure about the get but I fairly sure the dput() has to be before
> the mntput() because the shrink_dcache_*() cleanup routines object to
> dentrys that have a reference count of more than one.

For dget - mntget, there are several such code. For example,
nameidata_dentry_drop_rcu()
{
	struct dentry *parent = nd->path.dentry;
		:::
	parent->d_count++;
	spin_unlock(&dentry->d_lock);
	spin_unlock(&parent->d_lock);
		:::
	mntget(nd->path.mnt);
		:::

But I am not sure the "get" order is a problem.
Nick Piggin also replied and said dget and mntget is not a problem, and
I replied if I found such "put" order, I would write again.


J. R. Okajima
