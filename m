Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi12.ns.itscom.net ([219.110.2.182]:38116 "EHLO
	mtoichi12.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab1ASGn4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 01:43:56 -0500
From: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Subject: vfs-scale, general questions (Re: NFS root lockups with -next 20110113)
To: Nick Piggin <npiggin@gmail.com>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>,
        Mark Brown <broonie@opensource.wolfsonmicro.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
In-Reply-To: <AANLkTim=VY7+fo6d_nUXVxs+iZ_f79qWu_eYMUjvhVJO@mail.gmail.com>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com> <8138.1294924927@jrobl> <676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com> <8482.1294926315@jrobl> <AANLkTim=VY7+fo6d_nUXVxs+iZ_f79qWu_eYMUjvhVJO@mail.gmail.com>
Date: Wed, 19 Jan 2011 15:43:03 +0900
Message-ID: <909.1295419383@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Hi,

Nick Piggin:
> Thanks for your help, can you see how I've fixed it in my vfs-scale
> tree? What do you think?

Your fix is great. I have no objection at all.
Other than the fix, here are more generic questions about vfs-scale work.
I am happy if you reply when you have time.

- getcwd(2) needs d_lock?
  It acquires rename_lock and then tests whether the pwd is removed by
  d_unhashed(). If a race condition between vfs_rename_dir() which may
  unhash/rehash the dentry happens, then getcwd() may return the wrong
  result due to unprotected d_unhashed() call, I am afraid. rename_lock
  doesn't help this case.

- what is the right order of dget() and mntget()?
  If I remember correctly, someone said "mntget() first and then
  dget(). when putting, do in reverse" in the discussion when
  path_{get,put}() were born. So it is called "the right order" in the
  commit log.
  It was many years ago. Is it still true? And should rcu-walk follow it
  too? The current implementation doesn't seem to care about this order.

- d_move() and rename_lock
  This may be out of rcu-walk work, but rename_lock in d_move() looks
  outstanding since it surely kills concurrency. It is a pity that two
  unrelated but concurrent d_move-s are serialized when we run rename(2)
  on two different filesystems. Even if all of dentries, parents and
  hash buckets are different from each other, d_move() never run
  concurrently.


J. R. Okajima
