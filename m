From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 12:32:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803103213.GE21365@suse.de>
References: <20040802162448.GB21365@suse.de> <20040803021018.GG5581@sgi.com> <20040803060213.GA21134@suse.de> <20040803075506.GL5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Brwdb-0005uW-Bh
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 03:35:19 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Brwda-0005nn-E9
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 03:35:19 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 07A2B9BA9B8
	for <nfs@lists.sourceforge.net>; Tue,  3 Aug 2004 12:32:15 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040803075506.GL5581@sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi folks,

I've been looking at the problem from a different angle...

Theory:
	The main bottleneck is that we spend a long time in commit(),
	blocking other WRITE calls from making any progress (thereby
	stalling all NFS clients). The reason is what we take inode->i_sem
	in nfsd_sync, but the writev() code wants to grab the same
	semaphore.

Circumstantial Evidence:

I've been doing some tests with the latencies of WRITE and COMMIT, using a
single stream write. The average time we spend in nfsd_write is miniscule,
usually it's less than 2 milliseconds. However when a commit comes in,
we take a hit there as well - something around 500 ms for reiser, and
400 ms for ext3. Syncing to reiser frequently takes up to 1.2 seconds,
while the 400 ms for ext3 is pretty constant.

Right now, nfsd_sync calls

	filemap_fdatawrite
	filp->f_op->fsync
	filemap_fdatawait

all under the i_sem. However, it seems we don't need the i_sem for
the filemap_* functions (is that valid - at least sync_page_range
doesn't?). So I changed the code to make it grab i_sem only for the fsync
call, but unfortunately, that doesn't seem to make much of a difference,
as I found out. Most of the time taken by a commit is spent in fsync
(the delta between the fsync latency and the overall commit latency is
usually less than 5 ms, i.e. ~1%).

I also changed nfsd_sync to call filemap_fdatawrite_range instead of
filemap_fdatawrite, but that doesn't make a noticeable difference either.

I then re-enabled my flushfast hack, and the commit latencies went
down to 30 ms on ext3, with the occasional spike of 300 ms. On reiser,
the commit latency went down to something like 50 ms on average.

(The reiserfs rewrite case was fairly bad, however. Rewrite over NFS
on top of reiser is fairly slow to begin with, much slower than write;
and the gain from the flushfast patch is minimal - but that's a different
story)


Conclusion:

So this at least supports my theory that the commits are throttling the
writes quite a bit. For the sake of completeness, I did some more iozone
measurements, and on write/rewrite the performance gain is about 50%
on both reiser and ext3, for a single client. I would think for several
clients writing concurrently, the gain should be even more pronounced,
but I haven't run these tests yet.

I'm wondering what could happen if we change nfsd_sync to not take the
i_sem at all... I'll talk to a few VFS folks around here and try to find out.


PS:

Another thing I noticed was that the commit calls sent by the Linux
client (2.6.5) are not evenly distributed over time. Much of the time,
the client will call COMMIT 4-6 times a second, and then all of a sudden
I see 30-80 calls a second several times in a row.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
