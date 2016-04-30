Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34646 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbcD3S6l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 14:58:41 -0400
Date: Sat, 30 Apr 2016 19:58:36 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160430185836.GC25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
 <1461501975.5219.40.camel@poochiereds.net>
 <20160424191835.GL25498@ZenIV.linux.org.uk>
 <20160429075812.GY25498@ZenIV.linux.org.uk>
 <1462022142.10011.19.camel@poochiereds.net>
 <1462022576.10011.22.camel@poochiereds.net>
 <20160430142232.GA25498@ZenIV.linux.org.uk>
 <1462027414.10011.31.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1462027414.10011.31.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 30, 2016 at 10:43:34AM -0400, Jeff Layton wrote:

> Not exactly, but the test seems to have deadlocked without the last
> patch in play. Here's the ls command:
> 
> [jlayton@rawhide ~]$ cat /proc/1425/stack
> [<ffffffffa03d6eec>] nfs_block_sillyrename+0x5c/0xa0 [nfs]
> [<ffffffffa03c8ef8>] nfs_readdir+0xf8/0x620 [nfs]
> [<ffffffff812232bb>] iterate_dir+0x16b/0x1a0
> [<ffffffff812236e8>] SyS_getdents+0x88/0x100
> [<ffffffff81003cb2>] do_syscall_64+0x62/0x110
> [<ffffffff8174ae21>] return_from_SYSCALL_64+0x0/0x6a
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> ...and here is the nfsidem command:
> 
> [jlayton@rawhide ~]$ cat /proc/1295/stack
> [<ffffffff813953b7>] call_rwsem_down_write_failed+0x17/0x30
> [<ffffffff8121f65b>] filename_create+0x6b/0x150
> [<ffffffff812204e4>] SyS_mkdir+0x44/0xe0
> [<ffffffff81003cb2>] do_syscall_64+0x62/0x110
> [<ffffffff8174ae21>] return_from_SYSCALL_64+0x0/0x6a
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> 
> I'll have to take off here in a bit so I won't be able to help much
> until later, but all I was doing was running the cthon special tests
> like so:
> 
>     $ ./server -p /export -s -N 100 tlielax
> 
> That makes a directory called "rawhide.test" (since the client's
> hostname is "rawhide") and runs its tests in there. Then I ran this in
> a different shell:
> 
>     $ while true; do ls -l /mnt/tlielax/rawhide.test ; done
> 
> Probably I should run this on a stock kernel just to see if there are
> preexisting problems...

FWIW, I could reproduce that (and I really wonder WTF is going on - looks
like nfs_async_unlink_release() getting lost somehow), but not the memory
corruption with the last commit...  What .config are you using?
