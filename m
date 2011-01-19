Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58488 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300Ab1ASHVb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 02:21:31 -0500
In-Reply-To: <909.1295419383@jrobl>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com>
	<8138.1294924927@jrobl>
	<676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com>
	<8482.1294926315@jrobl>
	<AANLkTim=VY7+fo6d_nUXVxs+iZ_f79qWu_eYMUjvhVJO@mail.gmail.com>
	<909.1295419383@jrobl>
Date: Wed, 19 Jan 2011 18:21:29 +1100
Message-ID: <AANLkTi=CqLm=33acFV42N8VbNK9=hwXV9iegKn-jjGJS@mail.gmail.com>
Subject: Re: vfs-scale, general questions (Re: NFS root lockups with -next 20110113)
From: Nick Piggin <npiggin@gmail.com>
To: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>,
        Mark Brown <broonie@opensource.wolfsonmicro.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 19, 2011 at 5:43 PM, J. R. Okajima <hooanon05@yahoo.co.jp> wrote:
>
> Hi,
>
> Nick Piggin:
>> Thanks for your help, can you see how I've fixed it in my vfs-scale
>> tree? What do you think?
>
> Your fix is great. I have no objection at all.
> Other than the fix, here are more generic questions about vfs-scale work.
> I am happy if you reply when you have time.

Thanks for reviewing.


> - getcwd(2) needs d_lock?
>  It acquires rename_lock and then tests whether the pwd is removed by
>  d_unhashed(). If a race condition between vfs_rename_dir() which may
>  unhash/rehash the dentry happens, then getcwd() may return the wrong
>  result due to unprotected d_unhashed() call, I am afraid. rename_lock
>  doesn't help this case.

We have the lock in write mode there, so it should exclude that
particular race. But I need to take another look at this code I
think, I'm not sure it's completely right, so I would appreciate reviews.

A while back I had some extra checks in there and would restart
the entire reverse walk in case of races... but need to think about
it.


> - what is the right order of dget() and mntget()?
>  If I remember correctly, someone said "mntget() first and then
>  dget(). when putting, do in reverse" in the discussion when
>  path_{get,put}() were born. So it is called "the right order" in the
>  commit log.
>  It was many years ago. Is it still true? And should rcu-walk follow it
>  too? The current implementation doesn't seem to care about this order.

Well dget and mntget is not a problem, because we can only do
mntget while already guaranteeing a reference on the mount, and
only dget when already guaranteeing a ref on the dentry (and mount).

But dput must happen before mntput so you don't have dentry ref
without mnt ref. Can you point out where rcu-walk does this wrongly?


> - d_move() and rename_lock
>  This may be out of rcu-walk work, but rename_lock in d_move() looks
>  outstanding since it surely kills concurrency. It is a pity that two
>  unrelated but concurrent d_move-s are serialized when we run rename(2)
>  on two different filesystems. Even if all of dentries, parents and
>  hash buckets are different from each other, d_move() never run
>  concurrently.

Yes I have a patch for that. I made a small hash table of rename locks.
This makes independent same-dir renames scalable. However that was
not the main motivation of the patch. On a really big POWER7 system,
the lookup path goes into a strange bimodal behaviour in the presence
of a relatively small amount of rename activity and sometimes starves
and throughput crashes. Breaking up rename_lock solves that too.

I'll wait until things settle down a bit more and perhaps have a chance
to get more numbers before submitting it (although I can show you when
I get back).

Thanks,
Nick
