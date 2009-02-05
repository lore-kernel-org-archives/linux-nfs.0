Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50256 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760906AbZBEUYA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2009 15:24:00 -0500
Date: Thu, 5 Feb 2009 15:24:01 -0500
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 0/1] nfsd: Improve NFS server performance
Message-ID: <20090205202401.GH9200@fieldses.org>
References: <20081230104245.9409.30030.sendpatchset@localhost.localdomain> <20090204231958.GB20917@fieldses.org> <OF46E14C36.93250375-ON65257554.0050CEC8-65257554.005328DC@in.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF46E14C36.93250375-ON65257554.0050CEC8-65257554.005328DC@in.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 05, 2009 at 08:38:19PM +0530, Krishna Kumar2 wrote:
> Hi Bruce,
> 
> Thanks for your comments (also please refer to REV2 of patch as that is
> much simpler).

Yes, apologies, I only noticed I had a later vesion after responding to
the wrong one....

> > I think of open and lookup as fairly fast, so I'm surprised this
> > makes a great difference; do you have profile results or something
> > to confirm that this is in fact what made the difference?
> 
> Beyond saving the open/lookup times, the cache is updated only once.
> Hence no lock plus update is required for subsequent reads - the code
> does a single lock on every read operation instead of two. The time to
> get the cache is approximately the same for old vs new code; but in
> the new code we get file/dentry and svc_exp.
> 
> I used to have counters in nfsd_open - something like dbg_num_opens,
> dbg_open_jiffies, dgb_close_jiffies, dbg_read_jiffies,
> dgb_cache_jiffies, etc.  I can reintroduce those debugs and get a run
> and see how those numbers looks like, is that what you are looking
> for?

I'm not sure what you mean by dbg_open_jiffies--surely a single open of
a file already in the dentry cache is too fast to be measurable in
jiffies?

> > When do items get removed from this cache?
> 
> At the first open, the item is kept at the end of a global list (which is
> manipulated by the new daemon). After some jiffies are over, the daemon
> goes through the list till it comes to the first entry that has not
> expired; and frees up all the earlier entries. If the file is being used,
> it is not freed. If file is used after free, a new entry is added to the
> end of the list. So very minimal list manipulation is required - no sorting
> and moving entries in the list.

OK, yeah, I just wondered whether you could end up with a reference to a
file hanging around indefinitely even after it had been deleted, for
example.

I've heard of someone updating read-only block snapshots by stopping
mountd, flushing the export cache, unmounting the old snapshot, then
mounting the new one and restarting mountd.  A bit of a hack, but I
guess it works, as long as no clients hold locks or NFSv4 opens on the
filesystem.

An open cache may break that by holding references to the filesystem
they want to unmount.  But perhaps we should give such users a proper
interface that tells nfsd to temporarily drop state it holds on a
filesystem, and tell them to use that instead.

> Please let me know if you would like me to write up a small text about how
> this patch works.

Any explanation always welcome.

> > Could you provide details sufficient to reproduce this test if
> > necessary?  (At least: what was the test code, how many clients were
> > used, what was the client and server hardware, and what filesystem was
> > the server exporting?)
> 
> Sure - I will send the test code in a day (don't have access to the system
> right
> now, sorry. But this is a script that runs a C program that forks and then
> reads
> a file till it is killed and it prints the amount of data read and the
> amount of
> time it ran).
> 
> The other details are:
>       #Clients: 1
>       Hardware Configuration (both systems):
>             Two Dual-Core AMD Opteron (4 cpus) at 3GH.
>             1GB memory
>             10gbps private network
>       Filesystem: ext3 (one filesystem)

OK, thanks!  And what sort of disk on the server?

--b.
