From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: Using mmap result in data corruption
Date: Tue, 08 Mar 2005 10:01:11 -0500
Message-ID: <1110294071.13843.11.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0503081417180.19681-100000@starpc8.phyast.dur.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8gDD-0002Jh-JT
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 07:01:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8gDB-0002FP-Qo
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 07:01:31 -0800
To: "Peter W. Draper" <p.w.draper@durham.ac.uk>
In-Reply-To: <Pine.LNX.4.44.0503081417180.19681-100000@starpc8.phyast.dur.ac.uk>
Sender: nfs-admin@lists.sourceforge.net
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

ty den 08.03.2005 Klokka 14:41 (+0000) skreiv Peter W. Draper:

> Following Trond's advice I've changed to using an msync() call before
> munmap() and that fixes the problem.  However, I'd really like to avoid
> the potential performance impact of using an msync(MS_SYNC) by using an
> msync(MS_ASYNC) call instead, as the files I access can be mmap'd many
> times, plus can be quite large, but, when I switch to msync(MS_ASYNC) the
> data corruption returns (I am only interested in the correctness of the
> data when my applications exit).
> 
> Surely that is incorrect behaviour? Otherwise what is the point of
> msync(MS_ASYNC)?

The Single UNIX Spec v3 says that

        MS_ASYNC Perform asynchronous writes.
        MS_SYNC  Perform synchronous writes.

        When MS_ASYNC is specified, msync() shall return immediately
        once all the write operations are initiated or queued for
        servicing; when MS_SYNC is specified, msync() shall not return
        until all write operations are completed as defined for
        synchronized I/O data integrity completion. Either MS_ASYNC or
        MS_SYNC is specified, but not both.

So on Linux, msync(MS_ASYNC) just marks the pages as dirty (see the
comment in mm/msync.c). It is then up to the application to call fsync()
if it wants to flush those asynchronous writes to disk at some specific
time.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
