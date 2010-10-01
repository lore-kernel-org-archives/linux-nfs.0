Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59331 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029Ab0JAF6A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 01:58:00 -0400
Subject: Re: Odd NFS related SIGBUS (& possible fix)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Nick Piggin <npiggin@kernel.dk>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <1285734825.14081.87.camel@pasglop>
References: <1285734825.14081.87.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 01 Oct 2010 15:57:47 +1000
Message-ID: <1285912667.2463.68.camel@pasglop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-29 at 14:33 +1000, Benjamin Herrenschmidt wrote:
> Hi Nick, Trond !

(adding linux-nfs list and some more data)

> Now regarding the other bug, unless Trond has an idea already, I think I'll start
> a separate email thread once I've collected more data. I -think- it invalidates it
> because it sees a the server mtime that is more recent than the inode, but the
> server shouldn't be touching at files, so I suspect we get confused somewhere in
> the kernel and I don't know why yet (the code path inside NFS aren't obvious to
> me at this stage).

Now that one is hell...

So it seems to be that depending on the kernel and the machine, it
varies between

 - Fails often
 - Fails sometimes
 - Doesn't fail
 - Test crashes the kernel

Basically, "fails" here means I see the sigbus when running the test
case (I'll write details down below for those who didn't follow), so far
on Power7.

So from what I can tell, Trond's patch acdc53b2... (Replace
__nfs_write_mapping with sync_inode()) causes the problem to go from
"fails often" to "fails sometimes".

So for some reason, we seem to be taking a lot less of invalidations
from the server, and thus hitting that race I think I found (see
previous email) a lot less often. Whether the remaining invalidations
are "legit" or themselves the sign of something wrong, I don't know for
sure.

(Reminder: On 2.6.32.16, where we initially experienced the problem, I
found out that we get a -lot- of invalidations coming due to server
mtime being more recent than the local mtime, which is very very odd
considering that the local machine is the only one to ever modify the
files)

Now, I haven't managed to reproduce the failure on 2.6.34 with an x86_64
24 way machine.

Note: On that machine, kernel is whatever's in debian, unfortunately
this isn't a crashbox, I'm looking at getting an x86_64 one to test
other kernels as we speak.

However, that machine exhibit a different problem which is while running
the test case, ctrl-C doesn't work ... ctrl-Z does tho and you can then
kill it, very odd.

If I try current Linus upstream as of today on the Power7 box, I
experience something slightly similar... some echo happens when I
ctrl-C ... and the entire machine locks up. If I use an nmi to get a
stack dump of all processors, I observe 63 of them idle and one there:

[c0000000114cb5b0] c0000000001548c0 .page_mkclean+0x238/0x2c4
[c0000000114cb6f0] c00000000012e468 .clear_page_dirty_for_io+0xa0/0x1a8
[c0000000114cb780] c0000000002f30f4 .nfs_wb_page+0x90/0x100
[c0000000114cb860] c0000000002f3890 .nfs_flush_incompatible+0xc0/0xf0
[c0000000114cb900] c0000000002dff00 .nfs_vm_page_mkwrite+0x170/0x1a4
[c0000000114cb9a0] c000000000146e0c .do_wp_page+0x294/0x9a0
[c0000000114cbaa0] c000000000148468 .handle_mm_fault+0x9b8/0xa78
[c0000000114cbb90] c0000000006b1aac .do_page_fault+0x428/0x6ac
[c0000000114cbe30] c0000000000051e0 handle_page_fault+0x20/0x74

(roughly, I don't think it stays in page_mkclean, I -think- I've seen it
up one level but I'm not 100% sure, most of the time it's somewhere in
there tho).

The machine stops making fwd progress and doesn't echo on the console
anymore.

I actually just reproduced the lockup on x86_64 with 4 CPUs using
mmapstress01 -p 5 -t 1.3 -f 4096.

So the trick is to mount /tmp over nfs (so that the mmap'ed file ends up
on nfs) and run mmapstress01 as above. Then try ctrl-C it.

I'll do a bz for that one.

I'm now going to try going back kernel versions to see if I can also
reproduce the SIGBUS or other timing issues.

Cheers,
Ben.


