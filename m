From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: A unresponsive file system can hang all I/O in the system on
 linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Thu, 27 Sep 2007 23:50:34 -0700
Message-ID: <20070927235034.ae7bd73d.akpm@linux-foundation.org>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: "Chakri n" <chakriin5@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760438AbXI1Guz@vger.kernel.org>
In-Reply-To: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 27 Sep 2007 23:32:36 -0700 "Chakri n" <chakriin5@gmail.com> wrote:

> Hi,
> 
> In my testing, a unresponsive file system can hang all I/O in the system.
> This is not seen in 2.4.
> 
> I started 20 threads doing I/O on a NFS share. They are just doing 4K
> writes in a loop.
> 
> Now I stop NFS server hosting the NFS share and start a
> "dd" process to write a file on local EXT3 file system.
> 
> # dd if=/dev/zero of=/tmp/x count=1000
> 
> This process never progresses.

yup.

> There is plenty of HIGH MEMORY available in the system, but this
> process never progresses.
> 
> ...
> 
> The problem seems to be in balance_dirty_pages, which calculates
> dirty_thresh based on only ZONE_NORMAL. The same scenario works fine
> in 2.4. The dd processes finishes in no time.
> NFS file systems can go offline, due to multiple reasons, a failed
> switch, filer etc, but that should not effect other file systems in
> the machine.
> Can this behavior be fenced?, can the buffer cache be tuned so that
> other processes do not see the effect?

It's unrelated to the actual value of dirty_thresh: if the machine fills up
with dirty (or unstable) NFS pages then eventually new writers will block
until that condition clears.

2.4 doesn't have this problem at low levels of dirty data because 2.4
VFS/MM doesn't account for NFS pages at all.

I'm not sure what we can do about this from a design perspective, really. 
We have data floating about in memory which we're not allowed to discard
and if we allow it to increase without bound it will eventually either
wedge userspace _anyway_ or it will take the machine down, resulting in
data loss.

What it would be nice to do would be to write that data to local disk if
poss, then reclaim it.  Perhaps David Howells' fscache code can do that (or
could be tweaked to do so).

If you really want to fill all memory with pages whic are dirty against a
dead NFS server then you can manually increase
/proc/sys/vm/dirty_background_ratio and dirty_ratio - that should give you
the 2.4 behaviour.


<thinks>

Actually we perhaps could address this at the VFS level in another way. 
Processes which are writing to the dead NFS server will eventually block in
balance_dirty_pages() once they've exceeded the memory limits and will
remain blocked until the server wakes up - that's the behaviour we want.

What we _don't_ want to happen is for other processes which are writing to
other, non-dead devices to get collaterally blocked.  We have patches which
might fix that queued for 2.6.24.  Peter?
