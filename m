From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsd write throughput
Date: Tue, 3 Aug 2004 15:26:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803132624.GI21365@suse.de>
References: <20040802162448.GB21365@suse.de> <20040803021018.GG5581@sgi.com> <20040803060213.GA21134@suse.de> <20040803075506.GL5581@sgi.com> <20040803103213.GE21365@suse.de> <20040803112445.GO5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BrzJD-0004tx-Jc
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 06:26:27 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BrzJC-0000Tj-Qu
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 06:26:27 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040803112445.GO5581@sgi.com>
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

On Tue, Aug 03, 2004 at 09:24:46PM +1000, Greg Banks wrote:
> With IRIX clients, which do far fewer COMMITs than (at least 2.4) Linux
> clients, I have seen COMMIT latencies in the order of multiple seconds
> as over a gigabyte of data is written to disk at 180 MB/s.

Yes - commit latencies varies a lot, depending on disk speed, client,
network bandwidth, and the number of clients.

> I imagine they will not be thrilled by the idea.

Probably not :-) And judging by the experiments I did with this, it's
not worth it - now we end up woth all nfsd's stuck in filemap_fdatawait.

> I still think the best approach is to get the page cache to start
> pushing unstable NFS pages to disk more aggresively, after the WRITE
> but before the COMMIT.  This should avoid long waits for disk IO
> with i_sem held; IIRC the page cache will only hold i_sem long enough
> to traverse page lists, allowing another WRITE call to get in soon.

Right.

I looked into how else I could do this, using the normal
background writeout as you suggested. I looked at the way
pdflush_operation(background_writeout) is doing it, but I'm wondering
if this is the right place for us. background_writeout loops over all
dirty inodes in all super blocks, only to call do_writepages in the end
pretty much the same way filemap_flush does - and in the end it
may send out the wrong pages.

So in order to implement what you suggest, we would need to change a lot
of code in page-writeback.c and fs-writeback.c - just for the benefit
of nfsd. Is this worth it?

On the other hand, fadvise and filemap_flush is a perfectly sane way
of telling the kernel to get rid of a specific range of pages we're no
longer interested in, without having to have pdflush do a linear crawl
over all dirty supers and inodes.

So I guess the question I'm asking is - what would be a reasonable
heuristic for nfsd_write that improves streaming writes without hurting
random ones, and that doesn't cause fragmentation etc?

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
