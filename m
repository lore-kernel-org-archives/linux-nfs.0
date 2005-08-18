From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can anyone explain this state?
Date: Wed, 17 Aug 2005 20:18:36 -0400
Message-ID: <1124324316.8347.79.camel@lade.trondhjem.org>
References: <bc57270905081704131c4b23d4@mail.gmail.com>
	 <1124280174.23245.4.camel@lade.trondhjem.org> <43032CF2.3070908@redhat.com>
	 <1124282392.23245.26.camel@lade.trondhjem.org>
	 <20050817235136.GA12262@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>,
	Michael <mikore.li@gmail.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5qHk-0003Cv-DE
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 12:42:44 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5pTe-0006EY-GR
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 11:50:59 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1E5YAK-0000cw-DG
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 17:21:53 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20050817235136.GA12262@sgi.com>
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

to den 18.08.2005 Klokka 09:51 (+1000) skreiv Greg Banks:

> Trond, your comments also apply for READs with rsize<PAGE_SIZE; 2.4
> will do sync reads on the wire in this case.  The performance drop
> is not as dramatic as with writes because the server is doing its own
> local readahead, which can't happen for writes, but there's still
> a performance drop due to lack of parallelism on the wire.

Yes, however that only affects the first time the file is read.
The rather dramatic increase in performance between the first read and
subsequent attempts may almost certainly be attributed to caching, as
Peter pointed out.

Note: readahead too may cause an extra performance hit when the reads
are synchronous: if the kernel schedules more readahead than your
process actually wants to use, this may force your process to wait for
_all_ those reads to complete (since said process is responsible for
actually putting each synchronous read on the wire).
In the large rsize case, when doing asynchronous reads, this is not the
case. Your process will wait only on those pages it actually uses.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
