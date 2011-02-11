Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:49119 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751226Ab1BKDtk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 22:49:40 -0500
Subject: Re: vfs-scale, general questions (Re: NFS root lockups with -next
 20110113)
From: Ian Kent <raven@themaw.net>
To: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Cc: Nick Piggin <npiggin@gmail.com>,
        Santosh Shilimkar <santosh.shilimkar@ti.com>,
        Mark Brown <broonie@opensource.wolfsonmicro.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
In-Reply-To: <909.1295419383@jrobl>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com>
	 <8138.1294924927@jrobl> <676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com>
	 <8482.1294926315@jrobl>
	 <AANLkTim=VY7+fo6d_nUXVxs+iZ_f79qWu_eYMUjvhVJO@mail.gmail.com>
	 <909.1295419383@jrobl>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Feb 2011 11:49:29 +0800
Message-ID: <1297396169.3844.11.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-19 at 15:43 +0900, J. R. Okajima wrote:
> Hi,
> 
> Nick Piggin:
> > Thanks for your help, can you see how I've fixed it in my vfs-scale
> > tree? What do you think?
> 
> Your fix is great. I have no objection at all.
> Other than the fix, here are more generic questions about vfs-scale work.
> I am happy if you reply when you have time.
> 
> - getcwd(2) needs d_lock?
>   It acquires rename_lock and then tests whether the pwd is removed by
>   d_unhashed(). If a race condition between vfs_rename_dir() which may
>   unhash/rehash the dentry happens, then getcwd() may return the wrong
>   result due to unprotected d_unhashed() call, I am afraid. rename_lock
>   doesn't help this case.
> 
> - what is the right order of dget() and mntget()?
>   If I remember correctly, someone said "mntget() first and then
>   dget(). when putting, do in reverse" in the discussion when
>   path_{get,put}() were born. So it is called "the right order" in the
>   commit log.
>   It was many years ago. Is it still true? And should rcu-walk follow it
>   too? The current implementation doesn't seem to care about this order.

I didn't spot that, where did you see this?

I'm not sure about the get but I fairly sure the dput() has to be before
the mntput() because the shrink_dcache_*() cleanup routines object to
dentrys that have a reference count of more than one.

Ian


