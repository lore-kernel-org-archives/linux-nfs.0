Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:32823 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbcD3Oni (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 10:43:38 -0400
Received: by mail-qg0-f43.google.com with SMTP id f92so53737190qgf.0
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 07:43:37 -0700 (PDT)
Message-ID: <1462027414.10011.31.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sat, 30 Apr 2016 10:43:34 -0400
In-Reply-To: <20160430142232.GA25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
	 <1461501975.5219.40.camel@poochiereds.net>
	 <20160424191835.GL25498@ZenIV.linux.org.uk>
	 <20160429075812.GY25498@ZenIV.linux.org.uk>
	 <1462022142.10011.19.camel@poochiereds.net>
	 <1462022576.10011.22.camel@poochiereds.net>
	 <20160430142232.GA25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-04-30 at 15:22 +0100, Al Viro wrote:
> On Sat, Apr 30, 2016 at 09:22:56AM -0400, Jeff Layton wrote:
> > 
> > ...but looks like same problem:
> > 
> > (gdb) list *(__kmalloc_track_caller+0x96)
> > 0xffffffff811f9a06 is in __kmalloc_track_caller (mm/slub.c:245).
> > 240      *                      Core slab cache functions
> > 241      *******************************************************************/
> > 242
> > 243     static inline void *get_freepointer(struct kmem_cache *s, void *object)
> > 244     {
> > 245             return *(void **)(object + s->offset);
> > 246     }
> > 247
> > 248     static void prefetch_freepointer(const struct kmem_cache *s, void *object)
> > 249     {
> Joy...  Does that happen without the last commit as well?  I realize that
> memory corruption could well have been introduced earlier and changes in
> the last commit had only increased the odds, but...


Not exactly, but the test seems to have deadlocked without the last
patch in play. Here's the ls command:

[jlayton@rawhide ~]$ cat /proc/1425/stack
[<ffffffffa03d6eec>] nfs_block_sillyrename+0x5c/0xa0 [nfs]
[<ffffffffa03c8ef8>] nfs_readdir+0xf8/0x620 [nfs]
[<ffffffff812232bb>] iterate_dir+0x16b/0x1a0
[<ffffffff812236e8>] SyS_getdents+0x88/0x100
[<ffffffff81003cb2>] do_syscall_64+0x62/0x110
[<ffffffff8174ae21>] return_from_SYSCALL_64+0x0/0x6a
[<ffffffffffffffff>] 0xffffffffffffffff

...and here is the nfsidem command:

[jlayton@rawhide ~]$ cat /proc/1295/stack
[<ffffffff813953b7>] call_rwsem_down_write_failed+0x17/0x30
[<ffffffff8121f65b>] filename_create+0x6b/0x150
[<ffffffff812204e4>] SyS_mkdir+0x44/0xe0
[<ffffffff81003cb2>] do_syscall_64+0x62/0x110
[<ffffffff8174ae21>] return_from_SYSCALL_64+0x0/0x6a
[<ffffffffffffffff>] 0xffffffffffffffff


I'll have to take off here in a bit so I won't be able to help much
until later, but all I was doing was running the cthon special tests
like so:

    $ ./server -p /export -s -N 100 tlielax

That makes a directory called "rawhide.test" (since the client's
hostname is "rawhide") and runs its tests in there. Then I ran this in
a different shell:

    $ while true; do ls -l /mnt/tlielax/rawhide.test ; done

Probably I should run this on a stock kernel just to see if there are
preexisting problems...

-- 
Jeff Layton <jlayton@poochiereds.net>
